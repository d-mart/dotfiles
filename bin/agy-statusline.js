#!/usr/bin/env node
/**
 * Custom Antigravity CLI (agy) status line script.
 * Reads session telemetry JSON from stdin and renders a 2-line ANSI status bar.
 *
 * Usage in agy TUI:
 *   /statusline ~/.local/bin/agy-statusline.js
 *
 * Optional env vars:
 *   AGY_STATUSLINE_DUMP=/tmp/agy-statusline-payload.json  (dump raw stdin JSON to inspect fields)
 */

'use strict';

const fs = require('fs');
const os = require('os');
const path = require('path');

// ANSI helpers
const RESET = '\x1b[0m';
const BOLD = '\x1b[1m';
const DIM = '\x1b[2m';
const FG = {
  black: '\x1b[30m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  magenta: '\x1b[35m',
  cyan: '\x1b[36m',
  white: '\x1b[37m',
  gray: '\x1b[90m',
  brightGreen: '\x1b[92m',
  brightYellow: '\x1b[93m',
  brightBlue: '\x1b[94m',
  brightMagenta: '\x1b[95m',
  brightCyan: '\x1b[96m',
};

function c(color, text) {
  return `${color}${text}${RESET}`;
}

function stripAnsi(str) {
  return str.replace(/\x1b\[[0-9;]*m/g, '');
}

function formatTokens(n) {
  if (typeof n !== 'number' || Number.isNaN(n)) return null;
  if (n >= 1_000_000) return `${(n / 1_000_000).toFixed(1)}M`;
  if (n >= 1_000) return `${Math.round(n / 1_000)}k`;
  return String(n);
}

function formatDuration(ms) {
  if (typeof ms !== 'number' || Number.isNaN(ms) || ms <= 0) return 'now';
  const totalSec = Math.floor(ms / 1000);
  const days = Math.floor(totalSec / 86400);
  const hours = Math.floor((totalSec % 86400) / 3600);
  const mins = Math.floor((totalSec % 3600) / 60);
  if (days > 0) return `${days}d${hours}h`;
  if (hours > 0) return `${hours}h${String(mins).padStart(2, '0')}m`;
  if (mins > 0) return `${mins}m`;
  return `${totalSec}s`;
}

function parseResetTime(value) {
  if (value == null) return null;
  if (typeof value === 'number') {
    // Could be seconds or ms epoch, or seconds remaining
    if (value > 1e12) return formatDuration(value - Date.now());
    if (value > 1e9) return formatDuration(value * 1000 - Date.now());
    return formatDuration(value * 1000);
  }
  if (typeof value === 'string') {
    const parsed = Date.parse(value);
    if (!Number.isNaN(parsed)) {
      return formatDuration(parsed - Date.now());
    }
    return value;
  }
  return null;
}

function shortenPath(dirPath, maxLen = 38) {
  if (!dirPath) return '~';
  const home = os.homedir();
  let p = dirPath;
  if (home && p.startsWith(home)) {
    p = '~' + p.slice(home.length);
  }
  if (p.length <= maxLen) return p;

  const parts = p.split(path.sep).filter(Boolean);
  if (parts.length <= 2) return p;

  const prefix = p.startsWith('~') ? '~' : '';
  const tail = parts.slice(-2).join('/');
  const first = parts[0] === '~' ? '' : parts[0];
  const candidate = prefix ? `${prefix}/…/${tail}` : `${first}/…/${tail}`;
  return candidate.length <= maxLen ? candidate : `…/${tail}`;
}

function progressBar(pct, width = 10, invertColors = false) {
  const clamped = Math.max(0, Math.min(100, Number(pct) || 0));
  const filled = Math.round((clamped / 100) * width);
  const empty = width - filled;
  let barColor;
  if (invertColors) {
    barColor = clamped <= 20 ? FG.red : clamped <= 45 ? FG.brightYellow : FG.cyan;
  } else {
    barColor = clamped >= 80 ? FG.red : clamped >= 55 ? FG.brightYellow : FG.brightGreen;
  }

  return (
    c(FG.gray, '[') +
    c(barColor, '█'.repeat(filled)) +
    c(FG.gray, '░'.repeat(empty)) +
    c(FG.gray, ']')
  );
}

function getModeBadge(mode) {
  if (!mode || typeof mode !== 'string') return null;
  const m = mode.trim().toLowerCase();
  if (!m) return null;
  if (m === 'auto') return c(FG.brightGreen, '⇄ auto');
  if (m === 'accept-edits' || m === 'acceptedits') return c(FG.brightCyan, '✎ accept-edits');
  if (m === 'plan') return c(FG.brightMagenta, '☰ plan');
  return c(FG.gray, `• ${m}`);
}

function extractQuotaEntry(obj) {
  if (!obj || typeof obj !== 'object' || obj.disabled) return null;
  const remPct =
    typeof obj.remaining_fraction === 'number'
      ? obj.remaining_fraction * 100
      : obj.remaining_percentage ??
        obj.remaining_percent ??
        (typeof obj.used_percentage === 'number' ? 100 - obj.used_percentage : null);
  const resetStr = parseResetTime(
    obj.reset_in_seconds ??
      obj.reset_time ??
      obj.reset_at ??
      obj.resets_at ??
      obj.reset_in ??
      obj.resets_in_seconds
  );
  if (typeof remPct !== 'number' && !resetStr) return null;
  return { remPct, resetStr };
}

function formatQuotaSection(data, compact) {
  const raw = data.rate_limits || data.quota || data.usage || data.rate_limit || null;
  if (!raw || typeof raw !== 'object') return null;

  const entries = [];
  const direct = extractQuotaEntry(raw);
  if (direct) {
    entries.push({ label: '', ...direct });
  } else {
    const modelStr =
      (data.model && (data.model.id || data.model.display_name)) ||
      (typeof data.model === 'string' ? data.model : '');
    const isGemini = !modelStr || /^gemini/i.test(modelStr);
    const ignoreTokens = new Set(['gemini', 'low', 'medium', 'high', 'xhigh', 'max', 'pro', 'flash']);
    const modelTokens = modelStr
      .toLowerCase()
      .split(/[^a-z0-9]+/)
      .filter((t) => t.length >= 3 && !ignoreTokens.has(t));

    // Find any quota keys specific to the active model (e.g. gemini-argon-wtu-weekly)
    const modelSpecificKeys = Object.keys(raw).filter((k) => {
      const kl = k.toLowerCase();
      return modelTokens.some((tok) => kl.includes(tok));
    });

    const preferredKeys = isGemini
      ? ['gemini-5h', ...modelSpecificKeys, 'gemini-weekly', 'five_hour', 'seven_day', '5h', 'weekly']
      : ['3p-5h', ...modelSpecificKeys, '3p-weekly', 'five_hour', 'seven_day', '5h', 'weekly'];
    const windowLabels = {
      'gemini-5h': '5h',
      'gemini-weekly': '7d',
      'gemini-argon-wtu-weekly': 'argon-7d',
      '3p-5h': '5h',
      '3p-weekly': '7d',
      five_hour: '5h',
      seven_day: '7d',
      '5h': '5h',
      weekly: '7d',
    };

    const seen = new Set();
    for (const key of preferredKeys) {
      if (seen.has(key) || !raw[key]) continue;
      const parsed = extractQuotaEntry(raw[key]);
      if (parsed) {
        const label =
          windowLabels[key] ||
          key.replace(/^(gemini|3p)-/i, '').replace(/-weekly$/i, '-7d');
        entries.push({ label, ...parsed });
        seen.add(key);
      }
    }
    if (!entries.length) {
      for (const [key, val] of Object.entries(raw)) {
        if (seen.has(key)) continue;
        const parsed = extractQuotaEntry(val);
        if (parsed) {
          entries.push({ label: windowLabels[key] || key, ...parsed });
        }
      }
    }
  }

  if (!entries.length) return null;

  return entries
    .slice(0, 2)
    .map(({ label, remPct, resetStr }) => {
      const parts = [];
      if (typeof remPct === 'number') {
        const rounded = Math.round(remPct);
        const qColor = rounded <= 20 ? FG.red : rounded <= 45 ? FG.brightYellow : FG.cyan;
        const bar = compact ? '' : progressBar(rounded, 8, true) + ' ';
        const prefix = label ? `${label}: ` : '⚡';
        parts.push(`${bar}${c(qColor, `${prefix}${rounded}%`)}`);
      }
      if (resetStr) {
        parts.push(c(FG.gray, `↻ ${resetStr}`));
      }
      return parts.join(' ');
    })
    .filter(Boolean)
    .join(c(FG.gray, ' '));
}

function getStateBadge(state) {
  const s = (state || 'idle').toLowerCase();
  if (s === 'thinking') return c(FG.brightMagenta, '◐ thinking');
  if (s === 'working' || s === 'running') return c(FG.brightCyan, '⚡ working');
  if (s === 'tool_use' || s === 'tool') return c(FG.brightYellow, '⚙ tool');
  if (s === 'waiting') return c(FG.yellow, '◷ waiting');
  if (s === 'error') return c(FG.red, '✖ error');
  return c(FG.brightGreen, '● ready');
}

function getGsdHint(projectDir) {
  if (!projectDir) return null;
  try {
    const statePath = path.join(projectDir, '.planning', 'STATE.md');
    if (!fs.existsSync(statePath)) return null;
    const content = fs.readFileSync(statePath, 'utf8').slice(0, 1500);
    const phaseMatch = content.match(/Phase:\s*([^\n\r]+)/i);
    const statusMatch = content.match(/Status:\s*([^\n\r]+)/i);
    if (phaseMatch) {
      const phase = phaseMatch[1].trim().slice(0, 28);
      const status = statusMatch ? statusMatch[1].trim().slice(0, 16) : '';
      return status ? `${phase} (${status})` : phase;
    }
  } catch (_) {
    // Ignore read errors
  }
  return null;
}

function getGitBranchFallback(dir) {
  if (!dir) return null;
  try {
    let cur = dir;
    for (let i = 0; i < 6; i++) {
      const headFile = path.join(cur, '.git', 'HEAD');
      if (fs.existsSync(headFile)) {
        const head = fs.readFileSync(headFile, 'utf8').trim();
        if (head.startsWith('ref: refs/heads/')) {
          return head.slice('ref: refs/heads/'.length);
        }
        return head.slice(0, 7);
      }
      const parent = path.dirname(cur);
      if (parent === cur) break;
      cur = parent;
    }
  } catch (_) {
    // Ignore
  }
  return null;
}

function render(data) {
  const termWidth = Number(data.terminal_width) || process.stdout.columns || 120;
  const compact = termWidth < 90;

  // --- Line 1: State | Model | Context | Cost/Usage/Quota | Agents/Tasks ---
  const line1 = [];

  // 1. Agent state, mode & sandbox (if provided in payload)
  line1.push(getStateBadge(data.agent_state));
  const modeBadge = getModeBadge(data.cycle_mode || data.agent_mode || data.mode || data.agentMode);
  if (modeBadge) {
    line1.push(modeBadge);
  }
  if (data.sandbox && typeof data.sandbox.enabled === 'boolean') {
    line1.push(
      data.sandbox.enabled
        ? c(FG.green, '🔒 sandbox')
        : c(FG.yellow, '🔓 no-sandbox')
    );
  }

  // 2. Model & effort (skip effort suffix if already in display_name)
  const modelName =
    (data.model && (data.model.display_name || data.model.id)) ||
    (typeof data.model === 'string' ? data.model : null);
  if (modelName) {
    const rawEffort = data.model && data.model.effort ? String(data.model.effort) : '';
    const hasEffortInName =
      rawEffort && modelName.toLowerCase().includes(`(${rawEffort.toLowerCase()})`);
    const effort = rawEffort && !hasEffortInName ? ` (${rawEffort})` : '';
    line1.push(c(FG.brightBlue + BOLD, modelName) + c(FG.gray, effort));
  }

  // 3. Context window, >200k warning & prompt cache hit ratio
  const cw = data.context_window || {};
  if (typeof cw.used_percentage === 'number') {
    const pct = Math.round(cw.used_percentage);
    const bar = compact ? '' : progressBar(pct, 10) + ' ';
    const pctColor = pct >= 80 ? FG.red : pct >= 55 ? FG.brightYellow : FG.brightGreen;
    let tokInfo = '';
    const maxTok = cw.context_window_size || cw.total_tokens;
    if (maxTok && !compact) {
      const usedTok = Math.round((pct / 100) * maxTok);
      tokInfo = c(FG.gray, ` (${formatTokens(usedTok)}/${formatTokens(maxTok)})`);
    }
    const over200k = data.exceeds_200k_tokens ? ' ' + c(FG.yellow, '⚠ >200k') : '';
    let cacheInfo = '';
    const cu = cw.current_usage;
    if (cu && !compact) {
      const cacheRead = Number(cu.cache_read_input_tokens) || 0;
      const freshIn = Number(cu.input_tokens) || 0;
      const totalIn = cacheRead + freshIn;
      if (totalIn > 0) {
        const cachePct = Math.round((cacheRead / totalIn) * 100);
        const cacheColor = cachePct < 50 ? FG.yellow : FG.gray;
        cacheInfo = ' ' + c(cacheColor, `${cachePct}% cached`);
      }
    }
    line1.push(`${bar}${c(pctColor, `${pct}%`)}${tokInfo}${over200k}${cacheInfo}`);
  }

  // 4. Cost (if provided)
  const costVal =
    data.cost && (data.cost.estimated ?? data.cost.total_cost_usd ?? data.cost.session);
  if (typeof costVal === 'number') {
    line1.push(c(FG.yellow, `$${costVal.toFixed(costVal < 0.01 ? 4 : 2)}`));
  }

  // 5. Open tasks / active agents (from payload if provided)
  const agents = data.agents || data.subagents || data.active_agents;
  if (Array.isArray(agents) && agents.length > 0) {
    const active = agents.filter((a) => !a.status || a.status === 'running' || a.status === 'working').length;
    line1.push(c(FG.brightMagenta, `🤖 ${active}/${agents.length} agents`));
  } else if (typeof agents === 'number' && agents > 0) {
    line1.push(c(FG.brightMagenta, `🤖 ${agents} agent${agents > 1 ? 's' : ''}`));
  }

  const tasks = data.tasks || data.background_tasks || data.todos;
  if (Array.isArray(tasks) && tasks.length > 0) {
    const openCount = tasks.filter((t) => t.status !== 'completed' && t.status !== 'done').length;
    if (openCount > 0) {
      line1.push(c(FG.cyan, `☑ ${openCount} open`));
    }
  } else if (typeof tasks === 'number' && tasks > 0) {
    line1.push(c(FG.cyan, `☑ ${tasks} tasks`));
  }

  // --- Line 2: Working Dir | Git Branch | Project Phase | Time ---
  const line2 = [];

  const cwd = (data.workspace && (data.workspace.current_dir || data.workspace.project_dir)) || process.cwd();
  const projectDir = (data.workspace && data.workspace.project_dir) || cwd;

  line2.push(c(FG.blue, '📁 ' + shortenPath(cwd, compact ? 24 : 42)));

  const branch = (data.vcs && data.vcs.branch) || getGitBranchFallback(cwd);
  if (branch) {
    const dirty = data.vcs && data.vcs.dirty;
    const dirtyMark = dirty ? c(FG.brightYellow, ' ●') : c(FG.green, ' ✓');
    line2.push(c(FG.magenta, `⎇ ${branch}`) + dirtyMark);
  }

  const gsdHint = !compact ? getGsdHint(projectDir) : null;
  if (gsdHint) {
    line2.push(c(FG.cyan, `📋 ${gsdHint}`));
  }

  const quotaSection = formatQuotaSection(data, compact);
  if (quotaSection) {
    line2.push(quotaSection);
  }

  const now = new Date();
  const hhmm = `${String(now.getHours()).padStart(2, '0')}:${String(now.getMinutes()).padStart(2, '0')}`;
  line2.push(c(FG.gray, `🕒 ${hhmm}`));

  const sep = c(FG.gray, ' │ ');
  let out1 = line1.join(sep);
  let out2 = line2.join(sep);

  // Trim gracefully if still wider than terminal
  if (stripAnsi(out1).length > termWidth && compact) {
    out1 = line1.slice(0, 3).join(sep);
  }
  if (stripAnsi(out2).length > termWidth && compact) {
    out2 = line2.slice(0, 2).join(sep);
  }

  return `${out1}\n${out2}`;
}

function main() {
  let raw = '';
  process.stdin.setEncoding('utf8');
  process.stdin.on('data', (chunk) => {
    raw += chunk;
  });
  process.stdin.on('end', () => {
    let data = {};
    try {
      if (raw.trim()) data = JSON.parse(raw);
    } catch (_) {
      // Fallback to empty object
    }

    if (process.env.AGY_STATUSLINE_DUMP) {
      try {
        fs.writeFileSync(process.env.AGY_STATUSLINE_DUMP, JSON.stringify(data, null, 2));
      } catch (_) {}
    }

    process.stdout.write(render(data));
  });
}

main();

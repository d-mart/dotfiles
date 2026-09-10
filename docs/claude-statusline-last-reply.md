# Claude Code status line: "when did this session last reply?"

Adds a segment to the Claude Code status line showing **the wall-clock time of
the last assistant reply** and **how long the session has been idle since**:

```
mdl:Opus 5 (default) | Context: [████████░░░░░░░░] 103k/200k (52%) | ⎇ master | Session: 13m | ↩ 11:49am 20m
                                                                                                └─ this bit
```

It reads `↩ 11:49am now` while a turn is running, then ages into `↩ 11:49am
20m`, `↩ 9:03am 2h14m`, `↩ 12:19pm 6d23h`. The point is to glance at a tab you
switched away from and immediately know when it came back and how long it has
been sitting there — without doing clock math.

## Why not the built-in setting

Claude Code has a `showMessageTimestamps` setting that stamps every message
with its arrival time. As of 2.1.236 it does not work for most accounts,
because the renderer is gated on a server-side feature flag *in addition to*
the setting:

```js
let Y = mt(s => s.showMessageTimestamps) && nt("tengu_silk_hinge", !1)
```

The same flag wraps the `/config` menu item, so when the flag is off the toggle
does not even appear in the UI and setting the key by hand does nothing. Check
your own account:

```sh
python3 -c "import json,os;print(json.load(open(os.path.expanduser('~/.claude.json')))['cachedGrowthBookFeatures'].get('tengu_silk_hinge','<absent>'))"
```

If that ever prints `True`, `"showMessageTimestamps": true` in
`~/.claude/settings.json` starts working on its own and this widget becomes
redundant (harmless to keep either way).

A `Stop` hook is the other obvious approach, and it is a dead end: the only way
for a Stop hook to make Claude append text to a finished turn is
`{"decision": "block"}`, and Claude Code surfaces that block to the user as an
error-looking message on every single turn. There is no quiet variant.

## Prerequisites

| Need | Why | Check |
|---|---|---|
| Claude Code >= 2.1.97 | `statusLine.refreshInterval` support | `claude --version` |
| ccstatusline (recent v2.2.x) | provides the `custom-command` widget | already the status line on these boxes |
| `python3` on `$PATH` | the script is a python program in a bash wrapper | `python3 -V` |

## Step 1 — the script

Lives in this repo at `bin/claude-last-reply.sh`, and `deploy.sh` symlinks
`bin/` to `~/bin` — so **on any machine where you have run `deploy.sh`, this
step is already done** and the script is at `~/bin/claude-last-reply.sh`.

To recreate it from scratch:

```bash
cat > ~/bin/claude-last-reply.sh <<'SCRIPT'
#!/usr/bin/env bash
# ccstatusline "Custom Command" widget: shows when Claude last replied in this
# session, and how long it has been idle since.
#
# Answers "I switched away from this session -- when did it come back, and how
# long has it been sitting here?" Claude Code's own showMessageTimestamps
# setting is gated behind a server-side flag (tengu_silk_hinge), so the status
# line is the only place this can live today.
#
# Reads the Claude Code status JSON on stdin; prints one short segment.

exec python3 -c '
import json, sys, os
from datetime import datetime, timezone

TAIL_BYTES = 262144  # enough to cover a turn with heavy tool output


def last_assistant_time(path):
    size = os.path.getsize(path)
    with open(path, "rb") as fh:
        if size > TAIL_BYTES:
            fh.seek(size - TAIL_BYTES)
            fh.readline()  # discard the partial line we landed in
        lines = fh.read().splitlines()
    for raw in reversed(lines):
        try:
            entry = json.loads(raw)
        except ValueError:
            continue
        if entry.get("type") == "assistant" and entry.get("timestamp"):
            return datetime.fromisoformat(entry["timestamp"].replace("Z", "+00:00"))
    return None


def humanize(seconds):
    if seconds < 60:
        return "now"
    minutes = seconds // 60
    if minutes < 60:
        return "%dm" % minutes
    hours, minutes = divmod(minutes, 60)
    if hours < 24:
        return "%dh%02dm" % (hours, minutes)
    days, hours = divmod(hours, 24)
    return "%dd%dh" % (days, hours)


try:
    path = json.load(sys.stdin).get("transcript_path")
    when = last_assistant_time(path) if path and os.path.exists(path) else None
except Exception:
    when = None

if when is None:
    sys.exit(0)

local = when.astimezone()
age = int((datetime.now(timezone.utc) - when).total_seconds())
print("%s %s %s" % (chr(0x21A9), local.strftime("%-I:%M%p").lower(), humanize(max(age, 0))))
'
SCRIPT
chmod +x ~/bin/claude-last-reply.sh
```

Contract: reads Claude Code's status-line JSON on stdin, prints one short line
on stdout. Every failure path (no `transcript_path`, missing file, unparseable
JSON, no assistant message yet) prints nothing and exits 0, so ccstatusline
renders an empty segment rather than `[Error]` or `[Exit: 1]`.

It only reads the last 256KB of the transcript, so it stays fast (~30ms) no
matter how long the session has been running.

## Step 2 — register the ccstatusline widget

`~/.config/ccstatusline/` is **not** symlinked out of this repo, so this part is
per-machine.

### Option A — patch the JSON (idempotent, no TUI)

Inserts the widget immediately after the existing `session-clock` widget on
line 1. Safe to re-run; it will not double-insert.

```bash
cp ~/.config/ccstatusline/settings.json ~/.config/ccstatusline/settings.json.bak

python3 - <<'EOF'
import json, os, uuid

path = os.path.expanduser('~/.config/ccstatusline/settings.json')
data = json.load(open(path))
line = data['lines'][0]

if any(w.get('type') == 'custom-command'
       and 'claude-last-reply' in (w.get('commandPath') or '')
       for w in line):
    print('already present; nothing to do')
else:
    # anchor after session-clock if present, else at the end of line 1
    anchor = next((i for i, w in enumerate(line)
                   if w.get('type') == 'session-clock'), len(line) - 1)
    line[anchor + 1:anchor + 1] = [
        {'id': str(uuid.uuid4()), 'type': 'separator'},
        {'id': str(uuid.uuid4()), 'type': 'custom-command',
         'commandPath': '$HOME/bin/claude-last-reply.sh',
         'timeout': 2000, 'maxWidth': 22, 'color': 'brightCyan'},
    ]
    json.dump(data, open(path, 'w'), indent=2)
    print('inserted at index', anchor + 1)
EOF
```

The widget object it adds (`id` is generated per machine):

```json
{
  "type": "custom-command",
  "commandPath": "$HOME/bin/claude-last-reply.sh",
  "timeout": 2000,
  "maxWidth": 22,
  "color": "brightCyan"
}
```

`commandPath` is run through `/bin/sh -c`, which is why `$HOME` expands and the
path works regardless of where the dotfiles repo is checked out.

### Option B — the ccstatusline TUI

```sh
npx -y ccstatusline@latest
```

Edit a line, add a widget, search for **Custom Command**, then with it selected:
`e` for the command (`$HOME/bin/claude-last-reply.sh`), `t` for timeout
(`2000`), `w` for max width (`22`). Save on exit.

Leave `p` (preserve colors) **off** — the script emits plain text and lets
ccstatusline color it, so the normal widget color picker keeps working.

## Step 3 — make the idle counter tick

Without this the segment only re-renders when something happens in the session,
which freezes the age at whatever it said when the turn ended. The absolute
time stays correct regardless; only the `20m` part goes stale.

```bash
python3 - <<'EOF'
import json, os

path = os.path.expanduser('~/.claude/settings.json')
data = json.load(open(path))
data.setdefault('statusLine', {'type': 'command',
                               'command': 'npx -y ccstatusline@latest',
                               'padding': 0})
data['statusLine']['refreshInterval'] = 30
json.dump(data, open(path, 'w'), indent=2)
print(json.dumps(data['statusLine'], indent=2))
EOF
```

**Requires a Claude Code restart to take effect.** Steps 1 and 2 are live
immediately — ccstatusline is re-invoked from scratch on every render.

Cost: this re-runs the whole status line command every 30s per open session,
and `npx -y ccstatusline@latest` is ~0.5s of that. Fine for a handful of
sessions; raise the interval if you keep a lot of them open.

## Verify

```bash
# newest transcript for the current directory, fed through the real status line
PROJ="$HOME/.claude/projects/$(pwd | sed 's/[/.]/-/g')"
T=$(ls -t "$PROJ"/*.jsonl 2>/dev/null | head -1); echo "$T"

# 1. the script on its own
python3 -c "import json,sys;print(json.dumps({'transcript_path':sys.argv[1]}))" "$T" \
  | ~/bin/claude-last-reply.sh
# -> ↩ 2:39pm 12m

# 2. end to end, exactly what Claude Code renders
python3 -c "import json,sys;print(json.dumps({'transcript_path':sys.argv[1],'cwd':sys.argv[2],'model':{'id':'claude-opus-5','display_name':'Opus 5'}}))" "$T" "$(pwd)" \
  | npx -y ccstatusline@latest
```

## Troubleshooting

| Symptom | Cause |
|---|---|
| segment missing entirely | script printed nothing — no assistant reply in the transcript yet, or `transcript_path` absent/unreadable. Run verification step 1. |
| `[Cmd not found]` | `~/bin/claude-last-reply.sh` missing — `deploy.sh` not run on this machine. |
| `[Permission denied]` | missing execute bit: `chmod +x ~/bin/claude-last-reply.sh` |
| `[Timeout]` | `python3` cold-starting on a slow/networked FS. Raise `timeout` on the widget. |
| `[Exit: N]` | the script itself failed — should be impossible, everything is caught. Run verification step 1 for the real error. |
| time correct, age never changes | step 3 not applied, or Claude Code not restarted since. |
| hour renders `02:39pm` not `2:39pm` | `strftime("%-I")` is a glibc/BSD extension. Fine on macOS and glibc Linux; on musl (Alpine) use `%I`. |

## Files touched

| Path | Synced by this repo? |
|---|---|
| `bin/claude-last-reply.sh` → `~/bin/claude-last-reply.sh` | yes, via `deploy.sh` |
| `~/.config/ccstatusline/settings.json` | no — per-machine, step 2 |
| `~/.claude/settings.json` (`statusLine.refreshInterval`) | no — per-machine, step 3 |

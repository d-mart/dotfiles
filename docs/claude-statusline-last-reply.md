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
| ccstatusline (recent v2.2.x, config `version: 4`) | provides the `custom-command` widget | `npm i -g ccstatusline` (without it the wrapper falls back to `npx`, which works but is slower) |
| `jq` on `$PATH` | `bin/ccstatusline-fast` hides the transcript from ccstatusline with it | `jq --version` |
| `python3` on `$PATH` | the widget scripts and `deploy.sh`'s settings patch | `python3 -V` |

## Setup

Run `./deploy.sh`, then restart Claude Code. That covers all three pieces:

| Piece | Lives at | How it gets there |
|---|---|---|
| wrapper and widget scripts | `bin/ccstatusline-fast`, `bin/claude-*.py` → `~/bin/` | `bin/` symlinked by `deploy.sh` |
| ccstatusline layout, including the widgets | `.config/ccstatusline/settings.json` → `~/.config/ccstatusline/` | every dir in `.config/` symlinked by `deploy.sh` |
| `statusLine` (`$HOME/bin/ccstatusline-fast`) + `refreshInterval: 30` | `~/.claude/settings.json` | patched in place by `deploy.sh` |

`~/.claude/settings.json` is deliberately not symlinked: Claude Code rewrites it
and it holds per-machine plugins and permissions. `deploy.sh` adds a
`statusLine` block if there is none and a `refreshInterval` if it is unset,
moves the old default command (`npx -y ccstatusline@latest`) to the wrapper,
and leaves any other existing values alone.

The restart is for `refreshInterval`. Without it the segment only re-renders
when something happens in the session, which freezes the age at whatever it
said when the turn ended (the absolute time stays correct).

## Keeping it cheap: `ccstatusline-fast`

The status line command re-runs every 30s per open session, plus on every
update. Whenever the status JSON carries `transcript_path`, ccstatusline reads
and JSON-decodes the **whole** transcript on every run, whatever widgets are
configured. Long-lived sessions grow transcripts of hundreds of MB: on a 626MB
one each refresh cost ~14 CPU-seconds (~9s for the scan itself, ~5s more for
the speed widgets, which also read every subagent transcript). A handful of
such sessions kept several cores busy permanently.

`bin/ccstatusline-fast` renames `transcript_path` to `cc_transcript_path`
before ccstatusline sees it, which skips the scan (that refresh went to ~1s).
Every ccstatusline widget left in the layout reads Claude Code's status JSON
instead. The ones that needed the scan were replaced:

| Was | Now | Notes |
|---|---|---|
| `input-speed` | dropped | input t/s over a session is not a useful number |
| `output-speed` | `bin/claude-output-speed.py` | over the last 50 requests in the last 2MB of the transcript, timed like ccstatusline does (user/tool-result record → last streamed assistant record); recent, not session-average |
| `session-name` | `bin/claude-session-name.py` | `session_name` from the status JSON; falls back to the last `custom-title`/`ai-title` record in the last 1MB of the transcript |
| `tokens-cached` | `cache-hit-rate` (built in) | per-turn hit rate from the status JSON |
| `tokens-input`, `tokens-output` | dropped | the status JSON's `total_*_tokens` only cover the current turn, so no cheap session total exists; `session-cost` covers spend and `context-bar` covers size |

Custom-command widgets receive the same (renamed) JSON on stdin, so the
scripts read `cc_transcript_path`, falling back to `transcript_path`. Don't
add back a widget that needs the transcript scan without checking: it will
simply render nothing (or a current-turn number) under the wrapper.

### Machine that already has its own `~/.config/ccstatusline`

`deploy.sh` skips `.config` dirs that already exist as real directories, so
swap it for the symlink once (keeps a copy in case the local layout had
something worth merging into the repo's):

```sh
mv ~/.config/ccstatusline ~/.config/ccstatusline.local-bak
ln -s ~/p/dotfiles/.config/ccstatusline ~/.config/ccstatusline
```

## Changing the layout

```sh
ccstatusline
```

Because the whole directory is symlinked, the TUI saves straight into the repo
and the change shows up in `git status` like any other dotfile. The TUI won't
recognize `ccstatusline-fast` as its own status line command; don't use its
install option, which would put back a command that scans the transcript.

The custom-command widgets' settings, if you ever need to re-add them:
**Custom Command**, `e` command `$HOME/bin/claude-last-reply.py` (or
`claude-output-speed.py`, `claude-session-name.py`), `t` timeout `2000`, and
for the last-reply one `w` max width `22`. Leave `p` (preserve colors) **off**
— the scripts emit plain text and let ccstatusline color it.

`commandPath` is run through `/bin/sh -c`, which is why `$HOME` expands and the
path works regardless of where the dotfiles repo is checked out.

## The scripts' contract

Each reads Claude Code's status-line JSON on stdin (as passed on by
`ccstatusline-fast`, so the transcript is `cc_transcript_path`, with
`transcript_path` as a fallback) and prints one short line on stdout. Every
failure path (no transcript path, missing file, unparseable JSON, no assistant
message yet) prints nothing and exits 0, so ccstatusline renders an empty
segment rather than `[Error]` or `[Exit: 1]`.

They only read the tail of the transcript (256KB for last-reply, 1MB for the
session name fallback, 2MB for output speed), so they stay fast (~30-70ms) no
matter how long the session has been running.

## Verify

```bash
# newest transcript for the current directory, fed through the real status line
PROJ="$HOME/.claude/projects/$(pwd | sed 's/[/.]/-/g')"
T=$(ls -t "$PROJ"/*.jsonl 2>/dev/null | head -1); echo "$T"

# 1. the script on its own
python3 -c "import json,sys;print(json.dumps({'transcript_path':sys.argv[1]}))" "$T" \
  | ~/bin/claude-last-reply.py
# -> ↩ 2:39pm 12m

# 2. end to end, exactly what Claude Code renders
python3 -c "import json,sys;print(json.dumps({'transcript_path':sys.argv[1],'cwd':sys.argv[2],'model':{'id':'claude-opus-5','display_name':'Opus 5'}}))" "$T" "$(pwd)" \
  | ~/bin/ccstatusline-fast
# should take about a second however big $T is; tens of seconds means the
# transcript scan is back (jq missing, or the command isn't the wrapper)
```

## Troubleshooting

| Symptom | Cause |
|---|---|
| segment missing entirely | script printed nothing — no assistant reply in the transcript yet, or `transcript_path` absent/unreadable. Run verification step 1. |
| whole layout differs from the repo's | `~/.config/ccstatusline` is a real dir, not the symlink — see "Machine that already has its own". |
| `[Cmd not found]` | `~/bin/claude-last-reply.py` missing — `deploy.sh` not run on this machine. |
| `[Permission denied]` | missing execute bit: `chmod +x ~/bin/claude-last-reply.py` |
| `[Timeout]` | `python3` cold-starting on a slow/networked FS. Raise `timeout` on the widget. |
| `[Exit: N]` | the script itself failed — should be impossible, everything is caught. Run verification step 1 for the real error. |
| time correct, age never changes | `refreshInterval` unset, or Claude Code not restarted since. |
| high load, many `ccstatusline` processes at ~100% CPU | the status line is scanning whole transcripts: `statusLine.command` isn't `$HOME/bin/ccstatusline-fast`, or `jq` isn't on `$PATH`. |
| hour renders `02:39pm` not `2:39pm` | `strftime("%-I")` is a glibc/BSD extension. Fine on macOS and glibc Linux; on musl (Alpine) use `%I`. |

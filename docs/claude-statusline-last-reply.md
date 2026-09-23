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
| ccstatusline (recent v2.2.x, config `version: 4`) | provides the `custom-command` widget | run via `npx`, nothing to install |
| `python3` on `$PATH` | the widget script and `deploy.sh`'s settings patch | `python3 -V` |

## Setup

Run `./deploy.sh`, then restart Claude Code. That covers all three pieces:

| Piece | Lives at | How it gets there |
|---|---|---|
| widget script | `bin/claude-last-reply.py` → `~/bin/` | `bin/` symlinked by `deploy.sh` |
| ccstatusline layout, including the widget | `.config/ccstatusline/settings.json` → `~/.config/ccstatusline/` | every dir in `.config/` symlinked by `deploy.sh` |
| `statusLine` + `refreshInterval: 30` | `~/.claude/settings.json` | patched in place by `deploy.sh` |

`~/.claude/settings.json` is deliberately not symlinked: Claude Code rewrites it
and it holds per-machine plugins and permissions. `deploy.sh` only adds a
`statusLine` block if there is none and a `refreshInterval` if it is unset, and
leaves existing values alone.

The restart is for `refreshInterval`. Without it the segment only re-renders
when something happens in the session, which freezes the age at whatever it
said when the turn ended (the absolute time stays correct).

Cost: this re-runs the whole status line command every 30s per open session,
and `npx -y ccstatusline@latest` is ~0.5s of that. Fine for a handful of
sessions; raise the interval if you keep a lot of them open.

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
npx -y ccstatusline@latest
```

Because the whole directory is symlinked, the TUI saves straight into the repo
and the change shows up in `git status` like any other dotfile. The widget's
settings, if you ever need to re-add it: **Custom Command**, `e` command
`$HOME/bin/claude-last-reply.py`, `t` timeout `2000`, `w` max width `22`. Leave
`p` (preserve colors) **off** — the script emits plain text and lets
ccstatusline color it.

`commandPath` is run through `/bin/sh -c`, which is why `$HOME` expands and the
path works regardless of where the dotfiles repo is checked out.

## The script's contract

Reads Claude Code's status-line JSON on stdin, prints one short line on stdout.
Every failure path (no `transcript_path`, missing file, unparseable JSON, no
assistant message yet) prints nothing and exits 0, so ccstatusline renders an
empty segment rather than `[Error]` or `[Exit: 1]`.

It only reads the last 256KB of the transcript, so it stays fast (~30ms) no
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
  | npx -y ccstatusline@latest
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
| hour renders `02:39pm` not `2:39pm` | `strftime("%-I")` is a glibc/BSD extension. Fine on macOS and glibc Linux; on musl (Alpine) use `%I`. |

# dotfiles

Personal dotfiles for macOS, Arch Linux, and Ubuntu boxes. Everything is
symlinked from this checkout into `$HOME` (nothing is copied), so edits here
take effect everywhere immediately — the sole exception is
`~/.config/starship.toml`, which is generated per-machine; see below.

## Quick start

```
git clone <this repo> ~/dotfiles   # or ~/p/dotfiles, wherever — deploy.sh finds itself
~/dotfiles/deploy.sh
```

Safe to re-run — everything it does is idempotent (existing symlinks are
left alone, existing real files are backed up to `.bak` before being
replaced, stub/generated files are only created if missing).

On a fresh machine, run the platform provisioner first (installs packages,
sets OS defaults, etc.), then `deploy.sh`:

- **macOS** — `bin/mac-setup.sh` (installs Homebrew + `Brewfile`, sets macOS
  defaults, prompts for sudo up front so the rest can run unattended)
- **Arch Linux** — `bin/arch-setup.sh` (base-devel, paru/AUR helper, packages)
- **Ubuntu desktop** — `bin/ubuntu-desktop-settings.sh`

## Layout

| Path | What |
|---|---|
| `.zshrc`, `.bashrc`, `.bash_profile`, `.tmux.conf`, `.gitconfig`, ... | Top-level dotfiles, symlinked directly into `$HOME` by `deploy.sh`. |
| `.sh.d/` | Shell config sourced by `.zshrc`/`.bashrc` via `shell-init.sh`. `init.d/` holds numbered load-order scripts (`NNN_name.sh`; prefix with `_` to skip); `alias/` holds alias files split by scope (general, mac-only, zsh-only, and a local one — see below). |
| `bin/` | Standalone scripts symlinked onto `$PATH` as a directory: platform provisioners, one-off utilities (`mem-usage.sh`, `redshift.sh`, `woof.py`, ...), and `gen-starship-theme.sh`. |
| `.config/` | XDG app configs. `deploy.sh` symlinks each subdirectory here as a whole; `starship.toml.tmpl` is the one exception (see below). |
| `loadable_configs/` | App configs that aren't auto-deployed — Alfred workflow, Keyboard Maestro macros, a Firefox profile overlay, VSCodium settings. Import these into the relevant app by hand when setting it up. |
| `Brewfile` | macOS package list, installed by `mac-setup.sh` via `brew bundle`. |

## What `deploy.sh` does

1. Symlinks the top-level file/dir lists into `$HOME` (backing up any real
   file already there to `.bak`).
2. Creates `~/workspace`, `~/experiments`, `~/personal` and short symlinks to
   them (`~/w`, `~/x`, `~/p`).
3. Symlinks each `.config/` subdirectory into `~/.config/`.
4. Clones/pulls the external plugin repos it depends on (oh-my-zsh, bash-it,
   tmux plugins).
5. Drops a handful of machine-local stub files **only if they don't already
   exist** — `~/.tmux.conf.local`, `.sh.d/shell-init.local.sh`,
   `.sh.d/alias/aliases.local`, and (via `gen-starship-theme.sh`)
   `~/.config/starship.toml`.

### Local overrides

A few things are intentionally *not* symlinked, because they're meant to
differ per machine. `deploy.sh` seeds a stub for each on first run, then
leaves it alone:

- `~/.tmux.conf.local` — sourced by `.tmux.conf`; see
  `.tmux.conf.local.example` for the knobs (status bar colors, etc.).
- `.sh.d/shell-init.local.sh` — sourced early by `shell-init.sh`; put
  host-specific env vars/exports here.
- `.sh.d/alias/aliases.local` — machine-only aliases.
- `~/.config/starship.toml` — see below.

## Starship per-host theme

`.config/starship.toml.tmpl` is the tracked starship config. Its `[hostname]`
module has `__HOST_STYLE__` / `__HOST_EMOJI__` placeholders that
`bin/gen-starship-theme.sh` fills in deterministically from a stable
per-machine ID (hardware UUID on macOS, `/etc/machine-id` on Linux, hostname
as a last resort). Same machine → same color/emoji every time; different
machines land on different combinations, so an SSH session into another box
is visually obvious in the prompt instead of looking identical to your local
shell.

`deploy.sh` calls this automatically and writes a real file to
`~/.config/starship.toml` (not a symlink, since it's now machine-specific
content) the first time it doesn't find one already there.

### Regenerating

To pick up template changes, or to move a machine that's still on the old
plain-symlinked `starship.toml` (from before this existed) onto the
generated version:

```
~/dotfiles/bin/gen-starship-theme.sh --force
```

Without `--force` the script is a no-op once `~/.config/starship.toml` has
already been generated, so it's safe for `deploy.sh` to call unconditionally
on every deploy.

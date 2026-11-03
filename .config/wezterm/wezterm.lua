-- WezTerm config. Reloads automatically on save.
-- Docs: https://wezterm.org/config/files.html
-- Default key bindings: `wezterm show-keys`
--
-- Philosophy: tmux (prefix C-a) owns panes/windows/sessions, so WezTerm is
-- kept as a fast, good-looking terminal and avoids binding anything on C-a.

local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()

local is_mac = wezterm.target_triple:find('darwin') ~= nil

---------------------------------------------------------------------------
-- Appearance
---------------------------------------------------------------------------
-- Built-in scheme names: https://wezterm.org/colorschemes/index.html
config.color_scheme = 'Catppuccin Mocha'
-- Blacker than Mocha's #1e1e2e base: Catppuccin's darkest shade ("crust").
-- Use '#000000' for pure black.
config.colors = { background = '#11111b' }

-- JetBrains Mono ships inside WezTerm, so this works on every machine even
-- without the font installed. Nerd Font icons are also bundled as a fallback.
config.font = wezterm.font_with_fallback {
  'JetBrains Mono',
  'Fira Code',
}
config.font_size = is_mac and 14.0 or 12.0
-- Uncomment to disable ligatures (e.g. -> != ===):
-- config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }

config.window_padding = { left = 6, right = 6, top = 4, bottom = 2 }
config.initial_cols = 160
config.initial_rows = 45
config.adjust_window_size_when_changing_font_size = false

-- Tabs: tmux handles windows, so only show WezTerm's tab bar when needed.
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true

-- Dim panes that don't have focus (only matters for WezTerm-native splits).
config.inactive_pane_hsb = { saturation = 0.8, brightness = 0.7 }

config.default_cursor_style = 'SteadyBar'

-- Very light transparency (1.0 = opaque). Cells that set their own
-- background, like the tmux status bar, stay opaque via text_background_opacity.
config.window_background_opacity = 0.94
config.text_background_opacity = 1.0
-- macOS only (ignored elsewhere): blur what's behind the window.
config.macos_window_background_blur = 20

---------------------------------------------------------------------------
-- Behaviour
---------------------------------------------------------------------------
config.scrollback_lines = 20000
config.audible_bell = 'Disabled'
config.visual_bell = {
  fade_in_duration_ms = 75,
  fade_out_duration_ms = 75,
  target = 'CursorColor',
}
config.window_close_confirmation = 'NeverPrompt'
config.check_for_updates = false -- managed by apt / brew

---------------------------------------------------------------------------
-- Keys (defaults: CTRL+SHIFT+<key> on Linux, CMD+<key> on macOS)
--   CTRL+SHIFT+P      command palette (search every action)
--   CTRL+SHIFT+Space  quick-select: hint-label URLs/hashes/paths to copy
--   CTRL+SHIFT+X      copy mode (vim-style selection)
--   CTRL+SHIFT+F      search scrollback
--   CTRL+ +/-/0       font size
---------------------------------------------------------------------------
--   CTRL+SHIFT+R      reload config (also auto-reloads on save)
--   CTRL+SHIFT+L      debug overlay (Lua REPL + logs)
-- Add your own below, e.g. to free ALT+Enter (default: toggle fullscreen):
--   { key = 'Enter', mods = 'ALT', action = act.DisableDefaultAssignment },
---------------------------------------------------------------------------
config.keys = {
  -- Shift+Insert pastes the clipboard, like it does in GUI apps (WezTerm's
  -- default pastes the primary selection, which middle-click still does).
  -- Handy speech-to-text currently pastes with Ctrl+Shift+V (a WezTerm
  -- default); this lets its "Shift+Insert" method work here too if needed.
  { key = 'Insert', mods = 'SHIFT', action = act.PasteFrom 'Clipboard' },
}

---------------------------------------------------------------------------
-- Mouse: plain click only selects; CTRL+click (CMD on mac) opens links.
-- The default opens a link on any click, which is annoying when selecting.
---------------------------------------------------------------------------
local link_mod = is_mac and 'CMD' or 'CTRL'
config.mouse_bindings = {
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'NONE',
    action = act.CompleteSelection 'ClipboardAndPrimarySelection',
  },
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = link_mod,
    action = act.OpenLinkAtMouseCursor,
  },
  -- Swallow the press so CTRL+click doesn't also start a selection.
  {
    event = { Down = { streak = 1, button = 'Left' } },
    mods = link_mod,
    action = act.Nop,
  },
}

---------------------------------------------------------------------------
-- Per-machine overrides: create ~/.config/wezterm/local.lua (gitignored)
-- returning a function that receives and mutates `config`, e.g.
--   return function(config) config.font_size = 13 end
---------------------------------------------------------------------------
local ok, local_overrides = pcall(require, 'local')
if ok and type(local_overrides) == 'function' then
  local_overrides(config)
end

return config

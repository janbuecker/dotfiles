local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.default_prog = { wezterm.home_dir .. "/.nix-profile/bin/zsh" }
config.font = wezterm.font("JetBrains Mono")
config.font_size = 16.0
config.pane_focus_follows_mouse = true
config.window_decorations = "RESIZE"
config.hide_tab_bar_if_only_one_tab = true
config.inactive_pane_hsb = {
	brightness = 0.7,
}

-- use CTRL+^ in vim
config.use_dead_keys = false

-- keymaps
config.keys = {
	{ key = "d", mods = "CMD", action = wezterm.action.SplitHorizontal },
	{ key = "D", mods = "CMD", action = wezterm.action.SplitVertical },
	{ key = "b", mods = "CTRL", action = wezterm.action.RotatePanes("CounterClockwise") },
	{ key = "n", mods = "CTRL", action = wezterm.action.RotatePanes("Clockwise") },
}

config.mouse_bindings = {
	-- Change the default click behavior so that it only selects
	-- text and doesn't open hyperlinks
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "NONE",
		action = wezterm.action.CompleteSelection("ClipboardAndPrimarySelection"),
	},

	-- and make CTRL-Click open hyperlinks
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "CTRL",
		action = wezterm.action.OpenLinkAtMouseCursor,
	},
}

-- kanagawa
config.force_reverse_video_cursor = true
config.colors = {
	foreground = "#dcd7ba",
	background = "#1f1f28",

	cursor_bg = "#c8c093",
	cursor_fg = "#c8c093",
	cursor_border = "#c8c093",

	selection_fg = "#c8c093",
	selection_bg = "#2d4f67",

	scrollbar_thumb = "#16161d",
	split = "#16161d",

	ansi = { "#090618", "#c34043", "#76946a", "#c0a36e", "#7e9cd8", "#957fb8", "#6a9589", "#c8c093" },
	brights = { "#727169", "#e82424", "#98bb6c", "#e6c384", "#7fb4ca", "#938aa9", "#7aa89f", "#dcd7ba" },
	indexed = { [16] = "#ffa066", [17] = "#ff5d62" },
}

return config

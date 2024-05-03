local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.default_prog = { wezterm.home_dir .. "/.nix-profile/bin/zsh" }
config.font = wezterm.font("JetBrains Mono")
config.font_size = 16.0
config.pane_focus_follows_mouse = true
config.window_decorations = "RESIZE"
config.hide_tab_bar_if_only_one_tab = true
config.bold_brightens_ansi_colors = "BrightAndBold"
config.default_cursor_style = "BlinkingBar"
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"
config.front_end = "WebGpu"
config.webgpu_power_preference = "HighPerformance"
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

-- color scheme
config.color_scheme = "nightfox"
if wezterm.gui.get_appearance():find("Light") then
	config.color_scheme = "dayfox"
end

return config

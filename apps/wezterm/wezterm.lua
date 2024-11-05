local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.default_prog = { wezterm.home_dir .. "/.nix-profile/bin/zsh" }
config.font_size = 20
config.pane_focus_follows_mouse = true
config.window_decorations = "RESIZE"
config.hide_tab_bar_if_only_one_tab = true
config.bold_brightens_ansi_colors = "BrightAndBold"
config.default_cursor_style = "BlinkingBar"
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"
config.inactive_pane_hsb = {
	brightness = 0.7,
}

config.background = {
	{
		source = {
			File = wezterm.home_dir .. "/Pictures/kena.jpg",
		},
		hsb = { brightness = 0.05 },
	},
}

config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

-- use CTRL+^ in vim
config.use_dead_keys = false

-- keymaps
config.keys = {
	{ key = "d", mods = "CMD", action = wezterm.action.SplitHorizontal },
	{ key = "D", mods = "CMD", action = wezterm.action.SplitVertical },
	{ key = "Enter", mods = "ALT", action = wezterm.action.DisableDefaultAssignment },
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

-- font size based on display
local function adjustFontSize(window)
	if wezterm.gui.screens().active.name ~= "Built-in Retina Display" then
		window:set_config_overrides({})
		return
	end

	local overrides = { font_size = config.font_size }
	overrides.font_size = 16
	window:set_config_overrides(overrides)
end

wezterm.on("window-resized", function(window, _)
	adjustFontSize(window)
end)

wezterm.on("window-config-reloaded", function(window)
	adjustFontSize(window)
end)

require("bar").apply_to_config(config, {
	enabled_modules = {
		username = false,
		hostname = false,
		workspace = false,
		pane = true,
	},
})

return config

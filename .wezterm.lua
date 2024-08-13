local wezterm = require 'wezterm'

local config = wezterm.config_builder()

config.default_cursor_style = 'BlinkingUnderline'
config.use_fancy_tab_bar = false
config.font_size = 18.0
config.cursor_thickness = 3
config.window_background_opacity = 0.87

return config

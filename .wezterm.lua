local wezterm = require 'wezterm'

local config = wezterm.config_builder()

config.default_cursor_style = 'BlinkingUnderline'
config.use_fancy_tab_bar = false
config.font_size = 19.0
config.cursor_thickness = 4
config.window_background_opacity = 0.9

return config

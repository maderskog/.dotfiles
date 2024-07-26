local wezterm = require 'wezterm'

local config = wezterm.config_builder()

config.default_cursor_style = 'BlinkingBar'
config.use_fancy_tab_bar = false
config.font_size = 19.0
config.cursor_thickness = 4

return config

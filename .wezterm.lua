local wezterm = require 'wezterm'

local config = wezterm.config_builder()

config.default_cursor_style = 'BlinkingBlock'
config.use_fancy_tab_bar = false

return config

-- Autocmds are automatically loaded on the VeryLazy event
-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua

-- Transparent background (works with Ghostty's background-opacity)
local function force_transparency()
  local groups = {
    "Normal", "NormalNC", "NormalFloat", "SignColumn", "FoldColumn",
    -- Snacks explorer
    "SnacksExplorerNormal", "SnacksExplorerNormalNC", "SnacksExplorerWinBar",
    -- Status bar
    "StatusLine", "StatusLineNC",
    -- Sidebar / split backgrounds
    "WinSeparator",
  }
  for _, group in ipairs(groups) do
    vim.api.nvim_set_hl(0, group, { bg = "NONE", ctermbg = "NONE" })
  end

  for _, section in ipairs({ "a", "b", "c", "x", "y", "z" }) do
    for _, mode in ipairs({ "normal", "insert", "visual", "replace", "command", "inactive" }) do
      local hl = "lualine_" .. section .. "_" .. mode
      local ok, current = pcall(vim.api.nvim_get_hl_by_name, hl, true)
      if ok then
        current.background = nil
        pcall(vim.api.nvim_set_hl, 0, hl, current)
      end
    end
  end
end

vim.api.nvim_create_autocmd("ColorScheme", { pattern = "*", callback = force_transparency })
vim.defer_fn(force_transparency, 100)

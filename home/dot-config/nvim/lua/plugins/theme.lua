return {
  {
    "EdenEast/nightfox.nvim",
    lazy = false, -- FORCE load at startup
    priority = 1000, -- FORCE load before everything else
    config = function()
      require("nightfox").setup({
        options = {
          transparent = true, -- The 0.9 opacity fix
          styles = {
            sidebars = "transparent",
            floats = "transparent",
          },
        },
      })
      -- Apply the scheme immediately after setup
      vim.cmd("colorscheme carbonfox")
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      -- We explicitly tell LazyVim we are handling the colorscheme
      colorscheme = "carbonfox",
    },
  },
}


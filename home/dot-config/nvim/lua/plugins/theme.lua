return {
  -- Nightfox theme (carbonfox variant)
  {
    "EdenEast/nightfox.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      options = {
        transparent = true,
        styles = {
          comments = "italic",
          sidebars = "transparent",
          floats = "transparent",
        },
      },
    },
  },

  -- Tell LazyVim to use carbonfox
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "carbonfox",
    },
  },
}

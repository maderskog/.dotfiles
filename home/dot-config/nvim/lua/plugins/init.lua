return {
  { import = "nvchad.blink.lazyspec" },
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- UNCOMMENTED and ADDED elixir, python, go, etc.
  {
  	"nvim-treesitter/nvim-treesitter",
  	opts = {
  		ensure_installed = {
  			"vim", "lua", "vimdoc",
        "html", "css", "python", "go", "javascript", "typescript",
        "elixir", -- For .ex and .exs files
        "eex"     -- For Elixir templates (.heex, .eex)
  		},
  	},
  },
}


return {
  -- ── LazyVim language extras ──────────────────────────────────
  -- Each extra bundles: treesitter parsers, LSP, formatters, linters, DAP
  { import = "lazyvim.plugins.extras.lang.python" },
  { import = "lazyvim.plugins.extras.lang.go" },
  { import = "lazyvim.plugins.extras.lang.typescript" },
  { import = "lazyvim.plugins.extras.lang.json" },
  { import = "lazyvim.plugins.extras.lang.elixir" },
  { import = "lazyvim.plugins.extras.lang.svelte" },

  -- ── Extra treesitter parsers ─────────────────────────────────
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "bash",
        "css",
        "dockerfile",
        "eex",
        "elixir",
        "go",
        "heex",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "svelte",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "yaml",
      },
    },
  },

  -- ── Python: use ruff for linting/formatting ──────────────────
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ruff = {
          init_options = {
            settings = {
              args = { "--line-length=120" },
            },
          },
        },
      },
    },
  },

  -- ── ElixirLS (manual install at ~/.elixir-ls) ───────────────
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        elixirls = {
          cmd = { vim.fn.expand("~/.elixir-ls/release/language_server.sh") },
        },
      },
    },
  },

  -- ── Formatting ───────────────────────────────────────────────
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "ruff_format" },
        go = { "gofmt", "goimports" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        css = { "prettier" },
        html = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        svelte = { "prettier" },
      },
    },
  },
}

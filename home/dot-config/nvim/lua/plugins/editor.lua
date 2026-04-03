return {
  -- ── Mason: ensure key tools are installed ────────────────────
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "stylua",
        "shellcheck",
        "shfmt",
        "prettier",
      },
    },
  },
}

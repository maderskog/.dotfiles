local transparent = { bg = "NONE" }
local transparent_section = {
  a = transparent,
  b = transparent,
  c = transparent,
}

return {
  -- ── Lualine: transparent status bar ──────────────────────────
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.options = opts.options or {}
      opts.options.theme = {
        normal = transparent_section,
        insert = transparent_section,
        visual = transparent_section,
        replace = transparent_section,
        command = transparent_section,
        inactive = transparent_section,
      }
    end,
  },

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

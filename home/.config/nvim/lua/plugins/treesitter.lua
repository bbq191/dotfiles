return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter").setup({
        ensure_installed = {
          "python", "typescript", "tsx", "javascript",
          "html", "css", "json", "yaml", "toml",
          "lua", "vim", "vimdoc",
          "markdown", "markdown_inline",
          "bash", "dockerfile", "gitignore", "regex",
        },
        highlight = { enable = true },
        indent    = { enable = true },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection    = "<C-space>",
            node_incremental  = "<C-space>",
            node_decremental  = "<bs>",
          },
        },
      })
    end,
  },
  -- 彩虹括号
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = "BufReadPost",
    config = function()
      require("rainbow-delimiters.setup").setup({})
    end,
  },
}

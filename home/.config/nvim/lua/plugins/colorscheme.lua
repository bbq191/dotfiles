return {
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    opts = {
      style = "night",          -- #1a1b26 背景，与 kitty 一致
      transparent = true,       -- 透明背景，让 kitty blur 透过来
      terminal_colors = true,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
        sidebars = "transparent",
        floats = "transparent",
      },
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme("tokyonight")
    end,
  },
}

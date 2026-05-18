return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function() return vim.fn.executable("make") == 1 end,
      },
    },
    opts = {
      defaults = {
        prompt_prefix   = "  ",
        selection_caret = " ",
        border          = true,
        borderchars     = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
        -- 半透明背景与 kitty blur 协同
        winblend = 10,
        mappings = {
          i = {
            ["<C-k>"] = "move_selection_previous",
            ["<C-j>"] = "move_selection_next",
            ["<C-q>"] = "send_selected_to_qflist",
            ["<Esc>"] = "close",
          },
        },
      },
      pickers = {
        find_files   = { hidden = true },
        live_grep    = { additional_args = { "--hidden" } },
      },
    },
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      pcall(telescope.load_extension, "fzf")
    end,
  },
}

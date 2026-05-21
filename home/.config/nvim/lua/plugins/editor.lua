return {
  -- 自动补全括号，与 nvim-cmp 集成
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = { check_ts = true },
    config = function(_, opts)
      require("nvim-autopairs").setup(opts)
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },

  -- TSX 标签自动补全（React 开发必备）
  {
    "windwp/nvim-ts-autotag",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },

  -- 文件树
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    opts = {
      window = { width = 30 },
      filesystem = {
        filtered_items = {
          hide_dotfiles   = false,
          hide_gitignored = false,
        },
        follow_current_file = { enabled = true },
      },
      -- 屏蔽在 Neovim 0.13-dev 某些构建上无效的 BufModifiedSet 事件
      event_handlers = {
        { event = "vim_buffer_modified_set", handler = function() end },
      },
    },
  },

  -- 快捷键提示
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      spec = {
        { "<leader>b", group = "Buffer" },
        { "<leader>c", group = "Code" },
        { "<leader>d", group = "Diagnostic" },
        { "<leader>f", group = "Find/Format" },
        { "<leader>h", group = "Git hunk" },
        { "<leader>m", group = "Markdown" },
        { "<leader>t", group = "Terminal" },
        { "<leader>y", group = "Yazi" },
      },
    },
  },

  -- Yazi 文件管理器集成
  {
    "mikavilpas/yazi.nvim",
    event = "VeryLazy",
    keys = {
      { "<leader>yy", "<cmd>Yazi<CR>",     desc = "Open yazi (file)" },
      { "<leader>yw", "<cmd>Yazi cwd<CR>", desc = "Open yazi (workspace)" },
    },
    opts = {
      open_for_directories = false,
      keymaps = {
        show_help = "<F1>",
      },
    },
  },

  -- 终端 + LazyGit
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
      { "<leader>tt", "<cmd>ToggleTerm direction=float<CR>",      desc = "Float terminal" },
      { "<leader>th", "<cmd>ToggleTerm direction=horizontal<CR>", desc = "Horizontal terminal" },
      "<leader>tg",
    },
    opts = {
      shade_terminals = false,
      start_in_insert = true,
      float_opts = {
        border   = "curved",
        winblend = 10,   -- 与 kitty 透明度协调
      },
      on_open = function(term)
        vim.cmd("startinsert!")
        -- 确保 Esc Esc 在该 buffer 上可靠触发（比全局 map 优先级更高）
        vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { buffer = term.bufnr, noremap = true })
      end,
    },
    config = function(_, opts)
      require("toggleterm").setup(opts)
      local Terminal = require("toggleterm.terminal").Terminal
      local lazygit = Terminal:new({
        cmd = "lazygit",
        direction = "float",
        hidden = true,
      })
      vim.keymap.set("n", "<leader>tg", function() lazygit:toggle() end, { desc = "LazyGit" })
    end,
  },

  -- 包裹操作 ys / ds / cs
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    opts = {},
  },

  -- 多光标跳转（f/t 增强）
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "s",     function() require("flash").jump() end,       mode = { "n", "x", "o" }, desc = "Flash" },
      { "S",     function() require("flash").treesitter() end, mode = { "n", "o" },       desc = "Flash treesitter" },
    },
  },
}

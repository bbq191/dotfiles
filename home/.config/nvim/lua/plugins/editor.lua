return {
  -- 自动补全括号（函数补全后的括号由 blink.cmp 的 auto_brackets 负责）
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = { check_ts = true },
  },

  -- TSX 标签自动补全（React 开发必备）
  {
    "windwp/nvim-ts-autotag",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },

  -- 快捷键提示
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      spec = {
        { "<leader>b", group = "Buffer" },
        { "<leader>c", group = "Code" },
        { "<leader>f", group = "Find" },
        { "<leader>h", group = "Git hunk" },
        { "<leader>m", group = "Markdown" },
        { "<leader>r", group = "Replace" },
        { "<leader>t", group = "Terminal" },
      },
    },
  },

  -- Yazi 文件管理器集成
  {
    "mikavilpas/yazi.nvim",
    event = "VeryLazy",
    keys = {
      { "<leader>e", "<cmd>Yazi<CR>", desc = "Explorer (current file)" },
      { "<leader>E", "<cmd>Yazi cwd<CR>", desc = "Explorer (workspace)" },
    },
    opts = {
      open_for_directories = true, -- netrw 已禁用，nvim <dir> 直接进 yazi
      keymaps = {
        show_help = "<F1>",
      },
    },
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
      {
        "s",
        function()
          require("flash").jump()
        end,
        mode = { "n", "x", "o" },
        desc = "Flash",
      },
      {
        "S",
        function()
          require("flash").treesitter()
        end,
        mode = { "n", "o" },
        desc = "Flash treesitter",
      },
    },
  },

  -- 跨文件查找替换（预览 + 逐个确认；单文件的 <leader>rs 在 keymaps.lua）
  {
    "MagicDuck/grug-far.nvim",
    cmd = "GrugFar",
    keys = {
      {
        "<leader>rf",
        function()
          require("grug-far").open()
        end,
        desc = "Replace in files (project)",
      },
      {
        "<leader>rw",
        function()
          require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })
        end,
        desc = "Replace word (project)",
      },
      {
        "<leader>rw",
        function()
          require("grug-far").with_visual_selection()
        end,
        mode = "v",
        desc = "Replace selection (project)",
      },
    },
    opts = {},
  },
}

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
        { "<leader>e", desc = "Yazi (current file)" },
        { "<leader>d", group = "Diagnostic" },
        { "<leader>f", group = "Find" },
        { "<leader>h", group = "Git hunk" },
        { "<leader>m", group = "Markdown" },
        { "<leader>r", group = "Rename/Replace" },
        { "<leader>t", group = "Terminal/Toggle" },
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
      open_for_directories = true,   -- netrw 已禁用，nvim <dir> 直接进 yazi
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
      "<leader>tc",
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
        -- 确保 Alt-n 在该 buffer 上可靠触发（比全局 map 优先级更高）
        vim.keymap.set("t", "<A-n>", "<C-\\><C-n>", { buffer = term.bufnr, noremap = true })
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
      -- Claude Code：与 nvim 同一 cwd，收起后会话保活，下次弹出接着聊
      local claude = Terminal:new({
        cmd = "claude",
        direction = "vertical",
        size = function() return math.floor(vim.o.columns * 0.4) end,  -- 右侧 40% 宽
        hidden = true,
      })
      vim.keymap.set("n", "<leader>tc", function() claude:toggle() end, { desc = "Claude Code" })
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

  -- 跨文件查找替换（预览 + 逐个确认，弥补 <leader>s 只能单文件的短板）
  {
    "MagicDuck/grug-far.nvim",
    cmd = "GrugFar",
    keys = {
      { "<leader>rf", function() require("grug-far").open() end, desc = "Replace in files" },
      {
        "<leader>rw",
        function() require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } }) end,
        desc = "Replace word under cursor (project-wide)",
      },
      {
        "<leader>rw",
        function() require("grug-far").with_visual_selection() end,
        mode = "v",
        desc = "Replace selection (project-wide)",
      },
    },
    opts = {},
  },
}

return {
  -- mini.icons：唯一图标库；mock 掉 nvim-web-devicons 接口，lualine/bufferline 不再拉第二份图标插件
  {
    "echasnovski/mini.icons",
    version = false,
    lazy = false,
    config = function()
      require("mini.icons").setup()
      MiniIcons.mock_nvim_web_devicons()
    end,
  },

  -- snacks：模块集合，只开用得上的（其余默认关闭）
  --   image     内联图片（kitty graphics protocol；SVG/PDF 经 imagemagick 栅格化）
  --   notifier  通知浮窗（替代 nvim-notify）
  --   indent    缩进参考线 + 作用域（替代 indent-blankline）
  --   bufdelete 关 buffer 不破坏分屏布局
  --   bigfile   大文件自动降级（关 treesitter/LSP）
  --   quickfile 打开首个文件时先渲染再加载插件
  --   picker    只用其 ui_select：code action 等选择列表用浮窗（telescope 仍是主 picker）
  --   input     vim.ui.input 浮窗（rename 输入框）
  --   words     光标标识符的 LSP 引用高亮，]] / [[ 跳引用
  {
    "folke/snacks.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      image     = { enabled = true },
      notifier  = { enabled = true, timeout = 2500 },
      indent    = { enabled = true },
      bufdelete = { enabled = true },
      bigfile   = { enabled = true },
      quickfile = { enabled = true },
      picker    = { enabled = true, ui_select = true },   -- enabled 是 UIEnter 时 setup 的门控
      input     = { enabled = true },
      words     = { enabled = true },
    },
  },

  -- 状态栏
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        theme             = "auto",   -- 自动解析到 lua/lualine/themes/dms.lua（base46 动态主题）
        globalstatus      = true,
        component_separators = "|",
        section_separators  = { left = "", right = "" },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    },
  },

  -- Buffer 标签栏
  {
    "akinsho/bufferline.nvim",
    version = "*",
    event = "VeryLazy",
    opts = {
      options = {
        diagnostics = "nvim_lsp",
      },
    },
  },

  -- 颜色码内联预览（Tailwind 开发用得上）
  {
    "catgoose/nvim-colorizer.lua",   -- NvChad 仓库已归档，维护迁到 catgoose
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      user_default_options = {
        tailwind = true,
        css      = true,
      },
    },
  },
}

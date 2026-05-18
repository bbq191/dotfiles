return {
  -- mini.icons：which-key / bufferline 等插件优先用它，比 nvim-web-devicons 更轻
  { "echasnovski/mini.icons", version = false, opts = {} },

  -- 状态栏
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme             = "tokyonight",
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
    dependencies = "nvim-tree/nvim-web-devicons",
    opts = {
      options = {
        diagnostics = "nvim_lsp",
        offsets = {
          { filetype = "neo-tree", text = "File Explorer", highlight = "Directory", separator = true },
        },
      },
    },
  },

  -- 缩进参考线
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    main = "ibl",
    opts = {
      indent = { char = "│" },
      scope  = { enabled = true },
    },
  },

  -- 通知浮窗
  {
    "rcarriga/nvim-notify",
    opts = {
      timeout  = 2500,
      max_width = 50,
      render   = "compact",
      background_colour = "#1a1b26",   -- 与 Tokyo Night 背景一致
    },
    config = function(_, opts)
      require("notify").setup(opts)
      vim.notify = require("notify")
    end,
  },

  -- 颜色码内联预览（Tailwind 开发用得上）
  {
    "NvChad/nvim-colorizer.lua",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      user_default_options = {
        tailwind = true,
        css      = true,
      },
    },
  },
}

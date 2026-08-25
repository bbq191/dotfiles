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
      -- Normal 背景透明时 notify 需要实色兜底；动态取 base46 dms 主题的 base00，matugen 换主题后自动跟随
      background_colour = function()
        local ok, base46 = pcall(require, "base46")
        local theme = ok and base46.theme_tables and base46.theme_tables.dms
        return theme and theme.base_16 and theme.base_16.base00 or "#1a1c1f"
      end,
    },
    config = function(_, opts)
      require("notify").setup(opts)
      vim.notify = require("notify")
    end,
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

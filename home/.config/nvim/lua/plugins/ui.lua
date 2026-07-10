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
        theme             = "auto",   -- 自动跟随当前配色（dankcolors base16）
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
      -- Normal 背景透明时 notify 需要实色兜底；动态取当前 base16 的 base00，matugen 换主题后自动跟随
      background_colour = function()
        local ok, base16 = pcall(require, "base16-colorscheme")
        return ok and base16.colors and base16.colors.base00 or "#15130f"
      end,
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

return {
  -- Markdown 编辑器内渲染（纯 Lua，只依赖 treesitter 的 markdown parser）
  -- 普通模式下把标题/列表/代码块/表格渲染成美化样式，光标所在行自动还原源码
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.icons" },
    keys = {
      { "<leader>mr", "<cmd>RenderMarkdown toggle<CR>", desc = "Markdown render toggle" },
    },
    opts = {
      latex = { enabled = false },   -- 不装 latex parser，关掉以消除 checkhealth 警告
    },
  },

  -- 内联图片显示（kitty graphics protocol；SVG/PDF 经 imagemagick 栅格化）
  -- snacks 是模块集合，这里只启用 image，其余模块保持默认关闭
  {
    "folke/snacks.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      image = { enabled = true },
    },
  },
}

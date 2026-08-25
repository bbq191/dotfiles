return {
  -- Mason：LSP 二进制安装管理
  {
    "mason-org/mason.nvim",   -- 上游已从 williamboman 迁到 mason-org 组织
    build = ":MasonUpdate",
    opts = { ui = { border = "rounded" } },
  },

  -- mason-lspconfig：用 LSP server 名字管理安装
  -- automatic_enable = true（默认）：安装后自动调用 vim.lsp.enable()；v2 已移除 automatic_installation
  -- 服务端配置从 lsp/*.lua 文件读取（Neovim 0.11+ runtimepath 机制）
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason-org/mason.nvim" },
    opts = {
      ensure_installed = {
        "basedpyright",
        "ruff",
        "ts_ls",
        "tailwindcss",
        "jsonls",
        "html",
      },
    },
  },

  -- cmp-nvim-lsp 提前加载，在任何 buffer 打开前设置全局 capabilities
  -- 服务端启动时（BufReadPre）会读取这里的 capabilities，所以必须早于文件打开
  {
    "hrsh7th/cmp-nvim-lsp",
    lazy = false,
    config = function()
      -- 全局 capabilities：所有服务端都受益于 nvim-cmp 的补全协议扩展
      vim.lsp.config("*", {
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
      })

      -- 诊断显示样式
      vim.diagnostic.config({
        virtual_text  = { prefix = "●" },
        float         = { border = "rounded" },
        signs         = true,
        underline     = true,
        update_in_insert = false,
      })
    end,
  },
}

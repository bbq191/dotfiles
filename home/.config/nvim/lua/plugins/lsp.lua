return {
  -- Mason：LSP 二进制安装管理。按命令懒加载（常驻要加载整个 registry，约 20ms）；
  -- 其 bin 目录前置 PATH 与服务端启用改由 core/lsp.lua 在启动时直接做。
  {
    "mason-org/mason.nvim",   -- 上游已从 williamboman 迁到 mason-org 组织
    cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUpdate", "MasonLog" },
    build = ":MasonUpdate",
    opts = {},
  },

  -- mason-lspconfig：只保留 ensure_installed 的引导作用。
  -- 加载时机：手动 :Mason / :LspInstall，或 core/lsp.lua 发现有服务端二进制缺失时（新机器首次启动）。
  -- automatic_enable 关掉：vim.lsp.enable 由 core/lsp.lua 按 lsp/*.lua 文件名统一调用。
  {
    "mason-org/mason-lspconfig.nvim",
    cmd = { "Mason", "LspInstall", "LspUninstall" },
    dependencies = { "mason-org/mason.nvim" },
    opts = {
      automatic_enable = false,
      ensure_installed = {
        "basedpyright",
        "ruff",
        "ts_ls",
        "tailwindcss",
        "jsonls",
        "html",
        "lua_ls",
      },
    },
  },
}

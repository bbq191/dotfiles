return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = "ConformInfo",
    opts = {
      formatters_by_ft = {
        -- Python：ruff 一把梭（format + import sort）
        python = { "ruff_format", "ruff_organize_imports" },
        -- TypeScript / React
        typescript      = { "prettier" },
        typescriptreact = { "prettier" },
        javascript      = { "prettier" },
        javascriptreact = { "prettier" },
        -- 配置文件
        json    = { "prettier" },
        yaml    = { "prettier" },
        html    = { "prettier" },
        css     = { "prettier" },
        markdown = { "prettier" },
      },
      format_on_save = {
        timeout_ms = 3000,
        lsp_format = "fallback",   -- 旧写法 lsp_fallback 已废弃
      },
    },
  },
}

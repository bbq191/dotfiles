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
        -- dotfiles 自身：lua（本配置）/ fish / shell（stylua、shfmt 在 packages.txt）
        lua  = { "stylua" },
        fish = { "fish_indent" },
        sh   = { "shfmt" },
        bash = { "shfmt" },
      },
      -- markdown 不自动格式化：prettier 会改写列表符号和换行，笔记类文件只在 <leader>fm 手动触发
      format_on_save = function(bufnr)
        if vim.bo[bufnr].filetype == "markdown" then return nil end
        return { timeout_ms = 3000, lsp_format = "fallback" }
      end,
    },
  },
}

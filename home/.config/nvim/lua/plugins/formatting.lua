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
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        -- 配置文件
        json = { "prettier" },
        yaml = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        markdown = { "prettier" },
        -- dotfiles 自身：lua（本配置）/ fish / shell（stylua、shfmt 在 packages.txt）
        lua = { "stylua" },
        fish = { "fish_indent" },
        sh = { "shfmt" },
        bash = { "shfmt" },
      },
      -- 不自动保存时格式化：统一走 <leader>cf 手动触发（core/keymaps.lua）
    },
  },
}

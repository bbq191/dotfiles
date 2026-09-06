return {
  -- 代码片段引擎 + 内置 Python/TS/React 片段
  {
    "L3MON4D3/LuaSnip",
    lazy = true,   -- 只随 blink 在 InsertEnter 加载（常驻要 16ms）
    dependencies = { "rafamadriz/friendly-snippets" },
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },

  -- 补全：blink.cmp（Rust fuzzy，预编译二进制；Neovim 0.11+ 自动注册 LSP capabilities）
  {
    "saghen/blink.cmp",
    version = "1.*",
    event = "InsertEnter",
    dependencies = { "L3MON4D3/LuaSnip" },
    opts = {
      snippets = { preset = "luasnip" },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        providers = {
          buffer = { min_keyword_length = 3 },
        },
      },
      keymap = {
        preset = "default",
        ["<Tab>"]     = { "snippet_forward", "select_next", "fallback" },
        ["<S-Tab>"]   = { "snippet_backward", "select_prev", "fallback" },
        ["<CR>"]      = { "accept", "fallback" },
        ["<C-j>"]     = { "select_next", "fallback" },
        ["<C-k>"]     = { "select_prev", "fallback" },
        ["<C-b>"]     = { "scroll_documentation_up", "fallback" },
        ["<C-f>"]     = { "scroll_documentation_down", "fallback" },
        ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"]     = { "hide", "fallback" },
      },
      completion = {
        list = { selection = { preselect = false, auto_insert = false } },  -- 与原 noselect 行为一致，<CR> 只在选中项时接受
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
        menu = {
          draw = {
            columns = { { "kind_icon" }, { "label", "label_description", gap = 1 }, { "source_name" } },
          },
        },
      },
      signature = { enabled = true },   -- 输入参数时显示函数签名
      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
  },
}

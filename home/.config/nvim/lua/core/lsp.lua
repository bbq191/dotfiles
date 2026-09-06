-- 诊断显示样式（浮窗边框由 options.lua 的全局 winborder 统一）
vim.diagnostic.config({
  virtual_text = { prefix = "●" },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

-- Mason 的 bin 目录前置 PATH：mason.nvim 已改为按命令懒加载，这一步由这里代劳
local mason_bin = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "bin")
if vim.uv.fs_stat(mason_bin) then
  vim.env.PATH = mason_bin .. ":" .. vim.env.PATH
end

-- 启用 lsp/*.lua 里定义的全部服务端（文件名即服务端名，Neovim 0.11+ runtimepath 机制）
local servers = {}
for _, path in ipairs(vim.fn.glob(vim.fs.joinpath(vim.fn.stdpath("config"), "lsp", "*.lua"), true, true)) do
  table.insert(servers, vim.fn.fnamemodify(path, ":t:r"))
end
vim.lsp.enable(servers)

-- 新机器引导：有服务端二进制缺失时，UI 起来后加载 mason-lspconfig 触发 ensure_installed
local missing = vim.tbl_filter(function(name)
  local cmd = vim.lsp.config[name] and vim.lsp.config[name].cmd
  return type(cmd) == "table" and vim.fn.executable(cmd[1]) == 0
end, servers)
if #missing > 0 then
  vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    once = true,
    callback = function()
      vim.notify("LSP 二进制缺失: " .. table.concat(missing, ", ") .. "，正在通过 Mason 安装", vim.log.levels.WARN)
      require("lazy").load({ plugins = { "mason-lspconfig.nvim" } })
    end,
  })
end

-- LSP 快捷键只在服务端附着的 buffer 上生效，纯文本 buffer 按 K/gd 不会报错
-- Neovim 0.11+ 已内置: grr=references, gra=code_action, grn=rename, gri=implementation
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("core_lsp_attach", { clear = true }),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = desc })
    end

    map("n", "K", vim.lsp.buf.hover, "Hover")
    map("n", "gd", vim.lsp.buf.definition, "Go to definition")
    map("n", "gD", vim.lsp.buf.type_definition, "Type definition")
    map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
    map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
    -- snacks.words：在光标标识符的引用间跳转
    map("n", "]]", function() Snacks.words.jump(vim.v.count1) end, "Next reference")
    map("n", "[[", function() Snacks.words.jump(-vim.v.count1) end, "Prev reference")

    if client and client:supports_method("textDocument/inlayHint") then
      map("n", "<leader>ci", function()
        local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf })
        vim.lsp.inlay_hint.enable(not enabled, { bufnr = ev.buf })
      end, "Toggle inlay hints")
    end
  end,
})

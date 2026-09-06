vim.g.mapleader = " "
vim.g.maplocalleader = " "

local map = vim.keymap.set

-- 窗口跳转
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")
-- 终端模式直接跳窗（Claude/lazygit 竖分屏时不必先 Esc Esc）；用 Alt 避免抢 fish/claude 的 Ctrl 组合键
map("t", "<A-h>", "<C-\\><C-n><C-w>h", { desc = "Window left" })
map("t", "<A-j>", "<C-\\><C-n><C-w>j", { desc = "Window down" })
map("t", "<A-k>", "<C-\\><C-n><C-w>k", { desc = "Window up" })
map("t", "<A-l>", "<C-\\><C-n><C-w>l", { desc = "Window right" })

-- 窗口大小
map("n", "<C-Up>",    "<cmd>resize -2<CR>")
map("n", "<C-Down>",  "<cmd>resize +2<CR>")
map("n", "<C-Left>",  "<cmd>vertical resize -2<CR>")
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>")

-- 缩进保持选中
map("v", "<", "<gv")
map("v", ">", ">gv")

-- 移动选中行（Alt，把 J 合并行留给默认行为）
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move lines down" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move lines up" })

-- 黏贴不覆盖寄存器
map("x", "<leader>p", [["_dP]], { desc = "Paste without yank" })

-- 清除搜索高亮
map("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- 光标词全局替换：全部直接替换 / 逐个确认（inccommand=split 实时预览）
map("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Replace word under cursor" })
map("n", "<leader>S", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gcI<Left><Left><Left><Left>]], { desc = "Replace word under cursor (confirm each)" })

-- Buffer（按 bufferline 的显示顺序切换；关闭时保留分屏布局）
map("n", "<S-h>", "<cmd>BufferLineCyclePrev<CR>")
map("n", "<S-l>", "<cmd>BufferLineCycleNext<CR>")
map("n", "<leader>bd", function() Snacks.bufdelete() end, { desc = "Delete buffer" })
map("n", "<leader>bo", function() Snacks.bufdelete.other() end, { desc = "Close others" })

-- 保存 / 退出
map("n", "<leader>w", "<cmd>w<CR>",  { desc = "Save" })
map("n", "<leader>q", "<cmd>q<CR>",  { desc = "Quit" })
map("n", "<leader>Q", "<cmd>qa<CR>",  { desc = "Quit all" })   -- confirm=true 会对未保存改动弹确认

-- 文件浏览器（yazi）
map("n", "<leader>e", "<cmd>Yazi<CR>", { desc = "Yazi (current file)" })

-- Telescope
map("n", "<leader>ff", "<cmd>Telescope find_files<CR>",  { desc = "Find files" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>",   { desc = "Live grep" })
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>",     { desc = "Buffers" })
map("n", "<leader>fr", "<cmd>Telescope oldfiles<CR>",    { desc = "Recent files" })
map("n", "<leader>fs", "<cmd>Telescope lsp_document_symbols<CR>", { desc = "Symbols" })
map("n", "<leader>fd", "<cmd>Telescope diagnostics<CR>", { desc = "Diagnostics" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>",   { desc = "Help" })
map("n", "<leader>fk", "<cmd>Telescope keymaps<CR>",     { desc = "Keymaps" })
map("n", "<leader>f/", "<cmd>Telescope current_buffer_fuzzy_find<CR>", { desc = "Search in buffer" })
map("n", "<leader>f.", "<cmd>Telescope resume<CR>",      { desc = "Resume last picker" })

-- 诊断（LSP 相关按键在 core/lsp.lua 的 LspAttach 里按 buffer 绑定）
map("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, { desc = "Prev diagnostic" })
map("n", "]d", function() vim.diagnostic.jump({ count =  1 }) end, { desc = "Next diagnostic" })
map("n", "<leader>de", vim.diagnostic.open_float, { desc = "Diagnostic float" })

-- 格式化（Code 组，与 ca/ci 同族）
map({ "n", "v" }, "<leader>cf", function()
  require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format" })

-- 自动换行（类似 VS Code Alt+Z）
map("n", "<A-z>", function()
  vim.wo.wrap = not vim.wo.wrap
  vim.wo.linebreak = vim.wo.wrap
  vim.notify("Wrap: " .. (vim.wo.wrap and "on" or "off"))
end, { desc = "Toggle wrap" })

-- 终端：Alt-n 退到 normal（不用 Esc 开头，避免 TUI 里每个 Esc 等 timeoutlen）
map("t", "<A-n>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Markdown → PDF（pandoc + xelatex，reMarkable 纸感配置）
map("n", "<leader>mp", function()
  if vim.bo.filetype ~= "markdown" then
    vim.notify("Not a markdown file", vim.log.levels.WARN)
    return
  end
  vim.cmd("silent write")  -- 先存盘，导出的是最新内容
  local src = vim.fn.expand("%:p")
  local out = vim.fn.expand("%:p:r") .. ".pdf"
  local defaults = vim.fn.expand("~/.config/pandoc/remarkable.yaml")
  local err = {}
  vim.notify("Exporting: " .. out, vim.log.levels.INFO)
  vim.fn.jobstart({ "pandoc", src, "-o", out, "-d", defaults }, {
    stderr_buffered = true,
    on_stderr = function(_, data) if data then vim.list_extend(err, data) end end,
    on_exit = function(_, code)
      vim.schedule(function()
        if code == 0 then
          vim.notify("PDF exported: " .. out, vim.log.levels.INFO)
        else
          vim.notify("Export failed (exit " .. code .. ")\n" .. table.concat(err, "\n"),
            vim.log.levels.ERROR)
        end
      end)
    end,
  })
end, { desc = "Export MD to PDF (reMarkable)" })

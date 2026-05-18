vim.g.mapleader = " "
vim.g.maplocalleader = " "

local map = vim.keymap.set

-- 窗口跳转
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- 窗口大小
map("n", "<C-Up>",    "<cmd>resize -2<CR>")
map("n", "<C-Down>",  "<cmd>resize +2<CR>")
map("n", "<C-Left>",  "<cmd>vertical resize -2<CR>")
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>")

-- 缩进保持选中
map("v", "<", "<gv")
map("v", ">", ">gv")

-- 移动选中行
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")

-- 黏贴不覆盖寄存器
map("x", "<leader>p", [["_dP]], { desc = "Paste without yank" })

-- 清除高亮
map("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Buffer
map("n", "<S-h>", "<cmd>bprevious<CR>")
map("n", "<S-l>", "<cmd>bnext<CR>")
map("n", "<leader>bd", "<cmd>bdelete<CR>",    { desc = "Delete buffer" })
map("n", "<leader>bo", "<cmd>%bdelete|edit#|bdelete#<CR>", { desc = "Close others" })

-- 保存 / 退出
map("n", "<leader>w", "<cmd>w<CR>",  { desc = "Save" })
map("n", "<leader>q", "<cmd>q<CR>",  { desc = "Quit" })
map("n", "<leader>Q", "<cmd>qa!<CR>", { desc = "Quit all" })

-- 文件浏览器
map("n", "<leader>e", "<cmd>Neotree toggle<CR>", { desc = "File Explorer" })

-- Telescope
map("n", "<leader>ff", "<cmd>Telescope find_files<CR>",  { desc = "Find files" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>",   { desc = "Live grep" })
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>",     { desc = "Buffers" })
map("n", "<leader>fr", "<cmd>Telescope oldfiles<CR>",    { desc = "Recent files" })
map("n", "<leader>fs", "<cmd>Telescope lsp_document_symbols<CR>", { desc = "Symbols" })
map("n", "<leader>fd", "<cmd>Telescope diagnostics<CR>", { desc = "Diagnostics" })

-- LSP
-- Neovim 0.11+ 已内置: grr=references, gra=code_action, grn=rename, gri=implementation
-- 保留 <leader> 别名方便 which-key 提示，删除与内置 gr* 冲突的裸 gr 绑定
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
map("n", "<leader>rn", vim.lsp.buf.rename,      { desc = "Rename" })
map("n", "K",  vim.lsp.buf.hover)
map("n", "gd", vim.lsp.buf.definition,     { desc = "Go to definition" })
map("n", "gD", vim.lsp.buf.type_definition, { desc = "Type definition" })
map("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, { desc = "Prev diagnostic" })
map("n", "]d", function() vim.diagnostic.jump({ count =  1 }) end, { desc = "Next diagnostic" })
map("n", "<leader>de", vim.diagnostic.open_float, { desc = "Diagnostic float" })

-- 格式化
map({ "n", "v" }, "<leader>fm", function()
  require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Format" })

-- 终端
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Markdown → PDF（pandoc + xelatex）
map("n", "<leader>mp", function()
  if vim.bo.filetype ~= "markdown" then
    vim.notify("Not a markdown file", vim.log.levels.WARN)
    return
  end
  local src = vim.fn.expand("%:p")
  local out = vim.fn.expand("%:p:r") .. ".pdf"
  vim.notify("Exporting: " .. out, vim.log.levels.INFO)
  vim.fn.jobstart({
    "pandoc", src, "-o", out,
    "--pdf-engine=xelatex",
    "-V", "CJKmainfont=Noto Serif CJK SC",
    "-V", "CJKsansfont=Noto Sans CJK SC",
    "-V", "CJKmonofont=Noto Sans Mono CJK SC",
    "-V", "geometry:margin=2.5cm",
    "-V", "fontsize=12pt",
  }, {
    on_exit = function(_, code)
      if code == 0 then
        vim.schedule(function()
          vim.notify("PDF exported: " .. out, vim.log.levels.INFO)
        end)
      else
        vim.schedule(function()
          vim.notify("Export failed (exit " .. code .. ")", vim.log.levels.ERROR)
        end)
      end
    end,
  })
end, { desc = "Export MD to PDF" })

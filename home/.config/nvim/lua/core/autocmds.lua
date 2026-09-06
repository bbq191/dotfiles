local aug = function(name) return vim.api.nvim_create_augroup("core_" .. name, { clear = true }) end
local autocmd = vim.api.nvim_create_autocmd

-- 复制时高亮闪一下
autocmd("TextYankPost", {
  group = aug("yank"),
  callback = function() vim.hl.on_yank({ timeout = 150 }) end,
})

-- 重开文件回到上次光标位置（提交信息除外）
autocmd("BufReadPost", {
  group = aug("last_pos"),
  callback = function(ev)
    if vim.bo[ev.buf].filetype == "gitcommit" then return end
    local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
    local lines = vim.api.nvim_buf_line_count(ev.buf)
    if mark[1] > 0 and mark[1] <= lines then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- 终端窗口大小变化时重新均分分屏
autocmd("VimResized", {
  group = aug("resize"),
  command = "tabdo wincmd =",
})

-- 帮助/quickfix 之类的临时窗口：q 关闭，不进 buffer 列表
autocmd("FileType", {
  group = aug("close_with_q"),
  pattern = { "help", "qf", "man", "checkhealth", "lspinfo" },
  callback = function(ev)
    vim.bo[ev.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = ev.buf, silent = true, desc = "Close" })
  end,
})

-- 散文类文件：软换行 + 拼写检查（cjk 让中文不被标红）
autocmd("FileType", {
  group = aug("prose"),
  pattern = { "markdown", "gitcommit", "text" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.spell = true
    vim.opt_local.spelllang = { "en", "cjk" }
  end,
})

-- 保存到不存在的目录时自动创建父目录
autocmd("BufWritePre", {
  group = aug("mkdir"),
  callback = function(ev)
    if ev.match:match("^%w+://") then return end
    local dir = vim.fn.fnamemodify(ev.match, ":p:h")
    if vim.fn.isdirectory(dir) == 0 then vim.fn.mkdir(dir, "p") end
  end,
})

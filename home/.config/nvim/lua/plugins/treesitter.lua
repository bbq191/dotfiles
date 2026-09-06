return {
  {
    -- main 分支（2025 重写）：不再有 ensure_installed / highlight / indent / incremental_selection 选项，
    -- 只负责装 parser；高亮/缩进靠 Neovim 内置 vim.treesitter 在 FileType 时手动启用。
    -- 需要 tree-sitter CLI + C 编译器编译 parser（packages.txt 已含 tree-sitter、base-devel）。
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local ts = require("nvim-treesitter")
      ts.setup({})

      local langs = {
        "python", "typescript", "tsx", "javascript",
        "html", "css", "json", "yaml", "toml",
        "lua", "vim", "vimdoc",
        "markdown", "markdown_inline",
        "bash", "dockerfile", "gitignore", "regex",
        -- dotfiles 里实际编辑的：niri(kdl) / fish / DMS 插件(qml) / 各类 .conf / git 相关
        "kdl", "fish", "qmljs", "qmldir", "ini",
        "diff", "git_config", "gitcommit", "git_rebase", "ssh_config",
      }
      -- 缺的 parser 异步安装；已装的跳过
      local installed = {}
      for _, l in ipairs(ts.get_installed("parsers")) do installed[l] = true end
      local missing = vim.tbl_filter(function(l) return not installed[l] end, langs)
      if #missing > 0 then ts.install(missing) end

      -- 按 buffer 启用高亮 + treesitter 缩进（parser 不存在时静默跳过）
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("ts_enable", { clear = true }),
        callback = function(ev)
          local lang = vim.treesitter.language.get_lang(ev.match)
          if not lang then return end
          if pcall(vim.treesitter.start, ev.buf, lang) then
            vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },

  -- 语法文本对象：af/if 函数、ac/ic 类、aa/ia 参数；]f/[f 跳函数
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    init = function() vim.g.no_plugin_maps = true end,
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = { lookahead = true },
        move = { set_jumps = true },
      })
      local select = require("nvim-treesitter-textobjects.select")
      local move = require("nvim-treesitter-textobjects.move")
      local function sel(lhs, query, desc)
        vim.keymap.set({ "x", "o" }, lhs, function() select.select_textobject(query, "textobjects") end, { desc = desc })
      end
      sel("af", "@function.outer",  "Around function")
      sel("if", "@function.inner",  "Inside function")
      sel("ac", "@class.outer",     "Around class")
      sel("ic", "@class.inner",     "Inside class")
      sel("aa", "@parameter.outer", "Around argument")
      sel("ia", "@parameter.inner", "Inside argument")
      vim.keymap.set({ "n", "x", "o" }, "]f", function() move.goto_next_start("@function.outer", "textobjects") end, { desc = "Next function" })
      vim.keymap.set({ "n", "x", "o" }, "[f", function() move.goto_previous_start("@function.outer", "textobjects") end, { desc = "Prev function" })
    end,
  },

  -- 彩虹括号（直接用 vim.treesitter，与 main 分支兼容）
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = "BufReadPost",
    config = function()
      require("rainbow-delimiters.setup").setup({})
    end,
  },
}

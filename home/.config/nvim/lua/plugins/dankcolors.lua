return {
	{
		"RRethy/base16-nvim",
		priority = 1000,
		config = function()
			require('base16-colorscheme').setup({
				base00 = '#141312',
				base01 = '#141312',
				base02 = '#666c66',
				base03 = '#666c66',
				base04 = '#202320',
				base05 = '#b7bfb7',
				base06 = '#b7bfb7',
				base07 = '#b7bfb7',
				base08 = '#c44322',
				base09 = '#c44322',
				base0A = '#6f706e',
				base0B = '#098c00',
				base0C = '#010201',
				base0D = '#6f706e',
				base0E = '#020302',
				base0F = '#020302',
			})

			vim.api.nvim_set_hl(0, 'Visual', {
				bg = '#666c66',
				fg = '#b7bfb7',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Statusline', {
				bg = '#6f706e',
				fg = '#141312',
			})
			vim.api.nvim_set_hl(0, 'LineNr', { fg = '#666c66' })
			vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = '#010201', bold = true })

			vim.api.nvim_set_hl(0, 'Statement', {
				fg = '#020302',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Keyword', { link = 'Statement' })
			vim.api.nvim_set_hl(0, 'Repeat', { link = 'Statement' })
			vim.api.nvim_set_hl(0, 'Conditional', { link = 'Statement' })

			vim.api.nvim_set_hl(0, 'Function', {
				fg = '#6f706e',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Macro', {
				fg = '#6f706e',
				italic = true
			})
			vim.api.nvim_set_hl(0, '@function.macro', { link = 'Macro' })

			vim.api.nvim_set_hl(0, 'Type', {
				fg = '#010201',
				bold = true,
				italic = true
			})
			vim.api.nvim_set_hl(0, 'Structure', { link = 'Type' })

			vim.api.nvim_set_hl(0, 'String', {
				fg = '#098c00',
				italic = true
			})

			vim.api.nvim_set_hl(0, 'Operator', { fg = '#202320' })
			vim.api.nvim_set_hl(0, 'Delimiter', { fg = '#202320' })
			vim.api.nvim_set_hl(0, '@punctuation.bracket', { link = 'Delimiter' })
			vim.api.nvim_set_hl(0, '@punctuation.delimiter', { link = 'Delimiter' })

			vim.api.nvim_set_hl(0, 'Comment', {
				fg = '#666c66',
				italic = true
			})

			local current_file_path = vim.fn.stdpath("config") .. "/lua/plugins/dankcolors.lua"
			if not _G._matugen_theme_watcher then
				local uv = vim.uv or vim.loop
				_G._matugen_theme_watcher = uv.new_fs_event()
				_G._matugen_theme_watcher:start(current_file_path, {}, vim.schedule_wrap(function()
					local new_spec = dofile(current_file_path)
					if new_spec and new_spec[1] and new_spec[1].config then
						new_spec[1].config()
						print("Theme reload")
					end
				end))
			end
		end
	}
}

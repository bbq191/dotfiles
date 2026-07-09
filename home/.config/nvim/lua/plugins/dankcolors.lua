return {
	{
		"RRethy/base16-nvim",
		priority = 1000,
		config = function()
			require('base16-colorscheme').setup({
				base00 = '#15130f',
				base01 = '#15130f',
				base02 = '#6c6b69',
				base03 = '#6c6b69',
				base04 = '#232322',
				base05 = '#bfbeba',
				base06 = '#bfbeba',
				base07 = '#bfbeba',
				base08 = '#aa574e',
				base09 = '#aa574e',
				base0A = '#826d31',
				base0B = '#3f8c33',
				base0C = '#8d8364',
				base0D = '#826d31',
				base0E = '#c0b79d',
				base0F = '#c0b79d',
			})

			vim.api.nvim_set_hl(0, 'Visual', {
				bg = '#6c6b69',
				fg = '#bfbeba',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Statusline', {
				bg = '#826d31',
				fg = '#15130f',
			})
			vim.api.nvim_set_hl(0, 'LineNr', { fg = '#6c6b69' })
			vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = '#8d8364', bold = true })

			vim.api.nvim_set_hl(0, 'Statement', {
				fg = '#c0b79d',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Keyword', { link = 'Statement' })
			vim.api.nvim_set_hl(0, 'Repeat', { link = 'Statement' })
			vim.api.nvim_set_hl(0, 'Conditional', { link = 'Statement' })

			vim.api.nvim_set_hl(0, 'Function', {
				fg = '#826d31',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Macro', {
				fg = '#826d31',
				italic = true
			})
			vim.api.nvim_set_hl(0, '@function.macro', { link = 'Macro' })

			vim.api.nvim_set_hl(0, 'Type', {
				fg = '#8d8364',
				bold = true,
				italic = true
			})
			vim.api.nvim_set_hl(0, 'Structure', { link = 'Type' })

			vim.api.nvim_set_hl(0, 'String', {
				fg = '#3f8c33',
				italic = true
			})

			vim.api.nvim_set_hl(0, 'Operator', { fg = '#232322' })
			vim.api.nvim_set_hl(0, 'Delimiter', { fg = '#232322' })
			vim.api.nvim_set_hl(0, '@punctuation.bracket', { link = 'Delimiter' })
			vim.api.nvim_set_hl(0, '@punctuation.delimiter', { link = 'Delimiter' })

			vim.api.nvim_set_hl(0, 'Comment', {
				fg = '#6c6b69',
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

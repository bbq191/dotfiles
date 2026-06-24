return {
	{
		"RRethy/base16-nvim",
		priority = 1000,
		config = function()
			require('base16-colorscheme').setup({
				base00 = '#1a120d',
				base01 = '#1a120d',
				base02 = '#a59d99',
				base03 = '#a59d99',
				base04 = '#fff5ef',
				base05 = '#fffaf8',
				base06 = '#fffaf8',
				base07 = '#fffaf8',
				base08 = '#ffa39f',
				base09 = '#ffa39f',
				base0A = '#ffc09f',
				base0B = '#b6ffa5',
				base0C = '#ffdecc',
				base0D = '#ffc09f',
				base0E = '#ffcbb0',
				base0F = '#ffcbb0',
			})

			vim.api.nvim_set_hl(0, 'Visual', {
				bg = '#a59d99',
				fg = '#fffaf8',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Statusline', {
				bg = '#ffc09f',
				fg = '#1a120d',
			})
			vim.api.nvim_set_hl(0, 'LineNr', { fg = '#a59d99' })
			vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = '#ffdecc', bold = true })

			vim.api.nvim_set_hl(0, 'Statement', {
				fg = '#ffcbb0',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Keyword', { link = 'Statement' })
			vim.api.nvim_set_hl(0, 'Repeat', { link = 'Statement' })
			vim.api.nvim_set_hl(0, 'Conditional', { link = 'Statement' })

			vim.api.nvim_set_hl(0, 'Function', {
				fg = '#ffc09f',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Macro', {
				fg = '#ffc09f',
				italic = true
			})
			vim.api.nvim_set_hl(0, '@function.macro', { link = 'Macro' })

			vim.api.nvim_set_hl(0, 'Type', {
				fg = '#ffdecc',
				bold = true,
				italic = true
			})
			vim.api.nvim_set_hl(0, 'Structure', { link = 'Type' })

			vim.api.nvim_set_hl(0, 'String', {
				fg = '#b6ffa5',
				italic = true
			})

			vim.api.nvim_set_hl(0, 'Operator', { fg = '#fff5ef' })
			vim.api.nvim_set_hl(0, 'Delimiter', { fg = '#fff5ef' })
			vim.api.nvim_set_hl(0, '@punctuation.bracket', { link = 'Delimiter' })
			vim.api.nvim_set_hl(0, '@punctuation.delimiter', { link = 'Delimiter' })

			vim.api.nvim_set_hl(0, 'Comment', {
				fg = '#a59d99',
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

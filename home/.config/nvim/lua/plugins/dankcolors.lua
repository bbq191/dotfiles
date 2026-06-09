return {
	{
		"RRethy/base16-nvim",
		priority = 1000,
		config = function()
			require('base16-colorscheme').setup({
				base00 = '#17130a',
				base01 = '#17130a',
				base02 = '#6c6a66',
				base03 = '#6c6a66',
				base04 = '#232220',
				base05 = '#bfbdb7',
				base06 = '#bfbdb7',
				base07 = '#bfbdb7',
				base08 = '#c73f24',
				base09 = '#c73f24',
				base0A = '#8f6904',
				base0B = '#148c00',
				base0C = '#9e894f',
				base0D = '#8f6904',
				base0E = '#d7c592',
				base0F = '#d7c592',
			})

			vim.api.nvim_set_hl(0, 'Visual', {
				bg = '#6c6a66',
				fg = '#bfbdb7',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Statusline', {
				bg = '#8f6904',
				fg = '#17130a',
			})
			vim.api.nvim_set_hl(0, 'LineNr', { fg = '#6c6a66' })
			vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = '#9e894f', bold = true })

			vim.api.nvim_set_hl(0, 'Statement', {
				fg = '#d7c592',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Keyword', { link = 'Statement' })
			vim.api.nvim_set_hl(0, 'Repeat', { link = 'Statement' })
			vim.api.nvim_set_hl(0, 'Conditional', { link = 'Statement' })

			vim.api.nvim_set_hl(0, 'Function', {
				fg = '#8f6904',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Macro', {
				fg = '#8f6904',
				italic = true
			})
			vim.api.nvim_set_hl(0, '@function.macro', { link = 'Macro' })

			vim.api.nvim_set_hl(0, 'Type', {
				fg = '#9e894f',
				bold = true,
				italic = true
			})
			vim.api.nvim_set_hl(0, 'Structure', { link = 'Type' })

			vim.api.nvim_set_hl(0, 'String', {
				fg = '#148c00',
				italic = true
			})

			vim.api.nvim_set_hl(0, 'Operator', { fg = '#232220' })
			vim.api.nvim_set_hl(0, 'Delimiter', { fg = '#232220' })
			vim.api.nvim_set_hl(0, '@punctuation.bracket', { link = 'Delimiter' })
			vim.api.nvim_set_hl(0, '@punctuation.delimiter', { link = 'Delimiter' })

			vim.api.nvim_set_hl(0, 'Comment', {
				fg = '#6c6a66',
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

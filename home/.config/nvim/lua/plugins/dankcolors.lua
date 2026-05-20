return {
	{
		"RRethy/base16-nvim",
		priority = 1000,
		config = function()
			require('base16-colorscheme').setup({
				base00 = '#171216',
				base01 = '#171216',
				base02 = '#998e9a',
				base03 = '#998e9a',
				base04 = '#f8e9f8',
				base05 = '#fef8ff',
				base06 = '#fef8ff',
				base07 = '#fef8ff',
				base08 = '#ff9fab',
				base09 = '#ff9fab',
				base0A = '#fdcbff',
				base0B = '#a5ffbe',
				base0C = '#fee3ff',
				base0D = '#fdcbff',
				base0E = '#fdd4ff',
				base0F = '#fdd4ff',
			})

			vim.api.nvim_set_hl(0, 'Visual', {
				bg = '#998e9a',
				fg = '#fef8ff',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Statusline', {
				bg = '#fdcbff',
				fg = '#171216',
			})
			vim.api.nvim_set_hl(0, 'LineNr', { fg = '#998e9a' })
			vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = '#fee3ff', bold = true })

			vim.api.nvim_set_hl(0, 'Statement', {
				fg = '#fdd4ff',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Keyword', { link = 'Statement' })
			vim.api.nvim_set_hl(0, 'Repeat', { link = 'Statement' })
			vim.api.nvim_set_hl(0, 'Conditional', { link = 'Statement' })

			vim.api.nvim_set_hl(0, 'Function', {
				fg = '#fdcbff',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Macro', {
				fg = '#fdcbff',
				italic = true
			})
			vim.api.nvim_set_hl(0, '@function.macro', { link = 'Macro' })

			vim.api.nvim_set_hl(0, 'Type', {
				fg = '#fee3ff',
				bold = true,
				italic = true
			})
			vim.api.nvim_set_hl(0, 'Structure', { link = 'Type' })

			vim.api.nvim_set_hl(0, 'String', {
				fg = '#a5ffbe',
				italic = true
			})

			vim.api.nvim_set_hl(0, 'Operator', { fg = '#f8e9f8' })
			vim.api.nvim_set_hl(0, 'Delimiter', { fg = '#f8e9f8' })
			vim.api.nvim_set_hl(0, '@punctuation.bracket', { link = 'Delimiter' })
			vim.api.nvim_set_hl(0, '@punctuation.delimiter', { link = 'Delimiter' })

			vim.api.nvim_set_hl(0, 'Comment', {
				fg = '#998e9a',
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

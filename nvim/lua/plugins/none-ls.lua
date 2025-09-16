return {
	"nvimtools/none-ls.nvim",
	dependencies = {
		"nvimtools/none-ls-extras.nvim",
	},
	config = function()
		local null_ls = require("null-ls")
		local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
		local utils = require("null-ls.utils").make_conditional_utils()

		local hasBiome = utils.root_has_file({ "biome.json" })
		local hasEslint = utils.root_has_file({
			"eslint.config.js",
			".eslintrc",
			".eslintrc.js",
			".eslintrc.cjs",
			".eslintrc.yaml",
			".eslintrc.yml",
			".eslintrc.json",
		})

		local hasPrettier = utils.root_has_file({
			".prettierrc",
			".prettierrc.json",
			".prettierrc.yml",
			".prettierrc.yaml",
			".prettierrc.js",
			".prettierrc.cjs",
			"prettier.config.js",
			"prettier.config.cjs",
		})

		if hasEslint or hasPrettier then
			null_ls.setup({
				sources = {
					require("none-ls.diagnostics.eslint_d").with({
						filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
						condition = function()
							return hasEslint or hasPrettier
						end,
					}),
				},
			})
		end
	end,
}

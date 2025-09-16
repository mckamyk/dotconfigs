return {
	"stevearc/conform.nvim",
	config = function()
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

		local formatters_by_ft = {
			lua = { "stylua" },
		}

		if hasBiome then
			formatters_by_ft.javascript = { "biome-check" }
			formatters_by_ft.typescript = { "biome-check" }
			formatters_by_ft.javascriptreact = { "biome-check" }
			formatters_by_ft.typescriptreact = { "biome-check" }
		elseif hasEslint or hasPrettier then
			formatters_by_ft.javascript = { "prettier" }
			formatters_by_ft.typescript = { "prettier" }
			formatters_by_ft.javascriptreact = { "prettier" }
			formatters_by_ft.typescriptreact = { "prettier" }
		end

		require("conform").setup({
			formatters_by_ft = formatters_by_ft,
			format_on_save = {
				lsp_fallback = true,
				timeout_ms = 500,
			},
		})

		vim.keymap.set("n", "<leader>cf", function()
			require("conform").format()
		end, {})
	end,
}


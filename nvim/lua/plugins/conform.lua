return {
	"stevearc/conform.nvim",
	config = function()
		local utils = require("null-ls.utils").make_conditional_utils()

		local prettier_condition = function()
			-- check config files
			if
				utils.root_has_file({
					".prettierrc",
					".prettierrc.json",
					".prettierrc.yml",
					".prettierrc.yaml",
					".prettierrc.js",
					".prettierrc.mjs",
					".prettierignore",
					".prettierrc.cjs",
					"prettier.config.js",
					"prettier.config.cjs",
				})
			then
				return true
			end
		end

		local biome_condition = utils.root_has_file({ "biome.json" })

		require("conform").setup({
			formatters = {
				prettier = {
					condition = prettier_condition,
				},
				["biome-check"] = {
					condition = biome_condition,
				},
			},
			formatters_by_ft = {
				lua = { "stylua" },
				javascript = { "prettier", "biome-check" },
				typescript = { "prettier", "biome-check" },
				javascriptreact = { "prettier", "biome-check" },
				typescriptreact = { "prettier", "biome-check" },
			},
			format_on_save = {
				lsp_fallback = true,
				timeout_ms = 500,
				stop_after_first = true,
			},
		})

		vim.keymap.set("n", "<leader>cf", function()
			require("conform").format()
		end, {})
	end,
}

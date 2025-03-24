return {
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = { "lua_ls", "ts_ls", "tailwindcss", "solidity" },
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			local lspconfig = require("lspconfig")
			lspconfig.lua_ls.setup({
				capabilities = capabilities,
			})
			lspconfig.ts_ls.setup({
				capabilities = capabilities,
			})
			lspconfig.solidity.setup({
				capabilities = capabilities,
			})
			lspconfig.gopls.setup({
				capabilities = capabilities,
			})

			vim.diagnostic.config({
				signs = {
					text = {
						[vim.diagnostic.severity.ERROR] = "🔴",
						[vim.diagnostic.severity.WARN] = "🟡",
					},
					-- linehl = {
					-- 	[vim.diagnostic.severity.ERROR] = "ErrorMsg",
					-- },
					-- numhl = {
					-- 	[vim.diagnostic.severity.WARN] = "WarningMsg",
					-- },
				},
			})

			vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
			vim.keymap.set("n", "<leader>t", vim.lsp.buf.hover, {})
			vim.keymap.set("n", "gd", "<cmd>tab split | lua vim.lsp.buf.definition()<CR>", {})
			vim.keymap.set("n", "gr", vim.lsp.buf.references, {})
			vim.keymap.set("n", "<leader>a", vim.lsp.buf.code_action, {})

			vim.keymap.set("n", "<leader>n", vim.diagnostic.goto_next, {})
			vim.keymap.set("n", "<leader>m", vim.diagnostic.goto_prev, {})
		end,
	},
}

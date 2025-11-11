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
				ensure_installed = { "lua_ls", "vtsls", "tailwindcss", "solidity", "biome", "jsonls", "taplo" },
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			local function has_file(patterns)
				for _, pattern in ipairs(patterns) do
					if vim.fn.glob(pattern) ~= "" then
						return true
					end
				end
				return false
			end

			local hasBiome = has_file({ "biome.json" })

			vim.lsp.config('lua_ls', {
				capabilities = capabilities,
			})
			vim.lsp.enable('lua_ls')

			vim.lsp.config('vtsls', {
				capabilities = capabilities,
			})
			vim.lsp.enable('vtsls')

			if hasBiome then
				vim.lsp.config('biome', {
					capabilities = capabilities,
				})
				vim.lsp.enable('biome')
			end

			vim.lsp.config('solidity', {
				capabilities = capabilities,
			})
			vim.lsp.enable('solidity')

			vim.lsp.config('gopls', {
				capabilities = capabilities,
			})
			vim.lsp.enable('gopls')

			vim.lsp.config('jsonls', {
				capabilities = capabilities,
			})
			vim.lsp.enable('jsonls')

			vim.lsp.config('taplo', {
				capabilities = capabilities,
			})
			vim.lsp.enable('taplo')

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
			vim.keymap.set("n", "<leader>si", "<cmd>LspInfo<CR>", {})
		end,
	},
}

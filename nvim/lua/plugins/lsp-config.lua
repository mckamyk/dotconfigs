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
			local ensure_installed = { "lua_ls", "vtsls", "tailwindcss", "solidity", "biome", "jsonls", "taplo" }
			-- Only ensure eslint is installed if oxlint is not configured
			local hasOxlint = vim.fn.glob("*oxlintrc*") ~= "" or vim.fn.glob("oxlint.json") ~= ""
			if not hasOxlint then
				table.insert(ensure_installed, "eslint")
			end
			require("mason-lspconfig").setup({
				ensure_installed = ensure_installed,
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
			local hasOxlint = has_file({ ".oxlintrc.json", ".oxlintrc.toml", ".oxlintrc.js", "oxlint.json" })

			local on_attach = function(client, bufnr)
				-- Tailwind highlight setup
				if client.name == "tailwindcss" then
					require("tailwind-highlight").setup(client, bufnr, {
						single_column = false,
						debounce = 200,
						mode = 'background',
					})
				end

				-- LSP keybindings
				local opts = { buffer = bufnr }
				
				vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
				vim.keymap.set("n", "<leader>t", vim.lsp.buf.hover, opts)
				vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
				vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
				vim.keymap.set("n", "<leader>a", vim.lsp.buf.code_action, opts)
			end

			vim.lsp.config('lua_ls', {
				capabilities = capabilities,
				on_attach = on_attach,
			})
			vim.lsp.enable('lua_ls')

			vim.lsp.config('vtsls', {
				capabilities = capabilities,
				on_attach = on_attach,
			})
			vim.lsp.enable('vtsls')

			if hasBiome then
				vim.lsp.config('biome', {
					capabilities = capabilities,
					on_attach = on_attach,
				})
				vim.lsp.enable('biome')
			end

			vim.lsp.config('solidity', {
				capabilities = capabilities,
				on_attach = on_attach,
			})
			vim.lsp.enable('solidity')

			vim.lsp.config('gopls', {
				capabilities = capabilities,
				on_attach = on_attach,
			})
			vim.lsp.enable('gopls')

			vim.lsp.config('jsonls', {
				capabilities = capabilities,
				on_attach = on_attach,
			})
			vim.lsp.enable('jsonls')

			vim.lsp.config('taplo', {
				capabilities = capabilities,
				on_attach = on_attach,
			})
			vim.lsp.enable('taplo')

			-- Enable tailwindcss LSP
			vim.lsp.config('tailwindcss', {
				capabilities = capabilities,
				on_attach = on_attach,
			})
			vim.lsp.enable('tailwindcss')

			-- Enable eslint LSP only if oxlint is not configured
			if not hasOxlint then
				vim.lsp.config('eslint', {
					capabilities = capabilities,
					on_attach = on_attach,
				})
				vim.lsp.enable('eslint')
			end

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

			-- Diagnostic keybindings (global)

			vim.keymap.set("n", "<leader>n", vim.diagnostic.goto_next, {})
			vim.keymap.set("n", "<leader>m", vim.diagnostic.goto_prev, {})
			vim.keymap.set("n", "<leader>si", "<cmd>LspInfo<CR>", {})
		end,
	},
}

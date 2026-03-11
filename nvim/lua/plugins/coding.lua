-- Shared config loader for .nvim.local (theme only)
local utils = require("utils")

-- Plugin definitions
return {
	-- Syntax highlighting
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter").setup({
				auto_install = true,
			})
			-- Enable highlighting via autocmd (main branch API)
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
				callback = function(args)
					-- Check if parser exists before starting
					local ok, parser = pcall(vim.treesitter.get_parser, args.buf)
					if not ok or not parser then
						return -- Parser not available yet, auto_install will handle it
					end
					local start_ok, err = pcall(vim.treesitter.start, args.buf)
					if not start_ok then
						vim.notify("Treesitter failed for " .. vim.bo[args.buf].filetype .. ": " .. tostring(err), vim.log.levels.WARN)
					end
				end,
			})
		end,
	},
	-- Auto completion
	{
		"hrsh7th/cmp-nvim-lsp",
	},
	{
		"hrsh7th/nvim-cmp",
		config = function()
			local cmp = require("cmp")

			cmp.setup({
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
				mapping = cmp.mapping.preset.insert({
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
				}, {
					{ name = "buffer" },
				}),
			})
		end,
	},
	-- LSP
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
				ensure_installed = {
					"lua_ls",
					"solidity",
					"jsonls",
					"taplo",
					"tsgo",
					"oxlint",
					"oxfmt",
					"tailwindcss",
				},
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			local on_attach = function(client, bufnr)
				-- Tailwind highlight setup
				if client.name == "tailwindcss" then
					require("tailwind-highlight").setup(client, bufnr, {
						single_column = false,
						debounce = 200,
						mode = "background",
					})
				end
			end

			-- Always-on LSPs
			local always_on_lsps = { "lua_ls", "solidity", "jsonls", "taplo" }
			for _, lsp in ipairs(always_on_lsps) do
				vim.lsp.config(lsp, {
					capabilities = capabilities,
					on_attach = on_attach,
				})
				vim.lsp.enable(lsp)
			end

			-- TypeScript LSP: tsgo (always enabled)
			vim.lsp.config("tsgo", {
				capabilities = capabilities,
				on_attach = on_attach,
			})
			vim.lsp.enable("tsgo")

			-- gopls - filetype-specific
			vim.lsp.config("gopls", {
				capabilities = capabilities,
				on_attach = on_attach,
				filetypes = { "go", "gomod", "gowork", "gotmpl" },
			})
			vim.lsp.enable("gopls")

			-- oxlint - linting for JS/TS
			vim.lsp.enable("oxlint")

			-- oxfmt - formatting for JS/TS
			vim.lsp.enable("oxfmt")

			-- tailwindcss - CSS completion (filetype-restricted)
			-- Helper to find Tailwind v4 CSS config file
			local function find_tw4_config(root)
				local candidates = {
					"packages/ui/src/globals.css",
					"src/styles.css",
					"src/globals.css",
					"src/app.css",
					"app/globals.css",
					"styles/globals.css",
				}
				for _, candidate in ipairs(candidates) do
					local path = root .. "/" .. candidate
					if vim.fn.filereadable(path) == 1 then
						local content = vim.fn.readfile(path, "", 10)
						for _, line in ipairs(content) do
							if line:match("@import%s+[%\"']tailwindcss[%\"']") then
								return candidate
							end
						end
					end
				end
				return nil
			end

			vim.lsp.config("tailwindcss", {
				capabilities = capabilities,
				on_attach = on_attach,
				filetypes = {
					"html",
					"css",
					"scss",
					"sass",
					"less",
					"javascript",
					"javascriptreact",
					"typescript",
					"typescriptreact",
				},
				root_dir = function(bufnr, on_dir)
					local bufname = vim.api.nvim_buf_get_name(bufnr)
					local root = vim.fs.root(bufname, { "pnpm-workspace.yaml", "turbo.json" })
						or vim.fs.root(
							bufname,
							{ "tailwind.config.js", "tailwind.config.ts", "postcss.config.js", "package.json" }
						)
					if root then
						local tw4_config = find_tw4_config(root)
						if tw4_config then
							vim.g.tailwind_v4_config = vim.g.tailwind_v4_config or {}
							vim.g.tailwind_v4_config[root] = tw4_config
						end
						on_dir(root)
					end
				end,
				settings = {
					tailwindCSS = {
						experimental = {},
					},
				},
				on_init = function(client)
					local root = client.root_dir
					if root and vim.g.tailwind_v4_config and vim.g.tailwind_v4_config[root] then
						client.settings.tailwindCSS.experimental.configFile = vim.g.tailwind_v4_config[root]
					end
					return true
				end,
			})
			vim.lsp.enable("tailwindcss")

			vim.diagnostic.config({
				signs = {
					text = {
						[vim.diagnostic.severity.ERROR] = "🔴",
						[vim.diagnostic.severity.WARN] = "🟡",
					},
				},
			})
		end,
	},
	-- AI completion
	{
		"monkoose/neocodeium",
		event = "VeryLazy",
		config = function()
			local neocodeium = require("neocodeium")
			neocodeium.setup()
		end,
	},
	-- Tailwind tools - always enabled
	{
		"princejoogie/tailwind-highlight.nvim",
		dependencies = {
			"neovim/nvim-lspconfig",
		},
	},
	-- Auto pairs and autotag
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
	},
	{
		"windwp/nvim-ts-autotag",
		config = function()
			require("nvim-ts-autotag").setup({
				opts = {
					enable_close = true,
					enable_rename = true,
					enable_close_on_slash = false,
				},
			})
		end,
	},
}

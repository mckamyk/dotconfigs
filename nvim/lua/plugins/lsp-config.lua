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
						mode = "background",
					})
				end

				local function goto_definition()
					local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
					local result = vim.lsp.buf_request_sync(0, 'textDocument/definition', params, 5000)
					if not result or vim.tbl_isempty(result) then return end
					for _, res in pairs(result) do
						if res.result then
							local locations = vim.lsp.util.locations_to_items(res.result)
							if not vim.tbl_isempty(locations) then
								local location = locations[1]
								local target_file = location.filename
								local current_file = vim.fn.expand('%:p')
								if target_file ~= current_file then
									vim.cmd('tabnew')
								end
								local uri = location.uri or vim.uri_from_fname(location.filename)
								local target_bufnr = vim.uri_to_bufnr(uri)
								vim.api.nvim_win_set_buf(0, target_bufnr)
								vim.api.nvim_win_set_cursor(0, {location.lnum, location.col - 1})
								return
							end
						end
					end
				end

				-- LSP keybindings
				local opts = { buffer = bufnr }

				vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
				vim.keymap.set("n", "<leader>t", vim.lsp.buf.hover, opts)
				vim.keymap.set("n", "gd", goto_definition, opts)
				vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
				vim.keymap.set("n", "<leader>a", vim.lsp.buf.code_action, opts)
			end

			vim.lsp.config("lua_ls", {
				capabilities = capabilities,
				on_attach = on_attach,
			})
			vim.lsp.enable("lua_ls")

			vim.lsp.config("vtsls", {
				capabilities = capabilities,
				on_attach = on_attach,
			})
			vim.lsp.enable("vtsls")

			if hasBiome then
				vim.lsp.config("biome", {
					capabilities = capabilities,
					on_attach = on_attach,
				})
				vim.lsp.enable("biome")
			end

			vim.lsp.config("solidity", {
				capabilities = capabilities,
				on_attach = on_attach,
			})
			vim.lsp.enable("solidity")

			vim.lsp.config("gopls", {
				capabilities = capabilities,
				on_attach = on_attach,
			})
			vim.lsp.enable("gopls")

			vim.lsp.config("jsonls", {
				capabilities = capabilities,
				on_attach = on_attach,
			})
			vim.lsp.enable("jsonls")

			vim.lsp.config("taplo", {
				capabilities = capabilities,
				on_attach = on_attach,
			})
			vim.lsp.enable("taplo")

			-- Enable tailwindcss LSP
			-- Helper to find Tailwind v4 CSS config file (contains @import "tailwindcss")
			local function find_tw4_config(root)
				local candidates = {
					"packages/ui/src/globals.css", -- monorepo pattern
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
							if line:match('@import%s+["\']tailwindcss["\']') then
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
				root_dir = function(bufnr, on_dir)
					local bufname = vim.api.nvim_buf_get_name(bufnr)
					-- Try monorepo root first, then standard tailwind config
					local root = vim.fs.root(bufname, { "pnpm-workspace.yaml", "turbo.json" })
						or vim.fs.root(bufname, { "tailwind.config.js", "tailwind.config.ts", "postcss.config.js", "package.json" })
					if root then
						-- Store the tw4 config path for this root
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

			-- Enable eslint LSP only if oxlint is not configured
			if not hasOxlint then
				vim.lsp.config("eslint", {
					capabilities = capabilities,
					on_attach = on_attach,
				})
				vim.lsp.enable("eslint")
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

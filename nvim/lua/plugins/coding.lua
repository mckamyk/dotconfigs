return {
  -- Syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      local config = require("nvim-treesitter.configs")
      config.setup({
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
      })
    end
  },
  -- Auto completion
  {
    "hrsh7th/cmp-nvim-lsp"
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
        formatting = {
          format = require("tailwindcss-colorizer-cmp").formatter,
        },
      })
    end,
  },
  -- Formatting
  {
    "stevearc/conform.nvim",
    config = function()
      local function has_file(patterns)
        for _, pattern in ipairs(patterns) do
          if vim.fn.glob(pattern) ~= "" then
            return true
          end
        end
        return false
      end

      local prettier_condition = function()
        return has_file({
          ".prettierrc",
          ".prettierrc.json",
          ".prettierrc.yml",
          ".prettierrc.yaml",
          ".prettierrc.js",
          ".prettierrc.mjs",
          ".prettierrc.cjs",
          "prettier.config.js",
          "prettier.config.cjs",
        })
      end

      local biome_condition = function()
        return has_file({ "biome.json" })
      end

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
          javascript = { "biome-check", "prettier" },
          typescript = { "biome-check", "prettier" },
          javascriptreact = { "biome-check", "prettier" },
          typescriptreact = { "biome-check", "prettier" },
        },
        format_on_save = {
          lsp_fallback = true,
          timeout_ms = 500,
          stop_after_first = true,
        },
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

      local function load_project_config()
        local bufname = vim.api.nvim_buf_get_name(0)
        local root = vim.fs.root(bufname, { "pnpm-workspace.yaml", "turbo.json" })
          or vim.fs.root(bufname, { "tailwind.config.js", "tailwind.config.ts", "postcss.config.js", "package.json" })
        
        if not root then
          return {}
        end

        local config_file = root .. "/.nvim.local"
        if vim.fn.filereadable(config_file) ~= 1 then
          return {}
        end

        local config = {}
        local lines = vim.fn.readfile(config_file)
        for _, line in ipairs(lines) do
          line = vim.trim(line)
          if line ~= "" and not line:match("^#") then
            local key, value = line:match("^([^=]+)=(.+)$")
            if key and value then
              local parts = {}
              for part in key:gmatch("[^.]+") do
                table.insert(parts, part)
              end
              
              local current = config
              for i = 1, #parts - 1 do
                if not current[parts[i]] then
                  current[parts[i]] = {}
                end
                current = current[parts[i]]
              end
              
              if value == "true" then
                value = true
              elseif value == "false" then
                value = false
              elseif tonumber(value) then
                value = tonumber(value)
              end
              
              current[parts[#parts]] = value
            end
          end
        end
        return config
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
      local project_config = load_project_config()
      local tailwind_enabled = project_config.lsp and project_config.lsp.tailwindcss and project_config.lsp.tailwindcss.enabled ~= false

      if tailwind_enabled then
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
      end

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
  -- Tailwind tools
  {
    "roobert/tailwindcss-colorizer-cmp.nvim",
    config = function()
      require("tailwindcss-colorizer-cmp").setup({
        color_square_width = 2,
      })
    end,
  },
  {
    "princejoogie/tailwind-highlight.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
    },
  },
  -- Linting
  {
    "soulsam480/nvim-oxlint",
    opts = {},
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
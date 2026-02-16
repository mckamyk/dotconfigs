-- Shared config loader for .nvim.local
local M = {}

function M.get_project_root()
  local bufname = vim.api.nvim_buf_get_name(0)
  if bufname == "" then
    -- Fallback to current working directory if no buffer is loaded
    bufname = vim.fn.getcwd()
  end
  return vim.fs.root(bufname, { "pnpm-workspace.yaml", "turbo.json" })
    or vim.fs.root(bufname, { "tailwind.config.js", "tailwind.config.ts", "postcss.config.js", "package.json" })
    or vim.fn.getcwd() -- ultimate fallback
end

function M.load_project_tools()
  local root = M.get_project_root()
  if not root then
    return { has_config = false, tools = {} }
  end

  local config_file = root .. "/.nvim.local"
  if vim.fn.filereadable(config_file) ~= 1 then
    return { has_config = false, tools = {} }
  end

  local tools = {}
  local lines = vim.fn.readfile(config_file)
  for _, line in ipairs(lines) do
    line = vim.trim(line)
    if line ~= "" and not line:match("^#") then
      tools[line] = true
    end
  end

  return { has_config = true, tools = tools, root = root }
end

-- Track if we've shown warnings this session
M.warning_shown = false

-- Build formatters list from tools
function M.get_ts_formatters(tools, has_config_file)
  local formatters = {}

  if tools.oxfmt then
    table.insert(formatters, "oxfmt")
  end

  if tools.biome or (not has_config_file) then
    table.insert(formatters, "biome-check")
  end

  if tools.prettier then
    table.insert(formatters, "prettier")
  end

  return formatters
end

-- Function to show warnings about multiple tools
function M.show_tool_warnings(tools, has_config_file, ts_formatters)
  if M.warning_shown then
    return
  end

  -- Check for multiple formatters
  if #ts_formatters > 1 then
    vim.notify(
      "Multiple formatters selected: " .. table.concat(ts_formatters, ", ") .. ". Using first available.",
      vim.log.levels.WARN
    )
  end

  -- Check for multiple linters
  local linters = {}
  if tools.oxlint then
    table.insert(linters, "oxlint")
  end
  if tools.biome or (not has_config_file) then
    table.insert(linters, "biome")
  end
  if tools.eslint then
    table.insert(linters, "eslint")
  end

  if #linters > 1 then
    vim.notify(
      "Multiple linters active: " .. table.concat(linters, ", ") .. ". Both will run.",
      vim.log.levels.WARN
    )
  end

  M.warning_shown = true
end

-- Plugin definitions
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
      })
    end,
  },
  -- Formatting
  {
    "stevearc/conform.nvim",
    config = function()
      -- Load project tools at config time (when a buffer is open)
      local project_tools = M.load_project_tools()
      local has_config_file = project_tools.has_config
      local tools = project_tools.tools
      local ts_formatters = M.get_ts_formatters(tools, has_config_file)

      -- Set up autocmd to show warnings on TS/JS file open
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
        callback = function()
          M.show_tool_warnings(tools, has_config_file, ts_formatters)
        end,
      })

      require("conform").setup({
        formatters_by_ft = {
          lua = { "stylua" },
          javascript = ts_formatters,
          typescript = ts_formatters,
          javascriptreact = ts_formatters,
          typescriptreact = ts_formatters,
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
      -- Load project tools at config time
      local project_tools = M.load_project_tools()
      local has_config_file = project_tools.has_config
      local tools = project_tools.tools

      local ensure_installed = {
        "lua_ls",
        "vtsls",
        "solidity",
        "jsonls",
        "taplo",
        "gopls",
      }

      if tools.biome or (not has_config_file) then
        table.insert(ensure_installed, "biome")
      end

      if tools.eslint then
        table.insert(ensure_installed, "eslint")
      end

      if tools.tailwindcss then
        table.insert(ensure_installed, "tailwindcss")
      end

      require("mason-lspconfig").setup({
        ensure_installed = ensure_installed,
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- Load project tools at config time
      local project_tools = M.load_project_tools()
      local has_config_file = project_tools.has_config
      local tools = project_tools.tools

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
      local always_on_lsps = { "lua_ls", "vtsls", "solidity", "jsonls", "taplo" }
      for _, lsp in ipairs(always_on_lsps) do
        vim.lsp.config(lsp, {
          capabilities = capabilities,
          on_attach = on_attach,
        })
        vim.lsp.enable(lsp)
      end

      -- gopls - filetype-specific
      vim.lsp.config("gopls", {
        capabilities = capabilities,
        on_attach = on_attach,
        filetypes = { "go", "gomod", "gowork", "gotmpl" },
      })
      vim.lsp.enable("gopls")

      -- Conditional TypeScript ecosystem LSPs
      if tools.biome or (not has_config_file) then
        vim.lsp.config("biome", {
          capabilities = capabilities,
          on_attach = on_attach,
        })
        vim.lsp.enable("biome")
      end

      if tools.eslint then
        vim.lsp.config("eslint", {
          capabilities = capabilities,
          on_attach = on_attach,
        })
        vim.lsp.enable("eslint")
      end

      if tools.tailwindcss then
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
            local root = vim.fs.root(bufname, { "pnpm-workspace.yaml", "turbo.json" })
              or vim.fs.root(bufname, { "tailwind.config.js", "tailwind.config.ts", "postcss.config.js", "package.json" })
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
  -- Tailwind tools - conditional
  {
    "princejoogie/tailwind-highlight.nvim",
    cond = function()
      local project_tools = M.load_project_tools()
      return project_tools.tools.tailwindcss
    end,
    dependencies = {
      "neovim/nvim-lspconfig",
    },
  },
  -- Linting - conditional
  {
    "soulsam480/nvim-oxlint",
    cond = function()
      local project_tools = M.load_project_tools()
      return project_tools.tools.oxlint
    end,
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

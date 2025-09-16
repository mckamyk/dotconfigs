return {
  'stevearc/conform.nvim',
  event = { "BufReadPre", "BufNewFile" },
  opts = function()
    local function has_file(patterns)
      for _, pattern in ipairs(patterns) do
        if vim.fn.glob(pattern) ~= "" then
          return true
        end
      end
      return false
    end

    local hasEslint = has_file({
      "eslint.config.js",
      ".eslintrc",
      ".eslintrc.js",
      ".eslintrc.cjs",
      ".eslintrc.yaml",
      ".eslintrc.yml",
      ".eslintrc.json",
    })

    local hasPrettier = has_file({
      ".prettierrc",
      ".prettierrc.json",
      ".prettierrc.yml",
      ".prettierrc.yaml",
      ".prettierrc.js",
      ".prettierrc.cjs",
      "prettier.config.js",
      "prettier.config.cjs",
    })

    local formatters_by_ft
    if hasEslint or hasPrettier then
      formatters_by_ft = {
        javascript = { "prettierd", "prettier" },
        typescript = { "prettierd", "prettier" },
        javascriptreact = { "prettierd", "prettier" },
        typescriptreact = { "prettierd", "prettier" },
      }
    else
      formatters_by_ft = {
        javascript = { "biome" },
        typescript = { "biome" },
        javascriptreact = { "biome" },
        typescriptreact = { "biome" },
      }
    end

    return {
      formatters_by_ft = formatters_by_ft,
      formatters = {
        biome = {
          require_cwd = true
        },
      },
      format_on_save = {
        lsp_fallback = true
      }
    }
  end
}

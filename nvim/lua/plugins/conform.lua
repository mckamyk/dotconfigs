return {
  'stevearc/conform.nvim',
  event = { "BufReadPre", "BufNewFile" },
  opts = {

    formatters_by_ft = {
      javascript = { "biome", "prettierd", "prettier", stop_after_first = true },
      typescript = { "biome", "prettierd", "prettier", stop_after_first = true },
      javascriptreact = { "biome-check", "biome", "prettierd", "prettier", stop_after_first = true },
      typescriptreact = { "biome-check", "biome", "prettierd", "prettier", stop_after_first = true },
    },
    formatters = {
      biome = {
        require_cwd = true
      },
    },
    format_on_save = {
      lsp_fallback = true
    }
  }
}

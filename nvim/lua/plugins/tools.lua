return {
  -- OpenCode AI assistant
  {
    "NickvanDyke/opencode.nvim",
    dependencies = {
      "folke/snacks.nvim",
    },
    config = function()
      -- Required for automatic buffer reloading when OpenCode edits files
      vim.o.autoread = true

      -- OpenCode configuration
      vim.g.opencode_opts = {
        -- Use snacks for enhanced UI
        provider = {
          enabled = "snacks",
        },
        -- Enable automatic file reload on edits
        events = {
          reload = true,
        },
      }
    end,
  },
}
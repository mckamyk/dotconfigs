return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        explorer = {
          auto_close = true,
          jump = { close = true },
          layout = { preset = "default", preview = false },
        },
      },
    },
  },
}

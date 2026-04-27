return {
  "luckasRanarison/tailwind-tools.nvim",
  name = "tailwind-tools",
  build = ":UpdateRemotePlugins",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-telescope/telescope.nvim", -- optional
  },
  lazy = false,
  config = function()
    require("tailwind-tools").setup({
      server = {
        override = false,
      },
    })
  end,
}

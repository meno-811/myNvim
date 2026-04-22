-- codecompanion.nvim

return {
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    event = "VeryLazy",
    opts = {
      interactions = {
        chat = {
          adapter = {
            name = "deepseek",
            model = "deepseek-chat",
          },
        },
        inline = {
          adapter = {
            name = "deepseek",
            model = "deepseek-chat",
          },
        },
      },
      adapters = {
        http = {
          deepseek = function()
            return require("codecompanion.adapters").extend("deepseek", {
              env = {
                api_key = "sk-65ef8a9ae9c74b3eb4f40d85b1d122fb"
              },
            })
          end,
        },
      },
      opts = {
        log_level = "DEBUG",
      },
    },
    config = function(_, opts)
      require("codecompanion").setup(opts)
    end,
  },
}

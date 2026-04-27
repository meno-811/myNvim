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
                api_key = os.getenv("DEEPSEEK_API_KEY"),
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

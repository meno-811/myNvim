-- 例：~/.config/nvim/lua/plugins/avante.lua
-- 这是一个最小可用的 avante.nvim lazy.nvim 配置：
-- 1) 声明必需依赖
-- 2) build = "make" 用于下载/构建二进制
-- 3) 显式绑定最常用按键，并在注释中说明功能

return {
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = false,
    build = vim.fn.has("win32") ~= 0
        and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
        or "make",

    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",

      -- 可选：让 Avante 的输出以更好的 Markdown 形式渲染（不装也能用，只是显示效果差一些）
      {
        "MeanderingProgrammer/render-markdown.nvim",
        ft = { "markdown", "Avante" },
        opts = { file_types = { "markdown", "Avante" } },
      },
    },

    opts = {
      override_prompt_dir = vim.fn.expand("~/.config/nvim/avante_prompts"),
      behaviour = {
        auto_set_keymaps = false, -- 关闭插件默认键位，避免和你下面自定义的键位冲突
        auto_add_current_file = false,  -- 关闭每次打开文件时自动添加到 Avante 会话的功能
      },
      provider = "deepseek",
      auto_suggestions_provider = "deepseek",
      providers = {
        deepseek = {
          __inherited_from = "openai",
          endpoint = "https://api.deepseek.com",
          model = "deepseek-v4-flash",
          api_key_name = "DEEPSEEK_API_KEY",
          extra_request_body = {
            thinking = { type = "disabled" },
          }
        }
      }
    },

    keys = {
      -- <leader>aa：提问（普通/可视模式都可用；可视模式会把选区作为上下文）
      { "<leader>aa", "<Plug>(AvanteAsk)", mode = { "n", "v" }, desc = "Avante: Ask" },

      -- 可视模式 <leader>ae：对选区发起“可应用编辑”（生成补丁并可一键应用）
      { "<leader>ae", "<Plug>(AvanteEdit)", mode = "v", desc = "Avante: Edit selection" },

      -- <leader>ar：刷新当前 Avante 面板/会话显示
      { "<leader>ar", "<Plug>(AvanteRefresh)", mode = "n", desc = "Avante: Refresh" },

      -- <leader>as：开关 Avante 自动建议功能
      { "<leader>as", "<Plug>(AvanteToggleSuggestion)", mode = "n", desc = "Avante: Toggle AI suggestions" },

      -- <leader>at：开关 Avante 侧边栏
      { "<leader>at", "<Plug>(AvanteToggle)", mode = "n", desc = "Avante: Toggle sidebar" },
    },
  },
}

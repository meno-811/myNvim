-- minuet-ai.nvim 配置
-- 项目地址: https://github.com/milanglacier/minuet-ai.nvim
-- 功能: 基于 LLM 的 AI 代码补全插件，支持 OpenAI、Claude、Gemini、Ollama 等

return {
  -- 主插件
  {
    "milanglacier/minuet-ai.nvim",
    -- 依赖项：plenary.nvim 是必须的（工具函数库）
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require("minuet").setup({
        -- ============================================================
        -- 1. 虚拟文本（Virtual Text）前端配置
        -- 适用场景：不依赖 nvim-cmp/blink，直接以灰色虚影显示补全建议
        -- ============================================================
        virtualtext = {
          -- 自动触发补全的文件类型列表（空表表示不自动触发，需手动调用）
          -- 示例: auto_trigger_ft = { "lua", "python", "javascript" }
          auto_trigger_ft = {"lua","json","go","python"},

          -- 虚拟文本快捷键映射
          keymap = {
            -- 接受整个补全建议
            accept = "<A-A>",
            -- 只接受当前行
            accept_line = "<A-a>",
            -- 接受指定 n 行（会提示输入数字，如按 <A-z> 后输入 2 再回车）
            accept_n_lines = "<A-z>",
            -- 上一个补全项 / 手动触发补全
            prev = "<A-[>",
            -- 下一个补全项 / 手动触发补全
            next = "<A-]>",
            -- 关闭/取消当前补全
            dismiss = "<A-e>",
          },
        },

        -- ============================================================
        -- 2. LSP 模式配置（供 nvim-cmp / blink 以外的内置补全使用）
        -- ============================================================
        lsp = {
          -- 启用 LSP 补全的文件类型
          enabled_ft = { "toml", "lua", "cpp", "python", "javascript", "typescript" ,"json","go"},

          completion = {
            -- 在这些文件类型中自动触发内置补全（vim.lsp.completion.enable）
            -- 注意: 仅对 Neovim 内置补全有效，Mini.Completion 用户可忽略
            enabled_auto_trigger_ft = { "cpp", "lua", "python","json","go" },

            -- 接受多行补全时自动修正缩进（默认开启，作为上游问题的临时 workaround）
            adjust_indentation = true,
          },
        },

        -- ============================================================
        -- 3. 提供商（Provider）配置
        -- 支持: openai, claude, gemini, codestral, ollama, openai_compatible, openai_fim_compatible
        -- ============================================================
        provider = "openai_compatible", -- 默认使用 OpenAI，可按需切换

        -- 各提供商的 API 配置
        provider_options = {
        --   -- Ollama (本地模型) 配置
        --   ollama = {
        --     -- Ollama 本地服务地址
        --     base_url = "http://localhost:11434",
        --     -- 使用的本地模型名称（需提前 ollama pull）
        --     model = "codellama:7b-code",
        --     max_tokens = 512,
        --     temperature = 0.3,
        --   },
          -- 兼容 OpenAI API 格式的第三方服务（如 DeepSeek、Azure 等）
          openai_compatible = {
            api_key = "DEEPSEEK_API_KEY",
            end_point = "https://api.deepseek.com/v1/chat/completions",
            name = "Deepseek",
            model = "deepseek-chat",
            max_tokens = 512,
            temperature = 0.3,
          },
        },

        -- ============================================================
        -- 4. 提示词与上下文配置
        -- ============================================================
        -- 发送给 LLM 的上下文行数（光标前后各 n 行）
        context_window = 128,

        -- 提示词模板（高级用户可自定义，一般保持默认即可）
        -- template = { ... },

        -- ============================================================
        -- 5. 请求与性能配置
        -- ============================================================
        -- 请求超时时间（毫秒）。LLM 响应较慢，建议设长一些
        request_timeout = 3000,

        -- 是否启用流式传输（streaming），即使模型响应慢也能逐步显示
        stream = true,

        -- 并发请求数
        n_completions = 1,

        -- ============================================================
        -- 6. 其他选项
        -- ============================================================
        -- 是否在状态栏显示当前请求状态
        notify = "debug", -- 可选: "off", "error", "warning", "info", "debug"

        -- 是否启用 debounce（防抖），避免输入时频繁请求
        debounce_ms = 150,
      })
    end,
  },

  -- ================================================================
  -- 可选依赖（按需启用，如果使用 virtual text 前端则不需要以下插件）
  -- ================================================================

  -- nvim-cmp 集成（如需通过 cmp 触发补全，取消下面块的注释）
  -- {
  --   "hrsh7th/nvim-cmp",
  --   dependencies = { "milanglacier/minuet-ai.nvim" },
  --   opts = function(_, opts)
  --     -- 将 minuet 加入 cmp 数据源
  --     table.insert(opts.sources, {
  --       name = "minuet",
  --       group_index = 1,
  --       priority = 100,
  --     })
  --
  --     -- 增加超时时间以适应 LLM 的慢速响应
  --     opts.performance = vim.tbl_deep_extend("force", opts.performance or {}, {
  --       fetching_timeout = 2000,
  --     })
  --
  --     -- 手动触发补全的快捷键（Alt+y）
  --     opts.mapping = vim.tbl_deep_extend("force", opts.mapping or {}, {
  --       ["<A-y>"] = require("minuet").make_cmp_map(),
  --     })
  --   end,
  -- },

  -- blink.cmp 集成（如需使用 blink 替代 nvim-cmp，取消下面块的注释）
  -- {
  --   "saghen/blink.cmp",
  --   optional = true,
  --   opts = {
  --     keymap = {
  --       -- 手动触发 minuet 补全
  --       ["<A-y>"] = {
  --         function(cmp)
  --           cmp.show({ providers = { "minuet" } })
  --         end,
  --       },
  --     },
  --     sources = {
  --       -- 自动补全模式下将 minuet 加入默认源
  --       default = { "minuet", "lsp", "path", "snippets", "buffer" },
  --       providers = {
  --         minuet = {
  --           name = "minuet",
  --           module = "minuet.blink",
  --           score_offset = 100, -- 提高 minuet 的排序权重
  --         },
  --       },
  --     },
  --   },
  -- },
}

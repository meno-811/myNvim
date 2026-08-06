-- 代码补全插件配置
-- 包括cmp和AI补全
-- cmp 是一个通用的补全引擎，支持从多个来源补全代码。
-- 例如，从 LSP 服务器、缓冲区、路径等补全代码。

return {
    -- ========== 代码补全引擎 ==========
    {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",       -- 桥接插件：让 nvim-cmp 能从 LSP（语言服务器）获取补全建议
      "hrsh7th/cmp-buffer",         -- 数据源：从当前打开的文件（缓冲区）中提取已有单词作为补全项
      "hrsh7th/cmp-path",           -- 数据源：补全文件系统路径（如输入 ./ 或 /usr/ 时提示目录内容）
      "L3MON4D3/LuaSnip",           -- 代码片段引擎：展开 LSP 补全项中的代码片段
      "hrsh7th/cmp-cmdline",           -- 命令行补全插件：在命令行模式下补全命令
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      
      -- ========== Insert 模式配置 nvim-cmp ==========
      cmp.setup({
        preselect = cmp.PreselectMode.None,
        completion = {
          completeopt = "menu,menuone,noinsert,noselect",
        },
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        -- 自定义映射按键行为
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),             -- Ctrl+B 向上滚动补全文档（浮动窗口）
          ['<C-f>'] = cmp.mapping.scroll_docs(4),             -- Ctrl+F 向下滚动补全文档（浮动窗口）
          ['<C-e>'] = cmp.mapping.abort(),                  -- Ctrl+E 关闭补全菜单
          ['<CR>'] = cmp.mapping(function(fallback)
            if cmp.visible() and cmp.get_selected_entry() then
              cmp.confirm({ select = false })
            else
              fallback()
            end
          end, { 'i', 's' }), -- 仅确认手动选择的候选项，否则正常换行
          -- Tab 仅用于代码片段占位符跳转，不参与补全项选择
          ['<Tab>'] = cmp.mapping(function(fallback)
            if luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
            else fallback() end          -- 否则 → 执行默认 Tab 行为（输入制表符）
          end, { 'i', 's' }),           -- 在插入模式（i）和选择模式（s）下生效
          ['<Up>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
          ['<Down>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
          -- ['<Esc>'] = cmp.mapping(function(fallback)
          --   if cmp.visible() then
          --     cmp.abort()
          --   else
          --     fallback()
          --   end
          -- end, { 'i', 's' }),
        }),
        -- 优先级：LSP -> Buffer -> Path
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
        }, {
          { name = 'buffer' },
          { name = 'path' },
        }),
      })
      -- ========== Cmdline 模式配置 nvim-cmp ==========
      ----------------------------------------------------------------------
      -- `/` 搜索模式：类似 zsh 的 buffer 补全
      ----------------------------------------------------------------------
      cmp.setup.cmdline("/", {
        mapping = {
          -- Tab：呼出补全 / 下一个候选项
          ["<Tab>"] = function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            else
              cmp.complete()
            end
          end,

          -- Shift-Tab：上一个候选项
          ["<S-Tab>"] = function()
            if cmp.visible() then
              cmp.select_prev_item()
            end
          end,

          -- Enter：确认但不退出搜索
          ["<CR>"] = cmp.mapping.confirm({ select = true }),

          -- 上下方向键：选择候选项（zsh 风格）
          ["<Down>"] = cmp.mapping.select_next_item(),
          ["<Up>"] = cmp.mapping.select_prev_item(),
        },

        sources = {
          { name = "buffer" },
        },
      })

      ----------------------------------------------------------------------
      -- `:` 命令模式：zsh 风格 path + cmdline 补全
      ----------------------------------------------------------------------
      cmp.setup.cmdline(":", {
        mapping = {
          ["<Tab>"] = function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            else
              cmp.complete()
            end
          end,

          ["<S-Tab>"] = function()
            if cmp.visible() then
              cmp.select_prev_item()
            end
          end,

          ["<CR>"] = cmp.mapping.confirm({ select = true }),

          ["<Down>"] = cmp.mapping.select_next_item(),
          ["<Up>"] = cmp.mapping.select_prev_item(),
        },

        sources = cmp.config.sources({
          { name = "path" },
        }, {
          {
            name = "cmdline",
            option = {
              ignore_cmds = { "Man", "!" },
              treat_trailing_slash = true,
            },
          },
        }),
      })
    end
  },
}

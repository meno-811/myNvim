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
      "L3MON4D3/LuaSnip",           -- 代码片段引擎：支持自定义/预定义的代码模板（如 for 循环、函数模板）
      "saadparwaiz1/cmp_luasnip",   -- 桥接插件：让 nvim-cmp 能把 LuaSnip 的片段当作补全项显示
      "hrsh7th/cmp-cmdline",           -- 命令行补全插件：在命令行模式下补全命令
      "hrsh7th/cmp-path",     -- 路径补全（命令行模式常用）
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      
      require("luasnip.loaders.from_vscode").lazy_load()  -- 加载 VSCode 格式的片段集合
      -- ========== Insert 模式配置 nvim-cmp ==========
      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        -- 自定义映射按键行为
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),             -- Ctrl+B 向上滚动补全文档（浮动窗口）
          ['<C-f>'] = cmp.mapping.scroll_docs(4),             -- Ctrl+F 向下滚动补全文档（浮动窗口）
          ['<C-Space>'] = cmp.mapping.complete(),          -- Ctrl+Space 手动触发补全
          ['<C-e>'] = cmp.mapping.abort(),                  -- Ctrl+E 关闭补全菜单
          ['<CR>'] = cmp.mapping.confirm({select = true }),  -- 回车键确认补全
        -- tab 键切换补全项
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item()    -- 如果补全菜单显示中 → 选择补全菜单中的下一项
            elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()    -- 如果光标在片段占位符上 → 展开/跳到下一占位符
            else fallback() end          -- 否则 → 执行默认 Tab 行为（输入制表符）
          end, { 'i', 's' }),           -- 在插入模式（i）和选择模式（s）下生效

          -- -- ========== Tab 智能补全行为 ==========
          -- ['<Tab>'] = cmp.mapping(function(fallback)
          --   if cmp.visible() then
          --     -- 补全菜单打开 → 选择下一项
          --     cmp.select_next_item()
          --   elseif luasnip.expand_or_jumpable() then
          --     -- snippet 可展开或可跳转 → 展开或跳转
          --     luasnip.expand_or_jump()
          --   else
          --     -- 否则执行默认 Tab（插入 Tab 或缩进）
          --     fallback()
          --   end
          -- end, { 'i', 's' }),
          -- -- Shift-Tab：选择上一项
          -- ['<S-Tab>'] = cmp.mapping(function(fallback)
          --   if cmp.visible() then
          --     cmp.select_prev_item()
          --   elseif luasnip.jumpable(-1) then
          --     luasnip.jump(-1)
          --   else
          --     fallback()
          --   end
          -- end, { 'i', 's' }),
          -- -- ========== 方向键选择补全项 ==========
          -- ['<Down>'] = cmp.mapping.select_next_item(),
          -- ['<Up>'] = cmp.mapping.select_prev_item(),
        }),
        -- 优先级：LSP -> LuaSnip -> Buffer -> Path
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
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
  
    -- ========== AI 自动补全 ==========
  -- {
  --   "github/copilot.vim",
  --   config = function()
  --     vim.g.copilot_no_tab_map = true
  --     vim.keymap.set('i', '<C-J>', 'copilot#Accept("<CR>")', { expr = true, silent = true })
  --     vim.keymap.set('i', '<C-]>', '<Plug>(copilot-next)')
  --     vim.keymap.set('i', '<C-[>', '<Plug>(copilot-previous)')
  --   end
  -- },
}

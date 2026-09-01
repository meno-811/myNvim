-- 编辑窗口右侧的细滚动条：显示当前位置、LSP 引用和诊断位置。
return {
  "petertriho/nvim-scrollbar",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = { "kevinhwang91/nvim-hlslens" },
  opts = {
    show_in_active_only = true,
    hide_if_all_visible = true,
    throttle_ms = 50,
    handle = {
      text = " ",
      blend = 35,
    },
    marks = {
      Cursor = { text = "┃", highlight = "CursorLineNr" },
      -- `*`、`#` 和 `/` 的纯文本搜索结果（与白色 LSP 语义引用区分）。
      Search = { text = { "━", "═" }, highlight = "ScrollbarTextSearch", priority = 1 },
      -- 自定义处理器会按密度选择第 1/2 个字符，因此这里必须是数组。
      Misc = { text = { "━", "═" }, highlight = "ScrollbarLspReference", priority = 2 },
    },
    excluded_buftypes = { "terminal", "prompt", "nofile" },
    excluded_filetypes = {
      "neo-tree",
      "dropbar_menu",
      "dropbar_menu_fzf",
      "lazy",
      "mason",
      "help",
    },
    handlers = {
      cursor = true,
      diagnostic = true,
      handle = true,
      -- 由 config 中的官方 hlslens 处理器启用，避免 setup 阶段重复注册。
      search = false,
      gitsigns = false,
    },
  },
  config = function(_, opts)
    local function set_reference_highlight()
      vim.api.nvim_set_hl(0, "ScrollbarLspReference", { fg = "#ffffff", bold = true })
      vim.api.nvim_set_hl(0, "ScrollbarTextSearch", { fg = "#ffd75f", bold = true })
    end

    set_reference_highlight()
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("ScrollbarLspReferenceHighlight", { clear = true }),
      callback = set_reference_highlight,
      desc = "保持 LSP 引用滚动条标记为亮白色",
    })

    require("scrollbar").setup(opts)

    -- 使用 nvim-scrollbar 官方 hlslens 处理器提供搜索位置，避免逐行扫描全文；
    -- override_lens 关闭 hlslens 自身的行尾计数，只保留滚动条标记。
    require("hlslens").setup({
      override_lens = function() end,
    })
    require("scrollbar.handlers.search").setup()

    -- hlslens 不会自动接管原生 `*`/`#`；按官方建议在搜索后启动 lens，
    -- 让黄色搜索标记持续保留在滚动条上，直到用户执行 :noh。
    vim.keymap.set("n", "*", [[*<Cmd>lua require("hlslens").start()<CR>]], {
      silent = true,
      desc = "向后搜索光标单词并持续标记滚动条",
    })
    vim.keymap.set("n", "#", [[#<Cmd>lua require("hlslens").start()<CR>]], {
      silent = true,
      desc = "向前搜索光标单词并持续标记滚动条",
    })

    -- Neovim 的 document_highlight 会把语义引用写入 nvim.lsp.references
    -- 命名空间；直接复用这些结果，避免把不同作用域的同名文本混在一起。
    local reference_namespace = vim.api.nvim_create_namespace("nvim.lsp.references")
    require("scrollbar.handlers").register("lsp_references", function(bufnr)
      local marks = {}
      local seen = {}

      for _, extmark in ipairs(vim.api.nvim_buf_get_extmarks(bufnr, reference_namespace, 0, -1, {})) do
        local line = extmark[2]
        if not seen[line] then
          seen[line] = true
          marks[#marks + 1] = { line = line, type = "Misc" }
        end
      end

      return marks
    end)

    -- 自定义处理器需要先 show() 更新缓存，render() 才能画出标记。
    _G.refresh_lsp_reference_scrollbar = function(bufnr)
      bufnr = bufnr == 0 and vim.api.nvim_get_current_buf() or bufnr
      if not vim.api.nvim_buf_is_valid(bufnr) then return end

      for _, win in ipairs(vim.fn.win_findbuf(bufnr)) do
        if vim.api.nvim_win_is_valid(win) then
          vim.api.nvim_win_call(win, function()
            require("scrollbar.handlers").show()
            require("scrollbar").render()
          end)
        end
      end
    end
  end,
}

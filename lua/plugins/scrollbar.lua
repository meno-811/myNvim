-- 编辑窗口右侧的细滚动条：显示当前位置、LSP 引用和诊断位置。
return {
  "petertriho/nvim-scrollbar",
  event = { "BufReadPost", "BufNewFile" },
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
      -- 搜索标记由下面的原生搜索同步逻辑维护，不依赖 hlslens。
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

    local function sync_native_search_marks()
      local bufnr = vim.api.nvim_get_current_buf()
      local utils = require("scrollbar.utils")
      local scrollbar_marks = utils.get_scrollbar_marks(bufnr)

      if vim.v.hlsearch == 0 or vim.fn.getreg("/") == "" then
        scrollbar_marks.search = nil
      else
        local pattern = vim.fn.getreg("/")
        local search_marks = {}

        -- 每个匹配行只需要一个滚动条标记；vim.fn.match 使用同一套 Vim 正则。
        for line, text in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
          local ok, column = pcall(vim.fn.match, text, pattern)
          if ok and column >= 0 then
            search_marks[#search_marks + 1] = {
              line = line - 1,
              text = "━",
              type = "Search",
              level = 1,
            }
          end
        end
        scrollbar_marks.search = search_marks
      end

      utils.set_scrollbar_marks(bufnr, scrollbar_marks)
      require("scrollbar").render()
    end

    local function native_word_search(key)
      vim.cmd.normal({ key, bang = true })
      vim.schedule(sync_native_search_marks)
    end

    vim.keymap.set("n", "*", function() native_word_search("*") end, {
      silent = true,
      desc = "向后搜索光标单词并标记滚动条",
    })
    vim.keymap.set("n", "#", function() native_word_search("#") end, {
      silent = true,
      desc = "向前搜索光标单词并标记滚动条",
    })

    vim.api.nvim_create_autocmd("CmdlineLeave", {
      group = vim.api.nvim_create_augroup("ScrollbarNativeSearch", { clear = true }),
      pattern = { "/", "?", ":" },
      callback = function()
        vim.schedule(sync_native_search_marks)
      end,
      desc = "同步 Neovim 搜索结果到滚动条",
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

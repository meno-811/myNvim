-- lsp.lua
-- Neovim 0.12+ 原生 LSP 配置

return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "gopls", "pyright", "lua_ls","rust_analyzer" },
      })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      -- cmp-nvim-lsp 默认已经包含 semantic tokens 的 capabilities
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- 查找引用时不包含声明；若只有一个结果则直接跳转，多个结果再打开列表。
      local function smart_references()
        vim.lsp.buf.references({ includeDeclaration = false }, {
          on_list = function(options)
            local items = options.items or {}

            if #items == 0 then
              vim.notify("No references found", vim.log.levels.INFO)
              return
            end

            if #items == 1 then
              local item = items[1]
              local target_buf = vim.fn.bufadd(item.filename)
              vim.fn.bufload(target_buf)

              -- 把当前位置加入跳转列表，以便用 <C-o> 返回。
              vim.cmd("normal! m'")
              vim.api.nvim_win_set_buf(0, target_buf)
              vim.api.nvim_win_set_cursor(0, { item.lnum, math.max(item.col - 1, 0) })
              vim.cmd("normal! zv")
              return
            end

            vim.fn.setqflist({}, " ", options)
            vim.cmd("copen")

            -- 引用结果只作为临时选择窗口：回车跳转后立即关闭列表。
            -- 映射仅绑定到本次 quickfix buffer，不影响其他窗口。
            vim.keymap.set("n", "<CR>", function()
              vim.cmd("cc")
              vim.cmd("cclose")
            end, {
              buffer = 0,
              silent = true,
              desc = "Jump to reference and close results",
            })
          end,
        })
      end

      -- ========== LspAttach：按键映射 ==========
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
        callback = function(args)
          local bufnr = args.buf
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client then return end

          local map = function(mode, lhs, rhs, desc, opts)
            vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("force", {
              buffer = bufnr,
              silent = true,
              desc = desc,
            }, opts or {}))
          end

          map("n", "gd", vim.lsp.buf.definition, "Go to Definition")
          map("n", "gD", vim.lsp.buf.declaration, "Go to Declaration")
          -- Neovim 0.12 内置了 gra/grn/grr 等映射。若不设置 nowait，
          -- 按下 gr 后会等待 timeoutlen，确认用户是否还要输入第三个键。
          map("n", "gr", smart_references, "Go to References", { nowait = true })
          map("n", "gi", vim.lsp.buf.implementation, "Go to Implementation")
          map("n", "K", vim.lsp.buf.hover, "Hover")
          map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
          map("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")
          map("n", "[d", vim.diagnostic.goto_prev, "Prev Diagnostic")
          map("n", "]d", vim.diagnostic.goto_next, "Next Diagnostic")
          -- map("n", "<leader>e", vim.diagnostic.open_float, "Line Diagnostic")

          -- 光标停在符号上时，高亮当前符号及文档内的其他引用。
          if client:supports_method("textDocument/documentHighlight") then
            local highlight_group = vim.api.nvim_create_augroup("LspDocumentHighlight_" .. bufnr, { clear = true })

            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              group = highlight_group,
              buffer = bufnr,
              callback = function()
                vim.lsp.buf.document_highlight()
                -- LSP 请求是异步的；Rust Analyzer 处理大文件时可能稍慢，
                -- 分阶段刷新以确保引用 extmark 返回后能投影到滚动条。
                for _, delay in ipairs({ 80, 200, 500, 1000 }) do
                  vim.defer_fn(function()
                    if _G.refresh_lsp_reference_scrollbar then
                      _G.refresh_lsp_reference_scrollbar(bufnr)
                    end
                  end, delay)
                end
              end,
            })

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              group = highlight_group,
              buffer = bufnr,
              callback = function()
                vim.lsp.buf.clear_references()
                if _G.refresh_lsp_reference_scrollbar then
                  _G.refresh_lsp_reference_scrollbar(bufnr)
                end
              end,
            })

            vim.api.nvim_create_autocmd("LspDetach", {
              group = highlight_group,
              buffer = bufnr,
              callback = function(detach_args)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds({
                  group = highlight_group,
                  buffer = detach_args.buf,
                })
              end,
            })
          end
        end,
      })

      -- ========== Go ==========
      -- 关键修正：semanticTokens 直接放在 gopls 下，不是 ui.semanticTokens
      vim.lsp.config("gopls", {
        capabilities = capabilities,
        settings = {
          gopls = {
            semanticTokens = true,        -- ← 直接这里开，不要套 ui = {}
            analyses = {
              unusedparams = true,
              shadow = true,
            },
            staticcheck = true,
            gofumpt = true,
          },
        },
      })

      -- ========== Python ==========
      vim.lsp.config("pyright", {
        capabilities = capabilities,
        settings = {
          python = {
            analysis = {
              diagnosticMode = "workspace",
            },
          },
        },
      })

      -- ========== Rust ==========
      vim.lsp.config("rust_analyzer", {
        capabilities = capabilities,
        settings = {
          ["rust-analyzer"] = {
            completion = {
              -- 补全函数时只添加括号，不自动生成并选中参数名占位符。
              callable = { snippets = "add_parentheses" },
            },
          },
        },
      })

      -- ========== Lua ==========
      vim.lsp.config("lua_ls", {
        capabilities = capabilities,
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            workspace = {
              checkThirdParty = false,
              library = {
                vim.env.VIMRUNTIME,
                "${3rd}/luv/library",
              },
            },
          },
        },
      })
    end,
  },
}

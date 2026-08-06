-- lsp.lua
-- Neovim 0.12+ 原生 LSP 配置

vim.diagnostic.config({
  update_in_insert = true,
  virtual_text = true,
  signs = true,
  underline = true,
  severity_sort = true,
})

-- 插入模式只保留诊断下划线，离开插入模式后再显示行尾错误原因。
local diagnostic_display_group = vim.api.nvim_create_augroup("DiagnosticDisplayByMode", { clear = true })

vim.api.nvim_create_autocmd("InsertEnter", {
  group = diagnostic_display_group,
  callback = function()
    vim.diagnostic.config({ virtual_text = false })
  end,
})

vim.api.nvim_create_autocmd("InsertLeave", {
  group = diagnostic_display_group,
  callback = function()
    vim.diagnostic.config({ virtual_text = true })
  end,
})

return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup({
        registries = { "github:mason-org/mason-registry" },
      })
    end,
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "gopls", "pyright", "lua_ls" },
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

      -- ========== LspAttach：按键映射 ==========
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
        callback = function(args)
          local bufnr = args.buf
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client then return end

          local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
          end

          map("n", "gd", vim.lsp.buf.definition, "Go to Definition")
          map("n", "gD", vim.lsp.buf.declaration, "Go to Declaration")
          map("n", "gr", vim.lsp.buf.references, "Go to References")
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
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              group = highlight_group,
              buffer = bufnr,
              callback = vim.lsp.buf.clear_references,
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
        cmd = { "gopls" },
        filetypes = { "go", "gomod", "gowork", "gotmpl" },
        root_markers = { "go.mod", "go.work", ".git" },
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
      vim.lsp.enable("gopls")

      -- ========== Python ==========
      vim.lsp.config("pyright", {
        cmd = { "pyright-langserver", "--stdio" },
        filetypes = { "python" },
        root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile", ".git" },
        capabilities = capabilities,
        settings = {
          python = {
            analysis = {
              diagnosticMode = "workspace",
            },
          },
        },
      })
      vim.lsp.enable("pyright")

      -- ========== Lua ==========
      vim.lsp.config("lua_ls", {
        cmd = { "lua-language-server" },
        filetypes = { "lua" },
        root_markers = { ".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", "stylua.toml", ".git" },
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
      vim.lsp.enable("lua_ls")
    end,
  },
}

-- ============================================
-- Neovim IDE 配置（Neovim 0.11+ 兼容版）
-- ============================================

-- 基础设置
vim.g.lazygit_timeout = 900
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.termguicolors = true
vim.opt.mouse = 'a'
vim.opt.clipboard = 'unnamedplus'
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.cursorline = true

-- 快捷键前缀
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
-- Ctrl+S 保存（需要终端支持）
vim.keymap.set('n', '<C-s>', ':w<CR>', { silent = true })
vim.keymap.set('i', '<C-s>', '<Esc>:w<CR>a', { silent = true }) -- 插入模式下也可保存

-- LSP配置
vim.diagnostic.config({
  -- 在插入模式下也更新诊断
  update_in_insert = true,

  -- 其他可选配置
  virtual_text = true,        -- 在行尾显示错误信息
  signs = true,               -- 在行号旁显示错误图标
  underline = true,           -- 在错误代码下划线
  severity_sort = true,       -- 按严重程度排序
})

-- 插件配置
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- ========== 主题 ==========
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme "catppuccin-mocha"
    end
  },

  -- ========== 文件树 ==========
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup()
      vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>')
    end
  },

  -- ========== Fuzzy 查找 ==========
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local telescope = require("telescope")
      telescope.setup()
      vim.keymap.set('n', '<leader>ff', ':Telescope find_files<CR>')
      vim.keymap.set('n', '<leader>fg', ':Telescope live_grep<CR>')
      vim.keymap.set('n', '<leader>fb', ':Telescope buffers<CR>')
    end
  },

  -- ========== LSP 配置（Neovim 0.11+ 原生方式）==========
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup({
        -- 国内镜像加速（可选）
        registries = {
          "github:mason-org/mason-registry",
        },
      })
    end
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "gopls", "lua_ls", "pyright", "rust_analyzer" },
        automatic_installation = false, -- 手动控制安装
      })
    end
  },

  -- nvim-lspconfig 仅用于提供服务器配置，不再使用 lspconfig.xxx.setup()
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      -- Neovim 0.11+ 原生 LSP 配置方式
      -- 使用 vim.lsp.config 替代 lspconfig.xxx.setup()

      -- Go 语言支持
      vim.lsp.config.gopls = {
        cmd = { "gopls" },
        filetypes = { "go", "gomod", "gowork", "gotmpl" },
        root_markers = { "go.mod", "go.work", ".git" },
        capabilities = capabilities,
        settings = {
          gopls = {
            analyses = { unusedparams = true },
            staticcheck = true,
            gofumpt = true,
          }
        }
      }
      vim.lsp.enable('gopls')

      -- Lua 语言支持
      vim.lsp.config.lua_ls = {
        cmd = { "lua-language-server" },
        filetypes = { "lua" },
        root_markers = { ".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", "stylua.toml", "selene.toml", "selene.yml", ".git" },
        capabilities = capabilities,
        settings = {
          Lua = {
            runtime = { version = 'LuaJIT' },
            workspace = {
              checkThirdParty = false,
              library = {
                vim.env.VIMRUNTIME,
                "${3rd}/luv/library"
              }
            }
          }
        }
      }
      vim.lsp.enable('lua_ls')

      -- Python 支持
      vim.lsp.config.pyright = {
        cmd = { "pyright-langserver", "--stdio" },
        filetypes = { "python" },
        root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile", ".git" },
        capabilities = capabilities,
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              diagnosticMode = "openFilesOnly",
              useLibraryCodeForTypes = true
            }
          }
        }
      }
      vim.lsp.enable('pyright')

      -- Rust 支持
      vim.lsp.config.rust_analyzer = {
        cmd = { "rust-analyzer" },
        filetypes = { "rust" },
        root_markers = { "Cargo.toml", "rust-project.json", ".git" },
        capabilities = capabilities,
      }
      vim.lsp.enable('rust_analyzer')

      -- LSP 快捷键
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition)
      vim.keymap.set('n', 'gr', vim.lsp.buf.references)
      vim.keymap.set('n', 'K', vim.lsp.buf.hover)
      vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename)
      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action)
      vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format({ async = true }) end)
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

  -- ========== 代码补全引擎 ==========
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
            else fallback() end
          end, { 'i', 's' }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
        }, {
          { name = 'buffer' },
          { name = 'path' },
        }),
      })
    end
  },

  -- ========== 语法高亮（Treesitter）==========
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    branch = "main", -- 使用 main 分支
    config = function()
      -- 新 API 方式加载
      local ok, treesitter = pcall(require, "nvim-treesitter")
      if ok then
        -- 新版本 API
        treesitter.setup({
          ensure_installed = { "go", "lua", "python", "rust", "javascript", "typescript", "bash", "dockerfile" },
          highlight = { enable = true },
          indent = { enable = true },
        })
      else
        -- 回退到旧版本 configs API
        require("nvim-treesitter.configs").setup({
          ensure_installed = { "go", "lua", "python", "rust", "javascript", "typescript", "bash", "dockerfile" },
          highlight = { enable = true },
          indent = { enable = true },
        })
      end
    end
  },

  -- ========== 状态栏 & 缓冲区 ==========
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = { theme = 'catppuccin' }
      })
    end
  },
  {
    "akinsho/bufferline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("bufferline").setup({})
      vim.keymap.set('n', '<Tab>', ':BufferLineCycleNext<CR>')
      vim.keymap.set('n', '<S-Tab>', ':BufferLineCyclePrev<CR>')
      vim.keymap.set('n', '<leader>q', ':bd<CR>')
    end
  },

  -- ========== 终端集成 ==========
  {
    "akinsho/toggleterm.nvim",
    config = function()
      require("toggleterm").setup({
        size = 20,
        open_mapping = [[<c-\>]],
        direction = 'float',
      })
    end
  },

  -- ========== Git 集成 ==========
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
    end
  },
})

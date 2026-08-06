-- 项目的 Neovim 核心配置入口。
-- 插件自身的设置仍放在各插件文件中；编辑器级选项、映射、自动命令、
-- 诊断和 Treesitter 统一由 AstroCore 管理。

return {
    "AstroNvim/astrocore",
    dependencies = {
        {
            "nvim-mini/mini.nvim",
            config = function() require("mini.bufremove").setup() end,
        },
    },
    ---@param opts AstroCoreOpts
    opts = function(_, opts)
        local astro = require "astrocore"
        local maps = astro.empty_map_table()

        local function close_current_view()
            if vim.bo.buftype == "quickfix" then
                local wininfo = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1]
                vim.cmd(wininfo and wininfo.loclist == 1 and "lclose" or "cclose")
            else
                require("mini.bufremove").delete(0, false)
            end
        end

        -- Split navigation
        maps.n["<C-Left>"] = { "<C-w>h", desc = "Move to left split" }
        maps.n["<C-Down>"] = { "<C-w>j", desc = "Move to below split" }
        maps.n["<C-Up>"] = { "<C-w>k", desc = "Move to above split" }
        maps.n["<C-Right>"] = { "<C-w>l", desc = "Move to right split" }
        maps.n["<C-K>"] = { "<Cmd>resize -2<CR>", desc = "Resize split up" }
        maps.n["<C-J>"] = { "<Cmd>resize +2<CR>", desc = "Resize split down" }
        maps.n["<C-H>"] = { "<Cmd>vertical resize -2<CR>", desc = "Resize split left" }
        maps.n["<C-L>"] = { "<Cmd>vertical resize +2<CR>", desc = "Resize split right" }
        maps.n["<Tab>"] = { "<Cmd>BufferLineCycleNext<CR>", desc = "Next buffer" }
        maps.n["<S-Tab>"] = { "<Cmd>BufferLineCyclePrev<CR>", desc = "Previous buffer" }
        maps.n["<Leader>q"] = {
            close_current_view,
            desc = "Close current view",
        }
        for index = 1, 9 do
            maps.n["<Leader>" .. index] = {
                "<Cmd>BufferLineGoToBuffer " .. index .. "<CR>",
                desc = "Go to buffer " .. index,
            }
        end

        maps.i["<Left>"] = {
            function()
                return vim.fn.pumvisible() == 1 and "<Left>" or "<C-o>h"
            end,
            expr = true,
            silent = true,
            desc = "Move left across line boundaries",
        }
        maps.i["<Right>"] = {
            function()
                return vim.fn.pumvisible() == 1 and "<Right>" or "<C-o>l"
            end,
            expr = true,
            silent = true,
            desc = "Move right across line boundaries",
        }

        opts.mappings = maps

        opts.options = {
            opt = {
                number = true,
                relativenumber = true,
                cursorline = true,
                signcolumn = "yes",
                termguicolors = true,
                scrolloff = 8,
                updatetime = 300,
                expandtab = true,
                tabstop = 4,
                shiftwidth = 4,
                smartindent = true,
                ignorecase = true,
                smartcase = true,
                incsearch = true,
                virtualedit = "onemore",
                whichwrap = "b,s,<,>,h,l",
                mouse = "a",
                clipboard = "unnamedplus",
            },
        }

        opts.diagnostics = {
            update_in_insert = true,
            virtual_text = true,
            signs = true,
            underline = true,
            severity_sort = true,
        }

        opts.autocmds = {
            code_wrap = {
                {
                    event = "FileType",
                    pattern = { "lua", "python", "javascript", "go", "rust" },
                    desc = "Disable wrapping in code buffers",
                    callback = function() vim.opt_local.wrap = false end,
                },
            },
            text_wrap = {
                {
                    event = "FileType",
                    pattern = { "markdown", "text", "vimwiki" },
                    desc = "Enable readable wrapping in text buffers",
                    callback = function()
                        vim.opt_local.wrap = true
                        vim.opt_local.linebreak = true
                    end,
                },
            },
            diagnostics_by_mode = {
                {
                    event = "InsertEnter",
                    desc = "Hide diagnostic messages while typing",
                    callback = function() vim.diagnostic.config { virtual_text = false } end,
                },
                {
                    event = "InsertLeave",
                    desc = "Show diagnostic messages outside insert mode",
                    callback = function() vim.diagnostic.config { virtual_text = true } end,
                },
            },
        }

        -- 使用 AstroCore 对 nvim-treesitter main 分支的新 API 适配。
        -- 它会负责安装解析器，并按文件类型启用高亮、缩进和文本对象。
        opts.treesitter = {
            enabled = true,
            highlight = true,
            indent = true,
            ensure_installed = { "lua", "vim", "vimdoc", "bash", "markdown", "json", "go", "python" },
            auto_install = true,
            textobjects = {
                select = {
                    select_textobject = {
                        ["af"] = { query = "@function.outer", desc = "Select around function" },
                        ["if"] = { query = "@function.inner", desc = "Select inside function" },
                        ["ac"] = { query = "@class.outer", desc = "Select around class" },
                        ["ic"] = { query = "@class.inner", desc = "Select inside class" },
                    },
                },
            },
        }
    end,
}

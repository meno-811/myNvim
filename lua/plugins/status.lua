-- 状态栏 & 缓冲区


return{
    -- Buffer 关闭和通用窗口缩放依赖 Snacks；快捷键和插件一起注册。
    {
        "folke/snacks.nvim",
        keys = {
            {
                "<A-x>",
                function() Snacks.zen.zoom() end,
                mode = { "n", "i", "v", "t" },
                desc = "Toggle window zoom",
            },
            { "<Leader>q", function() require("utils.buffer").close_view() end, desc = "Close current view" },
            { "<Leader>ba", function() require("utils.buffer").close_all() end, desc = "Close all buffers" },
            { "<Leader>bo", function() require("utils.buffer").close_others() end, desc = "Close other buffers" },
        },
    },
    -- lualine.nvim,  美化并增强底部状态栏，显示当前模式、文件路径、Git 分支、文件编码、行号等信息。
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("lualine").setup({
                options = { theme = 'catppuccin-nvim' }
            })
        end
    },
    -- bufferline.nvim  在顶部显示已打开文件的标签页（类似 VS Code 的标签栏），支持鼠标点击、图标显示、诊断标记等。
    {
        "akinsho/bufferline.nvim",
        lazy = false, -- 启动即显示标签栏，避免 keys 使插件仅在首次切换时加载。
        dependencies = { "nvim-tree/nvim-web-devicons", "folke/snacks.nvim" },
        keys = function()
            local keys = {}
            for index = 1, 9 do
                keys[#keys + 1] = {
                    "<Leader>" .. index,
                    "<Cmd>BufferLineGoToBuffer " .. index .. "<CR>",
                    desc = "Go to buffer " .. index,
                }
            end
            return keys
        end,
        config = function()
            local position = 0
            local function record(buf)
                position = position + 1
                vim.b[buf].bufferline_position = position
            end
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                if vim.bo[buf].buflisted then record(buf) end
            end
            vim.api.nvim_create_autocmd("BufAdd", {
                group = vim.api.nvim_create_augroup("user_bufferline_order", { clear = true }),
                callback = function(event) record(event.buf) end,
            })
            require("bufferline").setup({
                options = {
                    -- 禁止从会话恢复手动排列；否则 custom_sort 会覆盖 sort_by。
                    persist_buffer_sort = false,
                    -- Reopening a deleted buffer can reuse its old ID.
                    sort_by = function(a, b)
                        return vim.b[a.id].bufferline_position < vim.b[b.id].bufferline_position
                    end,
                    -- Bufferline builds number labels before applying sort_by.
                    numbers = function(buffer)
                        local rank = 1
                        local position = vim.b[buffer.id].bufferline_position
                        for _, buf in ipairs(require("bufferline.utils").get_valid_buffers()) do
                            if vim.b[buf].bufferline_position < position then rank = rank + 1 end
                        end
                        return tostring(rank)
                    end,
    
                    -- 当前 buffer 高亮样式
                    indicator = {
                        style = "underline",  -- 下划线标记当前: underline | icon | none
                        icon = "▎",
                    },
    
                    -- 未保存修改指示
                    modified_icon = "●",
    
                    -- 分隔符样式
                    separator_style = "slant",  -- slant | padded_slant | thick | thin
    
                    -- 是否总是显示 tabline
                    always_show_bufferline = true,

                    -- 鼠标叉号和右键统一使用可回收替代 buffer 的关闭逻辑。
                    close_command = function(bufnr)
                        require("utils.buffer").close(bufnr)
                    end,
                    right_mouse_command = function(bufnr)
                        require("utils.buffer").close(bufnr)
                    end,
                },
  
                -- 自定义颜色（可选，适配你的主题）
                highlights = {
                    buffer_selected = {
                        bold = true,
                        italic = false,
                        fg = "#ffffff",
                    },
                    buffer_visible = {
                        fg = "#888888",
                    },
                    -- buffer_hidden = {
                    --     fg = "#555555",
                    -- },
                    modified_selected = {
                        fg = "#ff9e64",
                    }
                }
            })

        end
    },
}

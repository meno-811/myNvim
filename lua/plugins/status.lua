-- 状态栏 & 缓冲区


return{
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
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("bufferline").setup({
                options = {
                    -- 显示 buffer 编号，方便用数字切换
                    numbers = "ordinal",  -- 显示 1, 2, 3...
                    -- numbers = "buffer_id",  -- 显示真实 buffer id
    
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
            vim.keymap.set('n', '<Tab>', ':BufferLineCycleNext<CR>')    -- Tab 切换到下一个标签页
            vim.keymap.set('n', '<S-Tab>', ':BufferLineCyclePrev<CR>')    -- Shift-Tab 切换到上一个标签页
            -- vim.keymap.set('n', '<leader>q', ':bd<CR>')    -- leader+q 关闭当前标签页,目前leader是空格键
            vim.keymap.set('n', '<leader>q', ':confirm bd<CR>', { silent = true })
            -- 用于指定切换标签页
            vim.keymap.set("n", "<leader>1", "<Cmd>BufferLineGoToBuffer 1<CR>")
            vim.keymap.set("n", "<leader>2", "<Cmd>BufferLineGoToBuffer 2<CR>")
            vim.keymap.set("n", "<leader>3", "<Cmd>BufferLineGoToBuffer 3<CR>")
            vim.keymap.set("n", "<leader>4", "<Cmd>BufferLineGoToBuffer 4<CR>")
            vim.keymap.set("n", "<leader>5", "<Cmd>BufferLineGoToBuffer 5<CR>")
            vim.keymap.set("n", "<leader>6", "<Cmd>BufferLineGoToBuffer 6<CR>")
            vim.keymap.set("n", "<leader>7", "<Cmd>BufferLineGoToBuffer 7<CR>")
            vim.keymap.set("n", "<leader>8", "<Cmd>BufferLineGoToBuffer 8<CR>")
            vim.keymap.set("n", "<leader>9", "<Cmd>BufferLineGoToBuffer 9<CR>")
        end
    },
}

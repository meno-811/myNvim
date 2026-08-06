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

            local function close_current_buffer()
                local target = vim.api.nvim_get_current_buf()
                local replacement
                local alternate = vim.fn.bufnr("#")

                -- 优先回到上一个普通文件 buffer；否则选择任意其他普通文件
                -- buffer。先切换再删除，避免窗口短暂落到 Neo-tree 后触发退出。
                if alternate > 0
                    and alternate ~= target
                    and vim.api.nvim_buf_is_loaded(alternate)
                    and vim.bo[alternate].buflisted
                    and vim.bo[alternate].buftype == ""
                then
                    replacement = alternate
                else
                    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
                        if bufnr ~= target
                            and vim.api.nvim_buf_is_loaded(bufnr)
                            and vim.bo[bufnr].buflisted
                            and vim.bo[bufnr].buftype == ""
                        then
                            replacement = bufnr
                            break
                        end
                    end
                end

                local target_windows = vim.fn.win_findbuf(target)
                if replacement then
                    for _, winid in ipairs(target_windows) do
                        if vim.api.nvim_win_is_valid(winid) then
                            vim.api.nvim_win_set_buf(winid, replacement)
                        end
                    end
                end

                local ok, err = pcall(vim.cmd, "confirm bdelete " .. target)
                local delete_cancelled = vim.api.nvim_buf_is_loaded(target) and vim.bo[target].buflisted

                -- 用户取消关闭或删除失败时，恢复原先显示当前文件的窗口。
                if not ok or delete_cancelled then
                    for _, winid in ipairs(target_windows) do
                        if vim.api.nvim_win_is_valid(winid) and vim.api.nvim_buf_is_valid(target) then
                            vim.api.nvim_win_set_buf(winid, target)
                        end
                    end
                    if not ok then
                        vim.notify(err, vim.log.levels.ERROR)
                    end
                end
            end

            -- 关闭最后一个文件后，Neovim 会创建一个新的 [No Name] buffer。
            -- 如果它被移动过光标或进入过插入模式，之后从 Neo-tree 打开文件时，
            -- Neo-tree 可能会保留它并新建一个文件 buffer。真实文件读入后清理这种
            -- 完全空白且未修改的旧 buffer，保持首次打开文件时的替换行为一致。
            local cleanup_group = vim.api.nvim_create_augroup("cleanup_empty_unnamed_buffers", { clear = true })
            vim.api.nvim_create_autocmd("BufReadPost", {
                group = cleanup_group,
                callback = function(args)
                    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
                        if bufnr ~= args.buf
                            and vim.api.nvim_buf_is_valid(bufnr)
                            and vim.bo[bufnr].buflisted
                            and vim.bo[bufnr].buftype == ""
                            and vim.api.nvim_buf_get_name(bufnr) == ""
                            and not vim.bo[bufnr].modified
                            and vim.fn.bufwinid(bufnr) == -1
                            and vim.api.nvim_buf_line_count(bufnr) == 1
                            and vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] == ""
                        then
                            vim.api.nvim_buf_delete(bufnr, { force = false })
                        end
                    end
                end,
            })

            vim.keymap.set('n', '<Tab>', ':BufferLineCycleNext<CR>')    -- Tab 切换到下一个标签页
            vim.keymap.set('n', '<S-Tab>', ':BufferLineCyclePrev<CR>')    -- Shift-Tab 切换到上一个标签页
            -- vim.keymap.set('n', '<leader>q', ':bd<CR>')    -- leader+q 关闭当前标签页,目前leader是空格键
            vim.keymap.set('n', '<leader>q', close_current_buffer, { silent = true, desc = "Close current buffer" })
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

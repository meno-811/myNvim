local messages_win = nil

vim.api.nvim_create_user_command("MessagesBuffer", function()
    -- 再次执行命令时关闭窗口
    if messages_win and vim.api.nvim_win_is_valid(messages_win) then
        vim.api.nvim_win_close(messages_win, true)
        messages_win = nil
        return
    end

    local messages = vim.fn.execute("messages")
    local lines = vim.split(messages, "\n", { plain = true })
    local buf = vim.api.nvim_create_buf(false, true)

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
    vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })

    local width = math.max(1, vim.o.columns - 4)
    local max_height = math.max(5, math.floor(vim.o.lines * 0.35))
    local height = math.min(math.max(#lines, 5), max_height)

    messages_win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        row = 1,
        col = 2,
        width = width,
        height = height,
        style = "minimal",
        border = "rounded",
        title = " Messages ",
        title_pos = "center",
        zindex = 60,
    })

    vim.api.nvim_set_option_value("wrap", false, { win = messages_win })

    -- 默认定位到最新消息
    vim.api.nvim_win_set_cursor(messages_win, { math.max(#lines, 1), 0 })

    local close = function()
        if messages_win and vim.api.nvim_win_is_valid(messages_win) then
            vim.api.nvim_win_close(messages_win, true)
        end
        messages_win = nil
    end

    for _, key in ipairs({ "q", "<Esc>" }) do
        vim.keymap.set("n", key, close, {
            buffer = buf,
            silent = true,
            desc = "关闭消息窗口",
        })
    end
end, {
    desc = "在顶部浮动窗口中显示消息记录",
})

local readme_win = nil

-- 在只读浮窗中显示这套 Neovim 配置自己的 README，
-- 不受当前工作目录或正在编辑的代码项目影响。
vim.api.nvim_create_user_command("Readme", function()
    if readme_win and vim.api.nvim_win_is_valid(readme_win) then
        vim.api.nvim_win_close(readme_win, true)
        readme_win = nil
        return
    end

    local readme = nil
    for _, name in ipairs({ "README.md", "ReadMe.md", "readme.md" }) do
        local candidate = vim.fs.joinpath(vim.fn.stdpath("config"), name)
        if vim.uv.fs_stat(candidate) then
            readme = candidate
            break
        end
    end

    if not readme then
        vim.notify("Neovim 配置目录中没有 README.md", vim.log.levels.WARN)
        return
    end

    local lines = vim.fn.readfile(readme)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].filetype = "markdown"
    vim.bo[buf].modifiable = false
    vim.bo[buf].bufhidden = "wipe"

    local width = math.max(20, math.floor(vim.o.columns * 0.8))
    local height = math.max(8, math.floor(vim.o.lines * 0.8))
    readme_win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        row = math.floor((vim.o.lines - height) / 2),
        col = math.floor((vim.o.columns - width) / 2),
        width = width,
        height = height,
        style = "minimal",
        border = "rounded",
        title = " README.md ",
        title_pos = "center",
    })

    vim.wo[readme_win].wrap = true
    vim.wo[readme_win].linebreak = true

    local close = function()
        if readme_win and vim.api.nvim_win_is_valid(readme_win) then
            vim.api.nvim_win_close(readme_win, true)
        end
        readme_win = nil
    end

    for _, key in ipairs({ "q", "<Esc>" }) do
        vim.keymap.set("n", key, close, {
            buffer = buf,
            silent = true,
            desc = "关闭 README 窗口",
        })
    end
end, {
    desc = "在浮动窗口中显示 Neovim 配置 README",
})

-- 用户命令必须以大写字母开头；仅在完整输入 :readme 时展开为 :Readme。
vim.cmd([[cnoreabbrev <expr> readme getcmdtype() ==# ':' && getcmdline() ==# 'readme' ? 'Readme' : 'readme']])

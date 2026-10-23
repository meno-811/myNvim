local messages_win = nil

vim.api.nvim_create_user_command("Loadenv", function(opts)
    local path = vim.fn.fnamemodify(vim.fn.expand(opts.args), ":p")
    if vim.fn.filereadable(path) ~= 1 then
        error("Loadenv: 文件不可读: " .. path)
    end
    local bash = "bash"
    -- Windows 的 bash 别名可能指向 WSL；优先使用本机 Git Bash。
    if vim.fn.has("win32") == 1 then
        local git_bash = (vim.env.ProgramFiles or "C:/Program Files") .. "/Git/bin/bash.exe"
        if vim.fn.executable(git_bash) == 1 then
            bash = git_bash
        end
    end
    local result = vim.system({ bash, "--noprofile", "--norc", "-c", [[
env -0
set -a
source "$1" >&2 || exit $?
printf '\0'
env -0
]], "Loadenv", path }, { text = false }):wait()
    local before, after = result.stdout:match("^(.-)%z%z(.*)$")
    if result.code ~= 0 or not before or after == "" then
        error("Loadenv: 加载失败: " .. (result.stderr or ""))
    end
    local function parse(data)
        local env = {}
        for entry in data:gmatch("[^%z]+") do
            local key, value = entry:match("^([^=]+)=(.*)$")
            if key then
                env[key] = value
            end
        end
        return env
    end
    local old, new = parse(before), parse(after)
    for key, value in pairs(new) do
        if value ~= old[key] then
            vim.env[key] = value
        end
    end
    for key in pairs(old) do
        if new[key] == nil then
            vim.env[key] = nil
        end
    end
    vim.notify("Loadenv: 已加载 " .. path)
end, { nargs = 1, complete = "file", desc = "加载当前 Neovim 会话的环境变量" })

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

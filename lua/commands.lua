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

local function readonly_float(lines, opts)
    return require("snacks").win(vim.tbl_deep_extend("force", {
        text = lines,
        minimal = true,
        border = "rounded",
        title_pos = "center",
        bo = { modifiable = false, bufhidden = "wipe" },
        keys = { ["<Esc>"] = "close", ["<Leader>q"] = "close" },
    }, opts))
end

vim.api.nvim_create_user_command("MessagesBuffer", function()
    if messages_win and messages_win:valid() then
        messages_win:close()
        return
    end

    local lines = vim.split(vim.fn.execute("messages"), "\n", { plain = true })
    messages_win = readonly_float(lines, {
        row = 1,
        col = 2,
        width = math.max(1, vim.o.columns - 4),
        height = math.min(math.max(#lines, 5), math.max(5, math.floor(vim.o.lines * 0.35))),
        title = " Messages ",
        zindex = 60,
        wo = { wrap = false },
    })
    vim.api.nvim_win_set_cursor(messages_win.win, { math.max(#lines, 1), 0 })
end, {
    desc = "在顶部浮动窗口中显示消息记录",
})

local readme_win = nil

-- 在只读浮窗中显示这套 Neovim 配置自己的 README，
-- 不受当前工作目录或正在编辑的代码项目影响。
vim.api.nvim_create_user_command("Readme", function()
    if readme_win and readme_win:valid() then
        readme_win:close()
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

    local width = math.max(20, math.floor(vim.o.columns * 0.8))
    local height = math.max(8, math.floor(vim.o.lines * 0.8))
    readme_win = readonly_float(vim.fn.readfile(readme), {
        row = math.floor((vim.o.lines - height) / 2),
        col = math.floor((vim.o.columns - width) / 2),
        width = width,
        height = height,
        title = " README.md ",
        bo = { filetype = "markdown" },
        wo = { wrap = true, linebreak = true },
    })
end, {
    desc = "在浮动窗口中显示 Neovim 配置 README",
})

-- 用户命令必须以大写字母开头；仅在完整输入 :readme 时展开为 :Readme。
vim.cmd([[cnoreabbrev <expr> readme getcmdtype() ==# ':' && getcmdline() ==# 'readme' ? 'Readme' : 'readme']])

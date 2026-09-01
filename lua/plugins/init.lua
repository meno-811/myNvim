-- =================================================
-- 插件管理
-- =================================================

-- ===============================安装插件管理====================================
-- 构造一个标准的安装路径
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- 如果插件不存在，就用git克隆它
if not vim.uv.fs_stat(lazypath) then
  local output = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })

  if vim.v.shell_error ~= 0 then
    error(
      "lazy.nvim 下载失败：\n"
        .. output
        .. "\n请检查 Git、GitHub 网络或代理设置。"
    )
  end
end
-- 把插件路径../lazy/lazy.nvim添加到运行时路径，一般是/home/a3213/.local/share/nvim/data/lazy/lazy.nvim
vim.opt.rtp:prepend(lazypath)

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

    vim.api.nvim_set_option_value("modifiable", false, {
        buf = buf,
    })

    vim.api.nvim_set_option_value("bufhidden", "wipe", {
        buf = buf,
    })

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

    vim.api.nvim_set_option_value("wrap", false, {
        win = messages_win,
    })

    -- 默认定位到最新消息
    vim.api.nvim_win_set_cursor(
        messages_win,
        { math.max(#lines, 1), 0 }
    )

    local close = function()
        if messages_win and vim.api.nvim_win_is_valid(messages_win) then
            vim.api.nvim_win_close(messages_win, true)
        end
        messages_win = nil
    end

    vim.keymap.set("n", "q", close, {
        buffer = buf,
        silent = true,
        desc = "关闭消息窗口",
    })

    vim.keymap.set("n", "<Esc>", close, {
        buffer = buf,
        silent = true,
        desc = "关闭消息窗口",
    })
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

require("lazy").setup({
  { import = "plugins.ai_claudecode" },-- Claude Code IDE 集成
  { import = "plugins.ai_copilot" },-- GitHub Copilot 官方插件
  { import = "plugins.astrocore" },-- AstroCore 插件
  { import = "plugins.breadcrumb" },-- 可点击的 IDE 风格路径导航栏
  { import = "plugins.code_completion" },-- 代码补全
  { import = "plugins.daps" },-- 调试器插件
  { import = "plugins.git" },-- Git 相关的插件
  { import = "plugins.lsp" },-- LSP
  { import = "plugins.markdown" },-- Markdown 文档实时渲染
  { import = "plugins.neo_tree" },-- 文件树插件
  { import = "plugins.none_ls" },-- 伪 LSP 桥接器
  { import = "plugins.scrollbar" },-- 编辑窗口右侧的引用/诊断滚动条
  { import = "plugins.status" },-- 状态栏
  { import = "plugins.subject_skin" },-- 主题皮肤
  { import = "plugins.term" },-- 终端
  { import = "plugins.treesitter" },-- 树状语法分析器
})

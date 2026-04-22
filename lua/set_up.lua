-- =================================================
-- 初始化配置
-- =================================================

-- ===============基础设置=====================
local opt = vim.opt
local api = vim.api

-- 界面显示设置
opt.number = true           -- 显示行号
opt.relativenumber = true   -- 显示相对行号
opt.cursorline = true       -- 高亮当前行
opt.signcolumn = "yes"      -- 显示符号列，用于显示诊断图标或者git状态
opt.termguicolors = true    -- 启用真彩色支持
opt.scrolloff = 8           -- 滚动时保留8行上下文
api.nvim_create_autocmd("FileType", {       -- 文件类型如果是代码类型，关闭自动换行
    pattern = { "lua", "python", "javascript", "go", "rust" },
    callback = function()
        vim.opt_local.wrap = false
    end
})
api.nvim_create_autocmd("FileType", {       -- 文件类型如果是文本类型，启用自动换行和单词换行
    pattern = { "markdown", "text", "vimwiki" },
    callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.linebreak = true
    end
})

-- 缩进设置
opt.expandtab = true        -- 使用空格代替tab
opt.tabstop = 4             -- 一个tab键等于4个空格
opt.shiftwidth = 4          -- >> << 命令移动时的缩进宽
opt.smartindent = true      -- 智能缩进，根据语法自动缩进

-- 搜索设置
opt.ignorecase = true       -- 搜索时忽略大小写
opt.smartcase = true        -- 搜索时如果包括大写字母则区分大小写
opt.incsearch = true        -- 实时显示搜索结果
opt.incsearch = true        -- 实时显示搜索结果

-- 交互设置
opt.virtualedit = "onemore"     -- 修复一个插入模式无法移动光标到最后一个字符的bug
opt.whichwrap:append("<,>,h,l") -- 允许在行首行尾使用左右方向键和 h/l 键移动到下一行
opt.mouse = "a"                 -- 启用鼠标支持
opt.clipboard = "unnamedplus"   -- 使用系统剪贴板

vim.keymap.set("i", "<Left>", function()
    if vim.fn.pumvisible() == 1 then
        return "<Left>"
    end
    return "<C-o>h"
end, { expr = true, silent = true })

vim.keymap.set("i", "<Right>", function()
    if vim.fn.pumvisible() == 1 then
        return "<Right>"
    end
    return "<C-o>l"
end, { expr = true, silent = true })

api.nvim_create_autocmd("FileType", {
    pattern = { "lua", "python", "javascript", "go", "rust" },
    callback = function()
        vim.schedule(function()
            vim.opt_local.whichwrap:append("<,>,h,l")
        end)
    end,
})

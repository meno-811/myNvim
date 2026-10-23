-- 原生快捷键；Leader 必须在插件管理器启动前设置。
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local map = vim.keymap.set

-- Leader 只触发显式配置的组合键。先吞掉未配置的可打印字符，后续实际映射会覆盖对应项；
-- 这样按下 <Leader>i 不会回退执行 i，<Leader>a 等前缀超时也不会执行 a。
map({ "n", "x" }, "<leader><Space>", "<Nop>", { silent = true })
for code = 33, 126 do
    local key = string.char(code)
    -- "<" 在映射左侧需要使用按键记法，避免被当成特殊键名称的开头。
    if key == "<" then key = "<lt>" end
    map({ "n", "x" }, "<leader>" .. key, "<Nop>", { silent = true })
end

-- Ctrl+d：打开并进入当前行诊断浮窗，再按关闭并返回。
map("n", "<C-d>", function()
    local buf, win = vim.diagnostic.open_float({ scope = "line" })
    if not buf or not win then return end
    map("n", "<C-d>", function()
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
        end
    end, { buffer = buf, silent = true, nowait = true, desc = "Close diagnostic float" })
    vim.api.nvim_set_current_win(win)
end, { silent = true, desc = "Show line diagnostics" })

map({ "n", "v" }, "<C-s>", "<Cmd>write<CR>", { desc = "Save file" })
map("i", "<C-s>", "<Esc><Cmd>write<CR>", { desc = "Save file and leave insert mode" })
map({ "n", "x" }, "<C-a>", "ggVG", { desc = "Select all" })
map({ "n", "x" }, "<C-n>", "<C-a>", { desc = "Increment number" })
map("v", "<C-c>", '"+y', { desc = "Copy selection" })
map({ "n", "i", "v", "t" }, "<C-v>", function()
    vim.api.nvim_paste(vim.fn.getreg("+", 1), true, -1)
end, { desc = "Paste clipboard" })
map("c", "<C-v>", "<C-r>+", { desc = "Paste clipboard" })
map("i", "<A-i>", "<Esc>", { desc = "Leave insert mode" })
map("t", "<A-i>", [[<C-\><C-n>]], { desc = "Enter terminal normal mode" })
map({ "n", "i", "v" }, "<C-z>", "<Cmd>undo<CR>", { desc = "Undo" })
map({ "n", "i", "v" }, "<C-S-z>", "<Cmd>redo<CR>", { desc = "Redo" })
map("i", "<LeftMouse>", function()
    local winid = vim.fn.getmousepos().winid
    return winid ~= 0 and winid ~= vim.api.nvim_get_current_win()
        and "<Esc><LeftMouse>" or "<LeftMouse>"
end, { expr = true, desc = "Leave insert mode when clicking another window" })

-- 仅文本 buffer 在首尾行追加 Home/End 行为；其他位置保留原生移动。
for key, boundary in pairs { ["<Up>"] = "<Home>", ["<Down>"] = "<End>" } do
    map({ "n", "i", "x" }, key, function()
        if vim.bo.buftype ~= "" or vim.fn.pumvisible() == 1 then return key end
        local row = vim.fn.line "."
        if (key == "<Up>" and row == 1)
            or (key == "<Down>" and row == vim.fn.line("$")) then
            return boundary
        end
        return key
    end, {
        expr = true,
        silent = true,
        desc = key == "<Up>" and "Move up or to start of first line"
            or "Move down or to end of last line",
    })
end

map({ "n", "x" }, "<C-h>", "b", { desc = "Move to previous word" })
map({ "n", "x" }, "<C-l>", "w", { desc = "Move to next word" })
map({ "n", "x" }, "<C-k>", "{", { desc = "Move to previous paragraph" })
map({ "n", "x" }, "<C-j>", "}", { desc = "Move to next paragraph" })
map("i", "<C-l>", "<C-o>w", { desc = "Move to next word" })
map({ "n", "x", "o" }, "{", "<Nop>", { desc = "Use Ctrl+Up for previous paragraph" })
map({ "n", "x", "o" }, "}", "<Nop>", { desc = "Use Ctrl+Down for next paragraph" })
map({ "n", "x" }, "<C-Left>", "b", { desc = "Move to previous word" })
map({ "n", "x" }, "<C-Right>", "w", { desc = "Move to next word" })
map({ "n", "x" }, "<C-Up>", "{", { desc = "Move to previous paragraph" })
map({ "n", "x" }, "<C-Down>", "}", { desc = "Move to next paragraph" })
map("i", "<C-Left>", "<C-o>b", { desc = "Move to previous word" })
map("i", "<C-Right>", "<C-o>w", { desc = "Move to next word" })
map("i", "<C-Up>", "<C-o>{", { desc = "Move to previous paragraph" })
map("i", "<C-Down>", "<C-o>}", { desc = "Move to next paragraph" })

-- 在文本窗口中让 Shift+hjkl 与 Shift+方向键一致；Neo-tree 保留自己的按键。
for key, direction in pairs {
    H = "<S-Left>", J = "<S-Down>", K = "<S-Up>", L = "<S-Right>",
} do
    map({ "n", "x", "s" }, key, function()
        return vim.bo.filetype == "neo-tree" and key or direction
    end, { expr = true, silent = true, desc = "Select with " .. direction })
end

map("i", "<Left>", function()
    return vim.fn.pumvisible() == 1 and "<Left>" or "<C-o>h"
end, { expr = true, silent = true, desc = "Move left across line boundaries" })
map("i", "<Right>", function()
    return vim.fn.pumvisible() == 1 and "<Right>" or "<C-o>l"
end, { expr = true, silent = true, desc = "Move right across line boundaries" })

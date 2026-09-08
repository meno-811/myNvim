-- 原生快捷键；Leader 必须在插件管理器启动前设置。
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local map = vim.keymap.set

-- 窗口导航与大小调整。
map("n", "<C-Left>", "<C-w>h", { desc = "Move to left split" })
map("n", "<C-Down>", "<C-w>j", { desc = "Move to below split" })
map("n", "<C-Up>", "<C-w>k", { desc = "Move to above split" })
map("n", "<C-Right>", "<C-w>l", { desc = "Move to right split" })
map("n", "<C-K>", "<Cmd>resize -2<CR>", { desc = "Resize split up" })
map("n", "<C-J>", "<Cmd>resize +2<CR>", { desc = "Resize split down" })
map("n", "<C-H>", "<Cmd>vertical resize -2<CR>", { desc = "Resize split left" })
map("n", "<C-L>", "<Cmd>vertical resize +2<CR>", { desc = "Resize split right" })
map("n", "<C-d>", "<C-o>", { desc = "Jump backward" })
map("n", "<C-f>", "<C-i>", { desc = "Jump forward" })
map({ "n", "i", "x" }, "<C-s>", "<Cmd>write<CR>", { desc = "Save file" })
map({ "n", "i" }, "<C-z>", "<Cmd>undo<CR>", { desc = "Undo" })
map({ "n", "i" }, "<C-S-z>", "<Cmd>redo<CR>", { desc = "Redo" })

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

map("i", "<C-Left>", "<Home>", { desc = "Move to start of line" })
map("i", "<C-Right>", "<End>", { desc = "Move to end of line" })
map("i", "<Left>", function()
    return vim.fn.pumvisible() == 1 and "<Left>" or "<C-o>h"
end, { expr = true, silent = true, desc = "Move left across line boundaries" })
map("i", "<Right>", function()
    return vim.fn.pumvisible() == 1 and "<Right>" or "<C-o>l"
end, { expr = true, silent = true, desc = "Move right across line boundaries" })

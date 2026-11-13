-- 原生事件行为；命名分组避免重新加载时重复注册。
local group = vim.api.nvim_create_augroup("user_editor", { clear = true })

vim.api.nvim_create_autocmd("VimEnter", {
    group = group,
    desc = "Start with empty jump lists",
    callback = function() require("utils.buffer").clear_jumps() end,
})

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
    group = group,
    desc = "Reload files changed outside Neovim",
    command = "checktime",
})

vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = { "lua", "python", "javascript", "go", "rust" },
    desc = "Disable wrapping in code buffers",
    callback = function() vim.opt_local.wrap = false end,
})
vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = { "markdown", "text", "vimwiki" },
    desc = "Enable readable wrapping in text buffers",
    callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.linebreak = true
    end,
})
-- y/yy/Ctrl+c 与 Ctrl+v 共用系统剪贴板；删除操作不改动它，p 仍读内部寄存器。
vim.api.nvim_create_autocmd("TextYankPost", {
    group = group,
    desc = "Mirror yanks to the system clipboard",
    callback = function()
        local event = vim.v.event
        if vim.fn.has("clipboard") == 0 or event.operator ~= "y" then return end
        -- 显式 yank 到系统寄存器时无需重复写入；"_ 寄存器保持原样。
        if event.regname == "_" or event.regname == "+" or event.regname == "*" then return end
        vim.fn.setreg("+", event.regcontents, event.regtype)
    end,
})

vim.api.nvim_create_autocmd("InsertEnter", {
    group = group,
    desc = "Hide diagnostic messages while typing",
    callback = function() vim.diagnostic.config { virtual_text = false } end,
})
vim.api.nvim_create_autocmd("InsertLeave", {
    group = group,
    desc = "Show diagnostic messages outside insert mode",
    callback = function() vim.diagnostic.config { virtual_text = true } end,
})

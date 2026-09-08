-- 原生事件行为；命名分组避免重新加载时重复注册。
local group = vim.api.nvim_create_augroup("user_editor", { clear = true })

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

local M = {}

local replacement_key = "close_replacement"

local function is_empty(bufnr)
    return vim.api.nvim_buf_is_valid(bufnr)
        and vim.bo[bufnr].buflisted
        and vim.bo[bufnr].buftype == ""
        and vim.api.nvim_buf_get_name(bufnr) == ""
        and not vim.bo[bufnr].modified
        and vim.api.nvim_buf_line_count(bufnr) == 1
        and vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] == ""
end

function M.close(bufnr)
    local existing = {}
    for _, id in ipairs(vim.api.nvim_list_bufs()) do
        existing[id] = true
    end

    -- IDE-style tab close: remove the buffer identity completely. `delete()`
    -- only unloads it, so reopening the same path can resurrect the old buffer
    -- id and Bufferline position. `wipeout()` makes a later open a new tab.
    require("mini.bufremove").wipeout(bufnr, false)

    -- mini.bufremove may create a listed, unnamed buffer to preserve the window.
    -- Mark only buffers created by this close operation, so user-created :enew
    -- buffers are never mistaken for disposable replacements.
    for _, id in ipairs(vim.api.nvim_list_bufs()) do
        if not existing[id] and is_empty(id) then
            vim.b[id][replacement_key] = true
        end
    end
end

function M.setup()
    local group = vim.api.nvim_create_augroup("close_replacement_buffers", { clear = true })
    vim.api.nvim_create_autocmd("BufHidden", {
        group = group,
        callback = function(args)
            if vim.b[args.buf][replacement_key] and is_empty(args.buf) then
                vim.schedule(function()
                    if is_empty(args.buf) and vim.fn.bufwinid(args.buf) == -1 then
                        vim.api.nvim_buf_delete(args.buf, { force = false })
                    end
                end)
            end
        end,
    })
end

return M

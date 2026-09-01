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

local function listed_buffers_except(keep)
    local buffers = {}
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[bufnr].buflisted and bufnr ~= keep then
            table.insert(buffers, bufnr)
        end
    end
    return buffers
end

local function close_many(buffers)
    local modified = {}
    for _, bufnr in ipairs(buffers) do
        if vim.bo[bufnr].modified then
            local name = vim.api.nvim_buf_get_name(bufnr)
            table.insert(modified, name ~= "" and vim.fn.fnamemodify(name, ":t") or "[未命名]")
        end
    end

    if #modified > 0 then
        vim.notify("以下标签页尚未保存，已取消关闭：" .. table.concat(modified, "、"), vim.log.levels.WARN)
        return
    end

    for _, bufnr in ipairs(buffers) do
        if vim.api.nvim_buf_is_valid(bufnr) then M.close(bufnr) end
    end
end

function M.close_all()
    close_many(listed_buffers_except(nil))
end

function M.close_others()
    close_many(listed_buffers_except(vim.api.nvim_get_current_buf()))
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

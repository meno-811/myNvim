local M = {}

function M.clear_jumps()
    for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
            vim.api.nvim_win_call(win, vim.cmd.clearjumps)
        end
    end
end

function M.close_view()
    if vim.bo.buftype == "quickfix" then
        local wininfo = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1]
        vim.cmd(wininfo and wininfo.loclist == 1 and "lclose" or "cclose")
    else
        M.close()
    end
end

function M.close(bufnr)
    -- wipe=true 保持“关闭后重新打开获得新 buffer”的 IDE 标签页语义；
    -- Snacks 负责未保存提示、替代 buffer 选择和窗口布局保护。
    require("snacks").bufdelete({ buf = bufnr, wipe = true })
end

function M.close_all()
    require("snacks").bufdelete.all({ wipe = true })
    M.clear_jumps()
end

function M.close_others()
    require("snacks").bufdelete.other({ wipe = true })
    M.clear_jumps()
end

return M

local M = {}

function M.close(bufnr)
    -- wipe=true 保持“关闭后重新打开获得新 buffer”的 IDE 标签页语义；
    -- Snacks 负责未保存提示、替代 buffer 选择和窗口布局保护。
    require("snacks").bufdelete({ buf = bufnr, wipe = true })
end

function M.close_all()
    require("snacks").bufdelete.all({ wipe = true })
end

function M.close_others()
    require("snacks").bufdelete.other({ wipe = true })
end

return M

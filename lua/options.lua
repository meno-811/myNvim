-- 原生编辑器选项，不依赖插件。
local options = {
    number = true,
    relativenumber = true,
    cursorline = true,
    signcolumn = "yes",
    termguicolors = true,
    scrolloff = 8,
    updatetime = 300,
    expandtab = true,
    tabstop = 4,
    shiftwidth = 4,
    smartindent = true,
    ignorecase = true,
    smartcase = true,
    incsearch = true,
    -- 块选择时允许光标越过短行行尾；其他模式仍保留左右键跨行。
    virtualedit = "block,onemore",
    whichwrap = "b,s,<,>,h,l",
    mouse = "a",
    clipboard = "unnamedplus",
}

for name, value in pairs(options) do
    vim.opt[name] = value
end

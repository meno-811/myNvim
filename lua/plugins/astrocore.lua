-- 是的，我知道做这个决定很难但是
-- 我要慢慢把这个弄成astro同款（
-- 至少为什么一开始不用他纯粹是因为不是自己写的东西看不懂
-- 我写一遍就会用他了

return{
    "AstroNvim/astrocore",
      ---@param opts AstroCoreOpts
    opts = function(_, opts)
        local astro = require "astrocore"
        local maps = astro.empty_map_table()
        
        -- Split navigation
        maps.n["<C-H>"] = { "<C-w>h", desc = "Move to left split" }
        maps.n["<C-J>"] = { "<C-w>j", desc = "Move to below split" }
        maps.n["<C-K>"] = { "<C-w>k", desc = "Move to above split" }
        maps.n["<C-L>"] = { "<C-w>l", desc = "Move to right split" }
        maps.n["<C-Up>"] = { "<Cmd>resize -2<CR>", desc = "Resize split up" }
        maps.n["<C-Down>"] = { "<Cmd>resize +2<CR>", desc = "Resize split down" }
        maps.n["<C-Left>"] = { "<Cmd>vertical resize -2<CR>", desc = "Resize split left" }
        maps.n["<C-Right>"] = { "<Cmd>vertical resize +2<CR>", desc = "Resize split right" }

        opts.mappings = maps
    end,
}
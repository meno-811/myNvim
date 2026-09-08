-- ==========================================
-- Neovim IDE 配置  （Neovim 0.12+ 兼容版）
-- ==========================================

-- 原生配置先于插件加载，Leader 在解析插件快捷键前设置。
require("options")
require("key_map")
require("autocmds")

-- 加载自定义用户命令
require("commands")

-- 加载插件管理
require("plugins")

# myNvim

个人维护的 Neovim 配置，目前主要用于 Go、Python、Lua 和 Rust 开发。

## 环境与安装

需要 Neovim 0.12 或更高版本。

```bash
git clone https://github.com/meno-811/myNvim.git ~/.config/nvim
```

进入 Neovim 后可通过 `:Mason` 查看和安装语言服务器及外部工具。

使用 `:readme` 或 `:Readme` 可以在浮动窗口中查看这套 Neovim 配置的 README；按
`q` 或 `Esc` 关闭窗口。

## 常用快捷键

`<Leader>` 默认为空格。

| 快捷键 | 功能 |
| --- | --- |
| `*` / `#` | 搜索光标下的单词并向后 / 向前跳转 |
| `:noh` | 取消当前搜索高亮及滚动条搜索标记 |
| `Ctrl+d` / `Ctrl+f` | 跳转列表后退 / 前进 |
| `Shift+↑` / `Shift+↓` | 向上 / 向下翻页 |
| `<Leader>;` | 操作顶部路径导航栏 |
| `Ctrl+v`（或 `Ctrl+q`） | 进入块可视模式 |
| `gD` | 跳转到声明 |
| `gi` | 跳转到实现（接口、trait 或抽象类型） |
| `<Leader>ba` | 关闭全部标签页 |
| `<Leader>bo` | 仅保留当前标签页 |
| `<Leader>e` | 打开或关闭文件树 |
| `<Leader>1` 至 `<Leader>9` | 切换到对应编号的标签页 |
| `Ctrl+方向键` | 移动到对应方向的窗口 |
| `Ctrl+h/j/k/l` | 调整窗口大小 |
| `Ctrl+\` | 打开或关闭终端 |
| `<Leader>m` | 在 Markdown 文件中切换实时渲染 |
| `<Leader>?` | 查看当前缓冲区可用快捷键 |

## 终端操作

| 快捷键 | 功能 |
| --- | --- |
| `Alt+n` | 从终端输入模式进入普通模式，以便选择和复制内容 |

## 文件树操作

以下快捷键在 Neo-tree 文件树内使用：

| 快捷键 | 功能 |
| --- | --- |
| `>` | 切换到右侧标签 |
| `<` | 切换到左侧标签 |

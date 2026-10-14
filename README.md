# myNvim

个人维护的 Neovim 配置，主要用于 Go、Python、Lua 和 Rust 开发。

## 安装

需要 Neovim 0.12+。图标正常显示还需要终端使用 Nerd Font 3.3+。

```bash
git clone https://github.com/meno-811/myNvim.git ~/.config/nvim
```

在 x86_64 或 ARM64 Linux 上，也可以在项目根目录安装或更新最新 AppImage：

```bash
bash ./install-nvim.sh
```

首次启动后用 `:Mason` 查看语言服务器和外部工具。

## 常用命令

| 命令 | 功能 |
| --- | --- |
| `:Config` | 新建浮动终端并进入 Neovim 配置目录 |
| `:Readme` / `:readme` | 在浮窗中查看本文档，按 `q` 或 `Esc` 关闭 |
| `:MessagesBuffer` | 在可滚动、可复制的浮窗中查看完整消息记录 |
| `:Lazy` / `:Mason` / `:LspInfo` | 查看插件、外部工具和当前 LSP 状态 |

`<Leader>` 是空格。未配置的 Leader 组合会被忽略，不会回退执行普通单键命令。

## 编辑与导航

| 快捷键 | 功能 |
| --- | --- |
| `Ctrl+a` | 全选；插入模式下先退出插入 |
| `Ctrl+c`（可视模式） | 复制选区到系统剪贴板 |
| `Ctrl+s` | 保存；插入模式下保存并返回普通模式 |
| `Ctrl+z` / `Ctrl+Shift+z` | 撤销 / 重做 |
| `Ctrl+d` / `Ctrl+f` | 跳转列表后退 / 前进 |
| `Ctrl+h/l` 或 `Ctrl+←/→` | 上一个 / 下一个单词 |
| `Ctrl+k/j` 或 `Ctrl+↑/↓` | 上一个 / 下一个段落 |
| `Shift+↑/↓` | 向上 / 向下翻页 |
| `Shift+←/→` | 行首 / 行尾 |
| `Ctrl+v` 或 `Ctrl+q` | 块可视模式 |
| `gc` / `gcc` | 注释操作符 / 切换当前行注释 |
| `*` / `#` | 向后 / 向前搜索光标下单词 |
| `:noh` | 清除搜索高亮和滚动条搜索标记 |

普通模式下双击鼠标左键会在点击位置进入插入模式。插入模式的左右键可以跨行；在首行继续按 `↑` 到行首，在末行继续按 `↓` 到行尾。

多行插入相同内容：`Ctrl+v` 选择多行，按大写 `I` 输入，最后按 `Esc` 应用到全部选中行。

## 窗口、文件与终端

| 快捷键 | 功能 |
| --- | --- |
| `Tab` / `Shift+Tab` | 下一个 / 上一个文件标签 |
| `<Leader>1` … `<Leader>9` | 切换到对应编号的文件标签 |
| `<Leader>q` | 关闭当前文件或结果窗口 |
| `<Leader>ba` / `<Leader>bo` | 关闭全部 / 仅保留当前文件 |
| `<Leader>e` / `<Leader>o` | 切换文件树 / 在文件树与编辑区间切换焦点 |
| `<Leader>;` | 选择顶部路径或代码层级 |
| `<Leader>up` | 显示或隐藏顶部路径栏 |
| `Ctrl+w` 后接 `h/j/k/l`、方向键或 `w` | 移动窗口或切换到下一窗口 |
| `Ctrl+\` | 打开或关闭 ToggleTerm |
| `Alt+n`（终端输入模式） | 进入终端普通模式，便于选择和复制 |

`Ctrl+w` 窗口导航也适用于文本插入模式和 Claude Code 终端；文本插入模式会先退出插入。第二个 `h/j/k/l/w` 可以继续按住 Ctrl，也可以松开 Ctrl。

Neo-tree 中可用 `[b` / `]b` 切换栏目，`Y` 选择要复制的路径格式，`O` 或 `Shift+Enter` 用系统默认程序打开节点。

## LSP、诊断与补全

| 快捷键 | 功能 |
| --- | --- |
| `gd` / `gD` / `gi` / `gr` | 定义 / 声明 / 实现 / 引用 |
| `K` | 打开 hover；再按进入浮窗；第三次关闭 |
| `D` | 打开当前行诊断；再按进入浮窗；第三次关闭 |
| `[d` / `]d` | 上一个 / 下一个诊断 |
| `<Leader>rn` / `<Leader>ca` | 重命名 / Code Action |
| `Alt+l` | 接受整条 Copilot 建议 |

补全菜单中，`Tab` 接受选中项或首项，`Enter` 只确认手动选中的候选，`↑/↓` 只移动选择；菜单打开时按 `Esc` 只关闭菜单并保持插入模式。命令行和搜索使用同样的候选确认规则。

## Claude Code 与 Markdown

| 快捷键 | 功能 |
| --- | --- |
| `<Leader>ac` | 打开或切换 Claude Code，并进入输入状态 |
| `<Leader>as` | 发送选区、添加文件或聚焦 Claude Code，并进入输入状态 |
| `<Leader>ab` | 添加当前 buffer |
| `<Leader>ar` / `<Leader>aC` | 恢复 / 继续 Claude 会话 |
| `<Leader>am` | 选择 Claude 模型 |
| `<Leader>aa` / `<Leader>ad` | 接受 / 拒绝 Claude diff |
| `<Leader>m`（Markdown） | 切换终端内实时渲染 |

Markdown 预览是终端内渲染，不提供浏览器式字号和图片排版。

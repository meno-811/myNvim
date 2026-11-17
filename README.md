# myNvim 快捷键

`<Leader>` 是空格。未配置的 Leader 组合会被忽略，不会回退执行普通单键命令。

## 编辑与导航

| 快捷键 | 功能 |
| --- | --- |
| `Ctrl+a`（普通 / 可视模式） | 全选 |
| `Ctrl+a`（插入模式） | 插入上一次输入的文本（原生行为） |
| `Ctrl+n`（普通 / 可视模式） | 将光标处或选区中的数字加一 |
| `Ctrl+s` | 保存；插入模式下保存并返回普通模式 |
| `Ctrl+z` / `Ctrl+Shift+z` | 撤销 / 重做 |
| `Alt+i`（插入模式） | 返回普通模式 |
| `Alt+·`（Termius） | 等同于 `Esc` |
| `Ctrl+h/l`（普通 / 可视）或 `Ctrl+←/→` | 上一个 / 下一个单词 |
| `Ctrl+k/j`（普通 / 可视）或 `Ctrl+↑/↓` | 上一个 / 下一个段落 |
| `Shift+方向键` | 像普通输入框一样开始或扩展选区 |
| `Shift+h/j/k/l`（非 Neo-tree） | 等同于 `Shift+←/↓/↑/→` |
| `Ctrl+c`（可视 / Select 模式） | 复制选区，与 `y` 相同，同时写入系统剪贴板 |
| `Ctrl+v` | 从系统剪贴板粘贴（`p` 仍用内部寄存器） |
| `Ctrl+q`（普通模式） | 块可视模式 |
| `gc` / `gcc` | 注释操作符 / 切换当前行注释 |
| `*` / `#` | 向后 / 向前搜索光标下单词 |
| `:noh` | 清除搜索高亮和滚动条搜索标记 |

原生 `{` / `}` 已禁用，段落移动统一使用 `Ctrl+k/j` 或 `Ctrl+↑/↓`。`Ctrl+l` 覆盖的原生清高亮、diff 更新和重绘不迁移，需要时分别使用 `:noh`、`:diffupdate`、`:redraw!`。

Shift 选择使用 Neovim Select 模式：按 `Shift+方向键` 或 `Shift+Home/End/PageUp/PageDown` 开始选区，按住 Shift 继续扩大；松开 Shift 后按移动键会退出选择并照常移动。`Shift+Ctrl+方向键` 在保持选区的同时按单词/段落移动，距离与普通模式的 `Ctrl+方向键` 一致。直接输入会替换选中内容，`Esc` 取消选择。

多行插入相同内容：`Ctrl+q` 选择多行，按大写 `I` 输入，最后按 `Esc` 应用到全部选中行。

`Ctrl+c` 与原生 `y` 走同一套逻辑：`y`、`yy` 和 `Ctrl+c` 在写入内部寄存器的同时也会写入系统剪贴板，删除操作不会。`p` 仍只使用内部寄存器，只有 `Ctrl+v` 从系统剪贴板粘贴。普通模式的 `Ctrl+c` 保留原生取消语义。

Termius 中如果 `Ctrl+v` 无法粘贴，使用终端的粘贴按钮或长按粘贴。

插入模式的左右键可以跨行；在首行继续按 `↑` 到行首，在末行继续按 `↓` 到行尾。

## 窗口与文件

| 快捷键 | 功能 |
| --- | --- |
| `[b` / `]b` | 上一个 / 下一个 buffer（Neovim 原生） |
| `<Leader>1` … `<Leader>9` | 切换到对应编号的文件标签 |
| `<Leader>q` | 关闭当前文件或结果窗口 |
| `<Leader>ba` / `<Leader>bo` | 关闭全部 / 仅保留当前文件；两者都会重置跳转列表 |
| `<Leader>e` / `<Leader>o` | 切换文件树 / 在文件树与编辑区间切换焦点 |
| `<Leader>up` | 显示或隐藏顶部路径栏 |
| `Alt+x` | 将当前窗口切换为全屏浮窗 |
| `Ctrl+w` 后接 `h/j/k/l`、方向键或 `w`（普通模式） | 移动窗口或切换到下一窗口；`Ctrl+w w` 在普通文件间切换时跳过 Claude Code 缓冲区 |

插入模式保留原生的 `Ctrl+w` 删除前一个单词，以及 `Ctrl+h/j/k` 的退格、换行和 Digraph；跨单词或段落可使用 Ctrl 加方向键。

Neo-tree 中 `Enter` 打开文件并保留文件树，`Ctrl+Enter` 打开文件后关闭文件树；`[b` / `]b` 切换栏目，`Y` 选择要复制的路径格式，`O` 或 `Shift+Enter` 用系统默认程序打开节点。

Neo-tree 中最后一项再按 `↓` 回到第一项。`Ctrl+↑/↓` 跳到前面/后面深度不大于当前项的目录，跳过文件和更深的子目录；例如 `b2 → b → a`。没有符合条件的目录时停留原处，不展开或折叠目录。

## 代码跳转、诊断与补全

| 快捷键 | 功能 |
| --- | --- |
| `gd` / `gD` / `gri` / `grr` | 定义 / 声明 / 实现 / 引用 |
| `Ctrl+o` / `Ctrl+i`（或 `Tab`） | 跳转列表后退 / 前进（Neovim 原生） |
| `<Leader>;` | 选择顶部路径或代码层级 |
| `Ctrl+f`（LSP 文件） | 打开并进入 hover 浮窗；再按关闭 |
| `Ctrl+d` | 打开并进入当前行诊断浮窗；再按关闭 |
| `[d` / `]d` | 上一个 / 下一个诊断 |
| `<Leader>rn` / `<Leader>ca` | 重命名 / Code Action |
| `Alt+l` | 接受整条 Copilot 建议 |

补全菜单中，`Tab` 接受选中项或首项，`Enter` 只确认手动选中的候选，`↑/↓` 只移动选择；菜单打开时按 `Esc` 只关闭菜单并保持插入模式。命令行和搜索使用同样的候选确认规则。

## 终端与 Claude Code

| 快捷键 | 功能 |
| --- | --- |
| `Ctrl+\` | 打开或关闭 ToggleTerm（普通、插入、可视和终端输入模式）；Claude Code 终端输入模式下也可直接使用 |
| `Alt+i`（终端输入模式） | 进入终端普通模式；Claude Code 历史视图改为普通模式下按 `<Leader>m` |
| `<Leader>ac` | 打开或切换 Claude Code，并进入输入状态 |
| `<Leader>af` | 聚焦 Claude Code 并进入输入状态（普通和可视模式均可用） |
| `<Leader>as` | 发送选区、添加文件或聚焦 Claude Code，并进入输入状态 |
| `<Leader>ab` | 添加当前 buffer |
| `<Leader>ar` / `<Leader>aC` | 恢复 / 继续 Claude 会话 |
| `<Leader>am` | 选择 Claude 模型 |
| `<Leader>aa` / `<Leader>ad` | 接受 / 拒绝 Claude diff |

Claude Code 终端中可用 `Ctrl+w w` 切换到下一个窗口；未完成的 `Ctrl+w` 前缀超时后会被忽略，不会传给终端。普通文件窗口里按 `Ctrl+w w` 会跳过 Claude Code 缓冲区，只在 Claude 窗口内才会切到它；在 Claude 窗口内按 `Ctrl+w w` 则正常切换到下一个窗口。终端普通模式下按 `<Leader>q` 只隐藏窗口，不会结束会话；终端输入模式也可直接使用 `Alt+x` 切换全屏浮窗。

## Markdown

| 快捷键 | 功能 |
| --- | --- |
| `<Leader>m`（Markdown） | 切换终端内实时渲染；Claude Code 缓冲区普通模式下改为打开历史浮窗 |

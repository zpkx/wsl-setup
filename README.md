# WSL Zsh 环境配置

> WSL2 + Zsh + mise + Starship + NvChad — 一站式开发环境 dotfiles

## 环境概况

- **系统**: WSL2 (Ubuntu 24.04)
- **Shell**: Zsh 5.9
- **包管理器**: apt (系统) + mise (运行时版本管理 + CLI 工具)
- **编辑器**: Neovim（通过 NvChad 框架管理）

---

## 快速开始

```bash
# 克隆本仓库
git clone git@github.com:zpkx/wsl-setup.git ~/wsl-setup
cd ~/wsl-setup

# WSL 侧一键配置
chmod +x bootstrap.sh && ./bootstrap.sh
```

Windows 侧前置准备（以管理员身份运行 PowerShell）：

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\bootstrap.ps1
```

---

## 1. 基础系统更新

首先确保系统包索引和已安装的软件包为最新状态，为后续安装做准备。

```bash
sudo apt update && sudo apt upgrade -y
```

---

## 2. 安装 Zsh 并设为默认 Shell

安装 Zsh 并验证：

```bash
sudo apt-get install -y zsh
zsh --version          # 确认安装成功
chsh -s $(which zsh)
```

> ⚠️ **WSL 注意**：`chsh` 在某些 WSL 配置下可能不生效。如果重启终端后默认 Shell 仍是 bash，可以手动修改 `/etc/passwd`，或在 Windows Terminal 配置文件里将命令行设为 `wsl -e /usr/bin/zsh`。

---

## 3. mise — 统一的运行时与工具管理器

Shell 就绪后，安装统一的工具管理器。mise 承担两个角色：开发运行时版本管理（Node.js、Java、Go、Python）以及 CLI 工具安装（Sheldon、zoxide、eza、bat、ripgrep、neovim 等）。

```bash
curl https://mise.run | sh
mise use --global node@24 python@3.12 java@21 go@latest sheldon zoxide eza bat ripgrep neovim opencode starship
```

安装路径: `~/.local/bin/mise`

配置文件 (`~/.config/mise/config.toml`)，由上述 `mise use --global` 命令自动生成:

```toml
[tools]
bat = "latest"
eza = "latest"
go = "latest"
java = "21"
neovim = "latest"
node = "24"
opencode = "latest"
python = "3.12"
ripgrep = "latest"
sheldon = "latest"
starship = "latest"
zoxide = "latest"

[settings]
python.github_attestations = false
```

运行 `mise ls` 确认所有工具安装成功：

| 工具 | 用途 |
|------|------|
| bat | `cat` 替代，带语法高亮和行号 |
| eza | 现代化 `ls` 替代，支持图标和 tree 模式 |
| go | Go 语言编译工具链 |
| java | JDK |
| neovim | 现代化 Vim 分支编辑器 |
| node | Node.js 运行时 |
| opencode | 终端 AI 编码助手 |
| python | Python 解释器 |
| ripgrep | 极速代码搜索（`grep` 替代） |
| sheldon | Zsh 插件管理器 |
| starship | 轻量级提示符，显示 Git 状态、运行时版本等 |
| zoxide | 智能目录跳转 |

至此所有运行时和 CLI 工具已统一安装就绪。接下来依次配置插件管理器、提示符，最后用 `.zshrc` 将它们整合到一起。

---

## 4. Sheldon — Zsh 插件管理器

通过 Sheldon 管理 Zsh 插件，比 Oh My Zsh 更轻量（Rust 编写，启动速度快 10 倍）。

配置文件 (`sheldon/plugins.toml` → `~/.config/sheldon/plugins.toml`)：

```toml
shell = "zsh"

[plugins]

[plugins.zsh-autosuggestions]
github = "zsh-users/zsh-autosuggestions"
use = ["{{ name }}.zsh"]

[plugins.zsh-syntax-highlighting]
github = "zsh-users/zsh-syntax-highlighting"

[plugins.omz-plugins]
github = "ohmyzsh/ohmyzsh"
dir = "plugins"
use = ["{common-aliases,git}/*.plugin.zsh"]

[plugins.omz-lib]
github = "ohmyzsh/ohmyzsh"
dir = "lib"
use = ["history.zsh"]
```

已安装插件:

| 插件 | 来源 | 用途 |
|------|------|------|
| zsh-autosuggestions | zsh-users/zsh-autosuggestions | 命令自动补全建议（灰色提示） |
| zsh-syntax-highlighting | zsh-users/zsh-syntax-highlighting | 命令语法高亮 |
| omz-plugins (common-aliases, git) | ohmyzsh/ohmyzsh | Oh My Zsh 常用别名 + Git 别名 |
| omz-lib (history.zsh) | ohmyzsh/ohmyzsh | Oh My Zsh 历史相关函数库 |

验证：`sheldon source` 应正常输出而不报错。插件就绪后，接下来配置终端提示符。

---

## 5. Starship — 提示符配置

Sheldon 管理 Shell 功能，Starship 管理提示符外观。两者各自独立，在 `.zshrc` 中分别加载。

配置文件 (`starship.toml` → `~/.config/starship.toml`)：

```toml
"$schema" = 'https://starship.rs/config-schema.json'

add_newline = false
scan_timeout = 100
command_timeout = 1000
palette = "catppuccin_mocha"

[character]
# success_symbol = '🚀 '
# error_symbol = '💀 '

[shell]
disabled = false
style = 'cyan bold'

[os]
disabled = false
format = "$symbol "
style = ""

[os.symbols]
Ubuntu = "[ ](fg:peach)"

[palettes.catppuccin_mocha]
rosewater = "#f5e0dc"
flamingo  = "#f2cdcd"
pink      = "#f5c2e7"
mauve     = "#cba6f7"
red       = "#f38ba8"
maroon    = "#eba0ac"
peach     = "#fab387"
yellow    = "#f9e2af"
green     = "#a6e3a1"
teal      = "#94e2d5"
sky       = "#89dceb"
sapphire  = "#74c7ec"
blue      = "#89b4fa"
lavender  = "#b4befe"
text      = "#cdd6f4"
subtext1  = "#bac2de"
subtext0  = "#a6adc8"
overlay2  = "#9399b2"
overlay1  = "#7f849c"
overlay0  = "#6c7086"
surface2  = "#585b70"
surface1  = "#45475a"
surface0  = "#313244"
base      = "#1e1e2e"
mantle    = "#181825"
crust     = "#11111b"
```

> ⚠️ **字体提示**：Starship 的图标符号需要 [Nerd Font](https://www.nerdfonts.com/) 支持。如果终端显示乱码，安装 Nerd Font（如 Maple Mono 或 JetBrainsMono Nerd Font）并在终端设置中启用。

提示符配置完成。现在进入最后一步——用 `.zshrc` 把所有组件串联起来。

---

## 6. Zsh 配置 (.zshrc) — 整合所有组件

前面的步骤分别安装了工具并生成了各自的配置文件，现在通过 `.zshrc` 将它们按顺序加载。启动流程如下：

```
补全系统 → mise 环境 → Sheldon 插件 → zoxide → Starship → Homebrew → 别名与编辑器
```

```zsh
# case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z} m:{A-Z}={a-z}'

# load completions
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

eval "$(/home/peng/.local/bin/mise activate zsh)"
eval "$(sheldon source)"
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

alias ls='eza -F --icons --group-directories-first'
alias ll='ls -lHo --git'
alias la='ll -a'
alias lt='eza --tree --icons'
alias pn='pnpm'
alias cat='bat'

# Upgrade Everything
alias upev='sudo apt update -y && sudo apt full-upgrade -y && sudo apt autoremove -y && sudo apt clean -y && sudo apt autoclean -y'

#ask() { claude -p "$@" | glow }

export EDITOR='nvim'
```

### 配置要点

| 选项/配置 | 作用 |
|------|------|
| `matcher-list` | 大小写不敏感的 Tab 补全 |
| 条件 `compinit` | dump 文件 24h 内未修改则 `-C` 跳过重建，提高启动速度 |
| `mise activate zsh` | 激活 mise 管理的运行时（自动设置 PATH） |
| `sheldon source` | 加载 Sheldon 插件 |
| `zoxide init zsh` | 加载 zoxide（`z` / `zi` 智能跳转命令） |
| `starship init zsh` | 加载 Starship 提示符 |
| `brew shellenv` | 加载 Homebrew 环境变量（Linuxbrew） |
| `EDITOR='nvim'` | 默认编辑器设为 Neovim |
| `ls` / `ll` / `la` / `lt` | eza 别名，`ll` 含 git 信息，`la` 含隐藏文件 |
| `pn='pnpm'` | pnpm 快捷别名 |
| `cat='bat'` | 用 bat 替代 cat，自带语法高亮（主题: Catppuccin Mocha） |
| `upev` | 一键 apt 更新、全升级、自动清理 |

> **bat 主题**：`~/.config/bat/config` 中已设定 `--theme="Catppuccin Mocha"`，与 Starship 配色保持一致。
> **eza 颜色**：eza 自动适配终端 256 色 / truecolor 调色板，Catppuccin Mocha 终端配色下无需额外配置。

---

## 7. Windows 终端环境配置

最后一步是配置 Windows 上的终端应用和字体，获得完整的视觉体验。

### 7.1 Maple Mono 字体

[Maple Mono](https://github.com/subframe7536/maple-font) 是一款开源的等宽字体，内置 Nerd Font 图标支持，并带有独特的圆角字形和连字特性，与 Starship 图标完美兼容。

> Starship 配置中已使用 Nerd Font 符号（`` 等），Maple Mono 安装后即可直接渲染。

### 7.2 Warp 终端

[Warp](https://www.warp.dev) 是一款基于 Rust 的现代化终端，支持智能补全、AI 命令搜索、块编辑器等特性。

WSL 集成步骤：

1. 在 Windows 上安装 Warp（官网下载或 `winget install Warp.Warp`）
2. 打开 Warp → `Settings` → `Appearance` → `Font` → 选择 **Maple Mono**
3. 若字体列表中未出现 Maple Mono，重启 Warp 后会识别
4. `Features` → `WSL` → 确认已启用 WSL 集成
5. 默认 Shell 设为 WSL 的 Zsh

### 7.3 最终效果

完成以上配置后，终端呈现的效果：

| 层级 | 选择 | 作用 |
|------|------|------|
| **字体** | Maple Mono | Nerd Font 图标正常显示 |
| **终端** | Warp | 块选择、命令补全、AI 搜索 |
| **提示符** | Starship (Catppuccin Mocha) | Git 分支、OS 图标、运行时版本 |
| **配色** | Catppuccin Mocha | 粉紫棕色调护眼配色 |

---

## 8. NvChad — Neovim 配置框架

Neovim 已通过 mise 安装，在此基础上叠加 [NvChad](https://nvchad.com) 配置框架获得开箱即用的编辑器体验——内置丰富的插件、主题和键位映射。

```bash
# 克隆 NvChad starter 配置
git clone https://github.com/NvChad/starter ~/.config/nvim

# 首次启动 nvim，NvChad 会自动完成插件安装
nvim
```

NvChad 主题配置 (`nvim/lua/chadrc.lua` → `~/.config/nvim/lua/chadrc.lua`)：

```lua
M.base46 = {
  theme = "catppuccin",
}
```

> `EDITOR='nvim'` 已在 `.zshrc` 中设置。NvChad 的图标符号也依赖 Nerd Font，Maple Mono 即可正常渲染。

---

## 9. Zsh 启动性能测试

环境搭建完毕，最后验证启动性能，确保没有拖慢 Shell 的环节。

```bash
for i in $(seq 1 5); do /usr/bin/time -f '%e seconds' zsh -i -c exit 2>&1; done
```

运行 5 次交互式 Zsh 启动并打印每次耗时，用于基准对比。启动耗时在 200ms 以内为良好。

---

## 10. 目录结构与恢复

### 目录结构

```
.
├── bootstrap.ps1        # Windows 侧：WSL / Warp / 字体
├── bootstrap.sh          # WSL 侧：apt / zsh / mise / 全部配置
├── .zshrc                # Zsh 配置文件
├── starship.toml         # Starship 提示符配置
├── bat/
│   └── config            # bat 主题配置（Catppuccin Mocha）
├── nvim/
│   └── lua/
│       └── chadrc.lua    # NvChad 主题配置（catppuccin）
├── sheldon/
│   └── plugins.toml      # Sheldon 插件配置
└── mise/
    └── config.toml       # mise 运行时与工具配置
```

### 恢复步骤

**第一步 — 恢复 Windows 侧环境**

以管理员身份打开 PowerShell，执行：

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\bootstrap.ps1
```

此脚本会自动：
- 安装/更新 WSL2 + Ubuntu 24.04
- 安装 Warp 终端
- 安装 Maple Mono Nerd Font 字体

**第二步 — 进入 WSL 恢复 WSL 侧环境**

```bash
# 进入 WSL
wsl -d Ubuntu-24.04

# 进入仓库目录（从 GitHub 克隆或从 vault 复制）
cd ~/wsl-setup

# 执行恢复脚本
chmod +x bootstrap.sh && ./bootstrap.sh
```

此脚本会自动：
1. 系统更新（`apt update && apt upgrade`）
2. 安装 Zsh
3. 安装 mise
4. 通过 mise 安装所有运行时和 CLI 工具
5. 克隆 NvChad starter 配置
6. 复制 Sheldon 插件配置
7. 复制 Starship 提示符配置
8. 复制 bat 主题配置（Catppuccin Mocha）
9. 复制 NvChad 主题配置（catppuccin）
10. 复制 `.zshrc`
11. 设置 Zsh 为默认 Shell

**第三步 — 手动收尾**

- 打开 nvim，NvChad 会自动完成插件安装：`nvim`
- 重启 WSL 终端或执行 `exec zsh`
- 在 Warp 中设置字体：`Settings` → `Appearance` → `Font` → **Maple Mono**
- 在 `.zshrc` 中补回 `GITHUB_TOKEN` 等敏感环境变量
- 运行 `sheldon lock` 生成插件锁定文件
- 运行性能测试确认启动速度

#!/usr/bin/env bash
# ============================================================================
# WSL Zsh 环境一键配置脚本 (bootstrap.sh)
# 从 Obsidian vault 中的 dotfiles 恢复完整的 WSL 开发环境
#
# 用法:
#   chmod +x bootstrap.sh && ./bootstrap.sh
#
# 前置条件:
#   - 已安装 WSL2 + Ubuntu 发行版
#   - vault 已通过 Synology Drive 同步到 Windows
# ============================================================================

set -euo pipefail

# ── 路径探测 ────────────────────────────────────────────────────────────────
# 脚本路径 = Software/Windows/dotfiles/bootstrap.sh
# vault 根 = 向上 4 层
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VAULT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

DOTFILES="$SCRIPT_DIR"
ZSHRC_SRC="$DOTFILES/.zshrc"
SHELDON_SRC="$DOTFILES/sheldon/plugins.toml"
STARSHIP_SRC="$DOTFILES/starship.toml"
MISE_SRC="$DOTFILES/mise/config.toml"

echo "=========================================="
echo "  WSL Zsh 环境恢复脚本"
echo "=========================================="
echo "Vault 路径:   $VAULT_ROOT"
echo "Dotfiles 路径: $DOTFILES"
echo ""

# ── 1. 系统更新 ──────────────────────────────────────────────────────────────
echo "▶ [1/7] 更新系统包..."
sudo apt update && sudo apt upgrade -y

# ── 2. 安装 Zsh ──────────────────────────────────────────────────────────────
echo "▶ [2/7] 安装 Zsh..."
if ! command -v zsh &>/dev/null; then
    sudo apt-get install -y zsh
fi
echo "   Zsh: $(zsh --version 2>/dev/null | head -1)"

# ── 3. 安装 mise ──────────────────────────────────────────────────────────────
echo "▶ [3/7] 安装 mise..."
if ! command -v mise &>/dev/null; then
    curl https://mise.run | sh
fi
# 将 mise 加入 PATH（当前会话）
export PATH="$HOME/.local/bin:$PATH"
echo "   mise: $(mise --version 2>/dev/null | head -1)"

# ── 4. 通过 mise 安装所有工具 ──────────────────────────────────────────────────
echo "▶ [4/7] 通过 mise 安装工具..."
echo "   运行时: Node.js 24, Python 3.12, Java 21, Go latest"
echo "   CLI 工具: sheldon, zoxide, eza, bat, ripgrep, neovim, opencode, starship"

# 先复制 mise/config.toml 使其生效
mkdir -p "$HOME/.config/mise"
cp "$MISE_SRC" "$HOME/.config/mise/config.toml"

# mise install 安装所有工具
mise install

echo ""
echo "   验证安装:"
echo "   node:    $(node --version 2>/dev/null || echo '✗')"
echo "   python:  $(python --version 2>/dev/null || echo '✗')"
echo "   java:    $(java --version 2>/dev/null | head -1 || echo '✗')"
echo "   go:      $(go version 2>/dev/null || echo '✗')"
echo "   eza:     $(eza --version 2>/dev/null | head -1 || echo '✗')"
echo "   bat:     $(bat --version 2>/dev/null || echo '✗')"
echo "   rg:      $(rg --version 2>/dev/null | head -1 || echo '✗')"
echo "   nvim:    $(nvim --version 2>/dev/null | head -1 || echo '✗')"
echo "   starship: $(starship --version 2>/dev/null | head -1 || echo '✗')"

# ── 5. 安装 NvChad (Neovim 配置) ────────────────────────────────────────────────
echo "▶ [5/8] 安装 NvChad..."
if [ ! -d "$HOME/.config/nvim" ]; then
    git clone https://github.com/NvChad/starter ~/.config/nvim
    echo "   NvChad starter 已克隆，首次启动 nvim 会自动完成插件安装"
else
    echo "   NvChad 已存在"
fi

# ── 6. 配置 Sheldon 插件 ──────────────────────────────────────────────────────
echo "▶ [6/8] 配置 Sheldon 插件..."
mkdir -p "$HOME/.config/sheldon"
cp "$SHELDON_SRC" "$HOME/.config/sheldon/plugins.toml"
echo "   plugins.toml → ~/.config/sheldon/plugins.toml"

# ── 7. 配置 Starship ──────────────────────────────────────────────────────────
echo "▶ [7/8] 配置 Starship..."
mkdir -p "$HOME/.config"
cp "$STARSHIP_SRC" "$HOME/.config/starship.toml"
echo "   starship.toml → ~/.config/starship.toml"

# ── 8. 配置 .zshrc ────────────────────────────────────────────────────────────
echo "▶ [8/8] 配置 .zshrc..."
cp "$ZSHRC_SRC" "$HOME/.zshrc"
echo "   .zshrc → ~/.zshrc"

# ── 设置默认 Shell ───────────────────────────────────────────────────────────
echo ""
echo "▶ 设置 Zsh 为默认 Shell..."
if [[ "$SHELL" != "$(which zsh)" ]]; then
    chsh -s "$(which zsh)"
    echo "   已将默认 Shell 设为 Zsh（需重启终端生效）"
else
    echo "   默认 Shell 已经是 Zsh"
fi

# ── 完成 ─────────────────────────────────────────────────────────────────────
echo ""
echo "=========================================="
echo "  ✅ WSL 环境配置完成！"
echo "=========================================="
echo ""
echo "后续手动步骤:"
echo "  1. 打开 nvim，NvChad 会自动完成插件安装: nvim"
echo "  2. 重启 WSL 终端或执行: exec zsh"
echo "  3. 运行 sheldon lock 生成插件锁定文件"
echo "  4. (可选) 运行启动性能测试:"
echo "     for i in \$(seq 1 5); do"
echo '       /usr/bin/time -f "%e seconds" zsh -i -c exit 2>&1'
echo "     done"
echo "  5. 如果 \`brew shellenv\` 报错，忽略或安装 Homebrew"
echo "  6. 手动在 .zshrc 中添加 GITHUB_TOKEN 等敏感环境变量"
echo ""

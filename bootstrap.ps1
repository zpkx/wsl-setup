# ============================================================================
# Windows 环境前置配置脚本 (bootstrap.ps1)
# 在重装 Windows 后运行，安装 WSL / Warp / Maple Mono 字体
#
# 用法:
#   以管理员身份运行 PowerShell，然后:
#   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
#   .\bootstrap.ps1
#
# 前置条件:
#   - Windows 11 或 Windows 10 22H2+
#   - 网络连接
#   - Synology Drive 已同步 vault
# ============================================================================

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Windows 环境前置配置" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# ── 检测管理员权限 ───────────────────────────────────────────────────────────
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "⚠ 请以管理员身份运行此脚本！" -ForegroundColor Yellow
    Write-Host "   右键 PowerShell → 以管理员身份运行" -ForegroundColor Yellow
    exit 1
}

# ── 1. 启用 WSL ──────────────────────────────────────────────────────────────
Write-Host "▶ [1/4] 启用 WSL..." -ForegroundColor Green
$wslStatus = wsl --status 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "   WSL 已安装，检查更新..." -ForegroundColor Gray
    wsl --update
} else {
    Write-Host "   安装 WSL2 + Ubuntu 24.04..." -ForegroundColor Gray
    wsl --install -d Ubuntu-24.04
}

Write-Host "   WSL 版本:" (wsl --version 2>$null | Select-Object -First 1) -ForegroundColor Gray

# ── 2. 安装 Warp 终端 ────────────────────────────────────────────────────────
Write-Host "▶ [2/4] 安装 Warp 终端..." -ForegroundColor Green
$warpInstalled = Get-AppxPackage -Name "*Warp*" -ErrorAction SilentlyContinue
if (-not $warpInstalled) {
    try {
        winget install --id Warp.Warp --silent --accept-package-agreements --accept-source-agreements
        Write-Host "   Warp 安装完成" -ForegroundColor Gray
    } catch {
        Write-Host "   ⚠ winget 安装失败，请手动从 https://www.warp.dev 下载" -ForegroundColor Yellow
    }
} else {
    Write-Host "   Warp 已安装" -ForegroundColor Gray
}

# ── 3. 安装 Maple Mono 字体 ──────────────────────────────────────────────────
Write-Host "▶ [3/4] 安装 Maple Mono Nerd Font..." -ForegroundColor Green

$fontDir = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
$zipName = "MapleMonoNormal-NF-CN-unhinted.zip"

# 检查是否已安装（按文件名前缀匹配）
$installed = (Get-ChildItem "$fontDir\MapleMono*" -ErrorAction SilentlyContinue).Count -gt 0

if (-not $installed) {
    Write-Host "   下载 Maple Mono 字体..." -ForegroundColor Gray

    # 从 GitHub Releases 获取最新版
    $releasesApi = "https://api.github.com/repos/subframe7536/maple-font/releases/latest"
    try {
        $tag = (Invoke-RestMethod $releasesApi).tag_name
        $downloadUrl = "https://github.com/subframe7536/maple-font/releases/download/$tag/$zipName"
        $zipPath = "$env:TEMP\$zipName"

        Write-Host "   下载: $downloadUrl" -ForegroundColor Gray
        Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath -UseBasicParsing

        # 解压
        $tempExtract = "$env:TEMP\MapleMono"
        if (Test-Path $tempExtract) { Remove-Item -Recurse -Force $tempExtract }
        Expand-Archive -Path $zipPath -DestinationPath $tempExtract

        # 安装字体
        $fontFiles = Get-ChildItem -Path $tempExtract -Recurse -Include "*.ttf", "*.otf"
        if (-not (Test-Path $fontDir)) {
            New-Item -ItemType Directory -Force -Path $fontDir | Out-Null
        }

        foreach ($fontFile in $fontFiles) {
            $dest = "$fontDir\$($fontFile.Name)"
            Copy-Item -Path $fontFile.FullName -Destination $dest -Force
            # 注册字体到注册表
            $regName = "Maple Mono Nerd Font ($($fontFile.BaseName))"
            New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" `
                -Name $regName -Value $fontFile.Name -PropertyType String -Force | Out-Null
        }

        # 清理
        Remove-Item -Recurse -Force $tempExtract, $zipPath -ErrorAction SilentlyContinue

        Write-Host "   Maple Mono Nerd Font 安装完成" -ForegroundColor Gray
    } catch {
        Write-Host "   ⚠ 自动下载失败，请手动下载安装:" -ForegroundColor Yellow
        Write-Host "      https://github.com/subframe7536/maple-font/releases/latest" -ForegroundColor Yellow
    }
} else {
    Write-Host "   Maple Mono 字体已安装" -ForegroundColor Gray
}

# ── 4. 提示下一步 ─────────────────────────────────────────────────────────────
Write-Host "▶ [4/4] 后续步骤" -ForegroundColor Green
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  ✅ Windows 前置配置完成！" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "请继续以下操作:" -ForegroundColor White
Write-Host ""
Write-Host "  1. 打开 Warp → Settings → Appearance → Font → 选择 Maple Mono"
Write-Host "     Features → WSL → 启用 WSL 集成，默认 Shell 设为 Zsh"
Write-Host ""
Write-Host "  2. 进入 WSL，运行 bootstrap.sh 完成 WSL 侧配置:"
Write-Host "     wsl -d Ubuntu-24.04"
Write-Host '     cd /mnt/e/SynologyDrive/Obsidian\ Vault/Software/Windows/dotfiles'
Write-Host "     chmod +x bootstrap.sh && ./bootstrap.sh"
Write-Host ""
Write-Host "  3. 重启 WSL 终端即可使用完整环境"
Write-Host ""

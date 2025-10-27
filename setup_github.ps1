# GitHub仓库配置脚本
# 用于将本地Git仓库连接到GitHub

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  GitHub仓库配置脚本" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# 检查当前Git状态
Write-Host "检查当前Git状态..." -ForegroundColor Yellow
git status
Write-Host ""

# 显示仓库信息
Write-Host "当前仓库信息：" -ForegroundColor Cyan
git remote -v
Write-Host ""

# 检查是否已设置远程仓库
$hasRemote = git remote | Select-String "origin"
if ($hasRemote) {
    Write-Host "⚠️  已存在远程仓库配置" -ForegroundColor Yellow
    Write-Host ""
    $choice = Read-Host "是否要更新远程仓库地址？(Y/N)"
    if ($choice -eq "Y" -or $choice -eq "y") {
        git remote remove origin
        Write-Host "✅ 已移除旧的远程仓库配置" -ForegroundColor Green
    } else {
        Write-Host "❌ 取消操作" -ForegroundColor Red
        exit 0
    }
}

# 设置GitHub用户名
$githubUsername = "cxs00"
Write-Host ""
Write-Host "GitHub用户名: $githubUsername" -ForegroundColor Cyan

# 设置仓库名称
Write-Host ""
$repoName = Read-Host "请输入GitHub仓库名称 (默认: 500_double_led)"
if ([string]::IsNullOrWhiteSpace($repoName)) {
    $repoName = "500_double_led"
}

# 选择协议
Write-Host ""
Write-Host "请选择连接协议：" -ForegroundColor Cyan
Write-Host "1. HTTPS (推荐)" -ForegroundColor Green
Write-Host "2. SSH" -ForegroundColor Green
$protocol = Read-Host "请选择 (1/2)"

if ($protocol -eq "1" -or $protocol -eq "") {
    $remoteUrl = "https://github.com/$githubUsername/$repoName.git"
    Write-Host "✅ 使用HTTPS协议" -ForegroundColor Green
} else {
    $remoteUrl = "git@github.com:$githubUsername/$repoName.git"
    Write-Host "✅ 使用SSH协议" -ForegroundColor Green
}

# 添加远程仓库
Write-Host ""
Write-Host "添加远程仓库..." -ForegroundColor Yellow
git remote add origin $remoteUrl
Write-Host "✅ 远程仓库配置完成" -ForegroundColor Green
Write-Host "   地址: $remoteUrl" -ForegroundColor Cyan
Write-Host ""

# 显示配置结果
git remote -v

# 提示下一步操作
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  下一步操作" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. 创建GitHub仓库：" -ForegroundColor Yellow
Write-Host "   访问: https://github.com/new" -ForegroundColor Cyan
Write-Host "   仓库名称: $repoName" -ForegroundColor Cyan
Write-Host "   设置为 Private 或 Public" -ForegroundColor Cyan
Write-Host "   ⚠️  不要初始化README、.gitignore或license" -ForegroundColor Red
Write-Host ""
Write-Host "2. 推送代码到GitHub：" -ForegroundColor Yellow
Write-Host "   git push -u origin master" -ForegroundColor Green
Write-Host ""
Write-Host "3. 推送所有标签：" -ForegroundColor Yellow
Write-Host "   git push origin --tags" -ForegroundColor Green
Write-Host ""

Write-Host "按任意键退出..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")


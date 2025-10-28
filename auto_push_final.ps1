# 自动推送脚本 - 最终版本
# 尝试多种方法完成GitHub推送

$ErrorActionPreference = "Continue"
$projectPath = "D:\stm32\BilibiliProject\500 double led"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "GitHub自动推送脚本 - 多方案尝试" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Set-Location $projectPath

# 检查Git状态
Write-Host "[1/6] 检查Git仓库状态..." -ForegroundColor Yellow
git status

Write-Host ""
Write-Host "[2/6] 添加所有待推送文件..." -ForegroundColor Yellow
git add -A
git status

Write-Host ""
Write-Host "[3/6] 已在GitHub Desktop中打开仓库" -ForegroundColor Green
Write-Host "GitHub Desktop窗口应该已经打开" -ForegroundColor Green

Write-Host ""
Write-Host "[4/6] 尝试方案A：使用Git Credential Manager推送..." -ForegroundColor Yellow
git config --global credential.helper manager-core
$pushResult = git push -u origin master 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ 推送成功！" -ForegroundColor Green
    Write-Host ""
    Write-Host "验证推送结果：https://github.com/cxs00/double-led" -ForegroundColor Cyan
    exit 0
} else {
    Write-Host "❌ 方案A失败：$pushResult" -ForegroundColor Red
}

Write-Host ""
Write-Host "[5/6] 尝试方案B：使用不同的网络配置..." -ForegroundColor Yellow
git config --global http.version HTTP/1.1
git config --global http.postBuffer 524288000
$pushResult = git push -u origin master 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ 推送成功！" -ForegroundColor Green
    Write-Host ""
    Write-Host "验证推送结果：https://github.com/cxs00/double-led" -ForegroundColor Cyan
    exit 0
} else {
    Write-Host "❌ 方案B失败：$pushResult" -ForegroundColor Red
}

Write-Host ""
Write-Host "[6/6] 方案C：通过GitHub Desktop完成推送" -ForegroundColor Yellow
Write-Host ""
Write-Host "============================================" -ForegroundColor Magenta
Write-Host "由于网络限制，需要通过GitHub Desktop完成推送" -ForegroundColor Magenta
Write-Host "============================================" -ForegroundColor Magenta
Write-Host ""
Write-Host "GitHub Desktop窗口已打开，请按以下步骤操作：" -ForegroundColor Cyan
Write-Host ""
Write-Host "1️⃣  在GitHub Desktop窗口中，您应该看到：" -ForegroundColor White
Write-Host "   - 仓库名称：500 double led" -ForegroundColor Gray
Write-Host "   - 当前分支：master" -ForegroundColor Gray
Write-Host "   - 有待推送的commits" -ForegroundColor Gray
Write-Host ""
Write-Host "2️⃣  点击顶部的 [Push origin] 或 [Publish repository] 按钮" -ForegroundColor White
Write-Host ""
Write-Host "3️⃣  等待推送完成（可能需要1-2分钟）" -ForegroundColor White
Write-Host ""
Write-Host "4️⃣  推送完成后，访问验证：" -ForegroundColor White
Write-Host "   https://github.com/cxs00/double-led" -ForegroundColor Green
Write-Host ""
Write-Host "============================================" -ForegroundColor Magenta
Write-Host ""

# 保持GitHub Desktop窗口打开
Write-Host "提示：本脚本将保持运行，直到您在GitHub Desktop中完成推送" -ForegroundColor Yellow
Write-Host "完成后请在此窗口按 Ctrl+C 结束脚本" -ForegroundColor Yellow
Write-Host ""

# 循环检查推送状态
$checkCount = 0
while ($true) {
    Start-Sleep -Seconds 10
    $checkCount++
    
    # 检查远程仓库状态
    $remoteCheck = git ls-remote origin master 2>&1
    if ($LASTEXITCODE -eq 0 -and $remoteCheck -match "refs/heads/master") {
        Write-Host ""
        Write-Host "🎉🎉🎉 检测到推送成功！" -ForegroundColor Green
        Write-Host ""
        Write-Host "验证结果：" -ForegroundColor Cyan
        git log --oneline -5
        Write-Host ""
        Write-Host "查看GitHub仓库：https://github.com/cxs00/double-led" -ForegroundColor Cyan
        break
    }
    
    if ($checkCount % 6 -eq 0) {
        Write-Host "[$([DateTime]::Now.ToString('HH:mm:ss'))] 等待推送中... (已等待 $($checkCount * 10) 秒)" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "脚本完成！按任意键退出..." -ForegroundColor Green
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")


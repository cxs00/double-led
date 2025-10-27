# GitHub推送脚本
# 自动推送代码到 https://github.com/cxs00/double-led

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  GitHub代码推送脚本" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# 检查是否在正确的目录
$currentPath = Get-Location
Write-Host "当前目录: $currentPath" -ForegroundColor Yellow

# 检查远程仓库配置
Write-Host "`n检查远程仓库配置..." -ForegroundColor Green
git remote -v

# 尝试推送（方法1：HTTPS）
Write-Host "`n方法1: 尝试使用HTTPS推送..." -ForegroundColor Green
$result = git push -u origin master 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ 主分支推送成功!" -ForegroundColor Green
    
    # 推送标签
    Write-Host "`n推送标签..." -ForegroundColor Green
    git push origin --tags
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ 标签推送成功!" -ForegroundColor Green
        Write-Host "`n=====================================" -ForegroundColor Cyan
        Write-Host "  推送完成！" -ForegroundColor Green
        Write-Host "=====================================" -ForegroundColor Cyan
        Write-Host "`n访问您的仓库: https://github.com/cxs00/double-led" -ForegroundColor Yellow
    } else {
        Write-Host "✗ 标签推送失败" -ForegroundColor Red
    }
} else {
    Write-Host "✗ HTTPS推送失败: $result" -ForegroundColor Red
    
    # 尝试方法2：检查是否需要代理
    Write-Host "`n方法2: 检查是否需要配置代理..." -ForegroundColor Yellow
    Write-Host "如果您使用代理上网，请运行以下命令后重试：" -ForegroundColor Yellow
    Write-Host "  git config --global http.proxy http://127.0.0.1:端口号" -ForegroundColor Cyan
    Write-Host "  git config --global https.proxy http://127.0.0.1:端口号" -ForegroundColor Cyan
    
    # 尝试方法3：SSH
    Write-Host "`n方法3: 您也可以尝试使用SSH方式推送：" -ForegroundColor Yellow
    Write-Host "  1. 删除现有remote: git remote remove origin" -ForegroundColor Cyan
    Write-Host "  2. 添加SSH remote: git remote add origin git@github.com:cxs00/double-led.git" -ForegroundColor Cyan
    Write-Host "  3. 推送: git push -u origin master" -ForegroundColor Cyan
    Write-Host "  注意：需要先配置SSH密钥" -ForegroundColor Yellow
    
    # 提供手动推送说明
    Write-Host "`n方法4: 手动推送步骤：" -ForegroundColor Yellow
    Write-Host "  1. 确保网络连接正常" -ForegroundColor Cyan
    Write-Host "  2. 打开PowerShell或Git Bash" -ForegroundColor Cyan
    Write-Host "  3. 运行: git push -u origin master" -ForegroundColor Cyan
    Write-Host "  4. 运行: git push origin --tags" -ForegroundColor Cyan
}

Write-Host "`n按任意键退出..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")


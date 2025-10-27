# 切换到SSH推送方式
# 此脚本会将GitHub远程仓库从HTTPS切换到SSH

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  切换到SSH推送方式" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# 检查SSH密钥是否存在
$sshKeyPath = "$env:USERPROFILE\.ssh\id_rsa.pub"

if (Test-Path $sshKeyPath) {
    Write-Host "✓ 检测到SSH密钥已存在" -ForegroundColor Green
    
    # 显示公钥内容
    Write-Host "`n您的SSH公钥内容：" -ForegroundColor Yellow
    Get-Content $sshKeyPath
    Write-Host ""
    
    Write-Host "请执行以下步骤：" -ForegroundColor Yellow
    Write-Host "1. 复制上面的公钥内容（已自动复制到剪贴板）" -ForegroundColor Cyan
    Get-Content $sshKeyPath | Set-Clipboard
    Write-Host "2. 访问 https://github.com/settings/keys" -ForegroundColor Cyan
    Write-Host "3. 点击 'New SSH key'" -ForegroundColor Cyan
    Write-Host "4. 粘贴公钥并保存" -ForegroundColor Cyan
    Write-Host "`n完成后按任意键继续..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    
} else {
    Write-Host "⚠ 未检测到SSH密钥，现在生成..." -ForegroundColor Yellow
    Write-Host ""
    
    # 生成SSH密钥
    ssh-keygen -t rsa -b 4096 -C "cxs00@github" -f "$env:USERPROFILE\.ssh\id_rsa" -N '""'
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n✓ SSH密钥生成成功！" -ForegroundColor Green
        
        # 显示公钥
        Write-Host "`n您的SSH公钥内容：" -ForegroundColor Yellow
        Get-Content "$env:USERPROFILE\.ssh\id_rsa.pub"
        Write-Host ""
        
        Write-Host "公钥已复制到剪贴板！" -ForegroundColor Green
        Get-Content "$env:USERPROFILE\.ssh\id_rsa.pub" | Set-Clipboard
        
        Write-Host "`n请执行以下步骤：" -ForegroundColor Yellow
        Write-Host "1. 访问 https://github.com/settings/keys" -ForegroundColor Cyan
        Write-Host "2. 点击 'New SSH key'" -ForegroundColor Cyan
        Write-Host "3. 粘贴公钥（已在剪贴板）并保存" -ForegroundColor Cyan
        Write-Host "`n完成后按任意键继续..." -ForegroundColor Yellow
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    } else {
        Write-Host "✗ SSH密钥生成失败" -ForegroundColor Red
        exit 1
    }
}

# 测试SSH连接
Write-Host "`n测试SSH连接..." -ForegroundColor Green
ssh -T git@github.com 2>&1

# 切换远程仓库URL
Write-Host "`n切换远程仓库到SSH方式..." -ForegroundColor Green
git remote set-url origin git@github.com:cxs00/double-led.git

# 验证配置
Write-Host "`n当前远程仓库配置：" -ForegroundColor Yellow
git remote -v

# 尝试推送
Write-Host "`n开始推送..." -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Cyan
git push -u origin master

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✓ 主分支推送成功！" -ForegroundColor Green
    
    # 推送标签
    Write-Host "`n推送标签..." -ForegroundColor Green
    git push origin --tags
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n=====================================" -ForegroundColor Cyan
        Write-Host "  ✓ 推送完成！" -ForegroundColor Green
        Write-Host "=====================================" -ForegroundColor Cyan
        Write-Host "`n访问您的仓库: https://github.com/cxs00/double-led" -ForegroundColor Yellow
    }
} else {
    Write-Host "`n✗ 推送失败" -ForegroundColor Red
    Write-Host "请检查SSH密钥是否已正确添加到GitHub" -ForegroundColor Yellow
}

Write-Host "`n按任意键退出..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")


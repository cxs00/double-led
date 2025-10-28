# Git中文编码修复脚本
# 解决PowerShell和Git中文显示乱码问题

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Git中文编码配置脚本" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 1. 配置PowerShell编码为UTF-8
Write-Host "[1/3] 配置PowerShell编码..." -ForegroundColor Yellow
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
Write-Host "✓ PowerShell编码已设置为UTF-8" -ForegroundColor Green

# 2. 配置Git全局编码设置
Write-Host ""
Write-Host "[2/3] 配置Git编码..." -ForegroundColor Yellow
git config --global core.quotepath false
git config --global i18n.commitencoding utf-8
git config --global i18n.logoutputencoding utf-8
git config --global gui.encoding utf-8
Write-Host "✓ Git编码已设置为UTF-8" -ForegroundColor Green

# 3. 验证配置
Write-Host ""
Write-Host "[3/3] 验证配置..." -ForegroundColor Yellow
Write-Host ""
Write-Host "Git编码配置:" -ForegroundColor Cyan
git config --global --list | Select-String -Pattern "i18n|core.quotepath|gui.encoding"

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "✓ 编码配置完成！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "说明：" -ForegroundColor Cyan
Write-Host "1. 以后使用Git命令时，中文将正确显示" -ForegroundColor White
Write-Host "2. 新的commit信息将使用UTF-8编码" -ForegroundColor White
Write-Host "3. 建议：在PowerShell配置文件中添加编码设置" -ForegroundColor White
Write-Host ""
Write-Host "PowerShell配置文件位置：" -ForegroundColor Yellow
Write-Host "$PROFILE" -ForegroundColor Gray
Write-Host ""
Write-Host "添加以下内容到配置文件：" -ForegroundColor Yellow
Write-Host '[Console]::OutputEncoding = [System.Text.Encoding]::UTF8' -ForegroundColor Gray
Write-Host '[Console]::InputEncoding = [System.Text.Encoding]::UTF8' -ForegroundColor Gray
Write-Host '$OutputEncoding = [System.Text.Encoding]::UTF8' -ForegroundColor Gray
Write-Host ""


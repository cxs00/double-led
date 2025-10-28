@echo off
chcp 65001 >nul
title GitHub自动推送工具

echo.
echo ========================================
echo    GitHub自动推送工具
echo    仓库：cxs00/double-led
echo ========================================
echo.

cd /d "D:\stm32\BilibiliProject\500 double led"

echo [1/4] 检查Git状态...
git status
echo.

echo [2/4] 添加所有文件...
git add -A
echo.

echo [3/4] 配置凭据管理器...
git config --global credential.helper manager-core
git config --global http.version HTTP/1.1
echo.

echo [4/4] 尝试推送到GitHub...
echo.
echo 正在连接GitHub...
echo.

git push -u origin master 2>&1
if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo    ✅ 推送成功！
    echo ========================================
    echo.
    echo 验证地址：https://github.com/cxs00/double-led
    echo.
) else (
    echo.
    echo ========================================
    echo    网络连接失败，启动GitHub Desktop
    echo ========================================
    echo.
    
    REM 打开GitHub Desktop
    start "" "C:\Users\xx\AppData\Local\GitHubDesktop\bin\github.bat" open .
    
    echo GitHub Desktop已启动，请在应用中完成推送：
    echo.
    echo 1. 点击 [Push origin] 按钮
    echo 2. 等待推送完成
    echo 3. 访问 https://github.com/cxs00/double-led 验证
    echo.
)

echo.
echo 按任意键退出...
pause >nul


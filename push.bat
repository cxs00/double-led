@echo off
chcp 65001 >nul
title GitHub Auto Push

echo.
echo ========================================
echo    GitHub Auto Push Tool
echo    Repository: cxs00/double-led
echo ========================================
echo.

cd /d "D:\stm32\BilibiliProject\500 double led"

echo [1/4] Checking Git status...
git status
echo.

echo [2/4] Adding all files...
git add -A
echo.

echo [3/4] Configuring credentials...
git config --global credential.helper manager-core
git config --global http.version HTTP/1.1
echo.

echo [4/4] Pushing to GitHub...
echo.

git push -u origin master 2>&1
if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo    SUCCESS! Push completed!
    echo ========================================
    echo.
    echo Verify at: https://github.com/cxs00/double-led
    echo.
) else (
    echo.
    echo ========================================
    echo    Network failed, opening GitHub Desktop
    echo ========================================
    echo.
    
    start "" "C:\Users\xx\AppData\Local\GitHubDesktop\bin\github.bat" open .
    
    echo GitHub Desktop launched. Please:
    echo 1. Click [Push origin] button
    echo 2. Wait for completion
    echo 3. Verify at: https://github.com/cxs00/double-led
    echo.
)

echo.
pause


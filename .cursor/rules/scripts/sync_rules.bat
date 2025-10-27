@echo off
REM Cursor AI规则同步脚本
REM 功能：同步.cursorrules到Cursor工作区，更新文档
REM 作者：项目开发团队
REM 版本：v1.0
REM 日期：2025-10-25

echo ========================================
echo    Cursor AI 规则同步工具 v1.0
echo ========================================
echo.

REM 设置路径
set "SCRIPT_DIR=%~dp0"
set "RULES_DIR=%SCRIPT_DIR%.."
set "CURRENT_DIR=%RULES_DIR%\current"
set "PROJECT_ROOT=%SCRIPT_DIR%..\..\..\"

echo [1/5] 检查规则文件...
if not exist "%CURRENT_DIR%\.cursorrules" (
    echo [错误] 找不到规则文件: %CURRENT_DIR%\.cursorrules
    pause
    exit /b 1
)
echo [完成] 规则文件存在

echo.
echo [2/5] 复制规则到Cursor工作区...
REM Cursor工作区规则文件位置（通常在项目根目录的.cursor/文件夹）
set "WORKSPACE_CURSORRULES=%PROJECT_ROOT%\.cursor\.cursorrules"

copy /Y "%CURRENT_DIR%\.cursorrules" "%WORKSPACE_CURSORRULES%" >nul 2>&1
if %errorlevel% equ 0 (
    echo [完成] 规则已同步到工作区
) else (
    echo [警告] 无法复制到工作区（可能Cursor未打开或路径错误）
)

echo.
echo [3/5] 生成规则摘要...
REM 统计规则信息
set "RULE_FILE=%CURRENT_DIR%\.cursorrules"
for %%A in ("%RULE_FILE%") do set "FILE_SIZE=%%~zA"
set /a "FILE_SIZE_KB=%FILE_SIZE% / 1024"

echo   - 规则文件大小: %FILE_SIZE_KB% KB
echo   - 规则文件路径: .cursor\rules\current\.cursorrules

echo.
echo [4/5] 检查文档完整性...
set DOC_COUNT=0
if exist "%CURRENT_DIR%\rules_summary.md" set /a DOC_COUNT+=1
if exist "%CURRENT_DIR%\error_solutions.md" set /a DOC_COUNT+=1
if exist "%CURRENT_DIR%\coding_standards.md" set /a DOC_COUNT+=1
if exist "%CURRENT_DIR%\hardware_constraints.md" set /a DOC_COUNT+=1
if exist "%CURRENT_DIR%\smart_stepping_rules.md" set /a DOC_COUNT+=1

echo   - 找到 %DOC_COUNT%/5 个分类文档
if %DOC_COUNT% equ 5 (
    echo   [完成] 所有文档完整
) else (
    echo   [警告] 部分文档缺失
)

echo.
echo [5/5] 记录同步时间...
echo 最后同步时间: %date% %time% > "%RULES_DIR%\.last_sync"
echo [完成] 同步时间已记录

echo.
echo ========================================
echo   同步完成！
echo ========================================
echo.
echo 下一步操作：
echo   1. 重启Cursor或重新加载窗口
echo   2. 验证规则是否生效
echo   3. 查看规则文档：.cursor\rules\RULES_INDEX.md
echo.

pause


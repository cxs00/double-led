@echo off
chcp 65001
echo 自动检测和修复中文乱码文件夹名称...

cd /d "D:\stm32\BilibiliProject\500 double led\software"

echo 检测乱码文件夹...

REM 检测并修复常见的乱码文件夹
if exist "浣跨敤璇存槑" (
    echo 检测到乱码文件夹：浣跨敤璇存槑
    echo 应该重命名为：使用说明
    if not exist "使用说明" (
        ren "浣跨敤璇存槑" "使用说明"
        echo 已修复：浣跨敤璇存槑 -> 使用说明
    ) else (
        echo 目标文件夹已存在，删除乱码文件夹
        rd /s /q "浣跨敤璇存槑"
    )
)

if exist "澶囦唤鐗堟湰" (
    echo 检测到乱码文件夹：澶囦唤鐗堟湰
    echo 应该重命名为：备份版本
    if not exist "备份版本" (
        ren "澶囦唤鐗堟湰" "备份版本"
        echo 已修复：澶囦唤鐗堟湰 -> 备份版本
    ) else (
        echo 目标文件夹已存在，删除乱码文件夹
        rd /s /q "澶囦唤鐗堟湰"
    )
)

if exist "宸ョ▼鏂囦欢" (
    echo 检测到乱码文件夹：宸ョ▼鏂囦欢
    echo 应该重命名为：工程文件
    if not exist "工程文件" (
        ren "宸ョ▼鏂囦欢" "工程文件"
        echo 已修复：宸ョ▼鏂囦欢 -> 工程文件
    ) else (
        echo 目标文件夹已存在，删除乱码文件夹
        rd /s /q "宸ョ▼鏂囦欢"
    )
)

if exist "鐗堟湰鏇存柊璁板綍" (
    echo 检测到乱码文件夹：鐗堟湰鏇存柊璁板綍
    echo 应该重命名为：版本更新记录
    if not exist "版本更新记录" (
        ren "鐗堟湰鏇存柊璁板綍" "版本更新记录"
        echo 已修复：鐗堟湰鏇存柊璁板綍 -> 版本更新记录
    ) else (
        echo 目标文件夹已存在，删除乱码文件夹
        rd /s /q "鐗堟湰鏇存柊璁板綍"
    )
)

if exist "閰嶇疆鎸囧崡" (
    echo 检测到乱码文件夹：閰嶇疆鎸囧崡
    echo 应该重命名为：配置指南
    if not exist "配置指南" (
        ren "閰嶇疆鎸囧崡" "配置指南"
        echo 已修复：閰嶇疆鎸囧崡 -> 配置指南
    ) else (
        echo 目标文件夹已存在，删除乱码文件夹
        rd /s /q "閰嶇疆鎸囧崡"
    )
)

echo 检查修复结果...
dir /b

echo 自动修复完成！
echo 如果发现新的乱码文件夹，请运行此脚本进行修复。
pause

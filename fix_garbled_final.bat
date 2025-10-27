@echo off
chcp 65001
echo 最终修复所有乱码文件名...

cd "D:\stm32\BilibiliProject\500 double led"

echo 当前目录内容：
dir /b *.md *.txt

echo.
echo 开始修复乱码文件名...

REM 修复所有乱码文件名
if exist "AI鍗忎綔鎸囧崡.md" (
    ren "AI鍗忎綔鎸囧崡.md" "AI协作指南.md"
    echo 已修复：AI鍗忎綔鎸囧崡.md -> AI协作指南.md
)

if exist "娴嬭瘯楠岃瘉鏂囨。.md" (
    ren "娴嬭瘯楠岃瘉鏂囨。.md" "测试验证文档.md"
    echo 已修复：娴嬭瘯楠岃瘉鏂囨。.md -> 测试验证文档.md
)

if exist "椤圭洰鎬荤粨.md" (
    ren "椤圭洰鎬荤粨.md" "项目总结.md"
    echo 已修复：椤圭洰鎬荤粨.md -> 项目总结.md
)

if exist "楠屾敹娓呭崟.md" (
    ren "楠屾敹娓呭崟.md" "验收清单.md"
    echo 已修复：楠屾敹娓呭崟.md -> 验收清单.md
)

if exist "淇鎬荤粨.txt" (
    ren "淇鎬荤粨.txt" "修复总结.txt"
    echo 已修复：淇鎬荤粨.txt -> 修复总结.txt
)

if exist "鍗忎綔鎸囧崡.md" (
    ren "鍗忎綔鎸囧崡.md" "协作指南.md"
    echo 已修复：鍗忎綔鎸囧崡.md -> 协作指南.md
)

if exist "鍙樻洿鏃ュ織.md" (
    ren "鍙樻洿鏃ュ織.md" "变更日志.md"
    echo 已修复：鍙樻洿鏃ュ織.md -> 变更日志.md
)

if exist "鏁呴殰鎺掗櫎鎸囧崡.md" (
    ren "鏁呴殰鎺掗櫎鎸囧崡.md" "故障排除指南.md"
    echo 已修复：鏁呴殰鎺掗櫎鎸囧崡.md -> 故障排除指南.md
)

if exist "鏂囨。绱㈠紩.md" (
    ren "鏂囨。绱㈠紩.md" "文档索引.md"
    echo 已修复：鏂囨。绱㈠紩.md -> 文档索引.md
)

if exist "鏈€缁堟€荤粨.md" (
    ren "鏈€缁堟€荤粨.md" "最终总结.md"
    echo 已修复：鏈€缁堟€荤粨.md -> 最终总结.md
)

echo.
echo 修复完成！当前目录内容：
dir /b *.md *.txt

echo.
echo 乱码文件名修复完成！
pause

# 创建规则仓库和配置双向同步 - 一键执行脚本
# 项目：500_double_led
# 规则仓库：stm32-cursor-rules

param(
    [string]$ProxyAddr = "127.0.0.1:7897"
)

$ErrorActionPreference = "Stop"

# 配置
$PROJECT_DIR = "D:\stm32\BilibiliProject\500 double led"
$TEMP_DIR = "D:\stm32\BilibiliProject\stm32-cursor-rules-temp"
$RULES_REPO = "https://github.com/cxs00/stm32-cursor-rules.git"
$PROJECT_REPO = "https://github.com/cxs00/double-led.git"

# 辅助函数
function Print-Header {
    param([string]$Message)
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "  $Message" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host ""
}

function Print-Step {
    param([string]$Step, [string]$Message)
    Write-Host "[$Step] $Message" -ForegroundColor Yellow
}

function Print-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Print-Error {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

function Setup-Proxy {
    git config --global http.proxy "http://$ProxyAddr"
    git config --global https.proxy "http://$ProxyAddr"
}

function Clear-Proxy {
    git config --global --unset http.proxy 2>$null
    git config --global --unset https.proxy 2>$null
}

# 主流程
try {
    Print-Header "创建规则仓库和配置双向同步"

    # 第1步：推送到项目仓库
    Print-Step "1/5" "推送规则到项目仓库（double-led）..."
    cd $PROJECT_DIR

    Setup-Proxy
    
    try {
        git push origin master
        Print-Success "代码已推送到项目仓库"
        
        # 创建或更新Tag
        git tag -a 500_double_led-Rules-v1.1.0 -m "规则系统v1.1.0 - 添加元规则、检查点和同步系统" -f
        git push origin --tags -f
        Print-Success "Tag已创建并推送"
    } catch {
        Print-Error "推送到项目仓库失败：$_"
    }
    
    Clear-Proxy
    Write-Host ""

    # 第2步：提示创建GitHub仓库
    Print-Step "2/5" "创建GitHub仓库..."
    Write-Host ""
    Write-Host "请在浏览器中创建新的GitHub仓库：" -ForegroundColor White
    Write-Host ""
    Write-Host "  1. 访问：https://github.com/new" -ForegroundColor Cyan
    Write-Host "  2. 仓库名称：stm32-cursor-rules" -ForegroundColor White
    Write-Host "  3. 描述：STM32 Cursor AI Development Rules Repository" -ForegroundColor White
    Write-Host "  4. 可见性：Public（推荐）" -ForegroundColor White
    Write-Host "  5. ❌ 不要勾选任何初始化选项" -ForegroundColor Red
    Write-Host "  6. 点击 'Create repository'" -ForegroundColor White
    Write-Host ""
    
    $continue = Read-Host "创建完成后输入 'y' 继续，或 'n' 退出 [y/n]"
    if ($continue -ne 'y') {
        Print-Error "用户取消操作"
        exit 1
    }
    Write-Host ""

    # 第3步：准备规则仓库
    Print-Step "3/5" "准备规则仓库内容..."
    
    # 清理临时目录
    if (Test-Path $TEMP_DIR) {
        Remove-Item -Path $TEMP_DIR -Recurse -Force
        Print-Success "清理旧的临时目录"
    }

    # 创建临时目录
    New-Item -ItemType Directory -Path $TEMP_DIR | Out-Null
    cd $TEMP_DIR

    # 初始化Git
    git init
    git branch -M main
    Print-Success "Git仓库初始化完成"

    # 复制文件
    Copy-Item "$PROJECT_DIR\.cursor\rules\current\.cursorrules" -Destination "."
    Copy-Item "$PROJECT_DIR\.cursor\rules\current\error_solutions.md" -Destination "."
    Copy-Item "$PROJECT_DIR\.cursor\rules\CHANGELOG.md" -Destination "."
    Copy-Item "$PROJECT_DIR\STM32-Cursor-Rules-README.md" -Destination "README.md"
    
    New-Item -ItemType Directory -Path "scripts" -Force | Out-Null
    Copy-Item "$PROJECT_DIR\scripts\sync-rules.sh" -Destination "scripts\"
    
    Print-Success "规则文件复制完成"

    # 创建.gitignore
    @"
# macOS
.DS_Store

# Windows
Thumbs.db
Desktop.ini

# 临时文件
*.tmp
*.bak
*~

# 编辑器
.vscode/
.idea/
*.swp
"@ | Out-File -FilePath ".gitignore" -Encoding utf8

    Print-Success ".gitignore创建完成"

    # 提交
    git add .
    git commit -m "feat: initial commit - STM32 Cursor Rules v1.1.0

🎯 规则系统v1.1.0特性：
- ✅ 元规则系统（最高优先级）
- ✅ 强制检查点系统（4个检查点）
- ✅ 完整验证流程规范（STM32版）
- ✅ Git双向同步规则
- ✅ 15个错误解决方案
- ✅ 硬件架构规则
- ✅ 智能步进规则

📦 仓库说明：
本仓库专门用于保存和管理STM32项目的Cursor AI规则
支持双向同步，可跨项目共享

🔗 项目仓库：https://github.com/cxs00/double-led
"
    
    Print-Success "初始提交完成"

    # 创建Tag
    git tag -a v1.1.0 -m "规则系统v1.1.0 - 元规则、检查点、验证流程、双向同步"
    Print-Success "Tag v1.1.0创建完成"
    Write-Host ""

    # 第4步：推送到规则仓库
    Print-Step "4/5" "推送到规则仓库（stm32-cursor-rules）..."
    
    Setup-Proxy
    
    try {
        git remote add origin $RULES_REPO
        git push -u origin main
        Print-Success "main分支已推送"
        
        git push origin --tags
        Print-Success "Tags已推送"
    } catch {
        Print-Error "推送失败：$_"
        Print-Error "请检查仓库是否已创建，或者网络连接"
        throw
    }
    
    Clear-Proxy
    Write-Host ""

    # 第5步：清理临时目录
    Print-Step "5/5" "清理临时文件..."
    cd $PROJECT_DIR
    Remove-Item -Path $TEMP_DIR -Recurse -Force
    Print-Success "临时目录已清理"
    Write-Host ""

    # 完成
    Print-Header "✅ 规则仓库创建成功！"
    
    Write-Host "📦 仓库信息：" -ForegroundColor Cyan
    Write-Host "  规则仓库：https://github.com/cxs00/stm32-cursor-rules" -ForegroundColor White
    Write-Host "  项目仓库：https://github.com/cxs00/double-led" -ForegroundColor White
    Write-Host ""
    
    Write-Host "🔄 双向同步已配置完成！" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "📋 使用方法：" -ForegroundColor Cyan
    Write-Host "  # 拉取云端更新" -ForegroundColor Gray
    Write-Host "  bash scripts/sync-rules.sh pull" -ForegroundColor White
    Write-Host ""
    Write-Host "  # 推送本地更新" -ForegroundColor Gray
    Write-Host "  bash scripts/sync-rules.sh push" -ForegroundColor White
    Write-Host ""
    Write-Host "  # 检查同步状态" -ForegroundColor Gray
    Write-Host "  bash scripts/sync-rules.sh status" -ForegroundColor White
    Write-Host ""
    
    Write-Host "🎉 所有操作完成！" -ForegroundColor Green
    Write-Host ""

} catch {
    Print-Error "脚本执行失败：$_"
    Clear-Proxy
    exit 1
} finally {
    Clear-Proxy
}


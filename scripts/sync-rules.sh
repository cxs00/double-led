#!/bin/bash
# Git规则双向同步脚本 - STM32项目版
# 项目：500_double_led
# 规则仓库：stm32-cursor-rules

set -e  # 遇到错误立即退出

# ==================== 配置区域 ====================
PROJECT_NAME="500_double_led"
PROJECT_REPO="https://github.com/cxs00/double-led.git"
RULES_REPO="https://github.com/cxs00/stm32-cursor-rules.git"
RULES_FILE=".cursor/rules/current/.cursorrules"
CURRENT_DIR=$(cd "$(dirname "$0")/.." && pwd)

# 代理配置（如果需要）
USE_PROXY=true
PROXY_ADDR="127.0.0.1:7897"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ==================== 辅助函数 ====================

# 打印彩色消息
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 配置Git代理
setup_proxy() {
    if [ "$USE_PROXY" = true ]; then
        print_info "配置Git代理: $PROXY_ADDR"
        git config --global http.proxy http://$PROXY_ADDR
        git config --global https.proxy http://$PROXY_ADDR
    fi
}

# 清除Git代理
clear_proxy() {
    if [ "$USE_PROXY" = true ]; then
        git config --global --unset http.proxy 2>/dev/null || true
        git config --global --unset https.proxy 2>/dev/null || true
        print_info "已清除代理配置"
    fi
}

# 获取规则版本号
get_rules_version() {
    grep "# 规则版本：" "$CURRENT_DIR/$RULES_FILE" | head -1 | grep -o "v[0-9]\+\.[0-9]\+\.[0-9]\+" || echo "v1.0.0"
}

# ==================== 主要功能 ====================

# 📥 从云端拉取规则更新
sync_from_remote() {
    print_info "🔍 检查云端规则更新..."
    
    cd "$CURRENT_DIR"
    
    # 获取远程更新
    setup_proxy
    git fetch origin 2>/dev/null || {
        print_warning "无法连接到项目仓库"
    }
    clear_proxy
    
    # 检查规则文件是否有更新
    if git diff --quiet HEAD origin/main -- "$RULES_FILE" 2>/dev/null; then
        print_success "✅ 规则已是最新版本"
        return 0
    fi
    
    # 检查本地是否有未提交的修改
    if git diff --quiet "$RULES_FILE"; then
        # 本地无修改，直接拉取
        print_info "📥 发现云端规则更新，自动拉取..."
        setup_proxy
        git pull origin main
        clear_proxy
        print_success "✅ 云端规则已拉取"
    else
        # 本地有修改，提示用户
        print_warning "⚠️  本地规则有未提交的修改"
        echo ""
        echo "选择操作："
        echo "  1) 暂存本地修改，拉取云端（推荐）"
        echo "  2) 放弃本地修改，使用云端版本"
        echo "  3) 保留本地修改，跳过同步"
        read -p "请选择 [1-3]: " choice
        
        case $choice in
            1)
                git stash push -m "Auto-stash before sync $(date +%Y%m%d-%H%M%S)" "$RULES_FILE"
                setup_proxy
                git pull origin main
                clear_proxy
                git stash pop
                print_success "✅ 已合并云端更新和本地修改"
                ;;
            2)
                git checkout origin/main -- "$RULES_FILE"
                print_success "✅ 已使用云端规则（本地修改已丢弃）"
                ;;
            3)
                print_info "⊘ 跳过同步，保留本地修改"
                ;;
        esac
    fi
}

# 📤 推送规则到云端（双仓库）
push_to_remote() {
    print_info "📤 准备推送规则到云端..."
    
    cd "$CURRENT_DIR"
    
    # 检查规则文件是否有修改
    if git diff --quiet "$RULES_FILE"; then
        print_info "⊘ 规则文件无修改，无需推送"
        return 0
    fi
    
    print_info "📝 检测到规则文件修改"
    
    # 显示修改摘要
    echo ""
    echo "修改摘要："
    git diff --stat "$RULES_FILE"
    echo ""
    
    # 获取当前规则版本
    local current_version=$(get_rules_version)
    print_info "当前规则版本：$current_version"
    
    # 读取提交说明
    read -p "输入提交说明（回车使用默认）: " commit_msg
    if [ -z "$commit_msg" ]; then
        commit_msg="feat: 更新规则文件 $current_version"
    fi
    
    # 提交规则
    git add "$RULES_FILE"
    git commit -m "$commit_msg"
    
    # 推送到项目仓库
    print_info "📤 推送到项目仓库（double-led）..."
    setup_proxy
    if git push origin main; then
        print_success "✅ 规则已备份到项目仓库"
    else
        print_warning "⚠️  项目仓库推送失败"
    fi
    clear_proxy
    
    # 推送到规则仓库
    print_info "📤 推送到规则仓库（stm32-cursor-rules）..."
    setup_proxy
    if git push "$RULES_REPO" HEAD:main 2>/dev/null; then
        print_success "✅ 规则已同步到stm32-cursor-rules仓库"
        
        # 自动创建并推送Tag
        create_and_push_tag "$current_version"
    else
        print_warning "⚠️  规则仓库推送失败，可能仓库不存在或无权限"
        print_info "提示：请先创建仓库 https://github.com/cxs00/stm32-cursor-rules"
    fi
    clear_proxy
}

# 🏷️  创建并推送Tag到双仓库
create_and_push_tag() {
    local version=$1
    
    if [ -z "$version" ]; then
        print_warning "⚠️  未检测到版本号，跳过Tag创建"
        return 1
    fi
    
    local tag_name="${PROJECT_NAME}-Rules-${version}"
    print_info "🏷️  自动创建Tag: $tag_name"
    
    # 如果Tag已存在，先删除
    if git rev-parse "$tag_name" >/dev/null 2>&1; then
        print_warning "⚠️  Tag已存在，删除旧Tag"
        git tag -d "$tag_name"
        setup_proxy
        git push origin ":refs/tags/$tag_name" 2>/dev/null || true
        git push "$RULES_REPO" ":refs/tags/$tag_name" 2>/dev/null || true
        clear_proxy
    fi
    
    # 创建新Tag
    git tag -a "$tag_name" -m "规则系统 $version - 自动标记

📋 规则更新：$(date +%Y-%m-%d)
🔄 自动同步到GitHub（双仓库）
✅ 包含所有规则变更
📦 仓库：stm32-cursor-rules（主）+ double-led（备份）"
    
    # 推送Tag到两个远程仓库
    local tag_push_success=0
    
    setup_proxy
    
    # 推送到规则仓库（主要）
    if git push "$RULES_REPO" "$tag_name" 2>/dev/null; then
        print_success "✅ Tag已推送到stm32-cursor-rules仓库"
        tag_push_success=1
    else
        print_warning "⚠️  stm32-cursor-rules仓库Tag推送失败"
    fi
    
    # 推送到项目仓库（备份）
    if git push origin "$tag_name"; then
        print_success "✅ Tag已推送到double-led仓库（备份）"
    else
        print_warning "⚠️  double-led仓库Tag推送失败"
    fi
    
    clear_proxy
    
    if [ $tag_push_success -eq 1 ]; then
        print_success "🎉 规则和Tag已成功同步到stm32-cursor-rules！"
    else
        print_warning "⚠️  Tag推送部分失败，但规则文件已推送"
    fi
}

# 📊 检查同步状态
check_sync_status() {
    print_info "📊 规则同步状态"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    cd "$CURRENT_DIR"
    
    # 本地版本
    local local_version=$(get_rules_version)
    echo "本地规则版本：$local_version"
    
    # 最后提交时间
    local last_commit=$(git log -1 --format="%ci" -- "$RULES_FILE" 2>/dev/null || echo "未知")
    echo "最后修改时间：$last_commit"
    
    # 是否有未提交的修改
    if ! git diff --quiet "$RULES_FILE"; then
        print_warning "⚠️  有未提交的规则修改"
    else
        print_success "✅ 无未提交的修改"
    fi
    
    # 是否有未推送的提交
    setup_proxy
    git fetch origin 2>/dev/null || true
    clear_proxy
    
    local unpushed=$(git log origin/main..HEAD --oneline -- "$RULES_FILE" 2>/dev/null | wc -l)
    if [ $unpushed -gt 0 ]; then
        print_warning "⚠️  有 $unpushed 个未推送的规则提交"
    else
        print_success "✅ 所有规则修改已推送"
    fi
    
    # 是否有未拉取的提交
    local unpulled=$(git log HEAD..origin/main --oneline -- "$RULES_FILE" 2>/dev/null | wc -l)
    if [ $unpulled -gt 0 ]; then
        print_warning "⚠️  云端有 $unpulled 个新的规则提交"
    else
        print_success "✅ 已同步所有云端更新"
    fi
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# ==================== 主函数 ====================

main() {
    echo ""
    echo "╔════════════════════════════════════════════════╗"
    echo "║   Git规则双向同步系统 - STM32项目版           ║"
    echo "║   项目：500_double_led                        ║"
    echo "╚════════════════════════════════════════════════╝"
    echo ""
    
    case "${1:-}" in
        pull|sync)
            sync_from_remote
            ;;
        push)
            push_to_remote
            ;;
        status)
            check_sync_status
            ;;
        auto)
            # 自动同步：先拉取，后推送
            sync_from_remote
            push_to_remote
            ;;
        *)
            echo "用法: $0 {pull|push|status|auto}"
            echo ""
            echo "命令说明："
            echo "  pull    - 从云端拉取规则更新"
            echo "  push    - 推送本地规则到云端（双仓库）"
            echo "  status  - 检查同步状态"
            echo "  auto    - 自动同步（先拉后推）"
            echo ""
            exit 1
            ;;
    esac
    
    echo ""
}

# 捕获退出信号，确保清理代理配置
trap clear_proxy EXIT

# 执行主函数
main "$@"


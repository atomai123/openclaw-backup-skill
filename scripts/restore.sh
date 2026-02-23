#!/bin/bash
# OpenClaw Restore Script
# 用途：从备份恢复OpenClaw工作空间

set -e -o pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" && pwd )"
LOG_FILE="/root/repos/openclaw_backup/backup.log"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

WORKSPACE_DIR="/root/.openclaw/workspace"
BACKUP_DIR="/root/repos/openclaw_backup"

log_info() {
    echo -e "${GREEN}[INFO]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $(date '+%Y-%m-%m-%d %H:%M:%S') - $1"
}

if [ $# -eq 0 ]; then
    echo "用法: $0 <backup_name> [options]"
    echo ""
    echo "选项："
    echo "  --force     强制覆盖现有文件"
    echo "  --skip-conflicts  跳过冲突文件"
    echo ""
    echo "示例："
    echo "  $0 20260223_100727 --force"
    echo ""
    exit 1
fi

BACKUP_NAME="$1"
FORCE=false
SKIP_CONFLICTS=false

# 解析选项
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --force)
            FORCE=true
            shift
            ;;
        --skip-conflicts)
            SKIP_CONFLICTS=true
            shift
            ;;
        -*)
            log_error "未知选项: $1"
            exit 1
            ;;
        *)
            BACKUP_NAME="$1"
            ;;
    esac
    shift
done

BACKUP_PATH="$BACKUP_DIR/backups/$BACKUP_NAME"

if [ ! -d "$BACKUP_PATH" ]; then
    log_error "备份不存在: $BACKUP_PATH"
    exit 1
fi

# 检查备份清单
MANIFEST="$BACKUP_PATH/backup-manifest.txt"
if [ ! -f "$MANIFEST" ]; then
    log_error "备份清单不存在: $MANIFEST"
    exit 1
fi

# 显示备份信息
echo ""
echo "==================================="
echo "OpenClaw 恢复工具"
echo "==================================="
echo ""
echo "备份名称: $BACKUP_NAME"
echo ""

# 解析备份清单
BACKUP_TIME=$(grep "备份时间:" "$MANIFEST" | cut -d:2 -f1)
BACKUP_SIZE=$(grep "备份大小:" "$MANIFEST" | cut -d:2 -f1)
FILE_COUNT=$(grep "文件数量:" "$MANIFEST" | cut -d:2 -f1)

echo "备份时间: $BACKUP_TIME"
echo "备份大小: $BACKUP_SIZE"
echo "文件数量: $FILE_COUNT"
echo ""
echo "备份内容："
echo "- 核心文件（7个）"
echo "- 记忆目录"
echo "- 技能目录"
echo "- 工具目录"
echo ""

# 确认恢复
echo "警告：这将覆盖现有文件！"
read -p "确认恢复吗？(y/n): " confirm

if [ "$confirm" != "y" ]; then
    echo "已取消恢复"
    exit 0
fi

# 恢复核心文件
echo ""
echo "正在恢复核心文件..."
for file in MEMORY.md SOUL.md USER.md IDENTITY.md TOOLS.md AGENTS.md HEARTBEAT.md; do
    if [ -f "$BACKUP_PATH/$file" ]; then
        cp "$BACKUP_PATH/$file" "$WORKSPACE_DIR/"
        log_success "  ✓ $file"
    else
        log_warning "  ✗ $file (备份中不存在)"
    fi
done

# 恢复记忆目录
if [ -d "$BACKUP_PATH/memory" ]; then
    if [ "$FORCE" = "false" ] && [ -d "$WORKSPACE_DIR/memory" ]; then
        echo ""
        echo "警告：现有 memory/ 目录将被覆盖！"
        read -p "继续？(y/n): " continue_memory
        
        if [ "$continue_memory" = "y" ]; then
            rm -rf "$WORKSPACE_DIR/memory"
            cp -r "$BACKUP_PATH/memory" "$WORKSPACE_DIR/memory"
            log_success "  ✓ memory/ 目录"
        elif [ "$SKIP_CONFLICTS" = true ]; then
            log_warning "  ⚠️ 跳过 memory/ 目录（存在冲突）"
        else
            echo "取消恢复"
            exit 1
        fi
    else
        cp -r "$BACKUP_PATH/memory" "$WORKSPACE_DIR/memory/"
        log_success "  ✓ memory/ 目录"
    fi
else
    log_warning "  ✗ memory/ 目录（备份中不存在）"
fi

# 恢复技能目录
if [ -d "$BACKUP_PATH/skills" ]; then
    if [ "$FORCE" = "false" ] && [ -d "$WORKSPACE_DIR/skills" ]; then
        echo ""
        echo "警告：现有 skills/ 目录将被覆盖！"
        read -p "继续？(y/n): " continue_skills
        
        if [ "$continue_skills" = "y" ]; then
            rm -rf "$WORKSPACE_DIR/skills"
            cp -r "$BACKUP_PATH/skills" "$WORKSPACE_DIR/skills"
            log_success "  ✓ skills/ 目录"
        elif [ "$SKIP_CONFLICTS" = true ]; then
            log_warning "  ⚠️ 跳过 skills/ 目录（存在冲突）"
        else
            echo "取消恢复"
            exit 1
        fi
    else
        cp -r "$BACKUP_PATH/skills" "$WORKSPACE_DIR/skills/"
        log_success "  ✓ skills/ 目录"
    fi
else
    log_warning "  ✗ skills/ 目录（备份中不存在）"
fi

# 恢复工具目录
if [ -d "$BACKUP_PATH/tools" ]; then
    if [ "$FORCE" = "false ] && [ -d "$WORKSPACE_DIR/tools" ]; then
        echo ""
        echo "警告：现有 tools/ 目录将被覆盖！"
        read -p "继续？(y/n): " continue_tools
        
        if [ "$continue_tools" = "y" ]; then
            rm -rf "$WORKSPACE_DIR/tools"
            cp -r "$BACKUP_PATH/tools" "$WORKSPACE_DIR/tools"
            log_success "  ✓ tools/ 目录"
        elif [ "$SKIP_CONFLICTS" = true ]; then
            log_warning " ⚠️ 賳过 tools/ 目录（存在冲突）"
        else
            echo "取消恢复"
            exit 1
        fi
    else
        cp -r "$BACKUP_PATH/tools" "$WORKSPACE_DIR/tools/"
        log_success "  ✓ tools/ 目录"
    fi
else
    log_warning "  ✗ tools/ 目录（备份中不存在）"
fi

# 恢复备份清单
cp "$BACKUP_PATH/backup-manifest.txt" "$WORKSPACE_DIR/backup-manifest-$(date +%Y%m%d).txt"

echo ""
echo "==================================="
echo "恢复完成！"
echo "==================================="
echo ""
echo "已从备份恢复到工作空间"
echo ""
echo "备份时间: $BACKUP_TIME"
echo "备份大小: $BACKUP_SIZE"
echo ""
echo "下一步："
echo "1. 重启OpenClaw: openclaw restart"
echo "2. 验证数据完整性"
echo ""
echo "备份清单已保存到: $WORKSPACE_DIR/backup-manifest-$(date +%Y%m%d).txt"

log_success "恢复完成！"

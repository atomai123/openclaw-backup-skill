#!/bin/bash
# OpenClaw Backup Script
# 用途：完整备份OpenClaw工作空间到GitHub私有仓库

set -e -o pipefail

# 配置文件路径
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" && pwd )"
CONFIG_FILE="$SCRIPT_DIR/config.json"
LOG_FILE="$SCRIPT_DIR/backup.log"

# 默认配置
BACKUP_DIR="${BACKUP_DIR:-/root/repos/openclaw_backup}"
RETENTION_DAYS="${RETENTION_DAYS:-30}"
GIT_REMOTE="${GIT_REMOTE:-origin}"
ENABLE_AUTO_PUSH="${ENABLE_AUTO_PUSH:-true}"
COMPRESS_BACKUPS="${COMPRESS_BACKUPS:-false}"
BACKUP_LIST=(
    "MEMORY.md"
    "SOUL.md"
    "USER.md"
    "IDENTITY.md"
    "TOOLS.md"
    "AGENTS.md"
    "HEARTBEAT.md"
)

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

WORKSPACE_DIR="/root/.openclaw/workspace"
LOG_FILE="/root/repos/openclaw_backup/backup.log"

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
    echo -e "${RED}[ERROR]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# 创建备份目录
mkdir -p "$BACKUP_DIR/backups/$TIMESTAMP"

# 备份核心文件
log_info "备份核心文件..."
for file in "${BACKUP_LIST[@]}"; do
    if [ -f "$WORKSPACE_DIR/$file" ]; then
        cp "$WORKSPACE_DIR/$file" "$BACKUP_DIR/backups/$TIMESTAMP/"
        log_success "  ✓ $file"
    else
        log_warning "  ✗ $file (文件不存在)"
    fi
done

# 备份记忆目录
if [ -d "$WORKSPACE_DIR/memory" ]; then
    cp -r "$WORKSPACE_DIR/memory" "$BACKUP_DIR/backups/$TIMESTAMP/memory/"
    log_success "  ✓ memory/ 目录"
else
    log_warning "  ✗ memory/ 目录不存在"
fi

# 备份技能目录
if [ -d "$WORKSPACE_DIR/skills" ]; then
    cp -r "$WORKSPACE_DIR/skills" "$BACKUP_DIR/backups/$TIMESTAMP/skills/"
    log_success "  ✓ skills/ 目录"
else
    log_warning "  ✗ skills/ 目录不存在"
fi

# 备份工具目录
if [ -d "$WORKSPACE_DIR/tools" ]; then
    cp -r "$WORKSPACE_DIR/tools" "$BACKUP_DIR/backups/$TIMESTAMP/tools/"
    log_success "  ✓ tools/ 目录"
else
    log_warning "  ✗ tools/ 目录不存在"
fi

# 创建备份清单
BACKUP_SIZE=$(du -sh "$BACKUP_DIR/backups/$TIMESTAMP")
FILE_COUNT=$(find "$BACKUP_DIR/backups/$TIMESTAMP" -type f | wc -l)
cat > "$BACKUP_DIR/backups/$TIMESTAMP/backup-manifest.txt" << EOF
OpenClaw 备份清单
==================

备份时间: $TIMESTAMP
备份主机: $(hostname)
系统版本: $(uname -a)

备份内容:
- 核心文件（MEMORY.md, SOUL.md等）
- 记忆文件（memory/目录）
- 用户技能（skills/目录）
- 工具文件（tools/目录）

备份大小: $BACKUP_SIZE
文件数量: $FILE_COUNT

==================
生成时间: $(date '+%Y-%m-%d %H:%M:%S')
备份类型: $BACKUP_TYPE
EOF

log_info "备份大小: $BACKUP_SIZE"
log_info "文件数量: $FILE_COUNT"

# 提交到Git
cd "$BACKUP_DIR"

git add . 2>&1 | grep -v "^add.*backups/$TIMESTAMP" | head -5

if [ $? -eq 0 ]; then
    COMMIT_MSG="📦 手动备份: $TIMESTAMP"
    git commit -m "$COMMIT_MSG" 2>&1 | tail -3
    log_success "  ✓ Git提交成功 (commit: $(cd "$BACKUP_DIR" && git rev-parse --short HEAD))"
else
    log_error "  ✗ Git提交失败"
    cd -
    return 1
fi

# Git推送到远程仓库
if [ "$ENABLE_AUTO_PUSH" = "true" ]; then
    log_info "推送到远程仓库..."
    git push origin main 2>&1 | tail -3
    
    if [ $? -eq 0 ]; then
        COMMIT_HASH=$(cd "$BACKUP_DIR" && git rev-parse --short HEAD)
        log_success " ✓ Git推送成功 (commit: $COMMIT_HASH)"
    else
        log_error "  ✗ Git推送失败"
        cd -
        return 2
    fi
else
    log_info "Git推送已禁用（跳过推送）"
    COMMIT_HASH=$(cd "$BACKUP_DIR" && git rev-parse --short HEAD)
    log_info "   本地提交: $COMMIT_HASH"
fi

cd -

log_success "备份完成！"
echo ""
echo "备份位置: $BACKUP_DIR/backups/$TIMESTAMP"
echo "备份大小: $BACKUP_SIZE"
echo "文件数量: $FILE_COUNT"

# 返回0表示成功
return 0

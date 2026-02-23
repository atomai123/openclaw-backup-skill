#!/bin/bash
# OpenClaw Backup Cleanup Script
# 用途：清理指定天数前的旧备份，释放磁盘空间

set -e -o pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" && pwd )"
LOG_FILE="/root/repos/openclaw_backup/backup.log"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

BACKUP_DIR="/root/repos/openclaw_backup/backups"
DEFAULT_RETENTION_DAYS=30

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

# 解析参数
RETENTION_DAYS=${1:-$DEFAULT_RETENTION_DAYS}

# 检查备份目录是否存在
if [ ! -d "$BACKUP_DIR" ]; then
    log_error "备份目录不存在: $BACKUP_DIR"
    exit 1
fi

log_info "开始清理 $RETENTION_DAYS 天前的备份..."

# 查找要删除的备份
OLD_BACKUPS=$(find "$BACKUP_DIR/backups" -maxdepth 1 -mindepth 1 -type d -mtime +$RETENTION_DAYS)

if [ -z "$OLD_BACKUPS" ]; then
    TOTAL_SIZE=$(du -sh "$OLD_BACKUPS" | cut -f1)
    TOTAL_COUNT=$(echo "$OLD_BACKUPS" | tr ' ' ' '\n' | wc -l)
    DELETED_COUNT=0
    
    log_info "找到 $TOTAL_COUNT 个超过 $RETENTION_DAYS 天的备份"
    log_info "总大小: $TOTAL_SIZE"
    
    for dir in $OLD_BACKUPS; do
        rm -rf "$dir"
        ((DELETED_COUNT++))
        log_info "  ✓ 已删除: $(basename "$dir")"
    done
    
    if [ $DELETED_COUNT -gt 0 ]; then
        log_success "已清理 $DELETED_COUNT 个备份，释放 $TOTAL_SIZE 空间"
    else
        log_info "没有需要删除的备份"
    fi
else
    log_info "没有超过 $RETENTION_DAYS 天的旧备份"
fi

log_success "清理完成！"

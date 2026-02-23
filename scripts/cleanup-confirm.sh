#!/bin/bash
# OpenClaw Backup Cleanup Script with Confirmation
# 用途：清理指定天数前的旧备份，释放磁盘空间（需要用户确认）

set -e -o pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" && pwd )"
LOG_FILE="${OPENCLAW_HOME:-/root/.openclaw}/backup.log"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

OPENCLAW_HOME="${OPENCLAW_HOME:-/root/.openclaw}"
BACKUP_DIR="${OPENCLAW_HOME}/backups"
DEFAULT_RETENTION_DAYS=30

log_info() {
    echo -e "${GREEN}[INFO]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
    echo "[INFO] $(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
    echo "[SUCCESS] $(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
    echo "[WARNING] $(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
    echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# 解析参数
RETENTION_DAYS=${1:-$DEFAULT_RETENTION_DAYS}

# 检查备份目录是否存在
if [ ! -d "$BACKUP_DIR/backups" ]; then
    log_error "备份目录不存在: $BACKUP_DIR/backups"
    exit 1
fi

log_info "查找超过 $RETENTION_DAYS 天的备份..."

# 查找要删除的备份
OLD_BACKUPS=$(find "$BACKUP_DIR/backups" -maxdepth 1 -mindepth 1 -type d -mtime +$RETENTION_DAYS)

if [ -z "$OLD_BACKUPS" ]; then
    log_info "没有超过 $RETENTION_DAYS 天的旧备份"
    echo ""
    echo "✅ 备份清理完成（无需清理）"
    exit 0
fi

# 显示要删除的备份列表
echo ""
echo "==================================="
echo "以下备份将被删除："
echo "==================================="
echo ""

TOTAL_SIZE=0
TOTAL_COUNT=0
for dir in $OLD_BACKUPS; do
    dir_size=$(du -sh "$dir" | cut -f1)
    dir_name=$(basename "$dir")
    echo "📁 $dir_name"
    echo "   大小: $dir_size"
    echo ""

    # 计算总大小
    size_bytes=$(du -sb "$dir" | cut -f1)
    TOTAL_SIZE=$((TOTAL_SIZE + size_bytes))
    TOTAL_COUNT=$((TOTAL_COUNT + 1))
done

# 转换总大小为人类可读格式
if [ $TOTAL_SIZE -gt 1073741824 ]; then
    TOTAL_SIZE_HR=$(echo "scale=2; $TOTAL_SIZE / 1073741824" | bc)GB
elif [ $TOTAL_SIZE -gt 1048576 ]; then
    TOTAL_SIZE_HR=$(echo "scale=2; $TOTAL_SIZE / 1048576" | bc)MB
elif [ $TOTAL_SIZE -gt 1024 ]; then
    TOTAL_SIZE_HR=$(echo "scale=2; $TOTAL_SIZE / 1024" | bc)KB
else
    TOTAL_SIZE_HR=${TOTAL_SIZE}B
fi

echo "==================================="
echo "总计："
echo "  备份数量: $TOTAL_COUNT 个"
echo "  总大小: $TOTAL_SIZE_HR"
echo "  保留期限: $RETENTION_DAYS 天"
echo "==================================="
echo ""

# 确认删除
echo -e "${YELLOW}⚠️  警告：这些备份将被永久删除！${NC}"
echo ""
read -p "确认删除吗？(输入 'yes' 确认): " confirm

if [ "$confirm" != "yes" ]; then
    echo ""
    log_info "已取消清理操作"
    exit 0
fi

# 执行删除
echo ""
log_info "正在删除旧备份..."

DELETED_COUNT=0
for dir in $OLD_BACKUPS; do
    dir_name=$(basename "$dir")
    rm -rf "$dir"
    ((DELETED_COUNT++))
    log_success "  ✓ 已删除: $dir_name"
done

log_success "清理完成！已删除 $DELETED_COUNT 个备份，释放 $TOTAL_SIZE_HR 空间"

# 记录到日志
echo "" >> "$LOG_FILE"
echo "===================================" >> "$LOG_FILE"
echo "备份清理操作" >> "$LOG_FILE"
echo "===================================" >> "$LOG_FILE"
echo "时间: $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_FILE"
echo "删除数量: $DELETED_COUNT" >> "$LOG_FILE"
echo "释放空间: $TOTAL_SIZE_HR" >> "$LOG_FILE"
echo "保留期限: $RETENTION_DAYS 天" >> "$LOG_FILE"
echo "===================================" >> "$LOG_FILE"

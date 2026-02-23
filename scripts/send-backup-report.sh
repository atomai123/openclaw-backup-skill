#!/bin/bash
# 发送备份报告到飞书

# 读取报告文件
REPORT_FILE="$1"

if [ ! -f "$REPORT_FILE" ]; then
    echo "错误：报告文件不存在: $REPORT_FILE"
    exit 1
fi

# 读取报告内容
REPORT_CONTENT=$(cat "$REPORT_FILE")

# 使用OpenClaw的消息工具发送报告
# 这里需要调用OpenClaw的message工具
# 由于脚本中无法直接调用OpenClaw工具，我们将报告保存到指定位置
# 供OpenClaw主进程读取和发送

REPORT_SENT_DIR="/tmp/openclaw_backup_reports"
mkdir -p "$REPORT_SENT_DIR"

# 复制报告到发送目录
cp "$REPORT_FILE" "$REPORT_SENT_DIR/report_$(date +%Y%m%d_%H%M%S).txt"

echo "✅ 备份报告已保存，等待OpenClaw主进程发送到飞书"
echo "   报告位置: $REPORT_FILE"

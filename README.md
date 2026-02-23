# OpenClaw备份技能使用文档

## 🎯 快速开始

### 备份你的工作空间

立即备份：
```bash
/root/.openclaw/workspace/skills/openclaw-backup/scripts/backup.sh
```

### 查看最近的备份

```bash
ls -lt /root/repos/openclaw_backup/backups/ | tail -5
```

### 查看备份日志

```bash
tail -20 /root/repos/openclaw_backup/backup.log
```

---

## 📁 文件结构

```
skills/openclaw-backup/
├── SKILL.md                 # 技能说明（本文件）
├── README.md               # 使用文档（本文件）
├── config.json             # 配置文件
├── scripts/               # 脚本目录
│   ├── backup.sh             # 主备份脚本
│   ├── restore.sh            # 恢复脚本
│   └── cleanup.sh            # 清理脚本
└── logs/                  # 日志目录
```

---

## 🚀 核心功能

### 1. 自动备份
每天凌晨3点自动执行完整备份，包含：
- 核心文件：MEMORY.md, SOUL.md等7个文件
- 记忆数据：memory/ 目录
- 用户技能：skills/ 目录（含node_modules）
- 工具文件：tools/ 目录
- 自动推送到GitHub私有仓库

### 2. 手动备份
随时触发立即备份：
```bash
/root/.openclaw/workspace/skills/openclaw-backup/scripts/backup.sh
```

返回示例：
```
✅ 备份完成
- 备份位置: /root/repos/openclaw_backup/backups/20260223_100727
- 备份大小: 24M
- 文件数量: 2074个
- Git提交: a9d0129
- Git推送: 成功
```

### 3. 恢复工作空间

系统重装后快速恢复：
```bash
# 1. 克隆备份仓库
git clone https://github.com/atomai123/openclaw_backup.git

# 2. 解压最新备份到工作空间
cp -r openclaw_backup/backups/YYYYMMDD_HHMMSS /root/.openclaw/

# 3. 重启OpenClaw
openclaw restart
```

### 4. 清理旧备份
自动清理30天前的旧备份，释放磁盘空间：
```bash
/root/.openclaw/workspace/skills/openclaw-backup/scripts/cleanup.sh [days]
```

---

## ⚙️ 配置

编辑 `config.json`：

```json
{
  "backupDirectory": "/root/repos/openclaw_backup",
  "retentionDays": 30,
  "gitRemote": "origin",
  "enableAutoPush": true,
  "compressBackups": false,
  "notification": {
    "feishu": true,
    "telegram": true,
    "wechat": true
  }
}
```

**配置说明**：
- `retentionDays`：保留备份天数（默认30天）
- `compressBackups`：是否压缩旧备份（默认false）
- `enableAutoPush`：自动推送到GitHub（默认true）
- `notification.enable`：通知渠道设置

---

## 🔧 脚本详解

### backup.sh
主备份脚本，执行完整备份流程

**选项**：
```bash
/root/.openclaw/workspace/skills/openclaw-backup/scripts/backup.sh [options]
```

- `--manual`：标记为手动备份
- `--no-push`：跳过Git推送
- `--quiet`：静默模式，减少输出

**返回值**：
- 0：成功
- 1：备份失败
- 2：Git推送失败

### restore.sh
从指定备份恢复工作空间

**选项**：
```bash
/root/.openclaw/workspace/skills/openclup-backup/scripts/restore.sh <backup_name> [options]
```

- `--force`：强制覆盖现有文件
- `--skip-conflicts`：跳过冲突文件

**警告**：
- 会覆盖现有文件！
- 建议在恢复前手动确认

### cleanup.sh
清理指定天数前的旧备份

**选项**：
```bash
/root/.openclaw/workspace/skills/openclaw-backup/scripts/cleanup.sh <days>
```

**说明**：
- 默认30天
- 会自动释放磁盘空间

---

## 📊 备份报告

每次备份后生成详细报告，包含：
- 备份时间戳
- 备份大小和文件数量
- Git提交和推送状态
- 备份内容清单

---

## ⚠️ 故障排查

### Git推送失败
```bash
# 检查网络连接
ping github.com
telnet github.com 443

# 重新配置远程仓库
cd /root/repos/openclaw_backup
git remote -v
git remote set-url origin https://github.com/atomai123/openclaw_backup.git
```

### 磁盘空间不足
```bash
# 清理旧备份
/root/.openclaw/workspace/skills/openclaw-backup/scripts/cleanup.sh 15

# 手动删除指定备份
rm -rf /root/repos/openclaw_backup/backups/202602*
```

### 文件权限错误
```bash
# 修复权限
chmod -R 755 /root/.openclaw/workspace
chmod -R 755 /root/.openclaw
```

---

## 💡 最佳实践

1. **定期测试恢复**
   每周手动验证一次备份和恢复流程

2. **监控磁盘使用**
   备份前检查可用空间，定期清理旧备份

3. **重大变更前备份**
   系统升级前、重要操作前手动备份

4. **保持备份策略**
   合理使用保留天数设置，平衡空间和安全性

5. **验证备份完整性**
   恢复前验证备份文件清单

---

## 📞 相关技能

- `backup-auto` - 自动备份定时任务配置
- `healthcheck` - 系统健康检查和磁盘空间监控

---

*最后更新：2026-02-23 10:07:27*
*版本：1.0.0*

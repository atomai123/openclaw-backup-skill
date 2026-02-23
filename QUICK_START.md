# OpenClaw备份技能 - 快速开始

## 🚀 三步完成设置

### 步骤1：设置备份私有仓库

```bash
/root/.openclaw/workspace/skills/openclaw-backup/scripts/setup-private-repo.sh
```

这个脚本会：
- ✅ 创建本地备份目录
- ✅ 初始化Git仓库
- ✅ 指导创建GitHub私有仓库
- ✅ 连接远程仓库并推送

### 步骤2：手动测试备份

```bash
/root/.openclaw/workspace/skills/openclaw-backup/scripts/backup-with-report.sh
```

验证备份是否正常工作，检查GitHub私有仓库是否有新的提交。

### 步骤3：设置自动备份（cron）

```bash
# 编辑crontab
crontab -e

# 添加以下行（每天23:55执行备份）
55 23 * * * /root/.openclaw/workspace/skills/openclaw-backup/scripts/backup-with-report.sh >> /root/repos/openclaw_backup/backup.log 2>&1
```

---

## 📦 备份内容

每次备份包含：
- ✅ 核心文件（7个）
- ✅ 记忆文件（memory/目录）
- ✅ 对话记录（所有会话历史）
- ✅ Token使用记录（使用量和成本）
- ✅ 用户技能（skills/目录）
- ✅ 工具文件（tools/目录）

---

## 🔄 恢复流程

系统重装后：

```bash
# 1. 克隆备份仓库
git clone https://github.com/atomai123/openclaw_backup.git

# 2. 解压最新备份
cp -r openclaw_backup/backups/YYYYMMDD_HHMMSS /root/.openclaw/

# 3. 重启OpenClaw
openclaw restart
```

---

## 🧹 清理旧备份

```bash
# 查看备份列表
ls -lt /root/repos/openclaw_backup/backups/ | head -10

# 清理（会提示确认）
/root/.openclaw/workspace/skills/openclaw-backup/scripts/cleanup-confirm.sh 30
```

---

## 📊 备份时间

自动备份时间：**每天晚上23:55**

---

## ⚠️ 重要提示

1. **GitHub访问令牌** - 如果推送失败，需要配置GitHub个人访问令牌
2. **网络连接** - 确保服务器可以访问GitHub
3. **磁盘空间** - 定期清理旧备份，避免磁盘占满
4. **测试恢复** - 定期测试恢复流程，确保备份可用

---

## 📞 获取帮助

查看详细文档：
- `SKILL.md` - 完整技能文档
- `README.md` - 使用指南
- `docs/GITHUB_SETUP.md` - GitHub设置指南

---

*OpenClaw Backup System v1.2.0*

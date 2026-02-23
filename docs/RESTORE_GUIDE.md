# 系统重装恢复指南

本文档提供详细的系统重装后OpenClaw工作空间恢复步骤。

---

## 📋 恢复前准备

### 需要的信息
- GitHub私有仓库地址：`https://github.com/atomai123/openclaw_backup.git`
- GitHub个人访问令牌（如需要）
- 备份的日期或时间戳

### 需要的权限
- sudo权限（安装软件和修改系统文件）
- Git访问权限（克隆仓库和推送备份）

---

## 🚀 完整恢复流程（9步）

### 步骤1：安装必要的依赖

```bash
# 更新系统包
sudo apt update && sudo apt upgrade -y

# 安装Git
sudo apt install -y git

# 安装Node.js（如果使用npm安装的OpenClaw）
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs

# 安装OpenClaw（根据你的安装方式）
# 方式1：npm安装
npm install -g openclaw

# 方式2：从源码安装
# git clone https://github.com/openclaw/openclaw.git
# cd openclaw
# npm install -g .
```

### 步骤2：克隆备份仓库

```bash
# 创建备份目录
mkdir -p /root/repos

# 克隆备份仓库
cd /root/repos
git clone https://github.com/atomai123/openclaw_backup.git
```

**如果Git推送失败，配置GitHub访问令牌**：
```bash
cd /root/repos/openclaw_backup
git remote set-url origin https://<TOKEN>@github.com/atomai123/openclaw_backup.git
```

### 步骤3：查看可用的备份

```bash
# 进入备份目录
cd /root/repos/openclaw_backup/backups

# 查看所有备份（按时间倒序）
ls -lt

# 查看备份大小
du -sh */ | sort -hr

# 查看备份详情
cat 20260223_235500/backup-manifest.txt
```

### 步骤4：解压备份到工作空间

```bash
# 进入备份目录
cd /root/repos/openclaw_backup/backups

# 找到最新的备份
LATEST_BACKUP=$(ls -t | head -1)
echo "最新备份: $LATEST_BACKUP"

# 确认备份内容
cat "$LATEST_BACKUP/backup-manifest.txt"

# 解压备份到工作空间
sudo cp -r "$LATEST_BACKUP"/* /root/.openclaw/
```

**或使用restore.sh脚本（推荐）**：
```bash
/root/.openclaw/workspace/skills/openclaw-backup/scripts/restore.sh "$LATEST_BACKUP" --force
```

### 步骤5：验证恢复结果

```bash
# 检查核心文件是否存在
ls -la /root/.openclaw/workspace/*.md

# 检查记忆文件
ls -la /root/.openclaw/workspace/memory/

# 检查技能目录
ls -la /root/.openclaw/workspace/skills/

# 检查工具目录
ls -la /root/.openclaw/workspace/tools/

# 检查备份清单
cat /root/.openclaw/workspace/backup-manifest*.txt
```

### 步骤6：配置Git凭证（用于自动备份）

```bash
# 配置Git用户信息
git config --global user.name "atomai123"
git config --global user.email "atomai123@users.noreply.github.com"

# 配置Git凭证存储
git config --global credential.helper store

# 或使用个人访问令牌
cd /root/repos/openclaw_backup
git remote set-url origin https://<TOKEN>@github.com/atomai123/openclaw_backup.git
```

### 步骤7：重启OpenClaw

```bash
# 停止OpenClaw服务
openclaw stop

# 启动OpenClaw服务
openclaw start

# 查看状态
openclaw status

# 查看日志
openclaw logs -f
```

### 步骤8：验证自动备份

```bash
# 检查cron任务
crontab -l

# 如果没有自动备份任务，添加以下内容
crontab -e
# 添加：55 23 * * * /root/.openclaw/workspace/skills/openclaw-backup/scripts/backup-with-report.sh >> /root/repos/openclaw_backup/backup.log 2>&1

# 手动测试备份
/root/.openclaw/workspace/skills/openclaw-backup/scripts/backup-with-report.sh

# 检查备份日志
tail -20 /root/repos/openclaw_backup/backup.log
```

### 步骤9：验证数据完整性

```bash
# 检查核心文件
cat /root/.openclaw/workspace/MEMORY.md
cat /root/.openclaw/workspace/SOUL.md
cat /root/.openclaw/workspace/USER.md

# 检查最近的记忆文件
ls -lt /root/.openclaw/workspace/memory/ | head -5

# 检查技能
ls -la /root/.openclaw/workspace/skills/

# 检查备份是否推送到GitHub
cd /root/repos/openclaw_backup
git log --oneline -5
```

---

## ✅ 恢复检查清单

恢复完成后，检查以下项目：

- [ ] 核心文件已恢复（7个文件）
  - [ ] MEMORY.md
  - [ ] SOUL.md
  - [ ] USER.md
  - [ ] IDENTITY.md
  - [ ] TOOLS.md
  - [ ] AGENTS.md
  - [ ] HEARTBEAT.md

- [ ] 记忆文件已恢复（memory/目录）
  - [ ] memory/目录存在
  - [ ] 至少有最近30天的记录

- [ ] 技能文件已恢复（skills/目录）
  - [ ] skills/目录存在
  - [ ] openclaw-backup技能已恢复

- [ ] 工具文件已恢复（tools/目录）
  - [ ] tools/目录存在

- [ ] Git凭证已配置
  - [ ] git config --global user.name已设置
  - [ ] git config --global user.email已设置
  - [ ] git remote -v显示正确的仓库地址

- [ ] OpenClaw服务正常运行
  - [ ] openclaw status显示running
  - [ ] 可以通过飞书访问

- [ ] 自动备份cron任务已设置
  - [ ] crontab -l显示备份任务
  - [ ] 备份时间是23:55

- [ ] 手动备份测试成功
  - [ ] backup-with-report.sh执行成功
  - [ ] 备份推送到GitHub成功

- [ ] 备份推送到GitHub成功
  - [ ] git log显示最新的提交
  - [ ] GitHub仓库有新的备份

---

## 🔧 常见恢复问题

### 问题1：备份文件权限错误

**症状**：无法访问备份文件

**解决方案**：
```bash
# 修复权限
sudo chown -R root:root /root/.openclaw/
sudo chmod -R 755 /root/.openclaw/workspace
```

### 问题2：OpenClaw启动失败

**症状**：`openclaw start`命令失败

**解决方案**：
```bash
# 查看详细日志
openclaw logs -f

# 检查配置文件
cat /root/.openclaw/config.yaml

# 检查端口占用
sudo netstat -tlnp | grep 8080

# 重启服务
openclaw restart
```

### 问题3：备份推送失败

**症状**：`git push`命令失败

**解决方案**：
```bash
# 检查Git配置
cd /root/repos/openclaw_backup
git remote -v

# 检查网络连接
ping github.com

# 重新配置访问令牌
git remote set-url origin https://<TOKEN>@github.com/atomai123/openclaw_backup.git

# 测试推送
git push -u origin main
```

### 问题4：备份清单文件丢失

**症状**：无法找到backup-manifest.txt

**解决方案**：
```bash
# 重新生成备份清单
cd /root/.openclaw/workspace

# 创建新的备份清单
cat > backup-manifest.txt << EOF
OpenClaw 恢复清单
==================

恢复时间: $(date +%Y%m%d_%H%M%S)
恢复备份: <backup_name>

核心文件: $(ls -1 *.md 2>/dev/null | wc -l) 个
记忆文件: $(find memory/ -type f 2>/dev/null | wc -l) 个
技能文件: $(find skills/ -type f 2>/dev/null | wc -l) 个
工具文件: $(find tools/ -type f 2>/dev/null | wc -l) 个

==================
EOF
```

### 问题5：节点版本不匹配

**症状**：OpenClaw无法启动，提示Node.js版本错误

**解决方案**：
```bash
# 检查当前Node版本
node -v

# 安装正确的Node版本（根据OpenClaw要求）
# 例如安装Node 22.x
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs

# 重新安装OpenClaw
npm install -g openclaw
```

---

## 📝 恢复后最佳实践

### 1. 立即测试备份

恢复完成后立即运行一次手动备份：
```bash
/root/.openclaw/workspace/skills/openclaw-backup/scripts/backup-with-report.sh
```

验证：
- [ ] 备份执行成功
- [ ] 备份推送到GitHub
- [ ] 收到备份报告

### 2. 验证数据完整性

检查核心数据：
```bash
# 检查核心文件
cat /root/.openclaw/workspace/MEMORY.md | head -20

# 检查最近的记忆文件
ls -lt /root/.openclaw/workspace/memory/ | head -5

# 检查技能
ls -la /root/.openclaw/workspace/skills/
```

### 3. 重新配置系统

更新系统环境变量：
```bash
# 检查环境变量
env | grep OPENCLAW

# 重新配置数据库（如果使用）
# 重新连接外部服务（如果需要）
```

### 4. 文档化恢复过程

记录恢复日志：
```bash
cat > /root/.openclaw/restore-log.txt << EOF
OpenClaw恢复日志
==================

恢复时间: $(date '+%Y-%m-%d %H:%M:%S')
系统版本: $(uname -a)
OpenClaw版本: $(openclaw --version)

恢复备份: <backup_name>
恢复方式: <手动/脚本>

遇到的问题:
- <问题1>: <解决方案>
- <问题2>: <解决方案>

验证结果:
- [ ] 核心文件已恢复
- [ ] 记忆文件已恢复
- [ ] 技能文件已恢复
- [ ] OpenClaw正常运行
- [ ] 自动备份正常工作

==================
EOF
```

---

## 📞 获取帮助

如果遇到问题：
1. 查看OpenClaw日志：`openclaw logs -f`
2. 查看备份日志：`/root/repos/openclaw_backup/backup.log`
3. 查看恢复文档：`SKILL.md` - 系统重装恢复指南
4. 联系技术支持

---

*最后更新：2026-02-23*

# OpenClaw备份技能

**技能描述**：自动化备份OpenClaw工作空间到GitHub私有仓库，支持手动和自动备份，确保系统重装后可以快速恢复所有数据。

---

## 🎯 功能特性

- **自动备份**：每天晚上23:55自动执行完整备份
- **手动备份**：随时触发立即备份
- **智能清理**：清理旧备份前必须先确认（不会自动清理）
- **完整内容**：备份核心文件、记忆文件、对话记录、Token使用记录、技能、工具等所有重要数据
- **Git推送**：自动推送到GitHub私有仓库
- **完整验证**：备份后自动验证文件完整性
- **备份报告**：备份完成后自动发送详细报告到飞书
- **仓库管理**：一键设置GitHub私有仓库

---

## 🚀 快速开始

### 前置条件

在开始使用之前，需要完成以下设置：

#### 1. 设置GitHub私有仓库（用于存储备份）

```bash
# 运行设置脚本
/root/.openclaw/workspace/skills/openclaw-backup/scripts/setup-private-repo.sh
```

这个脚本会：
- ✅ 创建本地备份目录
- ✅ 初始化Git仓库
- ✅ 指导创建GitHub私有仓库
- ✅ 连接远程仓库
- ✅ 推送初始文件

#### 2. 配置Git凭证（如需要）

```bash
# 配置Git凭证
git config --global credential.helper store

# 或者使用GitHub个人访问令牌
git remote set-url origin https://<TOKEN>@github.com/<user>/<repo>.git
```

### 备份清单

OpenClaw备份包含以下内容：

#### 核心文件
- `MEMORY.md` - 长期记忆档案
- `SOUL.md` - 人格定义
- `USER.md` - 用户信息
- `IDENTITY.md` - 身份档案
- `TOOLS.md` - 工具配置
- `AGENTS.md` - 工作规范
- `HEARTBEAT.md` - 心跳检查清单

#### 记忆数据
- `memory/` - 每日记录目录
- `memory/YYYY-MM-DD.md` - 具体日期的记录
- `memory/heartbeat-state.json` - 心跳检查状态

#### 对话记录
- 所有与OpenClaw的对话历史
- 通过sessions_list和sessions_history工具获取

#### Token使用记录
- 每日Token使用量统计
- 模型调用记录
- 成本计算数据

#### 用户技能
- `skills/` - 所有自定义技能
- 包含node_modules依赖

#### 工具和脚本
- `tools/` - 工具文件和脚本
- 项目配置和模板

### 2. 备份位置

**本地备份目录**：
```
/root/repos/openclaw_backup/backups/
```

**Git仓库**：
```
https://github.com/atomai123/openclaw_backup.git
```

### 3. 自动备份时间

每天晚上 **23:55** 自动执行完整备份

### 4. 手动触发备份

执行备份：
```bash
/root/.openclaw/workspace/skills/openclaw-backup/scripts/backup-with-report.sh
```

返回示例：
```
✅ 备份完成
- 备份位置: /root/repos/openclaw_backup/backups/20260223_235500
- 备份大小: 25MB
- 文件数量: 2074个
- Git提交: a9d0129
- Git推送: 成功
- 备份报告: 已发送到飞书
```

### 4. 系统重装恢复指南

#### 完整恢复流程（详细步骤）

系统重装后，按照以下步骤恢复OpenClaw工作空间：

---

**步骤1：安装必要的依赖**

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

---

**步骤2：克隆备份仓库**

```bash
# 创建备份目录
mkdir -p /root/repos

# 克隆备份仓库
cd /root/repos
git clone https://github.com/atomai123/openclaw_backup.git
```

**注意**：如果Git推送失败，需要配置GitHub访问令牌：
```bash
git remote set-url origin https://<TOKEN>@github.com/atomai123/openclaw_backup.git
```

---

**步骤3：查看可用的备份**

```bash
# 进入备份目录
cd /root/repos/openclaw_backup/backups

# 查看所有备份（按时间倒序）
ls -lt

# 查看备份大小
du -sh */ | sort -hr
```

选择最新的备份（通常是时间戳最大的那个）。

---

**步骤4：解压备份到工作空间**

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

# 或者使用restore.sh脚本（推荐）
/root/.openclaw/workspace/skills/openclaw-backup/scripts/restore.sh "$LATEST_BACKUP" --force
```

---

**步骤5：验证恢复结果**

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

---

**步骤6：配置Git凭证（用于自动备份）**

```bash
# 配置Git凭证存储
git config --global user.name "atomai123"
git config --global user.email "atomai123@users.noreply.github.com"
git config --global credential.helper store

# 或使用个人访问令牌
cd /root/repos/openclaw_backup
git remote set-url origin https://<TOKEN>@github.com/atomai123/openclaw_backup.git
```

---

**步骤7：重启OpenClaw**

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

---

**步骤8：验证自动备份**

```bash
# 检查cron任务
crontab -l

# 如果没有自动备份任务，添加以下内容
# 55 23 * * * /root/.openclaw/workspace/skills/openclaw-backup/scripts/backup-with-report.sh >> /root/repos/openclaw_backup/backup.log 2>&1

# 手动测试备份
/root/.openclaw/workspace/skills/openclaw-backup/scripts/backup-with-report.sh

# 检查备份日志
tail -20 /root/repos/openclaw_backup/backup.log
```

---

**步骤9：验证数据完整性**

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

#### 使用restore.sh脚本（推荐）

```bash
# 进入工作空间
cd /root/.openclaw/workspace

# 运行恢复脚本
/root/.openclaw/workspace/skills/openclaw-backup/scripts/restore.sh <backup_name> --force

# 示例：恢复最新备份
LATEST_BACKUP=$(ls -t /root/repos/openclaw_backup/backups/ | head -1)
/root/.openclaw/workspace/skills/openclaw-backup/scripts/restore.sh "$LATEST_BACKUP" --force
```

**restore.sh脚本功能**：
- ✅ 自动解压备份文件
- ✅ 备份现有文件（如冲突）
- ✅ 恢复所有核心文件
- ✅ 恢复记忆、技能、工具目录
- ✅ 生成恢复报告

---

#### 恢复检查清单

恢复完成后，检查以下项目：

- [ ] 核心文件已恢复（7个文件）
- [ ] 记忆文件已恢复（memory/目录）
- [ ] 技能文件已恢复（skills/目录）
- [ ] 工具文件已恢复（tools/目录）
- [ ] Git凭证已配置
- [ ] OpenClaw服务正常运行
- [ ] 自动备份cron任务已设置
- [ ] 手动备份测试成功
- [ ] 备份推送到GitHub成功

---

#### 常见恢复问题

**问题1：备份文件权限错误**
```bash
# 修复权限
sudo chown -R root:root /root/.openclaw/
sudo chmod -R 755 /root/.openclaw/workspace
```

**问题2：OpenClaw启动失败**
```bash
# 查看详细日志
openclaw logs -f

# 检查配置文件
cat /root/.openclaw/config.yaml

# 重启服务
openclaw restart
```

**问题3：备份推送失败**
```bash
# 检查Git配置
cd /root/repos/openclaw_backup
git remote -v

# 检查网络连接
ping github.com

# 重新配置访问令牌
git remote set-url origin https://<TOKEN>@github.com/atomai123/openclaw_backup.git
```

**问题4：备份清单文件丢失**
```bash
# 重新生成备份清单
cd /root/.openclaw/workspace
cat > backup-manifest.txt << EOF
OpenClaw 恢复清单
==================

恢复时间: $(date +%Y%m%d_%H%M%S)
恢复备份: <backup_name>

核心文件: $(ls -1 *.md | wc -l) 个
记忆文件: $(find memory/ -type f | wc -l) 个
技能文件: $(find skills/ -type f | wc -l) 个
工具文件: $(find tools/ -type f | wc -l) 个

==================
EOF
```

---

#### 恢复后最佳实践

1. **立即测试备份**
   - 恢复完成后立即运行一次手动备份
   - 验证备份推送到GitHub
   - 检查备份报告

2. **验证数据完整性**
   - 检查核心文件内容
   - 查看最近的记忆文件
   - 验证技能和工具文件

3. **重新配置系统**
   - 更新系统环境变量
   - 重新配置数据库（如果使用）
   - 重新连接外部服务

4. **文档化恢复过程**
   - 记录恢复时间
   - 记录遇到的问题
   - 记录解决方案

---

## 📋 脚本历史

| 版本 | 日期 | 主要更新 |
|------|------|----------|
| v1.1 | 2026-02-23 | 增加对话记录、Token使用记录备份；调整自动备份时间至23:55；清理需确认；自动发送备份报告 |
| v1.0 | 2026-02-23 | 初始版本，完整备份功能 |

---

## 🔧 脚本结构

```
skills/openclaw-backup/
├── SKILL.md                      # 本文件
├── README.md                     # 使用文档
├── CHANGELOG.md                  # 更新日志
├── .gitignore                    # Git忽略配置
├── config.json                   # 配置文件
├── _meta.json                    # 技能元数据
├── QUICK_START.md                # 快速开始指南
└── scripts/
    ├── backup-with-report.sh       # 主备份脚本（含报告）⭐
    ├── backup.sh                   # 旧版备份脚本
    ├── restore.sh                  # 恢复脚本
    ├── cleanup-confirm.sh         # 清理脚本（需确认）⭐
    ├── cleanup.sh                 # 旧版清理脚本
    ├── send-backup-report.sh      # 发送备份报告
    └── setup-private-repo.sh      # 设置备份私有仓库 ⭐
```

**脚本说明**：
- ⭐ 推荐使用的新脚本
- 其他脚本保持向后兼容

## ⚙️ 配置选项

编辑 `config.json` 可以修改以下配置：

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
- `retentionDays`：保留备份的天数，默认30天
- `compressBackups`：是否压缩旧备份，默认false
- `enableAutoPush`：是否自动推送到GitHub，默认true
- `notification.enable`：通知渠道设置

---

## 🎯 核心脚本

### backup-with-report.sh
主备份脚本（推荐使用），执行完整备份流程并发送报告

**用法**：
```bash
/root/.openclaw/workspace/skills/openclaw-backup/scripts/backup-with-report.sh [options]
```

**选项**：
- `--manual`：标记为手动备份
- `--no-push`：跳过Git推送
- `--quiet`：静默模式，减少输出

**返回值**：
- 0：成功
- 1：备份失败
- 2：Git推送失败

**新功能**：
- ✅ 备份对话记录（所有会话历史）
- ✅ 备份Token使用记录（每日使用量和成本）
- ✅ 自动生成详细备份报告
- ✅ 自动发送报告到飞书

### backup.sh
旧版备份脚本（向后兼容）

**用法**：
```bash
/root/.openclaw/workspace/skills/openclaw-backup/scripts/backup.sh [options]
```

**选项**：
- `--manual`：标记为手动备份
- `--no-push`：跳过Git推送
- `--quiet`：静默模式，减少输出

**返回值**：
- 0：成功
- 1：备份失败
- 2：Git推送失败

**注意**：建议使用 `backup-with-report.sh` 替代此脚本

### restore.sh
恢复脚本，从备份恢复工作空间

**用法**：
```bash
/root/.openclaw/workspace/skills/openclaw-backup/scripts/restore.sh [backup_name] [options]
```

**选项**：
- `--force`：强制覆盖现有文件
- `--skip-conflicts`：跳过冲突文件

### cleanup-confirm.sh
清理旧备份，释放磁盘空间（推荐使用，需要用户确认）

**用法**：
```bash
/root/.openclaw/workspace/skills/openclaw-backup/scripts/cleanup-confirm.sh [days]
```

**参数**：
- `days`：保留的天数（默认30）

**重要**：
- ✅ 执行前会显示将要删除的备份列表
- ✅ 需要用户输入 'yes' 确认后才会执行清理
- ✅ 不会自动清理，避免误删
- ✅ 显示总删除大小

### cleanup.sh
旧版清理脚本（向后兼容）

**用法**：
```bash
/root/.openclaw/workspace/skills/openclaw-backup/scripts/cleanup.sh [days]
```

**参数**：
- `days`：保留的天数（默认30）

**注意**：建议使用 `cleanup-confirm.sh` 替代此脚本

---

## 📊 备份报告

每次备份后自动发送详细报告到飞书：

**备份信息**
- 备份时间戳
- 备份大小和文件数量
- Git提交哈希
- 备份类型（auto/manual）

**内容清单**
- 核心文件：7个文件
- 记忆文件：memory/目录下所有文件
- 对话记录：所有对话历史
- Token使用记录：每日使用量和成本
- 技能目录：所有技能及其依赖
- 工具目录：工具和脚本

**验证结果**
- 文件完整性检查
- Git推送状态
- 可用空间检查

**报告发送**
- 自动发送到飞书（用户主会话）
- 包含完整备份详情
- 如失败会发送错误报告

---

## ⚠️ 故障排查

### Git推送失败
```bash
# 检查远程仓库状态
cd /root/repos/openclaw_backup
git remote -v

# 检查网络连接
ping github.com
telnet github.com 443

# 重新配置远程
git remote set-url origin https://github.com/atomai123/openclaw_backup.git
```

### 磁盘空间不足
```bash
# 清理旧备份（会提示确认）
/root/.openclaw/workspace/skills/openclaw-backup/scripts/cleanup-confirm.sh 15

# 查看备份占用空间
du -sh /root/repos/openclaw_backup/backups/*

# 手动删除指定备份（谨慎操作！）
rm -rf /root/repos/openclaw_backup/backups/202602*
```

### 文件权限错误
```bash
# 修复权限
chmod -R 755 /root/.openclaw/workspace
chmod -R 755 /root/.openclaw
```

---

## 📝 最佳实践

1. **定期测试备份**
   - 每周手动验证一次备份和恢复流程
   - 定期检查GitHub私有仓库状态
   - 验证备份报告中的文件数量

2. **监控磁盘使用**
   - 备份前检查可用空间
   - 清理旧备份前仔细确认
   - 建议保留30天内的备份

3. **验证备份完整性**
   - 恢复前验证备份文件清单
   - 确认Git推送成功
   - 检查备份报告中的所有项目

4. **保持备份策略**
   - 重大变更前手动备份
   - 每月至少验证一次恢复流程
   - 定期查看备份报告了解系统状态

5. **文档化重要变更**
   - 更新配置时更新配置文档
   - 记录手动备份原因和内容
   - 保留备份清单记录

---

## 📚 相关文档

- `QUICK_START.md` - 快速开始指南
- `README.md` - 详细使用文档
- `docs/GITHUB_SETUP.md` - GitHub仓库设置指南
- `docs/RESTORE_GUIDE.md` - 系统重装恢复指南 ⭐
- `CHANGELOG.md` - 更新日志

---

## 📞 常见问题

**Q: 备份失败怎么办？**
A: 检查错误日志：`/root/repos/openclaw_backup/backup.log`

**Q: 如何跳过Git推送？**
A: 使用 `--no-push` 选项

**Q: 可以只备份部分文件吗？**
A: 可以编辑脚本中的 `BACKUP_LIST` 数组

**Q: 恢复时文件冲突怎么办？**
A: 使用 `--force` 选项强制覆盖，或手动合并

**Q: 如何设置GitHub私有仓库？**
A: 运行 `setup-private-repo.sh` 脚本

**Q: 如何查看备份报告？**
A: 备份完成后自动发送到飞书，或查看 `/tmp/backup_report.txt`

**Q: Git推送失败怎么办？**
A: 检查网络连接、GitHub凭证配置、仓库权限

**Q: 需要两个GitHub仓库吗？**
A: 不需要，只需要一个私有仓库用于存储备份数据即可

---

*创建时间：2026-02-23 10:07:27*
*作者：OpenClaw Backup System*
*版本：1.3.0*

---
**更新记录**：
- v1.3.0 (2026-02-23) - 添加详细的系统重装恢复指南（9步完整流程、检查清单、常见问题）
- v1.2.0 (2026-02-23) - 添加GitHub私有仓库设置脚本
- v1.1.0 (2026-02-23) - 增加对话记录、Token使用记录备份；调整自动备份时间至23:55；清理需确认；自动发送备份报告
- v1.0.0 (2026-02-23) - 初始版本，完整备份功能

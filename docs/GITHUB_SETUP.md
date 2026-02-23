# GitHub私有仓库设置指南

## 概述

OpenClaw备份技能使用一个GitHub私有仓库来存储工作空间的备份数据。

**仓库信息**：
- **用途**：存储OpenClaw工作空间的备份数据
- **可见性**：私有（仅自己可见）
- **内容**：备份文件、记录数据
- **更新频率**：每天23:55自动更新
- **仓库名**：`openclaw_backup`

---

## 快速开始

### 运行设置脚本（推荐）

```bash
/root/.openclaw/workspace/skills/openclaw-backup/scripts/setup-private-repo.sh
```

这个脚本会：
- ✅ 创建本地备份目录
- ✅ 初始化Git仓库
- ✅ 指导创建GitHub私有仓库
- ✅ 连接远程仓库
- ✅ 推送初始文件

---

## 手动设置步骤

### 步骤1：创建GitHub私有仓库

访问：https://github.com/new

填写信息：
- **Repository name**: `openclaw_backup`
- **Description**: OpenClaw工作空间备份（私有）
- **类型**: ⚪ **Private**
- **不要初始化README**（我们用自己的）

点击 "Create repository"

---

### 步骤2：连接到本地

```bash
# 创建备份目录
mkdir -p /root/repos

# 进入备份目录
cd /root/repos
mkdir -p openclaw_backup
cd openclaw_backup

# 初始化Git仓库
git init

# 创建.gitignore
cat > .gitignore << 'EOF'
# 日志文件
backup.log
*.log

# 临时文件
tmp/
temp/
*.tmp

# 系统文件
.DS_Store
Thumbs.db

# 编辑器
.vscode/
.idea/
*.swp
*.swo
*~
EOF

# 创建README.md
cat > README.md << 'EOF'
# OpenClaw备份仓库

这个私有仓库用于存储OpenClaw工作空间的自动备份。

## 备份内容

- 核心文件（MEMORY.md, SOUL.md等）
- 记忆文件（memory/目录）
- 对话记录（所有会话历史）
- Token使用记录
- 用户技能（skills/目录）
- 工具文件（tools/目录）

## 备份时间

每天晚上23:55自动执行备份。

## 恢复流程

系统重装后：

```bash
# 1. 克隆备份仓库
git clone https://github.com/atomai123/openclaw_backup.git

# 2. 解压最新备份到工作空间
cp -r openclaw_backup/backups/YYYYMMDD_HHMMSS /root/.openclaw/

# 3. 重启OpenClaw
openclaw restart
```

---

*自动备份 - OpenClaw Backup System*
EOF

# 提交初始文件
git add .
git commit -m "初始化备份仓库"

# 添加远程仓库
git remote add origin https://github.com/atomai123/openclaw_backup.git

# 推送到GitHub
git push -u origin main
```

---

### 步骤3：配置Git凭证（如需要）

#### 方式1：使用凭证存储

```bash
# 配置Git凭证存储
git config --global credential.helper store

# 推送时会提示输入用户名和访问令牌
git push -u origin main
# 输入GitHub用户名和访问令牌
```

#### 方式2：使用个人访问令牌（推荐）

```bash
# 使用个人访问令牌
git remote set-url origin https://<TOKEN>@github.com/atomai123/openclaw_backup.git

# 推送
git push -u origin main
```

---

## 获取GitHub个人访问令牌

### 1. 访问令牌页面

访问：https://github.com/settings/tokens

### 2. 生成新令牌

点击 "Generate new token" → "Generate new token (classic)"

### 3. 配置令牌

- **Note**: `OpenClaw Backup`
- **Expiration**: 选择合适的过期时间（如：90 days）
- **勾选权限**：
  - ✅ `repo`（完整的仓库访问权限）
  - ✅ `workflow`（如需要GitHub Actions）

### 4. 生成并复制

- 点击 "Generate token"
- **复制生成的令牌**（只显示一次！）
- 安全保存令牌

---

## 验证设置

### 检查私有仓库

```bash
# 查看远程仓库
cd /root/repos/openclaw_backup
git remote -v

# 查看Git状态
git status

# 查看最近提交
git log --oneline -5
```

### 测试备份

```bash
# 手动测试备份
/root/.openclaw/workspace/skills/openclaw-backup/scripts/backup-with-report.sh

# 查看备份日志
tail -20 /root/repos/openclaw_backup/backup.log
```

### 检查GitHub仓库

访问你的GitHub私有仓库：
```
https://github.com/atomai123/openclaw_backup
```

确认：
- ✅ 仓库已创建
- ✅ 初始文件已推送
- ✅ README.md显示正确
- ✅ 仓库类型为Private

---

## 日常维护

### 备份维护

- 每天晚上23:55自动执行备份
- 检查GitHub私有仓库是否有新的备份提交
- 定期清理30天前的旧备份

### 监控备份

```bash
# 查看备份列表
ls -lt /root/repos/openclaw_backup/backups/

# 查看备份大小
du -sh /root/repos/openclaw_backup/backups/*

# 查看备份日志
tail -f /root/repos/openclaw_backup/backup.log
```

### 清理旧备份

```bash
# 清理30天前的备份（会提示确认）
/root/.openclaw/workspace/skills/openclaw-backup/scripts/cleanup-confirm.sh 30
```

---

## 故障排查

### Git推送失败

#### 问题1：认证失败

```
error: unable to read askpass response
fatal: Authentication failed
```

**解决方案**：
```bash
# 重新配置Git凭证
git config --global credential.helper store
git push -u origin main
# 输入用户名和访问令牌
```

#### 问题2：权限被拒绝

```
remote: Permission denied to atomai123/openclaw_backup.git
```

**解决方案**：
- 检查仓库是否存在
- 检查访问令牌是否有`repo`权限
- 确认仓库类型为Private

#### 问题3：连接超时

```
fatal: unable to access 'https://github.com/...': Connection timed out
```

**解决方案**：
- 检查网络连接
- 检查防火墙设置
- 尝试使用SSH方式：
  ```bash
  git remote set-url origin git@github.com:atomai123/openclaw_backup.git
  ```

### 备份未自动推送

```bash
# 检查cron任务
crontab -l

# 查看备份日志
tail -20 /root/repos/openclaw_backup/backup.log

# 手动测试备份
/root/.openclaw/workspace/skills/openclaw-backup/scripts/backup-with-report.sh
```

---

## 最佳实践

### 1. 定期测试备份

- 每周手动执行一次备份
- 验证备份推送到GitHub
- 检查备份报告

### 2. 监控磁盘使用

- 定期检查备份目录大小
- 清理30天前的旧备份
- 监控GitHub私有仓库大小

### 3. 备份安全

- 定期更新访问令牌
- 不要分享私有仓库地址
- 定期检查仓库访问权限

### 4. 备份验证

- 定期测试恢复流程
- 验证备份文件完整性
- 确认所有重要数据已备份

---

## 相关文档

- `SKILL.md` - 完整技能文档
- `README.md` - 使用指南
- `QUICK_START.md` - 快速开始
- `docs/RESTORE_GUIDE.md` - 系统重装恢复指南
- `CHANGELOG.md` - 更新日志

---

*最后更新：2026-02-23*

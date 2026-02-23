# GitHub仓库设置指南

## 概述

OpenClaw备份技能使用两个GitHub仓库：
1. **私有仓库** - 存储OpenClaw工作空间的备份数据
2. **公开仓库** - 分享备份技能的代码

## 仓库对比

| 特性 | 私有仓库 | 公开仓库 |
|------|---------|---------|
| **用途** | 存储备份数据 | 分享技能代码 |
| **可见性** | 私有（仅自己可见） | 公开（任何人可见） |
| **内容** | 备份文件、记录数据 | 技能脚本、文档 |
| **更新频率** | 每天23:55自动更新 | 技能更新时手动更新 |
| **仓库名** | `openclaw_backup` | `openclaw-backup-skill` |

## 步骤1：设置私有仓库（存储备份数据）

### 运行设置脚本
```bash
/root/.openclaw/workspace/skills/openclaw-backup/scripts/setup-private-repo.sh
```

### 手动设置步骤

#### 1. 创建GitHub私有仓库

访问：https://github.com/new

填写信息：
- Repository name: `openclaw_backup`
- Description: OpenClaw工作空间备份（私有）
- 类型: ⚪ **Private**
- 不要初始化README（我们用自己的）

点击 "Create repository"

#### 2. 连接到本地

```bash
# 进入备份目录
cd /root/repos/openclaw_backup

# 初始化Git仓库（如果还没初始化）
git init

# 添加远程仓库
git remote add origin https://github.com/atomai123/openclaw_backup.git

# 创建.gitignore
cat > .gitignore << EOF
# 日志文件
backup.log
*.log

# 临时文件
tmp/
temp/
*.tmp
EOF

# 提交初始文件
git add .
git commit -m "初始化备份仓库"

# 推送到GitHub
git push -u origin main
```

#### 3. 配置Git凭证（如需要）

```bash
# 方式1：使用凭证存储
git config --global credential.helper store
git push -u origin main
# 输入GitHub用户名和访问令牌

# 方式2：使用个人访问令牌（推荐）
git remote set-url origin https://<TOKEN>@github.com/atomai123/openclaw_backup.git
git push -u origin main
```

### 获取GitHub个人访问令牌

1. 访问：https://github.com/settings/tokens
2. 点击 "Generate new token" → "Generate new token (classic)"
3. 配置令牌：
   - Note: `OpenClaw Backup`
   - Expiration: 选择合适的过期时间
   - 勾选权限：
     - ✅ `repo`（完整的仓库访问权限）
     - ✅ `workflow`（如需要GitHub Actions）
4. 点击 "Generate token"
5. 复制生成的令牌（只显示一次！）

## 步骤2：设置公开仓库（分享技能代码）

### 运行发布脚本
```bash
/root/.openclaw/workspace/skills/openclaw-backup/scripts/publish-to-github.sh
```

### 手动设置步骤

#### 1. 创建GitHub公开仓库

访问：https://github.com/new

填写信息：
- Repository name: `openclaw-backup-skill`
- Description: OpenClaw自动化备份技能 - 完整备份工作空间到GitHub私有仓库
- 类型: ⚪ **Public**
- 不要初始化README（我们用自己的）

点击 "Create repository"

#### 2. 推送技能代码

```bash
# 进入技能目录
cd /root/.openclaw/workspace/skills/openclaw-backup

# 初始化Git仓库
git init

# 添加所有文件
git add .

# 创建首次提交
git commit -m "feat: 初始提交 - OpenClaw备份技能 v1.2.0

功能特性：
- ✅ 自动备份（每天23:55）
- ✅ 手动备份
- ✅ 对话记录备份
- ✅ Token使用记录备份
- ✅ 智能清理（需确认）
- ✅ 备份报告自动发送
- ✅ Git推送到私有仓库"

# 添加远程仓库
git remote add origin https://github.com/atomai123/openclaw-backup-skill.git

# 推送到GitHub
git push -u origin main
```

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

### 检查公开仓库
```bash
# 查看远程仓库
cd /root/.openclaw/workspace/skills/openclaw-backup
git remote -v

# 查看Git状态
git status

# 查看最近提交
git log --oneline -5
```

## 日常维护

### 备份维护
- 每天晚上23:55自动执行备份
- 检查GitHub私有仓库是否有新的备份提交
- 定期清理30天前的旧备份

### 技能维护
- 技能更新后，推送到公开仓库
- 更新CHANGELOG.md记录变更
- 保持README.md文档最新

## 故障排查

### Git推送失败

**问题1：认证失败**
```
error: unable to read askpass response
fatal: Authentication failed
```

解决方案：
```bash
# 重新配置Git凭证
git config --global credential.helper store
git push -u origin main
# 输入用户名和访问令牌
```

**问题2：权限被拒绝**
```
remote: Permission denied to atomai123/openclaw_backup.git
```

解决方案：
- 检查仓库是否存在
- 检查访问令牌是否有`repo`权限
- 确认仓库类型（私有/公开）匹配

**问题3：连接超时**
```
fatal: unable to access 'https://github.com/...': Connection timed out
```

解决方案：
- 检查网络连接
- 检查防火墙设置
- 尝试使用SSH方式：
  ```bash
  git remote set-url origin git@github.com:atomai123/openclaw_backup.git
  ```

### 备份未自动推送

检查自动备份cron任务：
```bash
# 查看cron任务
crontab -l

# 查看备份日志
tail -20 /root/repos/openclaw_backup/backup.log
```

## 最佳实践

1. **定期测试备份**
   - 每周手动执行一次备份
   - 验证备份推送到GitHub
   - 检查备份报告

2. **监控磁盘使用**
   - 定期检查备份目录大小
   - 清理30天前的旧备份
   - 监控GitHub私有仓库大小

3. **更新技能**
   - 技能更新后推送到公开仓库
   - 更新版本号和CHANGELOG
   - 通知用户重大变更

4. **备份安全**
   - 定期更新访问令牌
   - 不要分享私有仓库地址
   - 定期检查仓库访问权限

---

*最后更新：2026-02-23*

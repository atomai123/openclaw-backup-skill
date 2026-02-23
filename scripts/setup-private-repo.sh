#!/bin/bash
# Setup GitHub Private Repository for OpenClaw Backup
# 用途：设置用于存储备份的GitHub私有仓库

set -e -o pipefail

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置
BACKUP_REPO_DIR="/root/repos/openclaw_backup"
GITHUB_USER="${GITHUB_USER:-atomai123}"
BACKUP_REPO_NAME="${BACKUP_REPO_NAME:-openclaw_backup}"

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

echo "==================================="
echo "OpenClaw备份 - GitHub私有仓库设置"
echo "==================================="
echo ""

# 步骤1：创建本地备份目录
if [ ! -d "$BACKUP_REPO_DIR" ]; then
    log_info "创建本地备份目录..."
    mkdir -p "$BACKUP_REPO_DIR"
    log_success "  ✓ 目录已创建: $BACKUP_REPO_DIR"
else
    log_info "备份目录已存在: $BACKUP_REPO_DIR"
fi

# 步骤2：初始化Git仓库
cd "$BACKUP_REPO_DIR"

if [ ! -d ".git" ]; then
    log_info "初始化Git仓库..."
    git init
    log_success "  ✓ Git仓库已初始化"
else
    log_info "Git仓库已存在"
fi

# 步骤3：创建.gitignore
log_info "创建.gitignore..."
cat > .gitignore << EOF
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
log_success "  ✓ .gitignore已创建"

# 步骤4：创建初始README
log_info "创建README.md..."
if [ ! -f "README.md" ]; then
    cat > README.md << EOF
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

\`\`\`bash
# 1. 克隆备份仓库
git clone https://github.com/$GITHUB_USER/$BACKUP_REPO_NAME.git

# 2. 解压最新备份到工作空间
cp -r openclaw_backup/backups/YYYYMMDD_HHMMSS /root/.openclaw/

# 3. 重启OpenClaw
openclaw restart
\`\`\`

---

*自动备份 - OpenClaw Backup System*
EOF
    log_success "  ✓ README.md已创建"
else
    log_info "  README.md已存在"
fi

# 步骤5：初始提交
log_info "创建初始提交..."
if ! git diff --quiet --exit-code; then
    git add .
    git commit -m "初始化备份仓库"
    log_success "  ✓ 初始提交已创建"
else
    log_info "  没有新的变更"
fi

cd -

# 步骤6：指导创建GitHub仓库
echo ""
echo "==================================="
echo "步骤6：创建GitHub私有仓库"
echo "==================================="
echo ""
echo "请按以下步骤操作："
echo ""
echo "1. 访问: https://github.com/new"
echo ""
echo "2. 填写仓库信息："
echo "   - Repository name: $BACKUP_REPO_NAME"
echo "   - Description: OpenClaw工作空间备份（私有）"
echo "   - 类型: ⚪ Private"
echo "   - 不要初始化README"
echo ""
echo "3. 点击 'Create repository'"
echo ""
read -p "创建完成后按回车继续..."

# 步骤7：连接远程仓库
echo ""
read -p "输入GitHub仓库地址 (例如: https://github.com/$GITHUB_USER/$BACKUP_REPO_NAME.git): " repo_url

if [ -z "$repo_url" ]; then
    repo_url="https://github.com/$GITHUB_USER/$BACKUP_REPO_NAME.git"
fi

cd "$BACKUP_REPO_DIR"

log_info "连接远程仓库..."
git remote add origin "$repo_url" 2>/dev/null || git remote set-url origin "$repo_url"
log_success "  ✓ 远程仓库已设置: $repo_url"

# 步骤8：推送到GitHub
echo ""
log_info "推送到GitHub..."
echo "  远程仓库: $repo_url"
echo "  仓库类型: Private"
echo ""

if git push -u origin main 2>/dev/null || git push -u origin master 2>/dev/null; then
    log_success "  ✓ 推送成功！"
    echo ""
    echo "==================================="
    echo "✅ 私有仓库设置完成！"
    echo "==================================="
    echo ""
    echo "仓库地址: $repo_url"
    echo "本地目录: $BACKUP_REPO_DIR"
    echo ""
    echo "下一步："
    echo "1. 验证仓库内容"
    echo "2. 测试自动备份功能"
    echo "3. 检查每天晚上23:55的备份"
    echo ""
else
    log_error "  ✗ 推送失败"
    echo ""
    echo "可能的原因："
    echo "1. 仓库不存在或地址错误"
    echo "2. 认证失败（需要配置GitHub访问令牌）"
    echo "3. 网络问题"
    echo ""
    echo "解决方案："
    echo "1. 检查仓库地址是否正确"
    echo "2. 配置Git凭证"
    echo "3. 使用GitHub个人访问令牌进行认证"
    echo ""
    exit 1
fi

cd -

log_success "私有仓库设置完成！"

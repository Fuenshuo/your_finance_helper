# Pre-Commit Hook 说明

## 概述

项目已配置 Git pre-commit hook，**在提交代码之前会自动运行 CI 合规性检查**。这确保了本地提交的代码必须通过 CI 流程中的代码质量检查，避免在 CI 中失败。

## CI 检查流程

Pre-commit hook 会按照 `.github/workflows/ci.yml` 中 `code-quality` job 的步骤执行以下检查：

1. **安装依赖** (`flutter pub get`)
2. **代码分析** (`flutter analyze lib/ --no-fatal-warnings`)
3. **代码格式化检查** (`dart format --set-exit-if-changed lib/`)
4. **严格 Linting** (`flutter analyze lib/ --fatal-infos`)

## 使用方法

### 自动执行

Pre-commit hook 会在每次执行 `git commit` 时自动运行：

```bash
git commit -m "your commit message"
```

如果检查通过，提交会正常完成。如果检查失败，提交会被阻止。

### 手动运行

你也可以手动运行检查脚本：

```bash
# 运行完整的 CI 检查（包括单元测试）
./scripts/pre-commit-check.sh

# 跳过单元测试（仅运行代码质量检查）
./scripts/pre-commit-check.sh --skip-tests
```

### 绕过检查（不推荐）

如果确实需要绕过检查（例如紧急修复），可以使用 `--no-verify` 标志：

```bash
git commit --no-verify -m "emergency fix"
```

**⚠️ 警告**: 使用 `--no-verify` 绕过的提交仍然会在 CI 中失败，请谨慎使用。

## 检查失败时的处理

如果 pre-commit hook 检查失败：

1. **代码格式化问题**: Hook 会自动格式化代码，你需要重新提交
2. **代码分析错误**: 查看错误信息，修复后重新提交
3. **Linting 错误**: 修复所有 info 级别的 lint 问题

## 安装 Hook

首次克隆仓库或 hook 文件丢失时，需要安装 hook：

```bash
./scripts/install-pre-commit-hook.sh
```

或者手动复制：

```bash
cp scripts/pre-commit-hook.template .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

## 文件位置

- **Pre-commit Hook**: `.git/hooks/pre-commit` (不会被 git 跟踪)
- **Hook 安装脚本**: `scripts/install-pre-commit-hook.sh`
- **检查脚本**: `scripts/pre-commit-check.sh`
- **CI 配置**: `.github/workflows/ci.yml`

## 注意事项

1. Pre-commit hook 只检查 `lib/` 目录下的代码，与 CI 流程保持一致
2. Hook 不会运行单元测试（避免提交过慢），但 CI 会运行
3. `.git/hooks/pre-commit` 文件不会被 git 跟踪，每个开发者需要单独安装
4. Hook 需要执行权限：`chmod +x .git/hooks/pre-commit`
5. 团队新成员克隆仓库后需要运行安装脚本

## 故障排除

### Hook 不执行

检查 hook 文件是否存在且有执行权限：

```bash
ls -la .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

### Hook 执行失败

查看详细错误信息：

```bash
.git/hooks/pre-commit
```

### 需要更新 Hook

如果 CI 流程更新，需要同步更新 pre-commit hook 和 `scripts/pre-commit-check.sh`。


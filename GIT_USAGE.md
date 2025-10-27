# Git仓库使用指南

## 仓库信息

- **项目名称**：500 double led
- **GitHub用户名**：cxs00
- **本地路径**：D:\stm32\BilibiliProject\500 double led
- **版本命名规则**：`项目名称_版本号`（如：500_double_led_v1.0.0）

## 当前版本

### v1.0.0 - 初始版本
- **标签**：500_double_led_v1.0.0
- **描述**：STM32双数码管显示系统，包含完整硬件配置、软件工程和文档
- **提交信息**：初始提交：500_double_led_v1.0.0 - STM32双数码管显示系统完整项目

## 版本更新流程

### 1. 创建新版本

#### 方式一：功能更新（小版本号）
```bash
# 1. 更新版本号（如：1.0.0 → 1.0.1）
# 2. 提交变更
git add .
git commit -m "更新：500_double_led_v1.0.1 - [描述变更内容]"
# 3. 创建标签
git tag -a 500_double_led_v1.0.1 -m "版本v1.0.1：[详细描述]"
```

#### 方式二：重要功能（中版本号）
```bash
# 1. 更新版本号（如：1.0.0 → 1.1.0）
# 2. 提交变更
git add .
git commit -m "更新：500_double_led_v1.1.0 - [描述新功能]"
# 3. 创建标签
git tag -a 500_double_led_v1.1.0 -m "版本v1.1.0：[详细描述新功能]"
```

#### 方式三：重大更新（大版本号）
```bash
# 1. 更新版本号（如：1.0.0 → 2.0.0）
# 2. 提交变更
git add .
git commit -m "更新：500_double_led_v2.0.0 - [描述重大更新]"
# 3. 创建标签
git tag -a 500_double_led_v2.0.0 -m "版本v2.0.0：[详细描述重大更新]"
```

### 2. 查看版本历史

```bash
# 查看所有标签
git tag -l

# 查看标签详情
git show 500_double_led_v1.0.0

# 查看提交历史
git log --oneline

# 查看某个版本的提交
git log 500_double_led_v1.0.0
```

### 3. 切换到指定版本

```bash
# 切换到某个标签
git checkout 500_double_led_v1.0.0

# 返回到最新版本
git checkout master
```

## 连接到GitHub

### 1. 创建GitHub仓库

1. 访问 https://github.com/new
2. 仓库名称：`500_double_led` 或 `stm32-double-led`
3. 设置为 Private 或 Public
4. **不要**初始化README、.gitignore或license（已存在）

### 2. 连接到GitHub

```bash
# 添加远程仓库
git remote add origin https://github.com/cxs00/500_double_led.git

# 或者使用SSH
git remote add origin git@github.com:cxs00/500_double_led.git

# 查看远程仓库
git remote -v
```

### 3. 推送代码和标签

```bash
# 推送所有代码
git push -u origin master

# 推送所有标签
git push origin --tags

# 推送指定标签
git push origin 500_double_led_v1.0.0
```

## 日常操作

### 查看当前状态

```bash
# 查看当前状态
git status

# 查看差异
git diff

# 查看提交历史
git log --graph --oneline --all
```

### 提交变更

```bash
# 添加所有文件
git add .

# 提交变更
git commit -m "描述变更内容"

# 提交并推送
git push
```

### 查看版本信息

```bash
# 查看当前版本
git describe --tags

# 查看所有标签及其描述
git tag -n1
```

## 版本命名规范

遵循**语义化版本**原则：

- **格式**：`500_double_led_v主版本号.次版本号.修订号`
- **主版本号**：重大更新，不兼容的API修改
- **次版本号**：新功能，向后兼容
- **修订号**：Bug修复，向后兼容

### 示例

- `500_double_led_v1.0.0` - 初始版本
- `500_double_led_v1.0.1` - Bug修复
- `500_double_led_v1.1.0` - 新增功能（如：新增菜单系统）
- `500_double_led_v2.0.0` - 重大更新（如：架构重构）

## 分支管理（可选）

### 创建功能分支

```bash
# 创建并切换到新分支
git checkout -b feature/智能步进优化

# 开发完成后合并到主分支
git checkout master
git merge feature/智能步进优化

# 删除功能分支
git branch -d feature/智能步进优化
```

### 创建发布分支

```bash
# 创建发布分支
git checkout -b release/v1.1.0

# 在发布分支上修复Bug
# 提交并打标签
git checkout master
git merge release/v1.1.0
git tag -a 500_double_led_v1.1.0 -m "版本v1.1.0"
```

## 回滚操作

### 撤销未提交的修改

```bash
# 撤销修改（保持工作区）
git checkout -- <文件名>

# 撤销所有未提交修改
git reset --hard HEAD
```

### 切换到历史版本

```bash
# 查看历史提交
git log --oneline

# 切换到指定提交
git checkout <commit-hash>

# 创建新分支
git checkout -b temp-branch <commit-hash>

# 返回最新版本
git checkout master
```

## 备份策略

### 本地备份

```bash
# 克隆仓库到备份位置
git clone --local D:\stm32\BilibiliProject\500\ double\ led D:\Backup\500_double_led_backup
```

### 远程备份

```bash
# 推送到GitHub
git push origin master

# 推送所有标签
git push origin --tags
```

## 常见问题

### 1. 忘记创建标签

```bash
# 为之前的提交打标签
git tag -a 500_double_led_v1.0.1 <commit-hash> -m "版本描述"
```

### 2. 修改标签

```bash
# 删除本地标签
git tag -d 500_double_led_v1.0.1

# 重新创建标签
git tag -a 500_double_led_v1.0.1 -m "正确的版本描述"

# 如果已推送到远程，需要强制推送
git push origin :refs/tags/500_double_led_v1.0.1
git push origin 500_double_led_v1.0.1
```

### 3. 合并冲突

```bash
# 解决冲突后
git add .
git commit -m "解决合并冲突"
```

## 检查清单

每次发布新版本前检查：

- [ ] 所有文件已提交
- [ ] 版本号已更新
- [ ] CHANGELOG已更新
- [ ] 代码已测试通过
- [ ] 已创建Git标签
- [ ] 已推送到远程仓库

---

**最后更新**：2025-10-25  
**维护者**：cxs00


# Cursor AI 规则管理系统

## 📋 系统简介

这是一个**自动化的Cursor AI规则管理系统**，用于管理、更新和同步项目开发规则。当您或其他开发者打开项目时，系统会自动初始化并加载所有规则。

## 🎯 主要功能

### ✅ 自动初始化
- 首次打开项目时自动加载规则
- 无需手动配置，零学习成本
- 生成初始化标记文件

### ✅ 规则同步
- 自动检测规则变更
- 支持一键同步到工作区
- 保留历史版本记录

### ✅ 文档生成
- 自动从 `.cursorrules` 提取内容
- 生成分类规则文档
- 维护规则索引和变更日志

### ✅ 版本管理
- 完整的历史版本归档
- 详细的变更记录
- 支持回滚和对比

## 📂 目录结构

```
.cursor/rules/
├── README.md                   # 本文件 - 系统说明
├── RULES_INDEX.md             # 规则快速索引
├── CHANGELOG.md               # 规则变更日志
│
├── current/                   # 当前规则（最新版本）
│   ├── .cursorrules          # Cursor AI规则文件
│   ├── rules_summary.md      # 规则总览
│   ├── error_solutions.md    # 已知错误解决方案
│   ├── coding_standards.md   # 编码规范
│   ├── hardware_constraints.md  # 硬件约束
│   └── smart_stepping_rules.md  # 智能步进算法
│
├── history/                   # 历史版本归档
│   └── v1.0_2025-10-25/      # 按版本号和日期归档
│       ├── .cursorrules      # 历史规则文件
│       └── changes.md        # 该版本的变更说明
│
├── templates/                 # 规则模板
│   ├── new_error_template.md # 新错误报告模板
│   └── rule_update_template.md  # 规则更新模板
│
├── docs/                      # 文档资料
│   ├── development_guide.md  # 开发指南
│   └── troubleshooting.md    # 故障排查
│
└── scripts/                   # 自动化脚本
    ├── sync_rules.bat        # Windows规则同步脚本
    ├── parse_rules.py        # 规则解析脚本
    └── auto_sync.bat         # 自动同步触发器
```

## 🚀 快速开始

### 对于新开发者

1. **克隆/复制项目后直接打开**
   - 项目会自动初始化
   - Cursor会提示规则已加载

2. **查看规则索引**
   ```
   .cursor/rules/RULES_INDEX.md  # 快速查找规则
   ```

3. **查看已知错误**
   ```
   .cursor/rules/current/error_solutions.md  # 11个已知错误及解决方案
   ```

4. **开始开发**
   - AI助手已了解所有规则
   - 自动避免已知错误
   - 遵循编码规范

### 对于项目维护者

1. **更新规则**
   ```bash
   # 编辑规则文件
   .cursor/rules/current/.cursorrules
   
   # 运行同步脚本
   .cursor/rules/scripts/sync_rules.bat
   ```

2. **创建版本归档**
   ```bash
   # 复制当前版本到history/
   # 更新CHANGELOG.md
   ```

3. **生成文档**
   ```bash
   # 运行解析脚本
   python .cursor/rules/scripts/parse_rules.py
   ```

## 📖 详细使用指南

### 规则文件说明

#### `.cursorrules` - 核心规则文件
- Cursor AI的配置文件
- 包含所有开发规则
- 自动被Cursor加载

#### `error_solutions.md` - 错误解决方案
- **11个已知错误及解决方案**
- 按错误类型分类
- 包含代码示例

#### `coding_standards.md` - 编码规范
- 显示代码规范
- 按键处理规范
- 时序控制规范

#### `hardware_constraints.md` - 硬件约束
- SPI引脚定义（不可更改）
- 74HC595/165配置
- LED和按键映射

#### `smart_stepping_rules.md` - 智能步进算法
- 低频/高频步进规则
- 升级逻辑详解
- 测试用例

### 自动化工作流

#### 初次打开项目
```
1. Cursor检测到.cursor/instructions.md
2. 自动执行初始化检查
3. 如果未初始化：
   - 创建.initialized标记
   - 加载规则到工作区
   - 显示欢迎消息
4. 如果已初始化：
   - 检查规则是否有更新
   - 提示是否同步
```

#### 规则更新时
```
1. 编辑.cursor/rules/current/.cursorrules
2. 运行sync_rules.bat
3. 脚本自动：
   - 检测变更内容
   - 更新文档
   - 记录变更日志
   - 同步到Cursor工作区
```

#### 版本归档时
```
1. 创建history/vX.Y_YYYY-MM-DD/
2. 复制当前.cursorrules
3. 编写changes.md说明变更
4. 更新CHANGELOG.md
```

## 🔧 脚本使用

### sync_rules.bat - 规则同步脚本
```batch
# 基本用法
.cursor\rules\scripts\sync_rules.bat

# 自动执行：
# - 复制规则到Cursor工作区
# - 生成分类文档
# - 更新索引
```

### parse_rules.py - 规则解析脚本
```python
# 基本用法
python .cursor\rules\scripts\parse_rules.py

# 功能：
# - 解析.cursorrules内容
# - 提取错误解决方案
# - 生成分类文档
# - 更新索引
```

## 📝 规则更新流程

### 添加新的错误解决方案

1. **编辑规则文件**
   ```markdown
   # 在.cursorrules中添加
   ### 错误12：新错误描述
   **症状：** 错误表现
   **原因：** 错误原因
   **解决方案：** 解决步骤
   ```

2. **运行同步**
   ```bash
   .cursor\rules\scripts\sync_rules.bat
   ```

3. **验证更新**
   - 检查error_solutions.md
   - 检查CHANGELOG.md
   - 测试Cursor是否加载

### 修改编码规范

1. **编辑对应章节**
   - 在.cursorrules中修改
   - 保持格式一致

2. **同步并测试**
   - 运行同步脚本
   - 验证AI助手行为

3. **记录变更**
   - 更新CHANGELOG.md
   - 说明修改原因

## 🎓 最佳实践

### ✅ 应该这样做
- ✅ 每次发现新问题立即更新规则
- ✅ 详细记录错误症状和解决方案
- ✅ 定期创建版本归档
- ✅ 使用脚本自动同步
- ✅ 保持规则文件格式一致

### ❌ 不应该这样做
- ❌ 手动编辑生成的文档（会被覆盖）
- ❌ 删除历史版本
- ❌ 修改规则文件后不同步
- ❌ 直接修改.cursor/instructions.md的自动逻辑
- ❌ 忽略CHANGELOG更新

## 🔍 故障排查

### 规则未自动加载？
1. 检查 `.cursor/instructions.md` 是否存在
2. 检查 `.cursor/rules/current/.cursorrules` 是否存在
3. 重启Cursor
4. 手动运行 `sync_rules.bat`

### 规则更新未生效？
1. 确认已运行同步脚本
2. 检查Cursor工作区规则
3. 重新加载窗口
4. 清除Cursor缓存并重启

### 脚本执行失败？
1. 检查Python是否安装（解析脚本需要）
2. 检查文件权限
3. 查看脚本输出的错误信息
4. 检查文件路径是否正确

## 📞 获取帮助

### 相关文档
- `RULES_INDEX.md` - 规则快速查找
- `CHANGELOG.md` - 历史变更记录
- `current/error_solutions.md` - 错误解决方案
- `docs/development_guide.md` - 开发指南

### 问题反馈
如遇到问题：
1. 查看RULES_INDEX.md是否有相关规则
2. 查看error_solutions.md是否有解决方案
3. 检查CHANGELOG.md了解最近变更
4. 查看历史版本对比差异

## 📊 系统状态

**当前版本：** v1.0  
**规则数量：** 11个已知错误 + 完整开发规范  
**最后更新：** 2025-10-25  
**状态：** ✅ 已验证，生产可用

---

## 🎉 开始使用

现在您已经了解了规则管理系统，可以：

1. 📖 查看 `RULES_INDEX.md` 快速了解所有规则
2. 🔍 查看 `current/error_solutions.md` 了解11个已知错误
3. 💻 开始编码，AI助手会自动遵循规则
4. 📝 遇到新问题时及时更新规则

**祝开发顺利！** 🚀


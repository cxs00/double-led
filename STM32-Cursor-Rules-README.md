# STM32 Cursor Rules Repository

## 📋 仓库说明

这是一个专门用于保存和管理STM32项目Cursor AI规则的仓库。

### 🎯 仓库目的

- **规则集中管理**：统一管理所有Cursor AI开发规则
- **版本控制**：追踪规则的历史变更
- **跨项目共享**：规则可以在多个STM32项目间共享
- **自动同步**：支持规则文件的双向自动同步

## 📦 仓库结构

```
stm32-cursor-rules/
├── .cursorrules              # 主规则文件
├── README.md                 # 本文件
├── CHANGELOG.md              # 规则变更日志
├── error_solutions.md        # 错误解决方案
├── hardware_constraints.md   # 硬件约束说明
├── smart_stepping_rules.md   # 智能步进规则
└── scripts/                  # 辅助脚本
    └── sync-rules.sh         # 双向同步脚本
```

## 🚀 使用方法

### 1. 在新项目中使用规则

```bash
# 克隆规则仓库到项目的.cursor/rules目录
cd your-stm32-project
git clone https://github.com/cxs00/stm32-cursor-rules.git .cursor/rules/current
```

### 2. 同步规则更新

```bash
# 拉取最新规则
cd .cursor/rules/current
git pull origin main

# 或使用同步脚本
./scripts/sync-rules.sh pull
```

### 3. 贡献规则更新

```bash
# 修改规则后推送
./scripts/sync-rules.sh push

# 或手动推送
git add .cursorrules
git commit -m "feat: 添加新规则"
git push origin main
```

## 📊 规则版本

当前版本：**v1.1.0**

### 版本历史

- **v1.1.0** (2025-10-28)
  - ✅ 添加元规则系统
  - ✅ 添加强制检查点系统
  - ✅ 添加完整验证流程规范
  - ✅ 整合cursor-workspace优秀实践

- **v1.0.0** (2025-10-25)
  - ✅ 初始版本
  - ✅ 硬件约束规则
  - ✅ 15个错误解决方案
  - ✅ 智能步进规则

## 🔄 双向同步机制

### 自动同步时机

1. **每次会话开始时**：自动拉取云端更新
2. **修改规则后**：自动推送到双仓库
3. **创建版本时**：自动创建并推送Tag

### 同步到的仓库

- **主仓库**：`github.com/cxs00/stm32-cursor-rules`（专用规则仓库）
- **备份仓库**：`github.com/cxs00/double-led`（项目仓库）

### Tag命名规则

格式：`{项目名称}-Rules-v{主版本}.{次版本}.{修订版本}`

示例：
- `500_double_led-Rules-v1.0.0`
- `500_double_led-Rules-v1.1.0`

## 🎯 适用项目

- **STM32F1系列**：STM32F103C8T6等
- **开发工具**：Keil MDK-ARM + STM32CubeMX
- **调试接口**：SWD (J-Link)
- **外设**：74HC595, 74HC165, 数码管, LED

## 📝 规则内容

### 核心规则

1. **元规则系统** - 确保AI严格遵守规则
2. **强制检查点** - 4个强制验证检查点
3. **验证流程** - 完整的质量保证闭环
4. **硬件约束** - STM32特定的硬件限制
5. **错误解决方案** - 15个常见错误及解决方法

### 规则特色

- ✅ 强制执行，非软建议
- ✅ 循环验证直到成功
- ✅ 自动快照和回退
- ✅ 详细的错误预防措施
- ✅ 结构化的问题记录

## 🛠️ 维护指南

### 添加新规则

1. 修改`.cursorrules`文件
2. 更新`CHANGELOG.md`
3. 更新规则版本号
4. 运行`./scripts/sync-rules.sh push`

### 修复规则错误

1. 创建issue说明问题
2. 修改规则文件
3. 添加到error_solutions.md
4. 提交并推送

### 版本管理

- **主版本**：重大架构变更
- **次版本**：新功能添加
- **修订版本**：Bug修复和优化

## 📞 支持

### 问题反馈

- GitHub Issues: https://github.com/cxs00/stm32-cursor-rules/issues
- 项目仓库: https://github.com/cxs00/double-led

### 文档

- 完整规则: `.cursorrules`
- 错误解决方案: `error_solutions.md`
- 硬件约束: `hardware_constraints.md`
- 智能步进: `smart_stepping_rules.md`

## 📄 许可证

MIT License

## 🙏 致谢

本规则系统参考和整合了以下优秀实践：
- Activity Tracker Rules (cursor-workspace)
- STM32开发最佳实践
- Keil MDK-ARM开发规范

---

**最后更新：** 2025-10-28  
**维护者：** cxs00  
**状态：** ✅ 持续维护中


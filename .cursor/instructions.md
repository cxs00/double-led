# Cursor AI - 自动加载指令与规则管理

## 🤖 自动初始化系统

本文件会在Cursor打开项目时**自动加载**，实现零配置规则管理。

---

## 🚀 首次打开检测

### 检查是否首次打开
```bash
# 检查标记文件
if [ ! -f ".cursor/rules/.initialized" ]; then
    echo "🎉 欢迎使用STM32 500双数码管变频器控制系统！"
    echo "正在初始化Cursor AI规则..."
    
    # 创建初始化标记
    touch ".cursor/rules/.initialized"
    
    # 记录初始化时间
    echo "初始化时间: $(date)" > ".cursor/rules/.initialized"
fi
```

### 自动加载规则
```bash
# 加载主规则文件
if [ -f ".cursor/rules/current/.cursorrules" ]; then
    echo "✅ 规则已加载: .cursor/rules/current/.cursorrules"
    echo "📖 查看规则索引: .cursor/rules/RULES_INDEX.md"
    echo "🐛 查看已知错误: .cursor/rules/current/error_solutions.md"
else
    echo "⚠️ 警告: 规则文件不存在，请运行 .cursor/rules/scripts/sync_rules.bat"
fi
```

---

## 📋 规则系统简介

### 规则文件位置
- **主规则文件**: `.cursor/rules/current/.cursorrules`
- **规则索引**: `.cursor/rules/RULES_INDEX.md`
- **错误解决方案**: `.cursor/rules/current/error_solutions.md`
- **编码规范**: `.cursor/rules/current/coding_standards.md`
- **硬件约束**: `.cursor/rules/current/hardware_constraints.md`
- **智能步进规则**: `.cursor/rules/current/smart_stepping_rules.md`

### 快速链接
- 📖 **[规则系统说明](.cursor/rules/README.md)**
- 🔍 **[规则快速索引](.cursor/rules/RULES_INDEX.md)**
- 🐛 **[11个已知错误及解决方案](.cursor/rules/current/error_solutions.md)**
- 📐 **[编码规范](.cursor/rules/current/coding_standards.md)**
- 🔌 **[硬件约束](.cursor/rules/current/hardware_constraints.md)**
- 🎯 **[智能步进算法](.cursor/rules/current/smart_stepping_rules.md)**
- 📝 **[变更日志](.cursor/rules/CHANGELOG.md)**

---

## 🎯 核心规则摘要

### ⚠️ 严禁操作（最重要）
1. **禁用JTAG调试** → 必须使用SWD（避免二次烧录失败）
2. **数码管段码必须取反** → 共阳极数码管（0=亮，1=灭）
3. **U2输出必须再次取反** → 补偿PNP三极管反相
4. **不可修改引脚定义** → SPI2引脚固定不可更改
5. **不可修改按键/LED映射** → 硬件连接固定

### ✅ 必须遵守的硬件约束
- **调试接口**: 只用SWD (PA13/PA14)，禁用JTAG
- **SPI引脚**: PB13(SCK), PB14(MISO), PB15(MOSI), PB7(LATCH)
- **74HC595级联**: U1 → U2 → U6
- **74HC165按键**: 9位输入（SER + D0-D7）
- **数码管类型**: 共阳极
- **LED映射**: ALM=0, V=1, FR=2, Hz=3, RUN=4, A=5
- **按键映射**: SER→RUN, D0→RESERVED, D1→ENTER, D2→FUNC, D3→STOP, D4→DOWN, D5→RPG, D6→SHIFT, D7→UP

### 🐛 已知错误（11个）
1. **ERR-01**: 二次烧录失败 → 使用SWD，64KB Flash算法
2. **ERR-02**: 长按无效 → KEY_Scan()改为电平触发
3. **ERR-03**: 高频小数点错误 → d7_buffer[3]带小数点
4. **ERR-04**: D8小数点错误 → SEG_SetDigit_D8(2,x,1)
5. **ERR-05**: 按键混乱 → 检查74HC165映射
6. **ERR-06**: 步进每次升级 → 超过阈值才升级
7. **ERR-07**: case重复 → 检查枚举值
8. **ERR-08**: 变量未定义 → 添加声明
9. **ERR-09**: SPI未定义 → include "stm32f1xx_hal_spi.h"
10. **ERR-10**: DOWN步进错误 → 移除AutoSetStepLevel
11. **ERR-11**: 长按延迟 → 用(count-threshold)%rate

### 💻 编码规范（9条）
1. **段码表取反** → 共阳极数码管
2. **U2输出取反** → u2_data = ~original
3. **频率格式** → 低频XXX.XX，高频XXXX.X
4. **小数点位置** → 低频d7[2]，高频d7[3]
5. **电平触发** → KEY_Scan()支持长按
6. **长按参数** → 250ms阈值，100ms重复
7. **步进超时** → 500ms重置为级别1
8. **刷新周期** → 显示20ms，按键50ms
9. **SPI顺序** → 先读键，再显示

### 🎯 智能步进
- **低频模式** (0.00-400.00Hz): 0.01→0.1→1→10Hz
- **高频模式** (0.0-4000.0Hz): 0.1→1→10→100Hz
- **UP键**: 频率超过阈值升级
- **DOWN键**: 频率到达倍数升级
- **超时**: 500ms无操作重置为级别1

---

## 🔄 规则更新检测

### 自动检测规则变更
```bash
# 检查规则文件修改时间
RULES_FILE=".cursor/rules/current/.cursorrules"
LAST_SYNC=".cursor/rules/.last_sync"

if [ -f "$RULES_FILE" ] && [ -f "$LAST_SYNC" ]; then
    if [ "$RULES_FILE" -nt "$LAST_SYNC" ]; then
        echo "📢 检测到规则更新！"
        echo "   运行同步脚本: .cursor/rules/scripts/sync_rules.bat"
        echo "   或重新加载Cursor窗口"
    fi
fi
```

---

## 🛠️ 规则管理工具

### 同步规则到工作区
```batch
REM Windows用户
.cursor\rules\scripts\sync_rules.bat
```

### 查看规则
```bash
# 查看规则索引
cat .cursor/rules/RULES_INDEX.md

# 查看错误解决方案
cat .cursor/rules/current/error_solutions.md

# 查看编码规范
cat .cursor/rules/current/coding_standards.md
```

### 更新规则
1. 编辑 `.cursor/rules/current/.cursorrules`
2. 运行 `.cursor/rules/scripts/sync_rules.bat`
3. 重启Cursor或重新加载窗口

---

## 📖 使用指南

### 新开发者快速入门
1. **查看规则系统说明**
   ```
   .cursor/rules/README.md
   ```

2. **查看规则快速索引**
   ```
   .cursor/rules/RULES_INDEX.md
   ```

3. **了解已知错误**
   ```
   .cursor/rules/current/error_solutions.md
   ```

4. **开始编码**
   - AI助手已了解所有规则
   - 自动避免已知错误
   - 遵循编码规范

### 遇到问题时
1. 在 `RULES_INDEX.md` 搜索关键词
2. 查看对应的错误解决方案
3. 按步骤执行修复
4. 验证问题解决

### 添加新功能时
1. 查看 `coding_standards.md` 了解规范
2. 检查 `hardware_constraints.md` 确认约束
3. 参考 `smart_stepping_rules.md` 了解算法
4. 编写代码并测试

---

## 🎓 AI助手指示

### 开发规则
当用户请求代码修改或新功能时：
1. ✅ **首先检查硬件约束** → 不可违反硬件限制
2. ✅ **查看已知错误** → 避免重复错误
3. ✅ **遵循编码规范** → 保持代码一致性
4. ✅ **参考智能步进规则** → 频率调节逻辑
5. ✅ **使用示例代码** → 规则文档中有完整示例

### 错误处理
当用户报告错误时：
1. ✅ **查找已知错误** → 在error_solutions.md中搜索症状
2. ✅ **提供完整解决方案** → 包含原因、代码示例、验证方法
3. ✅ **记录新错误** → 如果是新问题，建议添加到规则

### 代码审查
生成代码后自动检查：
- [ ] 是否使用了JTAG相关GPIO？
- [ ] 数码管段码是否取反？
- [ ] U2输出是否再次取反？
- [ ] 小数点位置是否正确？
- [ ] 按键映射是否正确？
- [ ] KEY_Scan()是否电平触发？
- [ ] 是否使用HAL_Delay()阻塞主循环？
- [ ] 智能步进逻辑是否正确？

---

## 📊 规则系统状态

### 当前版本信息
- **版本**: v1.0
- **规则数量**: 35+条
- **已知错误**: 11个
- **硬件约束**: 7条
- **编码规范**: 9条
- **智能步进级别**: 4级 × 2模式
- **文档完整性**: 100%
- **最后更新**: 2025-10-25

### 系统状态
- ✅ 规则文件完整
- ✅ 文档结构正确
- ✅ 自动化脚本就绪
- ✅ 历史版本已归档
- ✅ 索引链接有效

---

## 💡 提示与技巧

### 快速查找规则
使用`Ctrl+F`在`RULES_INDEX.md`中搜索关键词：
- 烧录问题 → ERR-01
- 按键问题 → ERR-02, ERR-05, ERR-11
- 显示问题 → ERR-03, ERR-04
- 步进问题 → ERR-06, ERR-10
- 编译问题 → ERR-07, ERR-08, ERR-09

### 规则优先级
1. **🔴 严重错误** → 立即修复
2. **🟡 中等错误** → 影响体验
3. **🟢 轻微错误** → 编译问题
4. **硬件约束** → 不可违反
5. **编码规范** → 必须遵守

### 开发建议
- ✅ 开发前查看规则总览
- ✅ 遇到问题先查索引
- ✅ 修改后运行同步脚本
- ✅ 定期查看变更日志
- ✅ 发现新问题及时记录

---

## 🎉 开始开发

现在您已经了解了规则管理系统，可以：

1. 📖 查看 `RULES_INDEX.md` 快速了解所有规则
2. 🔍 查看 `error_solutions.md` 了解11个已知错误
3. 💻 开始编码，AI助手会自动遵循规则
4. 📝 遇到新问题时及时更新规则

**祝开发顺利！** 🚀

---

## 📞 获取更多帮助

### 文档导航
- [规则系统说明](.cursor/rules/README.md)
- [规则快速索引](.cursor/rules/RULES_INDEX.md)
- [错误解决方案](.cursor/rules/current/error_solutions.md)
- [编码规范](.cursor/rules/current/coding_standards.md)
- [硬件约束](.cursor/rules/current/hardware_constraints.md)
- [智能步进规则](.cursor/rules/current/smart_stepping_rules.md)
- [变更日志](.cursor/rules/CHANGELOG.md)

### 问题反馈
如遇到问题，请按以下步骤：
1. 查看`RULES_INDEX.md`查找相关规则
2. 查看`error_solutions.md`查找解决方案
3. 检查`CHANGELOG.md`了解最近变更
4. 对比历史版本找出差异

---

**最后更新**: 2025-10-25  
**系统版本**: v1.0  
**状态**: ✅ 自动规则系统已激活

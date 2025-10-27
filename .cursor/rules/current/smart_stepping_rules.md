# 智能步进规则

## 📐 智能步进系统概述

智能步进是一个自适应频率调节系统，根据当前频率值自动调整步进大小，实现快速又精确的频率设定。

### 核心特性
- **4个步进级别**：从精细（0.01Hz）到粗糙（10Hz/100Hz）
- **2种频率模式**：低频（0.00-400.00Hz）和高频（0.0-4000.0Hz）
- **自动升级**：频率超过阈值自动升级到下一级别
- **超时重置**：500ms无操作自动重置到级别1
- **独立逻辑**：UP键和DOWN键有不同的升级判定逻辑

---

## 📊 步进级别详细说明

### 低频模式 (0.00-400.00Hz)

| 级别 | 步进值 | 频率范围 | 阈值 | 示例 |
|------|--------|----------|------|------|
| **级别1** | 0.01Hz | 0.00 ~ 0.09Hz | freq ≤ 9 | 0.00, 0.01, 0.02, ..., 0.09 |
| **级别2** | 0.1Hz | 0.10 ~ 0.90Hz | freq ≤ 90 | 0.10, 0.20, 0.30, ..., 0.90 |
| **级别3** | 1Hz | 1.00 ~ 9.90Hz | freq ≤ 990 | 1.00, 2.00, 3.00, ..., 9.00 |
| **级别4** | 10Hz | 10.00 ~ 400.00Hz | freq ≤ 40000 | 10.00, 20.00, ..., 400.00 |

**注意：** freq_hz单位为0.01Hz（例如：freq_hz=50表示0.50Hz）

### 高频模式 (0.0-4000.0Hz)

| 级别 | 步进值 | 频率范围 | 阈值 | 示例 |
|------|--------|----------|------|------|
| **级别1** | 0.1Hz | 0.0 ~ 0.9Hz | freq ≤ 90 | 0.0, 0.1, 0.2, ..., 0.9 |
| **级别2** | 1Hz | 1.0 ~ 9.9Hz | freq ≤ 990 | 1.0, 2.0, 3.0, ..., 9.0 |
| **级别3** | 10Hz | 10.0 ~ 99.9Hz | freq ≤ 9990 | 10.0, 20.0, ..., 99.0 |
| **级别4** | 100Hz | 100.0 ~ 4000.0Hz | freq ≤ 400000 | 100.0, 200.0, ..., 4000.0 |

**注意：** freq_hz单位为0.01Hz（例如：freq_hz=500表示5.00Hz在高频模式会四舍五入显示为5.0Hz）

---

## 💻 代码实现

### 步进级别枚举
```c
typedef enum {
    STEP_LEVEL_1 = 1,  // 第一级别（最小步进）
    STEP_LEVEL_2 = 2,  // 第二级别
    STEP_LEVEL_3 = 3,  // 第三级别
    STEP_LEVEL_4 = 4   // 第四级别（最大步进）
} StepLevel_t;
```

### 频率模式枚举
```c
typedef enum {
    FREQ_MODE_LOW = 0,   // 低频模式：0.00-400.00Hz
    FREQ_MODE_HIGH = 1   // 高频模式：0.0-4000.0Hz
} FreqMode_t;
```

### 阈值定义
```c
// 低频模式阈值（单位：0.01Hz）
const uint16_t LOW_STEP1_MAX = 9;       // 0.09Hz
const uint16_t LOW_STEP2_MAX = 90;      // 0.90Hz
const uint16_t LOW_STEP3_MAX = 990;     // 9.90Hz
const uint16_t FREQ_LOW_MAX = 40000;    // 400.00Hz

// 高频模式阈值（单位：0.01Hz）
const uint32_t HIGH_STEP1_MAX = 90;     // 0.9Hz
const uint32_t HIGH_STEP2_MAX = 990;    // 9.9Hz
const uint32_t HIGH_STEP3_MAX = 9990;   // 99.9Hz
const uint32_t FREQ_HIGH_MAX = 400000;  // 4000.0Hz
```

### 获取步进值函数
```c
static uint32_t GetFreqStepValue(StepLevel_t level)
{
    if (freq_mode == FREQ_MODE_LOW) {
        switch (level) {
            case STEP_LEVEL_1: return 1;      // 0.01Hz
            case STEP_LEVEL_2: return 10;     // 0.1Hz
            case STEP_LEVEL_3: return 100;    // 1Hz
            case STEP_LEVEL_4: return 1000;   // 10Hz
            default: return 1;
        }
    } else {  // FREQ_MODE_HIGH
        switch (level) {
            case STEP_LEVEL_1: return 10;     // 0.1Hz
            case STEP_LEVEL_2: return 100;    // 1Hz
            case STEP_LEVEL_3: return 1000;   // 10Hz
            case STEP_LEVEL_4: return 10000;  // 100Hz
            default: return 10;
        }
    }
}
```

---

## ⬆️ UP键升级逻辑

### 升级规则
UP键按频率**超过阈值**时升级到下一级别。

### 实现代码
```c
static void CheckStepLevelUpgrade(uint32_t freq)
{
    if (freq_mode == FREQ_MODE_LOW) {
        // 低频模式
        if (current_step_level == STEP_LEVEL_1 && freq > LOW_STEP1_MAX) {
            current_step_level = STEP_LEVEL_2;  // 超过0.09Hz → 升级到0.1Hz步进
        } else if (current_step_level == STEP_LEVEL_2 && freq > LOW_STEP2_MAX) {
            current_step_level = STEP_LEVEL_3;  // 超过0.90Hz → 升级到1Hz步进
        } else if (current_step_level == STEP_LEVEL_3 && freq > LOW_STEP3_MAX) {
            current_step_level = STEP_LEVEL_4;  // 超过9.90Hz → 升级到10Hz步进
        }
    } else {
        // 高频模式
        if (current_step_level == STEP_LEVEL_1 && freq > HIGH_STEP1_MAX) {
            current_step_level = STEP_LEVEL_2;  // 超过0.9Hz → 升级到1Hz步进
        } else if (current_step_level == STEP_LEVEL_2 && freq > HIGH_STEP2_MAX) {
            current_step_level = STEP_LEVEL_3;  // 超过9.9Hz → 升级到10Hz步进
        } else if (current_step_level == STEP_LEVEL_3 && freq > HIGH_STEP3_MAX) {
            current_step_level = STEP_LEVEL_4;  // 超过99.9Hz → 升级到100Hz步进
        }
    }
}
```

### UP键示例（低频模式）
```
起始：0.00Hz，级别1，步进0.01Hz
按UP：0.01, 0.02, 0.03, ..., 0.09
按UP：0.10 → 自动升级到级别2，步进0.1Hz ✅
按UP：0.20, 0.30, 0.40, ..., 0.90
按UP：1.00 → 自动升级到级别3，步进1Hz ✅
按UP：2.00, 3.00, 4.00, ..., 9.00
按UP：10.00 → 自动升级到级别4，步进10Hz ✅
按UP：20.00, 30.00, ..., 400.00（最大值）
```

---

## ⬇️ DOWN键升级逻辑

### 升级规则
DOWN键按频率**到达步进倍数**时升级到下一级别。

### 实现代码
```c
static void CheckStepLevelUpgradeForDown(uint32_t freq)
{
    if (freq_mode == FREQ_MODE_LOW) {
        // 低频模式
        if (current_step_level == STEP_LEVEL_1 && (freq % 10) == 0 && freq > 0) {
            current_step_level = STEP_LEVEL_2;  // 到达0.10, 0.20... → 升级
        } 
        else if (current_step_level == STEP_LEVEL_2 && (freq % 100) == 0 && freq >= 100) {
            current_step_level = STEP_LEVEL_3;  // 到达1.00, 2.00... → 升级
        } 
        else if (current_step_level == STEP_LEVEL_3 && (freq % 1000) == 0 && freq >= 1000) {
            current_step_level = STEP_LEVEL_4;  // 到达10.00, 20.00... → 升级
        }
    } else {
        // 高频模式
        if (current_step_level == STEP_LEVEL_1 && (freq % 100) == 0 && freq > 0) {
            current_step_level = STEP_LEVEL_2;  // 到达1.0, 2.0... → 升级
        } 
        else if (current_step_level == STEP_LEVEL_2 && (freq % 1000) == 0 && freq >= 1000) {
            current_step_level = STEP_LEVEL_3;  // 到达10.0, 20.0... → 升级
        } 
        else if (current_step_level == STEP_LEVEL_3 && (freq % 10000) == 0 && freq >= 10000) {
            current_step_level = STEP_LEVEL_4;  // 到达100.0, 200.0... → 升级
        }
    }
}
```

### DOWN键示例（低频模式）
```
起始：400.00Hz（超时后重置为级别1，步进0.01Hz）
按DOWN：399.99, 399.98, ..., 399.91, 399.90
按DOWN：399.90 → (399.90 % 0.10 == 0) → 升级到级别2，步进0.1Hz ✅
按DOWN：399.80, 399.70, ..., 399.10, 399.00
按DOWN：399.00 → (399.00 % 1.00 == 0) → 升级到级别3，步进1Hz ✅
按DOWN：398.00, 397.00, ..., 391.00, 390.00
按DOWN：390.00 → (390.00 % 10.00 == 0) → 升级到级别4，步进10Hz ✅
按DOWN：380.00, 370.00, ..., 10.00, 0.00
```

---

## ⏱️ 超时重置机制

### 超时规则
500ms无按键操作后，步进级别**强制重置**为级别1。

### 实现代码
```c
#define STEP_TIMEOUT 500  // 500ms超时

uint32_t last_freq_key_time = 0;  // 上次按键时间

// 在主循环中检查超时
uint32_t current_time = HAL_GetTick();
if (current_time - last_freq_key_time > STEP_TIMEOUT) {
    current_step_level = STEP_LEVEL_1;  // ✅ 强制重置为级别1
}

// 在UP/DOWN键处理中更新时间
case KEY_UP:
case KEY_DOWN:
    last_freq_key_time = current_time;  // 更新时间戳
    // ... 频率调整逻辑
    break;
```

### 超时示例
```
状态：级别4，步进10Hz，当前频率100.00Hz
操作：停止按键 → 等待500ms
结果：级别重置为级别1，步进0.01Hz ✅
再次按UP：100.01Hz（使用0.01Hz步进）
```

---

## 🔄 完整按键处理流程

### UP键处理
```c
case KEY_UP: {
    // 1. 检查超时（重置步进级别）
    if (current_time - last_freq_key_time > STEP_TIMEOUT) {
        current_step_level = STEP_LEVEL_1;
    }
    
    // 2. 获取当前步进值
    uint32_t step = GetFreqStepValue(current_step_level);
    
    // 3. 调整频率
    current_frequency += step;
    if (current_frequency > max_freq) {
        current_frequency = max_freq;  // 限制最大值
    }
    
    // 4. 检查是否需要升级步进级别
    CheckStepLevelUpgrade(current_frequency);
    
    // 5. 更新时间戳和显示
    last_freq_key_time = current_time;
    UpdateDisplay();
    break;
}
```

### DOWN键处理
```c
case KEY_DOWN: {
    // 1. 检查超时（重置步进级别）
    if (current_time - last_freq_key_time > STEP_TIMEOUT) {
        current_step_level = STEP_LEVEL_1;
    }
    
    // 2. 获取当前步进值
    uint32_t step = GetFreqStepValue(current_step_level);
    
    // 3. 调整频率
    if (current_frequency >= step) {
        current_frequency -= step;
    } else {
        current_frequency = 0;  // 限制最小值
    }
    
    // 4. 检查是否需要升级步进级别
    CheckStepLevelUpgradeForDown(current_frequency);
    
    // 5. 更新时间戳和显示
    last_freq_key_time = current_time;
    UpdateDisplay();
    break;
}
```

---

## 🔀 模式切换

### FUNC键 - 切换低频/高频模式
```c
case KEY_FUNC: {
    // 切换模式
    if (freq_mode == FREQ_MODE_LOW) {
        freq_mode = FREQ_MODE_HIGH;
        current_frequency = FREQ_HIGH_START;  // 0.1Hz
        SPI_Display_SetLED(LED_FR, 1);        // 点亮F/R指示高频
    } else {
        freq_mode = FREQ_MODE_LOW;
        current_frequency = FREQ_LOW_START;   // 0.01Hz
        SPI_Display_SetLED(LED_FR, 0);        // 熄灭F/R指示低频
    }
    
    // 重置步进级别
    current_step_level = STEP_LEVEL_1;
    last_freq_key_time = current_time;
    
    UpdateDisplay();
    break;
}
```

---

## 📝 测试用例

### 测试用例1：UP键连续升级（低频）
```
初始：0.00Hz，级别1
操作：连续按UP
预期：
  0.00 → 0.01 → 0.02 → ... → 0.09 (级别1)
  → 0.10 (升级到级别2)
  → 0.20 → 0.30 → ... → 0.90 (级别2)
  → 1.00 (升级到级别3)
  → 2.00 → 3.00 → ... → 9.00 (级别3)
  → 10.00 (升级到级别4)
  → 20.00 → 30.00 → ... → 400.00 (级别4，最大值)
```

### 测试用例2：DOWN键连续升级（低频）
```
初始：400.00Hz，超时后级别1
操作：连续按DOWN
预期：
  400.00 → 399.99 → ... → 399.91 → 399.90 (级别1)
  (到达0.10倍数，升级到级别2)
  → 399.80 → 399.70 → ... → 399.00 (级别2)
  (到达1.00倍数，升级到级别3)
  → 398.00 → 397.00 → ... → 390.00 (级别3)
  (到达10.00倍数，升级到级别4)
  → 380.00 → 370.00 → ... → 0.00 (级别4)
```

### 测试用例3：超时重置
```
初始：100.00Hz，级别4，步进10Hz
操作：停止按键，等待600ms
预期：步进级别重置为级别1，步进0.01Hz
再按UP：100.01Hz ✅
```

### 测试用例4：模式切换
```
初始：低频模式，50.00Hz
操作：按FUNC键
预期：
  - 切换到高频模式
  - 频率重置为0.1Hz
  - F/R LED点亮
  - 步进级别重置为级别1
显示：0000.1 Hz (高频格式) ✅
```

---

## ⚠️ 重要注意事项

### 禁止操作
- ❌ 随意修改阈值常量
- ❌ 修改步进级别数量
- ❌ 修改超时时间（已优化）
- ❌ 删除超时重置逻辑
- ❌ UP和DOWN使用相同升级逻辑

### 必须遵守
- ✅ UP键：超过阈值升级
- ✅ DOWN键：到达倍数升级
- ✅ 超时后强制重置为级别1
- ✅ 模式切换时重置步进级别
- ✅ 频率限制在最小/最大值内

---

## 📊 智能步进状态图

```
[级别1: 0.01/0.1Hz] 
    │
    │ freq > 阈值1
    ↓
[级别2: 0.1/1Hz]
    │
    │ freq > 阈值2
    ↓
[级别3: 1/10Hz]
    │
    │ freq > 阈值3
    ↓
[级别4: 10/100Hz]
    │
    ↓
    ↓ 超时500ms
    ↓
    ↓────────────────→ [强制重置到级别1]
```

---

**最后更新：** 2025-10-25  
**版本：** v1.0  
**状态：** ✅ 已验证并优化


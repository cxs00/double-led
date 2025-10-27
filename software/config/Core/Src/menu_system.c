/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : menu_system.c
  * @brief          : Multi-level menu system implementation
  ******************************************************************************
  */
/* USER CODE END Header */

#include "menu_system.h"
#include "segment_display.h"
#include "key.h"
#include <string.h>
#include <stdio.h>

/* 全局变量 */
MenuSystem_t g_menu_system;

/* 参数存储 */
static int32_t param_target_freq = 5000;
static int32_t param_max_freq = 40000;
static int32_t param_min_freq = 0;
static int32_t param_accel_time = 100;
static int32_t param_decel_time = 100;
static int32_t param_overcurrent = 3000;
static int32_t param_overvoltage = 450;
static int32_t param_undervoltage = 320;
static int32_t param_display_mode = 0;
static int32_t param_key_lock = 0;

/* 参数表定义 */
Parameter_t g_parameter_table[] = {
    {0, 0, "Target Freq",    PARAM_TYPE_UINT16, 0, 40000, 5000,  &param_target_freq,   1, 2, 1},
    {0, 1, "Max Freq",       PARAM_TYPE_UINT16, 0, 40000, 40000, &param_max_freq,      1, 2, 1},
    {0, 2, "Min Freq",       PARAM_TYPE_UINT16, 0, 40000, 0,     &param_min_freq,      1, 2, 1},
    {0, 3, "Accel Time",     PARAM_TYPE_UINT16, 0, 6000,  100,   &param_accel_time,    5, 1, 1},
    {0, 4, "Decel Time",     PARAM_TYPE_UINT16, 0, 6000,  100,   &param_decel_time,    5, 1, 1},
    {1, 0, "Overcurrent",    PARAM_TYPE_UINT16, 0, 5000,  3000,  &param_overcurrent,   2, 2, 1},
    {1, 1, "Overvoltage",    PARAM_TYPE_UINT16, 0, 500,   450,   &param_overvoltage,   3, 0, 1},
    {1, 2, "Undervoltage",   PARAM_TYPE_UINT16, 0, 400,   320,   &param_undervoltage,  3, 0, 1},
    {2, 0, "Display Mode",   PARAM_TYPE_ENUM,   0, 2,     0,     &param_display_mode,  0, 0, 1},
    {2, 1, "Key Lock",       PARAM_TYPE_ENUM,   0, 1,     0,     &param_key_lock,      0, 0, 1},
};

const uint8_t g_parameter_count = sizeof(g_parameter_table) / sizeof(Parameter_t);

/* 私有函数声明 */
static void MENU_DisplayMain(void);
static void MENU_DisplayGroup(void);
static void MENU_DisplayParam(void);
static void MENU_DisplayEdit(void);
static void MENU_EnterGroup(void);
static void MENU_EnterParam(void);
static void MENU_EnterEdit(void);
static void MENU_ExitEdit(void);
static void MENU_ExitParam(void);
static void MENU_ExitGroup(void);

/**
  * @brief  菜单系统初始化
  * @param  None
  * @retval None
  */
void MENU_Init(void)
{
    g_menu_system.current_state = MENU_STATE_MAIN;
    g_menu_system.current_group = 0;
    g_menu_system.current_param = 0;
    g_menu_system.edit_digit_pos = 0;
    g_menu_system.last_key_time = 0;
    g_menu_system.auto_return_enable = 1;
    
    MENU_LoadParameters();
}

/**
  * @brief  获取当前参数指针
  * @param  None
  * @retval Parameter_t* 当前参数指针
  */
Parameter_t* MENU_GetCurrentParameter(void)
{
    for (uint8_t i = 0; i < g_parameter_count; i++) {
        if (g_parameter_table[i].group == g_menu_system.current_group &&
            g_parameter_table[i].index == g_menu_system.current_param) {
            return &g_parameter_table[i];
        }
    }
    return NULL;
}

/**
  * @brief  菜单显示更新
  * @param  None
  * @retval None
  */
void MENU_UpdateDisplay(void)
{
    switch (g_menu_system.current_state) {
        case MENU_STATE_MAIN:
            MENU_DisplayMain();
            break;
        case MENU_STATE_GROUP:
            MENU_DisplayGroup();
            break;
        case MENU_STATE_PARAM:
            MENU_DisplayParam();
            break;
        case MENU_STATE_EDIT:
            MENU_DisplayEdit();
            break;
    }
}

static void MENU_DisplayMain(void)
{
    /* 主界面由main.c处理 */
}

static void MENU_DisplayGroup(void)
{
    char str[6];
    snprintf(str, sizeof(str), "F-%d", g_menu_system.current_group);
    SEG_DisplayString_D7(str);
    SEG_DisplayString_D8("     ");
}

static void MENU_DisplayParam(void)
{
    Parameter_t *param = MENU_GetCurrentParameter();
    if (param == NULL) {
        SEG_DisplayString_D7("E-RR");
        SEG_DisplayString_D8("     ");
        return;
    }
    
    char str[6];
    snprintf(str, sizeof(str), "F%d.%02d", param->group, param->index);
    SEG_DisplayString_D7(str);
    
    int32_t value = *(param->value_ptr);
    
    if (param->decimal_places == 0) {
        SEG_SetNumber_D8(value);
    } else if (param->decimal_places == 1) {
        uint8_t int_part = value / 10;
        uint8_t dec_part = value % 10;
        SEG_SetDigit_D8(0, int_part / 1000, 0);
        SEG_SetDigit_D8(1, (int_part / 100) % 10, 0);
        SEG_SetDigit_D8(2, (int_part / 10) % 10, 0);
        SEG_SetDigit_D8(3, int_part % 10, 1);
        SEG_SetDigit_D8(4, dec_part, 0);
    } else if (param->decimal_places == 2) {
        SEG_SetDigit_D8(0, (value / 10000) % 10, 0);
        SEG_SetDigit_D8(1, (value / 1000) % 10, 0);
        SEG_SetDigit_D8(2, (value / 100) % 10, 1);
        SEG_SetDigit_D8(3, (value / 10) % 10, 0);
        SEG_SetDigit_D8(4, value % 10, 0);
    }
    
    SEG_ClearAllLED();
    switch (param->unit) {
        case 1: SEG_SetLED(LED_HZ, 1); break;
        case 2: SEG_SetLED(LED_A, 1); break;
        case 3: SEG_SetLED(LED_V, 1); break;
    }
}

static void MENU_DisplayEdit(void)
{
    MENU_DisplayParam();
}

static void MENU_EnterGroup(void)
{
    g_menu_system.current_state = MENU_STATE_GROUP;
    g_menu_system.current_group = 0;
    g_menu_system.last_key_time = HAL_GetTick();
}

static void MENU_EnterParam(void)
{
    g_menu_system.current_state = MENU_STATE_PARAM;
    g_menu_system.current_param = 0;
    g_menu_system.last_key_time = HAL_GetTick();
}

static void MENU_EnterEdit(void)
{
    Parameter_t *param = MENU_GetCurrentParameter();
    if (param == NULL || param->writable == 0) return;
    
    g_menu_system.current_state = MENU_STATE_EDIT;
    g_menu_system.edit_digit_pos = 0;
    g_menu_system.last_key_time = HAL_GetTick();
}

static void MENU_ExitEdit(void)
{
    g_menu_system.current_state = MENU_STATE_PARAM;
    g_menu_system.last_key_time = HAL_GetTick();
}

static void MENU_ExitParam(void)
{
    g_menu_system.current_state = MENU_STATE_GROUP;
    g_menu_system.last_key_time = HAL_GetTick();
}

static void MENU_ExitGroup(void)
{
    g_menu_system.current_state = MENU_STATE_MAIN;
    g_menu_system.last_key_time = HAL_GetTick();
}

/**
  * @brief  按键处理
  * @param  key_value: 按键值
  * @retval None
  */
void MENU_ProcessKey(uint8_t key_value)
{
    Parameter_t *param;
    
    switch (g_menu_system.current_state) {
        case MENU_STATE_MAIN:
            if (key_value == KEY_RPG) {
                MENU_EnterGroup();
            }
            break;
        
        case MENU_STATE_GROUP:
            if (key_value == KEY_UP) {
                g_menu_system.current_group++;
                if (g_menu_system.current_group > 9) g_menu_system.current_group = 0;
            } else if (key_value == KEY_DOWN) {
                if (g_menu_system.current_group == 0) g_menu_system.current_group = 9;
                else g_menu_system.current_group--;
            } else if (key_value == KEY_RPG) {
                MENU_EnterParam();
            } else if (key_value == KEY_FUNC) {
                MENU_ExitGroup();
            }
            break;
        
        case MENU_STATE_PARAM:
            if (key_value == KEY_UP) {
                g_menu_system.current_param++;
                if (g_menu_system.current_param > 99) g_menu_system.current_param = 0;
                param = MENU_GetCurrentParameter();
                if (param == NULL) g_menu_system.current_param = 0;
            } else if (key_value == KEY_DOWN) {
                if (g_menu_system.current_param == 0) g_menu_system.current_param = 99;
                else g_menu_system.current_param--;
                param = MENU_GetCurrentParameter();
                if (param == NULL) g_menu_system.current_param = 0;
            } else if (key_value == KEY_ENTER) {
                MENU_EnterEdit();
            } else if (key_value == KEY_RPG) {
                MENU_ExitParam();
            }
            break;
        
        case MENU_STATE_EDIT:
            param = MENU_GetCurrentParameter();
            if (param == NULL) {
                MENU_ExitEdit();
                break;
            }
            
            if (key_value == KEY_UP) {
                *(param->value_ptr) += 1;
                if (*(param->value_ptr) > param->max_value) {
                    *(param->value_ptr) = param->max_value;
                }
            } else if (key_value == KEY_DOWN) {
                *(param->value_ptr) -= 1;
                if (*(param->value_ptr) < param->min_value) {
                    *(param->value_ptr) = param->min_value;
                }
            } else if (key_value == KEY_ENTER) {
                MENU_ExitEdit();
            } else if (key_value == KEY_SHIFT) {
                g_menu_system.edit_digit_pos++;
                if (g_menu_system.edit_digit_pos > 4) g_menu_system.edit_digit_pos = 0;
            }
            break;
    }
    
    g_menu_system.last_key_time = HAL_GetTick();
}

/**
  * @brief  保存参数到EEPROM
  * @param  None
  * @retval None
  */
void MENU_SaveParameters(void)
{
    /* TODO: 实现EEPROM保存功能 */
}

/**
  * @brief  从EEPROM加载参数
  * @param  None
  * @retval None
  */
void MENU_LoadParameters(void)
{
    /* TODO: 实现EEPROM加载功能 */
}


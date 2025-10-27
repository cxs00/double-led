/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : menu_system.h
  * @brief          : Multi-level menu system for inverter parameter setting
  ******************************************************************************
  */
/* USER CODE END Header */

#ifndef __MENU_SYSTEM_H
#define __MENU_SYSTEM_H

#ifdef __cplusplus
extern "C" {
#endif

#include "main.h"

/* 菜单状态定义 */
typedef enum {
    MENU_STATE_MAIN = 0,
    MENU_STATE_GROUP,
    MENU_STATE_PARAM,
    MENU_STATE_EDIT
} MenuState_t;

/* 参数类型定义 */
typedef enum {
    PARAM_TYPE_UINT16,
    PARAM_TYPE_INT16,
    PARAM_TYPE_FLOAT,
    PARAM_TYPE_ENUM
} ParamType_t;

/* 参数定义 */
typedef struct {
    uint8_t group;
    uint8_t index;
    const char *name;
    ParamType_t type;
    int32_t min_value;
    int32_t max_value;
    int32_t default_value;
    int32_t *value_ptr;
    uint8_t unit;
    uint8_t decimal_places;
    uint8_t writable;
} Parameter_t;

/* 菜单系统结构 */
typedef struct {
    MenuState_t current_state;
    uint8_t current_group;
    uint8_t current_param;
    uint8_t edit_digit_pos;
    uint32_t last_key_time;
    uint8_t auto_return_enable;
} MenuSystem_t;

/* 全局变量 */
extern MenuSystem_t g_menu_system;
extern Parameter_t g_parameter_table[];
extern const uint8_t g_parameter_count;

/* 基础函数 */
void MENU_Init(void);
void MENU_UpdateDisplay(void);
void MENU_ProcessKey(uint8_t key_value);
Parameter_t* MENU_GetCurrentParameter(void);
void MENU_SaveParameters(void);
void MENU_LoadParameters(void);

#ifdef __cplusplus
}
#endif

#endif /* __MENU_SYSTEM_H */


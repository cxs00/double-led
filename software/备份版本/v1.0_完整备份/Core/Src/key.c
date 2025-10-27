/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : key.c
  * @brief          : Key scan driver
  ******************************************************************************
  */
/* USER CODE END Header */

#include "key.h"
#include "spi_display.h"

static uint16_t key_last_state = 0;

/**
  * @brief  按键初始化
  * @param  None
  * @retval None
  */
void KEY_Init(void)
{
    key_last_state = 0;
}

/**
  * @brief  读取按键状态
  * @param  None
  * @retval 9位按键状态
  */
uint16_t KEY_Read(void)
{
    uint16_t key_state = SPI_Key_Read9Bits();
    return ~key_state;
}

/**
  * @brief  扫描按键
  * @param  None
  * @retval 按键ID
  */
uint8_t KEY_Scan(void)
{
    uint16_t key_state = KEY_Read();
    uint8_t key_pressed = KEY_NONE;
    
    if (key_state != key_last_state) {
        HAL_Delay(10);
        key_state = KEY_Read();
        
        if (key_state != key_last_state) {
            key_last_state = key_state;
            
            if (key_state & 0x100) {
                key_pressed = KEY_RUN;
            } else if (key_state & 0x001) {
                key_pressed = KEY_RESERVED;
            } else if (key_state & 0x002) {
                key_pressed = KEY_ENTER;
            } else if (key_state & 0x004) {
                key_pressed = KEY_FUNC;
            } else if (key_state & 0x008) {
                key_pressed = KEY_STOP;
            } else if (key_state & 0x010) {
                key_pressed = KEY_DOWN;
            } else if (key_state & 0x020) {
                key_pressed = KEY_RPG;
            } else if (key_state & 0x040) {
                key_pressed = KEY_SHIFT;
            } else if (key_state & 0x080) {
                key_pressed = KEY_UP;
            }
        }
    }
    
    return key_pressed;
}


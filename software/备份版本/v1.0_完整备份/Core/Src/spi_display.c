/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : spi_display.c
  * @brief          : SPI Display Driver
  ******************************************************************************
  */
/* USER CODE END Header */

#include "spi_display.h"

/**
  * @brief  SPI显示初始化
  * @param  None
  * @retval None
  */
void SPI_Display_Init(void)
{
    /* LATCH引脚已在MX_GPIO_Init()中初始化 */
    DISPLAY_LATCH_LOW();
}

/**
  * @brief  SPI发送数据
  * @param  data: 数据指针
  * @param  len: 数据长度
  * @retval None
  */
void SPI_Display_SendData(uint8_t *data, uint8_t len)
{
    DISPLAY_LATCH_LOW();
    HAL_SPI_Transmit(&hspi2, data, len, 100);
    DISPLAY_LATCH_HIGH();
    DISPLAY_LATCH_LOW();
}

/**
  * @brief  从74HC165读取9位按键状态
  * @param  None
  * @retval 9位按键状态（bit0-7=D0-D7, bit8=SER）
  */
uint16_t SPI_Key_Read9Bits(void)
{
    uint8_t rx_data[2] = {0, 0};
    
    /* 生成LOAD脉冲 */
    KEY_LOAD_LOW();
    for(uint8_t i = 0; i < 10; i++);
    KEY_LOAD_HIGH();
    
    /* 读取2字节数据 */
    HAL_SPI_Receive(&hspi2, rx_data, 2, 100);
    
    /* 组合9位数据 */
    uint16_t key_state = ((uint16_t)rx_data[0] << 1) | (rx_data[1] >> 7);
    
    return key_state;
}


/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : hc595.c
  * @brief          : 74HC595 Shift Register Driver
  ******************************************************************************
  */
/* USER CODE END Header */

#include "hc595.h"
#include "spi_display.h"

/**
  * @brief  初始化74HC595
  * @param  None
  * @retval None
  */
void HC595_Init(void)
{
    SPI_Display_Init();
}

/**
  * @brief  向74HC595发送数据
  * @param  data1: U6的数据
  * @param  data2: U2的数据
  * @param  data3: U1的数据
  * @retval None
  */
void HC595_SendData(uint8_t data1, uint8_t data2, uint8_t data3)
{
    uint8_t data[3] = {data1, data2, data3};
    SPI_Display_SendData(data, 3);
}


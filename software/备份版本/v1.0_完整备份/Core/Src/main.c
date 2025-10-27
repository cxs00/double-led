/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : main.c
  * @brief          : Main program body
  ******************************************************************************
  */
/* USER CODE END Header */
/* Includes ------------------------------------------------------------------*/
#include "main.h"

/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */
#include "hc595.h"
#include "spi_display.h"
#include "segment_display.h"
#include "key.h"
#include "menu_system.h"
/* USER CODE END Includes */

/* Private typedef -----------------------------------------------------------*/
/* USER CODE BEGIN PTD */

/* USER CODE END PTD */

/* Private define ------------------------------------------------------------*/
/* USER CODE BEGIN PD */

/* USER CODE END PD */

/* Private macro -------------------------------------------------------------*/
/* USER CODE BEGIN PM */

/* USER CODE END PM */

/* Private variables ---------------------------------------------------------*/
ADC_HandleTypeDef hadc1;

TIM_HandleTypeDef htim4;

/* USER CODE BEGIN PV */
/* 显示刷新定时器 */
uint32_t refresh_timer = 0;

/* 按键扫描定时器 */
uint32_t key_scan_timer = 0;
uint8_t key_value = KEY_NONE;
uint8_t last_key_value = KEY_NONE;

/* 频率控制参数（单位：0.01Hz） */
uint16_t current_frequency = 5000;  // 默认50.00Hz

/* 频率范围 */
const uint16_t FREQ_LOW_MIN = 0;
const uint16_t FREQ_LOW_MAX = 40000;

/* 智能步进阈值 */
const uint16_t FREQ_THRESHOLD_001 = 10;
const uint16_t FREQ_THRESHOLD_01 = 100;
const uint16_t FREQ_THRESHOLD_1 = 1000;

/* 电流显示参数（单位：0.01A） */
uint32_t current_ampere = 0;

/* 电机运行状态 */
typedef enum {
    MOTOR_STATE_STOP = 0,
    MOTOR_STATE_RUN = 1
} MotorRunState_t;

MotorRunState_t motor_run_state = MOTOR_STATE_STOP;

/* 长按检测 */
uint8_t key_long_press_count = 0;
const uint8_t KEY_LONG_PRESS_THRESHOLD = 10;

/* 智能步进计时器 */
uint32_t last_key_time = 0;
const uint32_t KEY_TIMEOUT = 1000;
uint16_t current_step = 1;
uint32_t last_up_time = 0;
uint32_t last_down_time = 0;
const uint32_t FAST_PRESS_INTERVAL = 200;
/* USER CODE END PV */

/* Private function prototypes -----------------------------------------------*/
void SystemClock_Config(void);
static void MX_GPIO_Init(void);
static void MX_ADC1_Init(void);
static void MX_TIM4_Init(void);
/* USER CODE BEGIN PFP */

/**
  * @brief  计算智能步进值
  * @param  freq: 当前频率
  * @param  current_step: 当前步进值
  * @retval 步进值
  */
static uint16_t GetFreqStep(uint16_t freq, uint16_t current_step)
{
    uint16_t max_step;
    
    if (freq < FREQ_THRESHOLD_001) {
        max_step = 1;
    } else if (freq < FREQ_THRESHOLD_01) {
        max_step = 10;
    } else if (freq < FREQ_THRESHOLD_1) {
        max_step = 100;
    } else {
        max_step = 1000;
    }
    
    if (current_step > max_step) {
        return max_step;
    }
    
    return current_step;
}

/**
  * @brief  更新双显示
  * @param  None
  * @retval None
  */
static void UpdateDisplay(void)
{
    // D7显示频率
    SEG_DisplayFrequency(current_frequency);
    
    // D8显示电流（245.13A格式）
    SEG_SetDigit_D8(0, (current_ampere / 10000) % 10, 0);
    SEG_SetDigit_D8(1, (current_ampere / 1000) % 10, 0);
    SEG_SetDigit_D8(2, (current_ampere / 100) % 10, 1);
    SEG_SetDigit_D8(3, (current_ampere / 10) % 10, 0);
    SEG_SetDigit_D8(4, current_ampere % 10, 0);
}

/* USER CODE END PFP */

/* Private user code ---------------------------------------------------------*/
/* USER CODE BEGIN 0 */

/* USER CODE END 0 */

/**
  * @brief  The application entry point.
  * @retval int
  */
int main(void)
{

  /* USER CODE BEGIN 1 */

  /* USER CODE END 1 */

  /* MCU Configuration--------------------------------------------------------*/

  /* Reset of all peripherals, Initializes the Flash interface and the Systick. */
  HAL_Init();

  /* USER CODE BEGIN Init */

  /* USER CODE END Init */

  /* Configure the system clock */
  SystemClock_Config();

  /* USER CODE BEGIN SysInit */

  /* USER CODE END SysInit */

  /* Initialize all configured peripherals */
  MX_GPIO_Init();
  MX_ADC1_Init();
  MX_TIM4_Init();
  /* USER CODE BEGIN 2 */
  
  /* ==================== 初始化驱动模块 ==================== */
  HC595_Init();
  SEG_Init();
  KEY_Init();
  MENU_Init();
  
  /* ==================== 欢迎界面演示 ==================== */
  
  // 1. 上电欢迎（全部LED闪烁3次）
  for(uint8_t i = 0; i < 3; i++) {
    SEG_SetLED(LED_HZ, 1);
    SEG_SetLED(LED_A, 1);
    SEG_SetLED(LED_V, 1);
    SEG_SetLED(LED_ALM, 1);
    SEG_SetLED(LED_FR, 1);
    SEG_SetLED(LED_RUN, 1);
    HAL_Delay(200);
    
    SEG_ClearAllLED();
    HAL_Delay(200);
  }
  
  // 2. 显示欢迎文字
  SEG_DisplayString_D7("HELLO");
  SEG_DisplayString_D8("88888");
  HAL_Delay(1000);
  
  // 3. 初始状态
  current_ampere = 24513;  // 245.13A
  UpdateDisplay();
  SEG_SetMotorState(MOTOR_STOP);
  motor_run_state = MOTOR_STATE_STOP;
  
  HAL_Delay(500);

  /* USER CODE END 2 */

  /* Infinite loop */
  /* USER CODE BEGIN WHILE */
  while (1)
  {
    /* USER CODE END WHILE */

    /* USER CODE BEGIN 3 */
    
    /* ========== 显示刷新（每2ms） ========== */
    if (HAL_GetTick() - refresh_timer >= SEG_REFRESH_TIME)
    {
      refresh_timer = HAL_GetTick();
      SEG_Refresh();
    }
    
    /* ========== 菜单显示更新（每100ms） ========== */
    static uint32_t menu_display_timer = 0;
    if (HAL_GetTick() - menu_display_timer >= 100)
    {
      menu_display_timer = HAL_GetTick();
      MENU_UpdateDisplay();
    }
    
    /* ========== 按键扫描（每50ms） ========== */
    if (HAL_GetTick() - key_scan_timer >= 50)
    {
      key_scan_timer = HAL_GetTick();
      key_value = KEY_Scan();
      
      /* ========== 按键处理 ========== */
      if (key_value != KEY_NONE)
      {
        // 检测长按
        if (key_value == last_key_value && key_value != KEY_NONE) {
          key_long_press_count++;
        } else {
          key_long_press_count = 0;
          last_key_value = key_value;
        }
        
        /* ========== 菜单系统按键处理 ========== */
        MENU_ProcessKey(key_value);
        
        /* ========== 运行控制按键处理（仅在主界面有效） ========== */
        if (g_menu_system.current_state == MENU_STATE_MAIN)
        {
          switch (key_value)
          {
            case KEY_RUN:
              // RUN按键：启动电机
              if (motor_run_state == MOTOR_STATE_STOP) {
                motor_run_state = MOTOR_STATE_RUN;
                SEG_SetMotorState(MOTOR_RUN_FORWARD);
              }
              break;
          
            case KEY_STOP:
              // STOP按键：停止电机
              if (motor_run_state == MOTOR_STATE_RUN) {
                motor_run_state = MOTOR_STATE_STOP;
                SEG_SetMotorState(MOTOR_STOP);
              }
              break;
          
            case KEY_UP:
              // UP按键：增加频率
              {
              uint32_t current_time = HAL_GetTick();
              
              if (current_time - last_key_time > KEY_TIMEOUT) {
                current_step = 1;
              }
              last_key_time = current_time;
              
              if (current_time - last_up_time < FAST_PRESS_INTERVAL) {
                if (current_step < 1000) {
                  if (current_step < 10) {
                    current_step = 10;
                  } else if (current_step < 100) {
                    current_step = 100;
                  } else {
                    current_step = 1000;
                  }
                }
              } else {
                current_step = 1;
              }
              last_up_time = current_time;
              
              uint16_t step = GetFreqStep(current_frequency, current_step);
              
              if (current_frequency <= FREQ_LOW_MAX - step) {
                current_frequency += step;
              } else {
                current_frequency = FREQ_LOW_MAX;
              }
              
              UpdateDisplay();
            }
            break;
          
            case KEY_DOWN:
              // DOWN按键：减少频率
              {
              uint32_t current_time = HAL_GetTick();
              
              if (current_time - last_key_time > KEY_TIMEOUT) {
                current_step = 1;
              }
              last_key_time = current_time;
              
              if (current_time - last_down_time < FAST_PRESS_INTERVAL) {
                if (current_step < 1000) {
                  if (current_step < 10) {
                    current_step = 10;
                  } else if (current_step < 100) {
                    current_step = 100;
                  } else {
                    current_step = 1000;
                  }
                }
              } else {
                current_step = 1;
              }
              last_down_time = current_time;
              
              uint16_t step = GetFreqStep(current_frequency, current_step);
              
              if (current_frequency >= FREQ_LOW_MIN + step) {
                current_frequency -= step;
              } else {
                current_frequency = FREQ_LOW_MIN;
              }
              
              UpdateDisplay();
              }
              break;
            
            default:
              break;
          }
        }
      } else {
        key_long_press_count = 0;
        last_key_value = KEY_NONE;
      }
    }
    
  }
  /* USER CODE END 3 */
}

/**
  * @brief System Clock Configuration
  * @retval None
  */
void SystemClock_Config(void)
{
  RCC_OscInitTypeDef RCC_OscInitStruct = {0};
  RCC_ClkInitTypeDef RCC_ClkInitStruct = {0};
  RCC_PeriphCLKInitTypeDef PeriphClkInit = {0};

  /** Initializes the RCC Oscillators according to the specified parameters
  * in the RCC_OscInitTypeDef structure.
  */
  RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSI;
  RCC_OscInitStruct.HSIState = RCC_HSI_ON;
  RCC_OscInitStruct.HSICalibrationValue = RCC_HSICALIBRATION_DEFAULT;
  RCC_OscInitStruct.PLL.PLLState = RCC_PLL_NONE;
  if (HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK)
  {
    Error_Handler();
  }

  /** Initializes the CPU, AHB and APB buses clocks
  */
  RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK|RCC_CLOCKTYPE_SYSCLK
                              |RCC_CLOCKTYPE_PCLK1|RCC_CLOCKTYPE_PCLK2;
  RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_HSI;
  RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
  RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV1;
  RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV1;

  if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_0) != HAL_OK)
  {
    Error_Handler();
  }
  PeriphClkInit.PeriphClockSelection = RCC_PERIPHCLK_ADC;
  PeriphClkInit.AdcClockSelection = RCC_ADCPCLK2_DIV2;
  if (HAL_RCCEx_PeriphCLKConfig(&PeriphClkInit) != HAL_OK)
  {
    Error_Handler();
  }
}

/**
  * @brief ADC1 Initialization Function
  * @param None
  * @retval None
  */
static void MX_ADC1_Init(void)
{

  /* USER CODE BEGIN ADC1_Init 0 */

  /* USER CODE END ADC1_Init 0 */

  ADC_ChannelConfTypeDef sConfig = {0};

  /* USER CODE BEGIN ADC1_Init 1 */

  /* USER CODE END ADC1_Init 1 */

  /** Common config
  */
  hadc1.Instance = ADC1;
  hadc1.Init.ScanConvMode = ADC_SCAN_DISABLE;
  hadc1.Init.ContinuousConvMode = DISABLE;
  hadc1.Init.DiscontinuousConvMode = DISABLE;
  hadc1.Init.ExternalTrigConv = ADC_SOFTWARE_START;
  hadc1.Init.DataAlign = ADC_DATAALIGN_RIGHT;
  hadc1.Init.NbrOfConversion = 1;
  if (HAL_ADC_Init(&hadc1) != HAL_OK)
  {
    Error_Handler();
  }

  /** Configure Regular Channel
  */
  sConfig.Channel = ADC_CHANNEL_1;
  sConfig.Rank = ADC_REGULAR_RANK_1;
  sConfig.SamplingTime = ADC_SAMPLETIME_1CYCLE_5;
  if (HAL_ADC_ConfigChannel(&hadc1, &sConfig) != HAL_OK)
  {
    Error_Handler();
  }
  /* USER CODE BEGIN ADC1_Init 2 */

  /* USER CODE END ADC1_Init 2 */

}

/**
  * @brief TIM4 Initialization Function
  * @param None
  * @retval None
  */
static void MX_TIM4_Init(void)
{

  /* USER CODE BEGIN TIM4_Init 0 */

  /* USER CODE END TIM4_Init 0 */

  TIM_SlaveConfigTypeDef sSlaveConfig = {0};
  TIM_IC_InitTypeDef sConfigIC = {0};
  TIM_MasterConfigTypeDef sMasterConfig = {0};
  TIM_OC_InitTypeDef sConfigOC = {0};

  /* USER CODE BEGIN TIM4_Init 1 */

  /* USER CODE END TIM4_Init 1 */
  htim4.Instance = TIM4;
  htim4.Init.Prescaler = 0;
  htim4.Init.CounterMode = TIM_COUNTERMODE_UP;
  htim4.Init.Period = 65535;
  htim4.Init.ClockDivision = TIM_CLOCKDIVISION_DIV1;
  htim4.Init.AutoReloadPreload = TIM_AUTORELOAD_PRELOAD_DISABLE;
  if (HAL_TIM_OC_Init(&htim4) != HAL_OK)
  {
    Error_Handler();
  }
  if (HAL_TIM_IC_Init(&htim4) != HAL_OK)
  {
    Error_Handler();
  }
  sSlaveConfig.SlaveMode = TIM_SLAVEMODE_RESET;
  sSlaveConfig.InputTrigger = TIM_TS_TI1FP1;
  sSlaveConfig.TriggerPolarity = TIM_INPUTCHANNELPOLARITY_RISING;
  sSlaveConfig.TriggerPrescaler = TIM_ICPSC_DIV1;
  sSlaveConfig.TriggerFilter = 0;
  if (HAL_TIM_SlaveConfigSynchro(&htim4, &sSlaveConfig) != HAL_OK)
  {
    Error_Handler();
  }
  sConfigIC.ICPolarity = TIM_INPUTCHANNELPOLARITY_RISING;
  sConfigIC.ICSelection = TIM_ICSELECTION_DIRECTTI;
  sConfigIC.ICPrescaler = TIM_ICPSC_DIV1;
  sConfigIC.ICFilter = 0;
  if (HAL_TIM_IC_ConfigChannel(&htim4, &sConfigIC, TIM_CHANNEL_1) != HAL_OK)
  {
    Error_Handler();
  }
  sConfigIC.ICPolarity = TIM_INPUTCHANNELPOLARITY_FALLING;
  sConfigIC.ICSelection = TIM_ICSELECTION_INDIRECTTI;
  if (HAL_TIM_IC_ConfigChannel(&htim4, &sConfigIC, TIM_CHANNEL_2) != HAL_OK)
  {
    Error_Handler();
  }
  sMasterConfig.MasterOutputTrigger = TIM_TRGO_RESET;
  sMasterConfig.MasterSlaveMode = TIM_MASTERSLAVEMODE_DISABLE;
  if (HAL_TIMEx_MasterConfigSynchronization(&htim4, &sMasterConfig) != HAL_OK)
  {
    Error_Handler();
  }
  sConfigOC.OCMode = TIM_OCMODE_TIMING;
  sConfigOC.Pulse = 0;
  sConfigOC.OCPolarity = TIM_OCPOLARITY_HIGH;
  sConfigOC.OCFastMode = TIM_OCFAST_DISABLE;
  if (HAL_TIM_OC_ConfigChannel(&htim4, &sConfigOC, TIM_CHANNEL_3) != HAL_OK)
  {
    Error_Handler();
  }
  if (HAL_TIM_OC_ConfigChannel(&htim4, &sConfigOC, TIM_CHANNEL_4) != HAL_OK)
  {
    Error_Handler();
  }
  /* USER CODE BEGIN TIM4_Init 2 */

  /* USER CODE END TIM4_Init 2 */

}

/**
  * @brief GPIO Initialization Function
  * @param None
  * @retval None
  */
static void MX_GPIO_Init(void)
{
  GPIO_InitTypeDef GPIO_InitStruct = {0};
/* USER CODE BEGIN MX_GPIO_Init_1 */
/* USER CODE END MX_GPIO_Init_1 */

  /* GPIO Ports Clock Enable */
  __HAL_RCC_GPIOA_CLK_ENABLE();
  __HAL_RCC_GPIOB_CLK_ENABLE();

  /*Configure GPIO pin Output Level */
  HAL_GPIO_WritePin(GPIOB, GPIO_PIN_7, GPIO_PIN_RESET);

  /*Configure GPIO pins : PB10 PB13 PB14 PB15 */
  GPIO_InitStruct.Pin = GPIO_PIN_10|GPIO_PIN_13|GPIO_PIN_14|GPIO_PIN_15;
  GPIO_InitStruct.Mode = GPIO_MODE_AF_PP;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_HIGH;
  HAL_GPIO_Init(GPIOB, &GPIO_InitStruct);

  /*Configure GPIO pin : PB11 */
  GPIO_InitStruct.Pin = GPIO_PIN_11;
  GPIO_InitStruct.Mode = GPIO_MODE_INPUT;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  HAL_GPIO_Init(GPIOB, &GPIO_InitStruct);

  /*Configure GPIO pin : PB7 */
  GPIO_InitStruct.Pin = GPIO_PIN_7;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  HAL_GPIO_Init(GPIOB, &GPIO_InitStruct);

  /*Configure GPIO pins : PB8 PB9 */
  GPIO_InitStruct.Pin = GPIO_PIN_8|GPIO_PIN_9;
  GPIO_InitStruct.Mode = GPIO_MODE_AF_OD;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_HIGH;
  HAL_GPIO_Init(GPIOB, &GPIO_InitStruct);

  /*Configure peripheral I/O remapping */
  __HAL_AFIO_REMAP_I2C1_ENABLE();

/* USER CODE BEGIN MX_GPIO_Init_2 */
/* USER CODE END MX_GPIO_Init_2 */
}

/* USER CODE BEGIN 4 */

/* USER CODE END 4 */

/**
  * @brief  This function is executed in case of error occurrence.
  * @retval None
  */
void Error_Handler(void)
{
  /* USER CODE BEGIN Error_Handler_Debug */
  /* User can add his own implementation to report the HAL error return state */
  __disable_irq();
  while (1)
  {
  }
  /* USER CODE END Error_Handler_Debug */
}

#ifdef  USE_FULL_ASSERT
/**
  * @brief  Reports the name of the source file and the source line number
  *         where the assert_param error has occurred.
  * @param  file: pointer to the source file name
  * @param  line: assert_param error line source number
  * @retval None
  */
void assert_failed(uint8_t *file, uint32_t line)
{
  /* USER CODE BEGIN 6 */
  /* User can add his own implementation to report the file name and line number,
     ex: printf("Wrong parameters value: file %s on line %d\r\n", file, line) */
  /* USER CODE END 6 */
}
#endif /* USE_FULL_ASSERT */

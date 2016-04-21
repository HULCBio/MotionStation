/* $Revision: 1.2 $ */

/*-------------------------------------------------------------\
|  These are external references to global register copies
|  of the command and configuration registers we will be 
|  manipulating.  Only a few bits of these registers are used 
|  for the eeprom and caldacs, so we want to make sure the
|  other bits in these registers are left at their current
|  state (before eeprom and caldac routines are called)
|  These should be declared in the main program that calls
|  the eeprom and caldac routines.
|  (Note: the mio_16x and mio_64f5 use same registers)
\--------------------------------------------------------------*/
/*
extern unsigned int   atmio_16x_comm1_val, atmio_16f5_comm1_val;
extern unsigned int   ao_6_10_cfg1_val, ao_6_10_cfg2_val;
*/
static unsigned int   atmio_16x_comm1_val, atmio_16f5_comm1_val;
static unsigned int   ao_6_10_cfg1_val, ao_6_10_cfg2_val;


/****************************************************************************/
/*                                                                          */
/* Function name:  caldac_wr                                                */
/*                                                                          */
/* Description:    write a value to the calibration DAC                     */
/*                                                                          */
/* Entry parameters:  board type, board address, dac, value                 */
/*                    (#defines for board type in eeprom.h)                 */
/*                                                                          */
/* Globals used:      atmio_16x_comm1_val, atmio_16f5_comm1_val             */
/*                    ao_6_10_cfg1_val, ao_6_10_cfg2_val;                   */
/*                                                                          */
/****************************************************************************/
static int caldac_wr
   (
   int board_type, 
   unsigned int base_addr, 
   int dac, 
   unsigned int value
   )
{
   int   index, bitmask, length;

   unsigned int CLK_mask, DO_mask, CALDACLD_mask;
   unsigned int CLK_reg, DO_reg, CALDACLD_reg;
   unsigned int *CLK_reg_ptr, *DO_reg_ptr, *CALDACLD_reg_ptr;
  

   /*-------------------------------------\
   | parm checking 
   \-------------------------------------*/

   if(OUT_OF_RANGE(board_type, 0, MAX_BRDTYPE_NUM)) 
      return(BRDTYPE_OUT_OF_RANGE);

   if(OUT_OF_RANGE(base_addr, MIN_BASE_ADDR, MAX_BASE_ADDR)) 
      return(BASE_ADDR_OUT_OF_RANGE);

   /*------------------------------------------\
   | set up board-specific caldac parameters
   \------------------------------------------*/

   switch(board_type) 
   {
      case AT_MIO_16X:
      case AT_MIO_64F_5:

         if ((board_type==AT_MIO_16X) && (dac<0 || dac>8))
            return(DAC_OUT_OF_RANGE);

         if ((board_type==AT_MIO_64F_5) && (dac<0 || dac>7))
            return(DAC_OUT_OF_RANGE);
         
         /* set up bitmask, reg addr, and reg soft copy for data clk.
            at-mio-16x and at-mio-64f-5 use the same values */
         CLK_mask    = 0x2000;
         CLK_reg     = ATMIO_16X_COMM1_REG;
         CLK_reg_ptr = &atmio_16x_comm1_val;

         /* set up bitmask, reg addr, and reg soft copy for data out line */
         DO_mask    = 0x4000;
         DO_reg     = ATMIO_16X_COMM1_REG;
         DO_reg_ptr = &atmio_16x_comm1_val;

         /* set up caldac load mechanism */
         CALDACLD_mask    = 0x0;
         if(dac<8)
            CALDACLD_reg = ATMIO_16X_DAC0LD_REG;
         else
            CALDACLD_reg = ATMIO_16X_DAC1LD_REG;

         break;

      case AT_MIO_16F_5:

         if (dac<0 || dac>7) return(DAC_OUT_OF_RANGE);

         /* set up bitmask, reg addr, and reg soft copy for data clk */
         CLK_mask    = 0x2000;
         CLK_reg     = ATMIO_16F5_COMM1_REG;
         CLK_reg_ptr = &atmio_16f5_comm1_val;

         /* set up bitmask, reg addr, and reg soft copy for data out line */
         DO_mask     = 0x4000;
         DO_reg      = ATMIO_16F5_COMM1_REG;
         DO_reg_ptr  = &atmio_16f5_comm1_val;

         /* set up caldac load mechanism */
         CALDACLD_mask    = 0x1000;
         CALDACLD_reg     = ATMIO_16F5_COMM1_REG;
         CALDACLD_reg_ptr = &atmio_16f5_comm1_val;

         break;

      case AT_AO_6_10:

         if (dac<0 || dac>23) return(DAC_OUT_OF_RANGE);

         /* set up bitmask, reg addr, and reg soft copy for data clk */
         CLK_mask    = 0x2;
         CLK_reg     = AO_6_10_CFG2_REG;
         CLK_reg_ptr = &ao_6_10_cfg2_val;

         /* set up bitmask, reg addr, and reg soft copy for data out line */
         DO_mask     = 0x1;
         DO_reg      = AO_6_10_CFG2_REG;
         DO_reg_ptr  = &ao_6_10_cfg2_val;

         /* set up caldac load mechanism */
         CALDACLD_mask    = ((dac & 0x0018) + 0x8)<<11;
         CALDACLD_reg     = AO_6_10_CFG2_REG;
         CALDACLD_reg_ptr = &ao_6_10_cfg2_val;

         /* clear Cal DAC Load pulsing */
         *CALDACLD_reg_ptr &= 0x3fff;
		 rl32eOutpW((unsigned short)CALDACLD_reg,(unsigned short)*CALDACLD_reg_ptr);

         dac &= 0x7;    /* get DAC value in 0-7 range */ 

         break;

   }  /* end switch */

   length = 12;

   /*-------------------------------------\
   |  caldacs 0-7 have length of 11;
   |  encode the caldac# in the value
   |  to be written
   \-------------------------------------*/
   if (dac < 8)
   {
      length = 11;
      value &= 0x00FF;
      value |= dac<<8;
   }  /* endif */

   /*-------------------------------------\
   | write out caldac value
   \-------------------------------------*/

   bitmask = (1 << (length-1));
   for (index=0; index<length; index++)
   {
      if(value & bitmask)
         *DO_reg_ptr |= DO_mask;       /* set data */
      else
         *DO_reg_ptr &= ~DO_mask;      /* clr data */

	  rl32eOutpW((unsigned short)DO_reg,(unsigned short)*DO_reg_ptr);

      *CLK_reg_ptr |= CLK_mask;
	  rl32eOutpW((unsigned short)CLK_reg,(unsigned short)*CLK_reg_ptr);

      *CLK_reg_ptr &= ~CLK_mask;
	  rl32eOutpW((unsigned short)CLK_reg,(unsigned short)*CLK_reg_ptr);

      bitmask >>= 1;
   }  /* endfor */


   /*----------------------------------------------\
   | Send appropriate load signal to update caldac 
   \----------------------------------------------*/

   switch(board_type)
   {
      case AT_MIO_16X:
      case AT_MIO_64F_5:
         //outp(CALDACLD_reg, DO_mask);
         break;

      case AT_MIO_16F_5:
      case AT_AO_6_10:
		 rl32eOutpW((unsigned short)CALDACLD_reg,(unsigned short)(*CALDACLD_reg_ptr | CALDACLD_mask));
         break;

   }  /* end switch */

   return(NO_ERROR);

}  /* end caldac_wr */


/****************************************************************************/
/*                                                                          */
/* Function name:    eeprom_read                                            */
/*                                                                          */
/* Description:      Read a value from the board EEPROM                     */
/*                                                                          */
/* Entry parameters: board type, board address, address, pointer to value   */
/*                                                                          */
/* Globals used:     atmio_16x_comm1_val, atmio_16f5_comm1_val,             */
/*                   a0_6_10_cfg1_val, ao6_10_cfg2_val                      */
/*                                                                          */
/****************************************************************************/
static int eeprom_read
   (
   int board_type, 
   unsigned int base_addr, 
   int eeprom_addr, 
   unsigned int* value
   )
{
   int CMD_CNT, READ_CNT;
   int iterations, data, index;
   unsigned int bitmask;

   unsigned int EWEN_CMD_mask, READ_CMD_mask;
   unsigned int EN_mask, DO_mask, CLK_mask, DI_mask;
   unsigned int EN_reg, DO_reg, CLK_reg, DI_reg;
   unsigned int *EN_reg_ptr, *DO_reg_ptr, *CLK_reg_ptr, *STAT_reg_val, *DI_reg_val;
   unsigned int *CFG1_reg_ptr;  /* used when board is at_ao_6_10 only */ 


   /*-------------------------------------\
   | parm checking 
   \-------------------------------------*/

   if(OUT_OF_RANGE(board_type, 0, MAX_BRDTYPE_NUM)) 
      return(BRDTYPE_OUT_OF_RANGE);

   if(OUT_OF_RANGE(base_addr, MIN_BASE_ADDR, MAX_BASE_ADDR)) 
      return(BASE_ADDR_OUT_OF_RANGE);

   switch(board_type)  
   {
      case AT_MIO_16X:   /* 128X8 Mode */
      case AT_MIO_64F_5:

         if(OUT_OF_RANGE(eeprom_addr, 0, MAX_128X8_ADDR))
            return(EEPROM_ADDR_OUT_OF_RANGE);
         break;

      case AT_MIO_16F_5:  /* 64X16 Mode */

         if(OUT_OF_RANGE(eeprom_addr, 0, MAX_64X16_ADDR)) 
            return(EEPROM_ADDR_OUT_OF_RANGE);
         break;

      case AT_AO_6_10:  /* 128X16 Mode */
         
         if(OUT_OF_RANGE(eeprom_addr, 0, MAX_128X16_ADDR))
            return(EEPROM_ADDR_OUT_OF_RANGE);
         break;

   }  /* end switch */
   

   /*----------------------------------------\
   | set up board-specific eeprom parameters 
   \----------------------------------------*/
   
   switch(board_type)
   {
      case AT_MIO_16X: 
      case AT_MIO_64F_5: 

         CMD_CNT  = CMD_128X8_CNT;
         READ_CNT = READ_128X8_CNT;

         EWEN_CMD_mask = EEPROM_128X8_EWEN;
         READ_CMD_mask = EEPROM_128X8_READ;

         EN_mask     = 0x8000;
         EN_reg      = ATMIO_16X_COMM1_REG;  
         EN_reg_ptr  = &atmio_16x_comm1_val;

         DO_mask     = 0x4000;
         DO_reg      = ATMIO_16X_COMM1_REG;  
         DO_reg_ptr  = &atmio_16x_comm1_val;

         CLK_mask    = 0x2000;
         CLK_reg     = ATMIO_16X_COMM1_REG;  
         CLK_reg_ptr = &atmio_16x_comm1_val;

         DI_mask     = 0x4;
         DI_reg      = ATMIO_16X_STAT0_REG;

         break;

      case AT_MIO_16F_5:

         CMD_CNT  = CMD_64X16_CNT;
         READ_CNT = READ_64X16_CNT;

         EWEN_CMD_mask = EEPROM_64X16_EWEN;
         READ_CMD_mask = EEPROM_64X16_READ;

         EN_mask     = 0x8000;
         EN_reg      = ATMIO_16F5_COMM1_REG;
         EN_reg_ptr  = &atmio_16f5_comm1_val;
                               
         DO_mask     = 0x4000;
         DO_reg      = ATMIO_16F5_COMM1_REG;
         DO_reg_ptr  = &atmio_16f5_comm1_val;

         CLK_mask    = 0x2000;
         CLK_reg     = ATMIO_16F5_COMM1_REG;
         CLK_reg_ptr = &atmio_16f5_comm1_val; 

         DI_mask     = 0x8;
         DI_reg      = ATMIO_16F5_STAT_REG;

         break;

      case AT_AO_6_10:

         CMD_CNT  = CMD_128X16_CNT;
         READ_CNT = READ_128X16_CNT;

         EWEN_CMD_mask = EEPROM_128X16_EWEN;
         READ_CMD_mask = EEPROM_128X16_READ;

         EN_mask     = 0x4;
         EN_reg      = AO_6_10_CFG2_REG;
         EN_reg_ptr  = &ao_6_10_cfg2_val;

         DO_mask     = 0x1;
         DO_reg      = AO_6_10_CFG2_REG;
         DO_reg_ptr  = &ao_6_10_cfg2_val;

         CLK_mask    = 0x2;
         CLK_reg     = AO_6_10_CFG2_REG;
         CLK_reg_ptr = &ao_6_10_cfg2_val;

         DI_mask     = 0x1;
         DI_reg      = AO_6_10_STAT_REG;

         /* Clear the GRP2WT bit (bit #7) in the Conf. Reg. 1 */
         /* to be able to access the Conf. Reg. 2             */

         CFG1_reg_ptr = &ao_6_10_cfg1_val;
		 rl32eOutpW((unsigned short)AO_6_10_CFG1_REG,(unsigned short)(*CFG1_reg_ptr & 0xFF7F));

         break;

   }/* end switch */

   /*-------------------------------------\
   |  PROGRAM ENABLE
   \-------------------------------------*/

   iterations = CMD_CNT;
   bitmask = (1 << (CMD_CNT-1));

   /* clear_eeprom */

   *EN_reg_ptr  &= ~EN_mask;   
   rl32eOutpW((unsigned short)EN_reg,(unsigned short)*EN_reg_ptr);
   /* disable eeprom */

   *DO_reg_ptr  &= ~DO_mask;
   rl32eOutpW((unsigned short)DO_reg,(unsigned short)*DO_reg_ptr);
   /* clr data */

   *CLK_reg_ptr &= ~CLK_mask;
   rl32eOutpW((unsigned short)CLK_reg,(unsigned short)*CLK_reg_ptr);
   /* clr clk */

   *CLK_reg_ptr |= CLK_mask;
   rl32eOutpW((unsigned short)CLK_reg,(unsigned short)*CLK_reg_ptr);
   /* set clk */

   *EN_reg_ptr  |= EN_mask;
   rl32eOutpW((unsigned short)EN_reg,(unsigned short)*EN_reg_ptr);      
   /* enable eeprom */

   *CLK_reg_ptr &= ~CLK_mask;
   rl32eOutpW((unsigned short)CLK_reg,(unsigned short)*CLK_reg_ptr);  
   /* clr clk */

   /* strobe_eeprom */

   *CLK_reg_ptr |= CLK_mask;
   rl32eOutpW((unsigned short)CLK_reg,(unsigned short)*CLK_reg_ptr);
   /* set clk */

   *CLK_reg_ptr &= ~CLK_mask;
   rl32eOutpW((unsigned short)CLK_reg,(unsigned short)*CLK_reg_ptr);
   /* clr clk */

   for (index=0; index<iterations; index++)
   {
      if(EWEN_CMD_mask & bitmask)
         *DO_reg_ptr |= DO_mask;    /* set data  */
      else
         *DO_reg_ptr &= ~DO_mask;   /* clr data  */
	  rl32eOutpW((unsigned short)DO_reg,(unsigned short)*DO_reg_ptr);

      /* strobe eeprom */

      *CLK_reg_ptr |= CLK_mask;
	  rl32eOutpW((unsigned short)CLK_reg,(unsigned short)*CLK_reg_ptr);
      /* set clk */

      *CLK_reg_ptr &= ~CLK_mask; 
	  rl32eOutpW((unsigned short)CLK_reg,(unsigned short)*CLK_reg_ptr);
      /* clr clk */

      bitmask >>= 1;

   }  /* end for */

   *EN_reg_ptr &= ~EN_mask;
   rl32eOutpW((unsigned short)EN_reg,(unsigned short)*EN_reg_ptr);
   /* disable eeprom */


   /*-------------------------------------\
   | SEND READ MODE AND ADDRESS
   \-------------------------------------*/
    
   data = READ_CMD_mask | eeprom_addr;

   iterations = CMD_CNT;
   bitmask = (1 << (CMD_CNT-1));

   /* clear_eeprom */

   *DO_reg_ptr  &= ~DO_mask;  
   rl32eOutpW((unsigned short)DO_reg,(unsigned short)*DO_reg_ptr);
   /* clr data  */
   
   *CLK_reg_ptr |= CLK_mask;
   rl32eOutpW((unsigned short)CLK_reg,(unsigned short)*CLK_reg_ptr);
   /* set clk */

   *EN_reg_ptr  |= EN_mask;
   rl32eOutpW((unsigned short)EN_reg,(unsigned short)*EN_reg_ptr);
   /* enable eeprom */

   /* strobe_eeprom */

   *CLK_reg_ptr &= ~CLK_mask;
   rl32eOutpW((unsigned short)CLK_reg,(unsigned short)*CLK_reg_ptr);
   /* clr clk */

   *CLK_reg_ptr |= CLK_mask;
   rl32eOutpW((unsigned short)CLK_reg,(unsigned short)*CLK_reg_ptr);  
   /* set clk */

   *CLK_reg_ptr &= ~CLK_mask; 
   rl32eOutpW((unsigned short)CLK_reg,(unsigned short)*CLK_reg_ptr);
   /* clr clk */


   for (index=0; index<iterations; index++)
   {
      if(data & bitmask)
         *DO_reg_ptr |= DO_mask;    /* set data  */
      else
         *DO_reg_ptr &= ~DO_mask;   /* clr data  */
	  rl32eOutpW((unsigned short)DO_reg,(unsigned short)*DO_reg_ptr);

      /* strobe eeprom */

      *CLK_reg_ptr |= CLK_mask;
	  rl32eOutpW((unsigned short)CLK_reg,(unsigned short)*CLK_reg_ptr);
      /* set clk */

      *CLK_reg_ptr &= ~CLK_mask;
	  rl32eOutpW((unsigned short)CLK_reg,(unsigned short)*CLK_reg_ptr);
      /* clr clk */

      bitmask >>= 1;

   }  /* end for */


   /*-------------------------------------\
   |  READ IN VALUE 
   \-------------------------------------*/
   
   *value = 0;

   *DO_reg_ptr &= ~DO_mask;
   rl32eOutpW((unsigned short)DO_reg,(unsigned short)*DO_reg_ptr); 
   /* clr data */

   for (index=0; index<READ_CNT; index++)
   {
      /* strobe eeprom */

      *CLK_reg_ptr |= CLK_mask; 
      rl32eOutpW((unsigned short)CLK_reg,(unsigned short)*CLK_reg_ptr); 
      /* set clk */

      *CLK_reg_ptr &= ~CLK_mask; 
	  rl32eOutpW((unsigned short)CLK_reg,(unsigned short)*CLK_reg_ptr);
      /* clr clk */
      *value |= (((rl32eInpW((unsigned short)DI_reg) & DI_mask) ? 1:0) << ((READ_CNT-1)-index));
   
   }  /* end for */

   *EN_reg_ptr &= ~EN_mask;
   rl32eOutpW((unsigned short)EN_reg,(unsigned short)*EN_reg_ptr);  
   /* disable eeprom */

   /* Restore original contents to Conf Reg 1 for AT-AO board */
   if (board_type==AT_AO_6_10)
   	  rl32eOutpW((unsigned short)AO_6_10_CFG1_REG,(unsigned short)*CFG1_reg_ptr);

   return(NO_ERROR);

}  /* end eeprom_read */

#define NOEWRITE 1

#ifndef NOEWRITE



/****************************************************************************/
/*                                                                          */
/* Function name:     eeprom_write                                          */
/*                                                                          */
/* Description:       Write a value to the board EEPROM                     */
/*                                                                          */
/* Entry parameters:  board address, base address, eeprom address, value    */
/*                                                                          */
/* Globals used:      atmio_16x_comm1_val, atmio_16f5_comm1_val,            */
/*                    ao6_10_cfg2_val                                       */
/*                                                                          */
/****************************************************************************/
int eeprom_write
   (
   int board_type, 
   unsigned int base_addr,
   int eeprom_addr, 
   unsigned int value
   )
{
   int data,iterations, index;
   int CMD_CNT, WRITE_CNT;
   unsigned int bitmask;

   unsigned int EWEN_CMD_mask, WRITE_CMD_mask;
   unsigned int EN_mask, DO_mask, CLK_mask, STAT_mask, DI_mask;
   unsigned int EN_reg, DO_reg, CLK_reg, STAT_reg, DI_reg;
   unsigned int* EN_reg_ptr, *DO_reg_ptr, *CLK_reg_ptr, *STAT_reg_val, *DI_reg_val;
   unsigned int *CFG1_reg_ptr;  /* used when board is at_ao_6_10 only */ 

   int delay=20000;

   /*-------------------------------------\
   | parm checking 
   \-------------------------------------*/

   if(OUT_OF_RANGE(board_type, 0, MAX_BRDTYPE_NUM)) 
      return(BRDTYPE_OUT_OF_RANGE);

   if(OUT_OF_RANGE(base_addr, MIN_BASE_ADDR, MAX_BASE_ADDR)) 
      return(BASE_ADDR_OUT_OF_RANGE);
   
   /*----------------------------------------------\
   |  check for valid eeprom address; also check
   |  that address is not restricted eeprom write
   |  area; HW will ignore writes to restricted
   |  area, but we want to notify calling routine
   |  with an error
   \----------------------------------------------*/
   switch (board_type)
   {
      case AT_MIO_16X:   /* 128X8 Mode */
      case AT_MIO_64F_5:

         if(OUT_OF_RANGE(eeprom_addr, 0, MAX_128X8_ADDR))
            return(EEPROM_ADDR_OUT_OF_RANGE);

         else if(OUT_OF_RANGE(eeprom_addr, 0, MAX_128X8_WRITE_ADDR)) 
            return(VALUE_OUT_OF_RANGE);

         break;

      case AT_MIO_16F_5:  /* 64X16 Mode */

         if(OUT_OF_RANGE(eeprom_addr, 0, MAX_64X16_ADDR)) 
            return(EEPROM_ADDR_OUT_OF_RANGE);
         
         else if(OUT_OF_RANGE(eeprom_addr, 0, MAX_64X16_WRITE_ADDR)) 
            return(VALUE_OUT_OF_RANGE);
         
         break;

      case AT_AO_6_10:  /* 128X16 Mode */
         
         if(OUT_OF_RANGE(eeprom_addr, 0, MAX_128X16_ADDR))
            return(EEPROM_ADDR_OUT_OF_RANGE);
         
         else if(OUT_OF_RANGE(eeprom_addr, 0, MAX_128X16_WRITE_ADDR)) 
            return(VALUE_OUT_OF_RANGE);
      
         break;

   }  /* end switch */
   

   /*----------------------------------------\
   | set up board-specific eeprom parameters 
   \----------------------------------------*/

   switch (board_type)
   {
      case AT_MIO_16X:
      case AT_MIO_64F_5:
   
         CMD_CNT   = CMD_128X8_CNT;
         WRITE_CNT = WRITE_128X8_CNT;

         EWEN_CMD_mask  = EEPROM_128X8_EWEN;
         WRITE_CMD_mask = EEPROM_128X8_WRITE;

         EN_mask     = 0x8000;
         EN_reg      = ATMIO_16X_COMM1_REG;
         EN_reg_ptr  = &atmio_16x_comm1_val;

         DO_mask     = 0x4000;
         DO_reg      = ATMIO_16X_COMM1_REG; 
         DO_reg_ptr  = &atmio_16x_comm1_val;

         CLK_mask    = 0x2000;
         CLK_reg     = ATMIO_16X_COMM1_REG; 
         CLK_reg_ptr = &atmio_16x_comm1_val;

         STAT_mask   = 0x2;
         STAT_reg    = ATMIO_16X_STAT0_REG;

         DI_mask     = 0x4;
         DI_reg      = ATMIO_16X_STAT0_REG;

         break;

      case AT_MIO_16F_5:
   
         CMD_CNT   = CMD_64X16_CNT;
         WRITE_CNT = WRITE_64X16_CNT;

         EWEN_CMD_mask  = EEPROM_64X16_EWEN;
         WRITE_CMD_mask = EEPROM_64X16_WRITE;

         EN_mask     = 0x8000;
         EN_reg      = ATMIO_16F5_COMM1_REG;
         EN_reg_ptr  = &atmio_16f5_comm1_val;

         DO_mask     = 0x4000;
         DO_reg      = ATMIO_16F5_COMM1_REG;
         DO_reg_ptr  = &atmio_16f5_comm1_val;

         CLK_mask    = 0x2000;
         CLK_reg     = ATMIO_16F5_COMM1_REG;
         CLK_reg_ptr = &atmio_16f5_comm1_val; 

         STAT_mask   = 0x4;
         STAT_reg    = ATMIO_16F5_STAT_REG;

         DI_mask     = 0x8;
         DI_reg      = ATMIO_16F5_STAT_REG;

         break;

      case AT_AO_6_10:

         CMD_CNT   = CMD_128X16_CNT;
         WRITE_CNT = WRITE_128X16_CNT;

         EWEN_CMD_mask  = EEPROM_128X16_EWEN;
         WRITE_CMD_mask = EEPROM_128X16_WRITE;

         EN_mask     = 0x4;
         EN_reg      = AO_6_10_CFG2_REG;
         EN_reg_ptr  = &ao_6_10_cfg2_val;

         DO_mask     = 0x1;
         DO_reg      = AO_6_10_CFG2_REG;
         DO_reg_ptr  = &ao_6_10_cfg2_val;

         CLK_mask    = 0x2;
         CLK_reg     = AO_6_10_CFG2_REG;
         CLK_reg_ptr = &ao_6_10_cfg2_val;

         DI_mask     = 0x1;
         DI_reg      = AO_6_10_STAT_REG;
   
         /* Clear the GRP2WT bit (bit #7) in the Conf. Reg. 1 */
         /* to be able to access the Conf. Reg. 2             */

         CFG1_reg_ptr = &ao_6_10_cfg1_val;
         
         outpw(AO_6_10_CFG1_REG, *CFG1_reg_ptr & 0xFF7F);

         break;


   }  /* end switch */


   /*-------------------------------------\
   |  PROGRAM ENABLE
   \-------------------------------------*/
   
   iterations = CMD_CNT;
   bitmask = (1 << (CMD_CNT-1));

   /* clear_eeprom */

   *EN_reg_ptr  &= ~EN_mask;
   outpw(EN_reg, *EN_reg_ptr);   /* disable eeprom */

   *DO_reg_ptr  &= ~DO_mask;
   outpw(DO_reg, *DO_reg_ptr);   /* clr data */
   
   *CLK_reg_ptr &= ~CLK_mask;
   outpw(CLK_reg, *CLK_reg_ptr); /* clr clk */

   *CLK_reg_ptr |= CLK_mask;
   outpw(CLK_reg, *CLK_reg_ptr); /* set clk */

   *EN_reg_ptr  |= EN_mask;
   outpw(EN_reg, *EN_reg_ptr);   /* enable eeprom */

   *CLK_reg_ptr &= ~CLK_mask;
   outpw(CLK_reg, *CLK_reg_ptr); /* clr clk */

   /* strobe_eeprom */

   *CLK_reg_ptr |= CLK_mask;
   outpw(CLK_reg, *CLK_reg_ptr); /* set clk */

   *CLK_reg_ptr &= ~CLK_mask;
   outpw(CLK_reg, *CLK_reg_ptr); /* clr clk */

   for (index=0; index<iterations; index++)
   {
      if(EWEN_CMD_mask & bitmask)
         *DO_reg_ptr |= DO_mask;    /* set data */
      else                       
         *DO_reg_ptr &= ~DO_mask;   /* clr data */

      outpw(DO_reg, *DO_reg_ptr);

      /* strobe eeprom */

      *CLK_reg_ptr |= CLK_mask;
      outpw(CLK_reg, *CLK_reg_ptr); /* set clk */

      *CLK_reg_ptr &= ~CLK_mask; 
      outpw(CLK_reg, *CLK_reg_ptr); /* clr clk */

      bitmask >>= 1;

  }   /* endfor */

  *EN_reg_ptr &= ~EN_mask; outpw(EN_reg, *EN_reg_ptr);  /* disable eeprom */


   /*-------------------------------------\
   | SEND WRITE MODE AND ADDRESS
   \-------------------------------------*/
   
   data = WRITE_CMD_mask | eeprom_addr;
   
   iterations = CMD_CNT;
   bitmask = (1 << (CMD_CNT-1));

   /* clear_eeprom */

   *DO_reg_ptr  &= ~DO_mask; 
   outpw(DO_reg, *DO_reg_ptr);   /* clr data  */
   
   *CLK_reg_ptr &= ~CLK_mask; 
   outpw(CLK_reg, *CLK_reg_ptr); /* clr clk */

   *CLK_reg_ptr |= CLK_mask;  
   outpw(CLK_reg, *CLK_reg_ptr); /* set clk */

   *EN_reg_ptr  |= EN_mask;   
   outpw(EN_reg, *EN_reg_ptr);   /* enable eeprom */

   *CLK_reg_ptr &= ~CLK_mask; 
   outpw(CLK_reg, *CLK_reg_ptr); /* clr clk */

   /* strobe_eeprom */

   *CLK_reg_ptr |= CLK_mask;  
   outpw(CLK_reg, *CLK_reg_ptr); /* set clk */

   *CLK_reg_ptr &= ~CLK_mask; 
   outpw(CLK_reg, *CLK_reg_ptr); /* clr clk */


   for (index=0; index<iterations; index++)
   {
      if(data & bitmask)
         *DO_reg_ptr |= DO_mask;    /* set data  */
      else 
         *DO_reg_ptr &= ~DO_mask;   /* clr data  */

      outpw(DO_reg, *DO_reg_ptr);

      /* strobe eeprom */

      *CLK_reg_ptr |= CLK_mask;  
      outpw(CLK_reg, *CLK_reg_ptr); /* set clk */

      *CLK_reg_ptr &= ~CLK_mask; 
      outpw(CLK_reg, *CLK_reg_ptr); /* clr clk */

      bitmask >>= 1;

   }  /* endfor */

   
   /*-------------------------------------\
   |  CHECK IF COMMAND MODE WAS VALID                      
   \-------------------------------------*/

   if(board_type!=AT_AO_6_10)  /* AT_AO_6_10 does not allow this check */
   {
      if (!((inpw((unsigned) STAT_reg) & STAT_mask)? 1:0))
      {      
         *EN_reg_ptr &= ~EN_mask;  
         outpw(EN_reg, *EN_reg_ptr);  /* disable eeprom */

         return(EEPROM_MODE_ERROR);
      }
   }
   
   /*-------------------------------------\
   | WRITE DATA 
   \-------------------------------------*/

   iterations = WRITE_CNT;
   bitmask = ( 1 << (WRITE_CNT-1));

   for (index=0; index<iterations; index++)
   {
      if(value & bitmask)
         *DO_reg_ptr |= DO_mask;       /* set data */
      else
         *DO_reg_ptr &= ~DO_mask;      /* clr data */

      outpw(DO_reg, *DO_reg_ptr);

      /* strobe eeprom */

      *CLK_reg_ptr |= CLK_mask; 
      outpw(CLK_reg, *CLK_reg_ptr);    /* set clk */

      *CLK_reg_ptr &= ~CLK_mask; 
      outpw(CLK_reg, *CLK_reg_ptr);    /* clr clk */

      bitmask >>= 1;

   }  /* endfor */

   *EN_reg_ptr &= ~EN_mask;  
   outpw(EN_reg, *EN_reg_ptr);   /* disable eeprom */

   
   /*-------------------------------------\
   | WAIT FOR EEPROM TO FINISH
   \-------------------------------------*/

   *EN_reg_ptr |= EN_mask;   
   outpw(EN_reg, *EN_reg_ptr);   /* enable eeprom */
   
   while (delay-- && !((inpw((unsigned) DI_reg) & DI_mask) ? 1:0))
   {
      *DO_reg_ptr  &= ~DO_mask; 
      outpw(DO_reg, *DO_reg_ptr);   /* clr data */

      *CLK_reg_ptr |= CLK_mask;
      outpw(CLK_reg, *CLK_reg_ptr); /* set clk */
      
      *CLK_reg_ptr &= ~CLK_mask;
      outpw(CLK_reg, *CLK_reg_ptr); /* clr clk */

   }  /* end while */
   
   *EN_reg_ptr &= ~EN_mask;         
   outpw(EN_reg, *EN_reg_ptr);      /* disable eeprom */

   if(board_type==AT_AO_6_10)
      /* Restore original contents to Conf Reg 1 */
      outpw(AO_6_10_CFG1_REG, *CFG1_reg_ptr);

   if (delay>0)
      return(NO_ERROR);
   else
      return(EEPROM_WAIT_ERROR);

}

#endif

/* end eeprom_write */
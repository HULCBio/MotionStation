/* $Revision: 1.1 $ */
//===========================================================================
//
// NAME:    pdl_brd.c: 
//
// DESCRIPTION:
//
//          PowerDAQ QNX driver interface to board-level FW functions
//
// AUTHOR:  Alex Ivchenko
//
// DATE:    12-APR-2000
//
// REV:     0.8
//
// R DATE:  
//
// HISTORY:
//
//      Rev 0.8,     12-MAR-2000,     Initial version.
//
//
//---------------------------------------------------------------------------
//      Copyright (C) 2000 United Electronic Industries, Inc.
//      All rights reserved.
//---------------------------------------------------------------------------//
//
// this file is not to be compiled independently
// but to be included into pdfw_lib.c



////////////////////////////////////////////////////////////////////////
//   
// BOARD CONTROL SECTION
//
////////////////////////////////////////////////////////////////////////

//  
//       NAME:  pd_adapter_enable_interrupt()
//
//   FUNCTION:  Enable or Disable board interrupt generation.
//              During interrupt generation, the PCI INTA line is
//              is asserted to request servicing of board events.
//
//  ARGUMENTS:  u32 val -- 0: disable, 1: enable Irq.
//
//    RETURNS:  1 if it worked, 0 if it failed.
//
int pd_adapter_enable_interrupt(int board, u32 val)
{
   return pd_dsp_cmd_write_ack(board, PD_BRDINTEN, val);
}

//  
//       NAME:  pd_adapter_acknowledge_interrupt()
//
//   FUNCTION:  The acknowledge interrupt command clears and disables the
//              Host PC interrupt.
//              Servicing an interrupt does not re-enable the interrupt.
//              After all events have been processed, the interrupt should
//              be re-enabled by calling the PDFWEnableIrq() function.
//
//  ARGUMENTS:  
//
//    RETURNS:  1 if it worked, 0 if it failed.
//
int pd_adapter_acknowledge_interrupt(int board)
{
   u32 dwStatus;


   pd_dsp_cmd_no_ret(board, PD_BRDINTACK);
   
   dwStatus = pd_dsp_get_status(board);
   if ( !(dwStatus & (ULONG)(1<<HSTR_HINT)) )
       return TRUE;
       
   return FALSE;
}


//        NAME: pd_adapter_get_board_status()
//
//    FUNCTION: The get board status command returns the status and
//              events of all subsystems, but does not disable or clear
//              any asserted board event bits.
//
//   ARGUMENTS: u32* pdwStatusBuf -- ptr to buffer to store event words
//
//              All error conditions are included in the board events.
//
//       NOTES: PARAM #0    <-- pending board Events (status)
//              PARAM #1    <-- combined registers PD_UDEIntr and PD_AUEStat
//              PARAM #2    <-- combined registers PD_AIOIntr1 and PD_AIOIntr2
//              PARAM #3    <-- AInIntrStat
//              PARAM #4    <-- AOutIntrStat
//
//              * This routine is optimized for fastest execution possible.
//
//    RETURNS:  1 if it worked, 0 if it failed.
//
int pd_adapter_get_board_status(int board, PTEvents pEvent)
{
   u32 dwReply, res;

   dwReply = pd_dsp_cmd_ret_value(board, PD_BRDSTATUS);         
   if (dwReply != 5) 
      return 0;

   //printf_P("pd_adapter_get_board_status\n");

   // read data block
   res = pd_dsp_read(board); ////printf("str: Board 0x%x\n", res);
   pEvent->Board = res;

   res = pd_dsp_read(board); ////printf("str: ADUIntr 0x%x\n", res);
   pEvent->ADUIntr = res;

   res = pd_dsp_read(board); ////printf("str: AIOIntr 0x%x\n", res);
   pEvent->AIOIntr = res;

   res = pd_dsp_read(board); ////printf("str: AInIntr 0x%x\n", res);
   pEvent->AInIntr = res;

   res = pd_dsp_read(board); ////printf("str: AOutIntr 0x%x\n", res);
   pEvent->AOutIntr = res;

   return 1;
}

//      NAME:   pd_adapter_set_board_event1()
//
// ARGUMENTS:  u32 dwEvents  -- value of ADUEIntrStat Event configuration word
//
//
//  FUNCTION:   The set board events 1 command sets selected UDEIntr register
//              event bits enabling/disabling and/or clearing individual
//              board level interrupt events, thereby re-enabling the event
//              interrupts.
//
//              Interrupt Mask (Im) bits:   0 = disable, 1 = enable interrupt
//              Status/Clear (SC) bits:     0 = clear interrupt, 1 = unchanged
//
//              In use: 1. Keep a copy of latest dwEvents word written.
//                      2. int OR the dwEvents word to set all status
//                         (SC) bits to 1.
//                      3. To disable interrupts, change corresponding
//                         interrupt mask bits (Im) to 0, to enable, change
//                         mask bits to 1.
//                      4. To clear interrupt status bits (SC), re-enabling
//                         the interrupts, set the corresponding bits to 0.
//                      5. Save a copy of the new dwEvents word and issue
//                         command to set events.
//
//              * The set board events 1 command does not clear, enable,
//                or disable the PC Host interrupt.
//
//    RETURNS:  1 if it worked, 0 if it failed.
//
int pd_adapter_set_board_event1(int board, u32 dwEvents)
{
   return pd_dsp_cmd_write_ack(board, PD_BRDSETEVNTS1, dwEvents);

}


//      NAME:   pd_adapter_set_board_event2()
//
// ARGUMENTS:  u32 dwEvents  -- value of AIOIntr Event configuration word
//
//  FUNCTION:   The set board events 2 command sets selected AIOIntr1 and
//              AIOIntr2 register event bits enabling/disabling and/or
//              clearing individual board level interrupt events, thereby
//              re-enabling the event interrupts.
//
//              Interrupt Mask (Im) bits:   0 = disable, 1 = enable interrupt
//              Status/Clear (SC) bits:     0 = clear interrupt, 1 = unchanged
//
//              In use: 1. Keep a copy of latest dwEvents word written.
//                      2. int OR the dwEvents word to set all status
//                         (SC) bits to 1.
//                      3. To disable interrupts, change corresponding
//                         interrupt mask bits (Im) to 0, to enable, change
//                         mask bits to 1.
//                      4. To clear interrupt status bits (SC), re-enabling
//                         the interrupts, set the corresponding bits to 0.
//                      5. Save a copy of the new dwEvents word and issue
//                         command to set events.
//              * Registers PD_AIOIntr1 and PD_AIOIntr2 are combined.
//              * The set board events 2 command does not clear, enable,
//                or disable the PC Host interrupt.
//
//    RETURNS:  1 if it worked, 0 if it failed.
//
int pd_adapter_set_board_event2(int board, u32 dwEvents)
{
   return pd_dsp_cmd_write_ack(board, PD_BRDSETEVNTS2, dwEvents);
}

//       NAME:  pd_adapter_eeprom_read()
//
//  ARGUMENTS:  u32     dwMaxSize   -- max buffer size in words
//              uint16_t *pwReadBuf  -- ptr to buffer to save ID data
//
// Description: Read board ID data block from onboard SPI EEPROM.
//
//              The data block returned contains all board identification,
//              configuration, calibration settings, PN, REV, SN, Firmware
//              Version, Calibration Date, and First Use Date in a 256
//              16-bit word block.
//              This command replaces Get Board ID.
//              User level functions parse block into individual data
//              values.
//
//    RETURNS:  The number of 16-bit words saved in the buffer if all
//              worked, and -1 if it failed.
//
int pd_adapter_eeprom_read(int board, u32 dwMaxSize, uint16_t *pwReadBuf)
{
    u32 i;
    u32 dwEepromSize;

    //printf("pd_dsp_cmd_ret_value \n");
 

    // Issue PD_BRDEPRMRD command and read 1 word
    dwEepromSize = pd_dsp_cmd_ret_value(board, PD_BRDEPRMRD);
    if ( dwEepromSize == 0 )
        return -1;

    //printf("pd_dsp_cmd_ret_value OK \n");
 
    // Read data in block.
    //FIXME - should we use special functions for copying data???
    for ( i = 0; i < dwEepromSize; i++ )
    {
        if ( i < dwMaxSize )
            *(pwReadBuf + i) = (USHORT)pd_dsp_read(board);
        else
            pd_dsp_read(board);    // read and discard overflow
    }

    //printf("pd_dsp_read_ack \n");
 

    if (!pd_dsp_read_ack(board)) 
      return -1;

    //printf("pd_dsp_read_ack OK \n");
 

    return i;
}

//
// Function:    int pd_adapter_eeprom_write()
//
// Parameters:  ULONG   dwBufSize   -- write buffer size in words
//              USHORT  *pwWriteBuf -- buffer containing data to write
//
// Returns:     int status  -- TRUE:  command succeeded
//                                 FALSE: command failed
//
// Description: Write block to SPI EEPROM.
//              The EEPROM write command writes a data block containing
//              board ID and configuration information to the onboard
//              EEPROM.
//
int pd_adapter_eeprom_write(int board, u32 dwBufSize, u16* pwWriteBuf)
{
    u32 i, dwReply, dwWords;

    // Issue PD_BRDEPRMWR command and read EEPROM Buffer Size.
    dwReply = pd_dsp_cmd_ret_value(board, PD_BRDEPRMWR);
    if ( dwReply == 0 )
        return FALSE;

    dwWords = (dwReply < dwBufSize) ? dwReply:dwBufSize;

    // Write number of words in block to be written.
    pd_dsp_write(board, dwWords);

    // Write block of dwWords to transmit register.
    for ( i = 0; i < dwWords; i++ )
        pd_dsp_write(board, (u32)*(pwWriteBuf + i));

    return pd_dsp_read_ack(board);
}

//
// Function:    int pd_cal_dac_write()
//
// Parameters:  ULONG dwCalDACValue -- Cal DAC adrs and value to output:
//                                      bits 0-7:  Value to output (0-255)
//                                      bits 8-10: DAC Output selection (0-7)
//                                      bit  11:   Cal DAC selection (0/1)
//                                      bit  12:   Select PD2-AO mode
//                                      bit  13-15:PD2-AO DAC selection (0-7)
//
//
// Returns:     int status  -- TRUE:  command succeeded
//                                 FALSE: command failed
//
// Description: The Cal DAC Write command writes the DAC select adrs and
//              value to the specified calibration DAC.
//
// Notes:       This function updates the driver's AIn configuration and
//              calibration table. --> this was moved to dispatch table.
//
int pd_cal_dac_write(int board, u32 dwCalDACValue)
{
    // Issue PD_CALDACWRITE with param and check acknowledge.
    return pd_dsp_cmd_write_ack(board, PD_CALDACWRITE, dwCalDACValue);
}

// Function:    int PdDiagPCIInt(PADAPTER_INFO pAdapter)
//
// Parameters:  PADAPTER_INFO pAdapter -- ptr to adapter info struct
//
// Returns:     int status  -- TRUE:  command succeeded
//                                 FALSE: command failed
//
// Description: The diagnostics PCI interrupt command asserts the PCI
//              Host interrupt.
//
// Notes:
//
int pd_adapter_test_interrupt(int board)
{
    u32 dwStatus;

    pd_board[board].bTestInt = 1;

    // Issue PD_DIAGPCIINT command.
    pd_dsp_cmd_no_ret(board, PD_DIAGPCIINT);

    // Get DSP PCI interrupt status and check if INTA was deasserted.
    dwStatus = pd_dsp_get_status(board);
    if ( !(dwStatus & (DWORD)(1<<HSTR_HINT)) )
        return TRUE;
    return FALSE;

}










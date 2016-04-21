/* $Revision: 1.1.2.1 $ */
//===========================================================================
//
// NAME:    pdl_ain.c: 
//
// DESCRIPTION:
//
//          PowerDAQ QNX driver interface to Analog Input FW functions
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
// ANALOG INPUT SECTION
//
////////////////////////////////////////////////////////////////////////
//
//       NAME:  pd_ain_set_config
//
//   FUNCTION:  Sets the configuration of the analog input subsystem.
//
//  ARGUMENTS:  int board                  -- The board to configure.
//              u32 pd_ain_config             -- the ain configuration word
// **no**       u32 pd_ain_BlkXfer            -- AIn FHF DMA Block Xfer Size-1
//              u32 pd_ain_pre_trigger_count  -- AIn Pre-trigger Scan Count
//              u32 pd_ain_post_trigger_count -- AIn Post-trigger Scan Count
//
//    RETURNS:  1 if it worked, 0 if it failed.
//
int pd_ain_set_config(
   int board,
   u32 pd_ain_config,
   u32 pd_ain_pre_trigger_count,
   u32 pd_ain_post_trigger_count
) 
{
   u32 dwDataOffset, i, dwCalDACValue;

   //printf_P("setting ain config to 0x%08X on board %d\n", pd_ain_config, board);

   // Does this adapter support autocalibration?
   if ( pd_board[board].PCI_Config.SubsystemID & ADAPTER_AUTOCAL )
   {
       // Compare modes in configuration -- if mode changed --> load calibration:
       if ( (pd_board[board].AinSS.SubsysConfig & (AIB_MODEBITS)) != (pd_ain_config & (AIB_MODEBITS)) )
       {
           // Find offset for current mode in bytes.
           dwDataOffset = ((pd_ain_config & (AIB_MODEBITS))>>1) * 4;

           // Program CALDACs.
           for ( i = 0; i < 3; i++ )
           {
               dwCalDACValue = pd_board[board].Eeprom.u.Header.CalibrArea[dwDataOffset + i];
               pd_dsp_cmd_write_ack(board, PD_CALDACWRITE,
                                 (((i*2)<<8)|(dwCalDACValue & 0xFF)));
               pd_dsp_cmd_write_ack(board, PD_CALDACWRITE,
                                 (((i*2+1)<<8)|((dwCalDACValue & 0xFF00)>>8)));
           }
       }
   }

   // check for FW mode (depends of board type and logic used)
   if ((pd_board[board].Eeprom.u.Header.FWModeSelect & 0xFFFF) == PD_AIB_SELMODE0)
      pd_ain_config |= AIB_SELMODE0;

   // Store current configuration.
   pd_board[board].AinSS.SubsysConfig = pd_ain_config;
   //printf_P("pd_ain_config = 0x%x\n", pd_ain_config);      

   pd_dsp_command(board, PD_AICFG);     
   if (pd_dsp_read(board) != 1) 
   {
      //printf_F("set ain config FAILS on board %d\n", board);
      return 0;
   }

   pd_dsp_write(board, pd_ain_config);
   pd_dsp_write(board, pd_ain_pre_trigger_count);
   pd_dsp_write(board, pd_ain_post_trigger_count);

   return (pd_dsp_read(board) == 1) ? 1 : 0;
}

//
//       NAME:  pd_ain_set_cv_clock
//
//   FUNCTION:  Sets the analog input conversion start (pacer) clock.
//              Configures the DSP Timer to generate a clock signal using
//              the specified divider from either a 11.0 MHz or 33.0 MHz
//              base clock frequency.
//
//  ARGUMENTS:  int board          -- The board in question.
//              u32 clock_divisor  -- conversion start clock divider
//
//    RETURNS:  1 if it worked, 0 if it didn't.
//
int pd_ain_set_cv_clock(int board, u32 clock_divisor) 
{
   pd_dsp_command(board, PD_AICVCLK);  
   if (pd_dsp_read(board) != 1) 
   {
      return 0;
   }
   pd_dsp_write(board, clock_divisor);
   return (pd_dsp_read(board) == 1) ? 1 : 0;
}

//
//       NAME:  pd_ain_set_cl_clock
//
//   FUNCTION:  Sets the analog input channel list start (burst) clock.
//              Configures the DSP Timer to generate a clock signal using
//              the specified divider from either an 11.0 MHz or a 33 MHz
//              base clock frequency.
//
//  ARGUMENTS:  int board          -- The board in question.
//              u32 clock_divisor  -- The new clock divisor.
//
//    RETURNS:  1 if it worked, 0 if it failed.
//
int pd_ain_set_cl_clock(int board, u32 clock_divisor) 
{
   pd_dsp_command(board, PD_AICLCLK); 
   if (pd_dsp_read(board) != 1) 
   {
      return 0;
   }
   pd_dsp_write(board, clock_divisor);
   return (pd_dsp_read(board) == 1) ? 1 : 0;
}




//
//       NAME:  pd_ain_set_channel_list
//
//   FUNCTION:  Sets the ADC Channel/Gain List.  This overwrites and
//              completely replaces any pre-existing channel list.
//              The channel list can contain from 1 to 256 channel entries.
//              The configuration data word for each entry includes the
//              channel mux selection, gain, and slow bit setting.
//
//  ARGUMENTS:  int board        -- The board in question.
//              u32 num_entried  -- Number of channels in list.
//              u32 list[]       -- The list.
//
//    RETURNS:  1 if it worked, 0 if it failed.
//
int pd_ain_set_channel_list(int board, u32 num_entries, u32 list[]) 
{
   int i;
   u32 dwGainCfg;

   // channel list is located in the input buffer of ioctl()
   // that's why
   //printf_P("setting ain channel list (%d entries) on board %d\n", num_entries, board);

   // Check is board MFS - set up gains
   if ( PD_IS_MFS(pd_board[board].PCI_Config.SubsystemID) )
   {
       dwGainCfg = 0;
       for (i = 0; i < num_entries; i++)
       {
           if (((*list) & 0x3F) <= 8)
           {
               dwGainCfg |= ((*(list+i) >> 6) & 3) << ((*(list+i) & 0x7) << 1);
           }
       }
       pd_dsp_cmd_write_ack(board, PD_AISETSSHGAIN, dwGainCfg);
   }

   pd_dsp_command(board, PD_AICHLIST); 
   if (pd_dsp_read(board) != 1) 
   { 
      //printf_F("setting ain channel list FAILS on board %d\n", board);
      return 0;
   }

   pd_dsp_write(board, num_entries);
   for (i = 0; i < num_entries; i++) 
   {
      pd_dsp_write(board, list[i]);
   }

   return (pd_dsp_read(board) == 1) ? 1 : 0;
}

//
//       NAME:  pd_ain_set_busmaster_list
//
//   FUNCTION:  Send the bmlist structure to the board.  This contains
//              two buffer addresses as well as 2 sizes.
//
//  ARGUMENTS:  int board        -- The board in question.
//              bmlist *list     -- The list.
//
//              where bmlist is:  an array of 4 unsigned long ints.
//                                phys addr, buf1 >> 8
//                                phys addr, buf2 >> 8
//                                size of half fifo, mult of AIBM_TXSIZE (== 512)
//                                size of buffer, mult of AIBM_TXSIZE
//
//    RETURNS:  1 if it worked, 0 if it failed.
//
int pd_ain_set_busmaster_list(int board, unsigned long *list) 
{
    int i;
    pd_dsp_command( board, PD_AICHLIST );
    if( pd_dsp_read(board) != 1 )
    {
		return 0;
    }
    pd_dsp_write( board, AIBM_SET );
    for( i = 0 ; i < 4 ; i++ )
    {
		pd_dsp_write( board, list[i] );
    }
    return( pd_dsp_read(board) == 1 ) ? 1 : 0;
}

// Function:    pd_ain_set_events()
//
// Parameters:  DWORD dwEvents  -- AInIntrStat Event configuration word
//
// Returns:     BOOLEAN status  -- TRUE:  command succeeded
//                                 FALSE: command failed
//
// Description: Set selected AIn AInIntrStat event bits enabling/disabling
//              and/or clearing individual firmware level events, thereby
//              re-enabling the event interrupts.
//
//              AInIntrStat Bit Settings:
//
//                  AIB_xxxxIm bits:    0 = disable, 1 = enable interrupt
//                  AIB_xxxxSC bits:    0 = clear interrupt, 1 = no change
//
// Notes:       See pdfw_def.h for the AInIntrStat event word format.
//
int pd_ain_set_events (int board, u32 dwEvents)
{
    return pd_dsp_cmd_write_ack(board, PD_AISETEVNT, dwEvents);
}


//
//       NAME:  pd_ain_get_status
//
//   FUNCTION:  Reads the analog in Interrupt/Status registers.
//
//  ARGUMENTS:  The board to read from.
//
//    RETURNS:  The contents of the registers.
//
int pd_ain_get_status(int board, u32* status) 
{
   pd_dsp_command(board, PD_AISTATUS);
   *status = pd_dsp_read(board);
   return TRUE;
}

//
//       NAME:  pd_ain_sw_start_trigger()
//
//   FUNCTION:  Triggers the AIn Start event to start sample aquisition.
//
//  ARGUMENTS:  The board to start.
//    
//    RETURNS:  1 if it worked and 0 if it failed
//
int pd_ain_sw_start_trigger(int board) 
{
   //printf_P("ain sw start trigger on board %d\n", board);
   pd_dsp_command(board, PD_AISTARTTRIG); 
   return (pd_dsp_read(board) == 1) ? 1 : 0;
}

//
//       NAME:  pd_ain_sw_stop_trigger
//
//   FUNCTION:  Triggers the AIn Stop event to stop sample aquisition.
//
//  ARGUMENTS:  The board in question.
//
//    RETURNS:  1 if it worked, and 0 if not.
//
int pd_ain_sw_stop_trigger(int board) 
{
   //printf_P("ain sw stop trigger on board %d\n", board);
   pd_dsp_command(board, PD_AISTOPTRIG);
   return (pd_dsp_read(board) == 1) ? 1 : 0;
}

//    
//       NAME:  pd_ain_set_enable_conversion
//
//   FUNCTION:  Enables or disables ADC conversions.  This function is
//              irrespective of the AIn Conversion Start and AIn Channel
//              List Start signals.  During configuration and following 
//              an error condition, the analog input process is disabled
//              and must be re-enabled to perform subsequent conversions.
//              This command permits completing AIn configuration before
//              the subsystem responds to the Start trigger.
//
//              PD_AINCVEN <== 0:   AIn subsystem Start Trigger is disabled
//                                  and ignored. Conversion in progress
//                                  will not be interrupted but the start
//                                  trigger is disabled from retriggering
//                                  the subsystem again.
//
//              PD_AINCVEN <== 1:   AIn subsystem Start Trigger is enabled
//                                  and data acquisition will start on the
//                                  first valid AIn start trigger.
//
//  ARGUMENTS:  The board in questions, and a boolean - 0 to disable ADC
//              conversions, 1 to enable.
//
//    RETURNS:  1 if it worked, 0 if it failed.
//
int pd_ain_set_enable_conversion(int board, int enable) 
{
   //printf_P("setting ain conversion to %d on board %d\n", enable, board);
   pd_dsp_command(board, PD_AICVEN);
   if (pd_dsp_read(board) != 1) 
   {
      return 0;
   }
   pd_dsp_write(board, (u32)enable);
   return (pd_dsp_read(board) == 1) ? 1 : 0;
}

// Function:    pd_ain_get_value()
//
// Parameters:  board
//              USHORT *pwSample
//
// Returns:     BOOLEAN status  -- TRUE:  command succeeded
//                                 FALSE: command failed
//
// Description: The AIn Get Single Value command reads a single value
//              from the ADC FIFO.
//
// Notes:
//
int pd_ain_get_value(int board, u16* value)
{
    u32 dwReply;

    // Issue PD_AIGETVALUE command and get return value.
    dwReply = pd_dsp_cmd_ret_value(board, PD_AIGETVALUE);
    if ( dwReply == ERR_RET )
    {
        *value = 0;
        return 0;
    }
    *value = dwReply;
    return 1;
}

//
// Function:    pd_ain_set_ssh_gain()
//
// Parameters:  board
//              ULONG dwCfg -- SSH PGA configuration
//
// Returns:     BOOLEAN status  -- TRUE:  command succeeded
//                                 FALSE: command failed
//
// Description: Sets SSH PGA configuration
//
// Notes: PD2-MFS-xDG boards only
//
int pd_ain_set_ssh_gain(int board, u32 dwCfg)
{
    // Issue PD_AISETSSHGAIN with param and check acknowledge.
    return pd_dsp_cmd_write_ack(board, PD_AISETSSHGAIN, dwCfg);
}


//
//       NAME:  pd_ain_get_samples
//
//   FUNCTION:  Get any available samples from the ADC FIFO.
//
//  ARGUMENTS:  int board        -- The board in question.
//              int max_samples  -- Read at most this many samples.
//              u16 buffer[]     -- Put the samples here.
//
//    RETURNS:  The number of samples actually read.
//
//       NOTE:  Last value read must always by ERR_RET.
//
int pd_ain_get_samples(int board, int max_samples, uint16_t buffer[]) 
{
   int i;
   int nSamples;
   u32 dwSample = 0;

   //printf_P("getting ain samples from board %d\n", board);

   pd_dsp_command(board, PD_AIGETSAMPLES);
   if (pd_dsp_read(board) != 1) 
   {
      //printf_F("getting ain samples FAILS from board %d\n", board);
      return -EIO;
   }

   pd_dsp_write(board, (u32)max_samples);
   nSamples = 0;
   for (i = 0; i < max_samples + 1; i++) 
   {
      dwSample = pd_dsp_read(board);
      if (dwSample == ERR_RET) 
      {
        //printf_T("end of samples\n");
        break;
      }

      if (i < max_samples) 
      {
        buffer[nSamples++] = (u16)dwSample;
      }
   }

   if (dwSample != ERR_RET) {
      //printf_F(KERN_ERR PD_ID "ERROR! no end of buffer in pd_ain_get_samples!\n");
      return -EIO;
   }

   return nSamples;
}

//
//       NAME:  pd_ain_reset
//
//   FUNCTION:  Resets the ADC subsystem to the default startup
//              configuration.  All operations in progress are stopped and
//              all configurations and buffers are cleared.  All transfers
//              in  progress are interrupted and masked.
//   
//  ARGUMENTS:  The board on which to reset the ADC logic.
//
//    RETURNS:  1 if it worked and 0 if it failed.
//
int pd_ain_reset(int board)
{
   //printf_P("ain reset on board %d\n", board);
   pd_dsp_command(board, PD_AIRESET); 
   return (pd_dsp_read(board) == 1) ? 1 : 0;
}

//
//       NAME:  pd_ain_sw_cl_start()
//
//   FUNCTION:  Triggers the ADC Channel List Start signal.  This starts a
//              scan.
//
//  ARGUMENTS:  The board to trigger.
//
//    RETURNS:  1 if it worked, 0 if it failed.
//
int pd_ain_sw_cl_start(int board) 
{
   //printf_P("sending sw cl start signal to board %d\n", board);

   pd_dsp_command(board, PD_AISWCLSTART); 
   return (pd_dsp_read(board) == 1) ? 1 : 0;
}

//
//       NAME:  pd_ain_sw_cv_start()
//
//   FUNCTION:  Triggers the ADC Conversion Start signal.  This starts a
//              scan.
//
//  ARGUMENTS:  The board to trigger.
//
//    RETURNS:  1 if it worked, 0 if it failed.
//
int pd_ain_sw_cv_start(int board) 
{
   //printf_P("sending sw cl start signal to board %d\n", board);

   pd_dsp_command(board, PD_AISWCVSTART); 
   return (pd_dsp_read(board) == 1) ? 1 : 0;
}


//
//       NAME:  pd_ain_reset_cl()
//
//   FUNCTION:  Resets the ADC Channel List to the first channel in the list.
//              This command is similar to the SW Channel List Start, but
//              does not enable the list for conversions.
//
//  ARGUMENTS:  The board to reset.
//
//    RETURNS:  1 if it worked, 0 if it failed.
//
int pd_ain_reset_cl(int board) 
{
   pd_dsp_command(board, PD_AICLRESET); 
   return (pd_dsp_read(board) == 1) ? 1 : 0;
}

// Function:    pd_ain_clear_data()
//
// Parameters:  board
//
// RETURNS:     1 if it worked, 0 if it failed.
//
// Description: The clear all AIn data command clears the ADC FIFO and
//              all AIn data storage buffers.
//
// Notes:
//
int pd_ain_clear_data(int board)
{
    // Issue PD_AICLRDATA command and check ack.
    return pd_dsp_cmd_ret_ack(board, PD_AICLRDATA);
}

//
//
//       NAME:  pd_ain_read_scan()
//
//   FUNCTION:  Reads the values of the analog input lines.
//
//  ARGUMENTS:  The board to read from, the userspace buffer to read into,
//              and the number of bytes to read.
//
//    RETURNS:  Number of bytes actually read.
//
size_t pd_ain_read_scan(
   int board,
   const char *buffer,
   size_t count
) {
    u32 pd_ain_config, pd_ain_cl_size;
    int nValues, nScans;
    u16 wXOR = 0x8000;      //FIXME: should be taken from pd_hcaps.h
    u16 AInBuf[AINBUFSIZE];
    u32 CList[PD_MAX_CL_SIZE];
    u32 dwSum;
    int delay_ms;
    int i, j, ret;
 
    //printf_P("entered pd_ain_read_scan: board: %d count: %d\n", board, count);    


    pd_ain_config =  AIN_BIPOLAR | AIN_RANGE_10V | AIN_CV_CLOCK_CONTINUOUS | AIN_CL_CLOCK_CONTINUOUS;
    pd_ain_cl_size = count / sizeof(u16);

    // check pd_ain_cl_size - do not go further if it's incorrect
    if ((pd_ain_cl_size < 1)||(pd_ain_cl_size > PD_MAX_CL_SIZE))
       return 0;

    for (i = 0; i < PD_MAX_CL_SIZE; i++)
        CList[i] = i;

    pd_ain_reset(board);
    ret = pd_ain_set_config(board, pd_ain_config, 0, 0);

    ret = pd_ain_set_channel_list(board, pd_ain_cl_size, CList);
    ret = pd_ain_set_enable_conversion(board, 1);
    ret = pd_ain_sw_start_trigger(board);

    delay_ms = pd_ain_cl_size / 2;
    if (delay_ms < 5) delay_ms = 5;
    delay(delay_ms);

    ret = pd_ain_sw_stop_trigger(board);
    ret = pd_ain_set_enable_conversion(board, 0);
    nValues = pd_ain_get_samples(board, AINBUFSIZE, AInBuf);
    nScans = nValues / pd_ain_cl_size;

    //printf_T("%d samples (%d scans) available\n", nValues, nScans);

    if (!nScans) return 0; // no scans available

    // get average
    for (j=0; j < pd_ain_cl_size; j++)
    {
       dwSum = 0;
       for (i=0; i < nScans; i++)
          dwSum += *(AInBuf + i*pd_ain_cl_size + j) ^ wXOR;

       *((u16*)buffer + j) = (u16)(dwSum / nScans);
    }

    return count;
}


//
// Function:    PdAInFlushFifo
//
// Parameters:  PADAPTER_INFO pAdapter -- pointer to device extension
//
//
// Description: The Flush AIn Sample FIFO function gets all samples from the
//              AIn sample FIFO as quickly as possible and stores them in
//              a temporary buffer stored in device extention.
//
//              This function is called from the ISR or a DPC to process the
//              AIn FHF hardware interrupt event by transferring data from
//              board to the temporary buffer.
//
//              Two types of reads from the board are performed, first
//              a Block Transfer is used to read a fixed size block from
//              the DSP / AIn FIFO using the fastest PCI Slave mode
//              possible via DSP DMA. Following the block transfer, a
//              PD_AIGETSAMPLES is performed to read all remaining samples.
//
// Notes:       The board status must indicate FHF before this function is
//              called otherwise data read could be invalid.
//
//              Each sample is stored in 16 bits.
//
//
//

int pd_ain_flush_fifo(int board)
{
    u32   dwMaxSamples;
    u16*  pwBuf = pd_board[board].AinSS.BufInfo.XferBuf;
    u32   dwCount;
    u32   dwSample = ERR_RET;
    u32   nBlks;
    int   i, bCount;
    
    dwMaxSamples = pd_board[board].AinSS.BufInfo.XferBufValues;             //0x400

    //printf_P("pd_ain_flush_fifo: XferBufValues(1): 0x%x BlkXferValues: 0x%x XferBufValueCount: 0x%x\n", pd_board[board].AinSS.BufInfo.XferBufValues, pd_board[board].AinSS.BufInfo.BlkXferValues, pd_board[board].AinSS.BufInfo.XferBufValueCount );

    // fifo sizes currently are 1k, 16k or 32k samples
    // a block is 512 samples or 1/2 k, so for FHF, nBlks is just fifo size.
    nBlks = pd_board[board].Eeprom.u.Header.ADCFifoSize;

    for ( i = dwCount = 0; i < nBlks; i++)
    {
      // Issue PD_AIN_BLK_XFER command w/o return value.
      pd_dsp_cmd_no_ret(board, PD_AIN_BLK_XFER);
  
      // Read fixed size block of samples from receive register.
      for (bCount = 0; bCount < pd_board[board].AinSS.BufInfo.BlkXferValues; bCount++ )
      {
              *(pwBuf++) = (u16)pd_dsp_read_x(board);
      }
      dwCount += bCount;
    }
    
    //printf_T("pd_ain_flush_fifo: xfer 0x%x values\n", dwCount);
    pd_board[board].AinSS.BufInfo.XferBufValueCount = dwCount;

    // Issue PD_AIGETSAMPLES command and check ack.
    if ( !pd_dsp_cmd_ret_ack(board, PD_AIGETSAMPLES) )
    {
        //printf_F("Error: cannot execute PD_AIGETSAMPLES in pd_ain_flush_fifo\n");
        return FALSE;
    }

    // Write max number of sample words that can be read.
    pd_dsp_write(board, (dwMaxSamples-dwCount));

    // Read block of dwMaxBufSize+1 from receive register until ERR_RET.
    for ( ; dwCount < (dwMaxSamples+1); dwCount++ )
    {
        dwSample = pd_dsp_read(board);
        if (dwSample == ERR_RET)
            break;

        if (dwCount < dwMaxSamples)
            *(pwBuf++) = (USHORT)dwSample;
    }

    // set # of valid samples read.

    //printf_T("pd_ain_flush_fifo: x-count 0x%x values\n", dwCount - pd_board[board].AinSS.BufInfo.XferBufValueCount);

    pd_board[board].AinSS.BufInfo.XferBufValueCount = dwCount;

    //printf_T("pd_ain_flush_fifo: BlkXferValues(2): 0x%x BlkXferValueCount: 0x%x\n", pd_board[board].AinSS.BufInfo.BlkXferValues, pd_board[board].AinSS.BufInfo.XferBufValueCount );

    if (dwSample != ERR_RET)
    {
        //printf_F("Error: No end of buffer in PdFlushAInFifo\n");
        return FALSE;
    }

    return TRUE;
}

//
//       NAME:  pd_ain_get_xfer_samples
//
//   FUNCTION:  Get samples from the ADC FIFO using DMA
//
//  ARGUMENTS:  int board        -- The board in question.
//              u16 buffer[]     -- Put the samples here.
//
//    RETURNS:  The number of samples actually read.
//
//       NOTE:  FW 00218 supports this function!!!
//
int pd_ain_get_xfer_samples(int board, int samples, uint16_t* buffer) 
{
    int nSamples = samples; //pd_board[board].AinSS.BufInfo.BlkXferValues;
    int i;

    // Read fixed size block of samples from receive register.

    pd_dsp_cmd_no_ret(board, PD_AIN_BLK_XFER);
   
    //printf_P("AIN_BLKXFER_16: nSamples = %d\n", nSamples);    
    for (i = 0; i < nSamples; i++ )  // 16-bit XFer
    {                                            
       *((uint16_t*)buffer++) = (u16)pd_dsp_read_x(board);
    }

    return nSamples;
}

//
//       NAME:  pd_ain_set_xfer_size
//
//   FUNCTION:  Set samples size to transfer from ADC FIFO using DMA
//
//  ARGUMENTS:  int board        -- The board in question.
//              u32              -- Size
//
//    RETURNS:  The number of samples actually read.
//
//       NOTE:  FW 00222 supports this function!!!
//
int pd_ain_set_xfer_size(int board, u32 size) 
{
    // store new DSP DMA transfer size - should be even
    pd_board[board].AinSS.BufInfo.BlkXferValues = size;
    
    // Issue PD_AIXFERSIZE command and check ack.
    return pd_dsp_cmd_write_ack(board, PD_AIXFERSIZE, size-1);
}

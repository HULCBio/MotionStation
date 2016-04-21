/* $Revision: 1.1.2.3 $ */
//===========================================================================
//
// NAME:    pdl_fwi.c: 
//
// DESCRIPTION:
//
//          PowerDAQ QNX driver interface to basic r/w FW functions
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
//---------------------------------------------------------------------------
//
// this file is not to be compiled independently
// but to be included into pdfw_lib.c

//////////////////////////////////////////////////////////////////////
//
// FIRMWARE INTERFACE
//
//////////////////////////////////////////////////////////////////////

//#define readl(addr) (*(u32*)addr)
//#define writel(b,addr) (*(u32*)addr = (b))


u32 readl(char* addr)
{
   u32 val;
   val = *(volatile u32*)addr;
    //printf("r%X a%X\n", val, (u32)((u32*)addr));
   return val;

}

void writel(u32 val, char* addr)
{
   *(volatile u32*)addr = val;
    //printf("w%X a%X", val, (u32)((u32*)addr));
   return;
}

// 
//       name:  pd_dsp_get_status
//
//   function:  Reads the status of the PD's DSP.  Duh.
//
//  arguments:  The board (index) to read from.
//  
//    returns:  The status.
//
u32 pd_dsp_get_status(int board) 
{
   return readl((char*)pd_board[board].address + PCI_HSTR);
}

// 
//       name:  pd_dsp_int_status
//
//   function:  Reads the status of DSP HSTR. Returns true if
//              (1<<HSTR_HINT)
//
//
u32 pd_dsp_int_status(int board) 
{
   u32 val;
   val = readl((char*)pd_board[board].address + PCI_HSTR);
   return (val & (1<<HSTR_HINT));
}

// 
//       name:  pd_dsp_get_flags()
//
//   function:  Reads the flags of the PD's DSP.  Duh.
//
//  arguments:  The board (index) to read from.
//  
//    returns:  The flags.
//
u32 pd_dsp_get_flags(int board) 
{
   return (pd_dsp_get_status(board) >> HSTR_HF) & 0x7;
}

// 
//       name:  pd_dsp_set_flags()
//
//   function:  Sets the flags of the PD's DSP.
//
//  arguments:  The board (index) to set DSP flags on, and the new flags.
//  
//    returns:  Nothing.
//
void pd_dsp_set_flags(int board, u32 new_flags) {

   // clear flags
   pd_board[board].HI32CtrlCfg &= ~(u32)(0x07<<HCTR_HF);

   // set flags
   pd_board[board].HI32CtrlCfg |= (u32)((new_flags & 0x07)<<HCTR_HF);
   writel(pd_board[board].HI32CtrlCfg, ((char*)pd_board[board].address + PCI_HCTR));
}

// 
//       name:  pd_dsp_command(), pd_dsp_cmd_no_ret()
//
//   function:  Sends a command to the DSP.
//
//  arguments:  The board (index) of the DSP to send the command to.
//  
//    returns:  Nothing.
//
void pd_dsp_command(int board, int command) 
{
   writel((1L | command), ((char*)pd_board[board].address + PCI_HCVR));
}

void pd_dsp_cmd_no_ret(int board, u16 command) 
{
   writel((1L | command), ((char*)pd_board[board].address + PCI_HCVR));
}

// 
//       name:  pd_dsp_write()
//
//   function:  Write data to the PowerDAQ transmit data register.
//
//  arguments:  The board (index) to write to, and the data to write.
//  
//    returns:  Nothing.
//
void pd_dsp_write(int board, u32 data) 
{
   unsigned long i;

   for (i = 0; (!(pd_dsp_get_status(board) & (1 << HSTR_HTRQ))) && (i < MAX_PCI_BUSY_WAIT); i ++) { }
   if (i == MAX_PCI_BUSY_WAIT) 
   {
       return;
   }

   writel(data, ((char*)pd_board[board].address + PCI_HTXR));
}

// 
//       name:  pd_dsp_write_x()
//
//   function:  The same as pd_dsp_write_x() but doesn't check dsp status before write
//              Write data to the PowerDAQ transmit data register.
//
void pd_dsp_write_x(int board, u32 data) 
{
   writel(data, ((char*)pd_board[board].address + PCI_HTXR));
}

// 
//       name:  pd_dsp_read()
//
//   function:  Read data from the PowerDAQ slave receive data register.
//
//  arguments:  The board (index) to read from.
//  
//    returns:  The 32-bit word read.
//
u32 pd_dsp_read(int board) 
{
   unsigned long i;
   int stat;

   for (i = 0; !((stat = pd_dsp_get_status(board)) & (1 << HSTR_HRRQ)) && (i < MAX_PCI_BUSY_WAIT); i++)
   {
     ;
   }
   if (i >= MAX_PCI_BUSY_WAIT) {
      return (u32)-1;
   }
   return readl((char*)pd_board[board].address + PCI_HRXS);
}

// 
//       name:  pd_dsp_read_x()
//
//   function:  The same as pd_dsp_read() but doesn't check dsp status before read
//              Read data from the PowerDAQ slave receive data register.
//              
u32 pd_dsp_read_x(int board) 
{
   return readl((char*)pd_board[board].address + PCI_HRXS);
}

//
//       name:  pd_dsp_cmd_ret_ack()
//
// description: Read one word PowerDAQ command completion acknowledge and
//              check acknowledge value.
//
//  arguments:  The board (index) to read from, command
//  
//    returns:  1 if works, 0 if fails
//
u32 pd_dsp_cmd_ret_ack(int board, u16 wCmd)
{
    // Issue command.
    pd_dsp_command(board, wCmd);

    // Read and check command ack.
    return pd_dsp_read(board);
}

//
//       name:  pd_dsp_cmd_ret_value()
//
// description: Read one word PowerDAQ command completion acknowledge and
//              return value.
//
//  arguments:  The board (index) to read from, command
//  
//    returns:  value read from the DSP
//
u32 pd_dsp_cmd_ret_value(int board, u16 wCmd)
{
    // Issue command.
    //printf("pd_dsp_command \n");
    pd_dsp_command(board, wCmd);

    // Read and check command ack.
    //printf("pd_dsp_read \n");
    return pd_dsp_read(board);
}

// Function:    u32 pd_dsp_read_ack()
//
//
// Returns:     BOOLEAN status  -- TRUE:  command succeeded
//                                 FALSE: command failed
//
// Description: Read one word PowerDAQ command completion acknowledge and
//              check acknowledge value.
//
u32 pd_dsp_read_ack(int board)
{
    // Read command ack.
    if (pd_dsp_read(board) != 1)
    {
        return 0;
    }
    return 1;
}

// Function:	pd_dsp_reg_read(board, offset)
//
//
// Returns:		value the value at 'offset' in DSP memory space
//
// Description:	Read one word at location 'offset' in the DSP memory space
// The write function does the corresponding write command to 'offset'.
//
// Created for xPC by G. Weast 5/12/2003
//
u32 pd_dsp_reg_read( int board, u32 offset )
{
	if( !pd_dsp_cmd_ret_ack( board, PD_BRDREGRD ) )
		return false;
		
	// Write address and read the value there
	pd_dsp_write( board, offset );
	return pd_dsp_read( board );
}

u32 pd_dsp_reg_write( int board, u32 offset, u32 value )
{
	if( !pd_dsp_cmd_ret_ack( board, PD_BRDREGWR ) )
		return false;
	
	// Write address and write the value there
	pd_dsp_write( board, offset );
	return pd_dsp_write_ack( board, value );
}

//
// Function:    u32 pd_dsp_write_ack()
//
// Parameters:  PADAPTER_INFO pAdapter -- ptr to adapter info struct
//              ULONG dwValue   -- value to write to transmit data register
//
// Returns:     BOOLEAN status  -- TRUE:  command succeeded
//                                 FALSE: command failed
//
// Description: Write one word to DSP transmit data register and read
//              PowerDAQ command completion acknowledge and check
//              acknowledge value.
//
u32 pd_dsp_write_ack(int board, u32 dwValue)
{
    pd_dsp_write(board, dwValue);

    return pd_dsp_read_ack(board);
}

//
// Function:     u32 pd_dsp_cmd_write_ack()
//
// Parameters:  USHORT  wCmd    -- PD command to issue
//              ULONG dwValue   -- value to write to transmit data register
//
// Returns:     BOOLEAN status  -- TRUE:  command succeeded
//                                 FALSE: command failed
//
// Description: Issue PD command with one word parameter: issue command,
//              read and check acknowledge, write one word to DSP transmit
//              data register and read/check command completion acknowledge.
//
u32 pd_dsp_cmd_write_ack(int board, u16 wCmd, u32 dwValue)
{
    // Issue command and check ack.
    if ( !pd_dsp_cmd_ret_ack(board, wCmd))
        return FALSE;

    // Write 1 word parameter and check command completion acknowledge.
    return pd_dsp_write_ack(board, dwValue);
}

//  
//       NAME:  pd_dsp_acknowledge_interrupt()
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
u32 pd_dsp_acknowledge_interrupt( int board )
{
   u32 i, j, val; 

   pd_dsp_cmd_no_ret( board, PD_BRDINTACK );

   for (i = 0; i < MAX_PCI_BUSY_WAIT; i++) 
   {
       // something like KeStallExecutionProcessor(1); udelay(1);
       for (j = 50; j>0; j--) val = j;
       if (!pd_dsp_int_status(board)) 
           return TRUE;
   }
   return FALSE; 
}

// 
//       name:  pd_reset_dsp()
//
//   function:  Resets the DSP and reloads the bootstrapper.
//
//  arguments:  The board (index) of the DSP to reset.
//  
//    returns:  1 if all went well, and 0 if there was a problem.
//
int pd_reset_dsp(int board) 
{
   int i;
   int HF;
   u32 HI32Cfg;

   pd_dsp_command(board, PD_BRDHRDRST);
   delay(10);
   
   HF = pd_dsp_get_flags(board);
   for (i = 0; (HF != 1) && (HF != 3) && (i < MAX_PCI_WAIT); i ++) {
      delay(1);
      HF = pd_dsp_get_flags(board);
   }
   if (i == MAX_PCI_WAIT) {
      return 0;
   }

   pd_board[board].HI32CtrlCfg = (u32)(1L << HCTR_HTF0 | 1L << HCTR_HRF0);
   writel(pd_board[board].HI32CtrlCfg, ((char*)pd_board[board].address + PCI_HCTR));

   HI32Cfg = readl((char*)pd_board[board].address + PCI_HCTR);
   if (HI32Cfg != pd_board[board].HI32CtrlCfg) {
      return 0;
   }

   return 1;
}

// 
//       name:  pd_download_firmware_bootstrap
//
//   function:  Downloads the bootstrapper.
//
//  arguments:  The board (index) to download the bootstrapper to.
//  
//    returns:  1 if all went well, and 0 if there was a problem.
//
int pd_download_firmware_bootstrap(int board) 
{
   int i;
   u32 val;

   pd_dsp_command(board, PD_BRDFWDNLD);
   if (pd_dsp_read(board) != 1) {
      return 0;
   }

   pd_dsp_write(board, FWDnldLoader.dwMemSize);
   pd_dsp_write(board, FWDnldLoader.dwMemAdrs);

   for (i = 0; i < FWDnldLoader.dwMemSize; i ++) {
      pd_dsp_write(board, FWDnldLoader.dwMemData[i]);
   }

   val = 0;
   for (i = 0; (val != 1) && (val != 3) && (i < MAX_PCI_WAIT); i ++) {
      val = pd_dsp_get_flags(board);
      delay(1);
   }

   if (i == MAX_PCI_WAIT) {
      return 0;
   }

   return 1;
}

// 
//       name:  pd_reset_board
//
//   function:  Performs a complete reset.  All onboard operations are
//              stopped, all configurations and buffers are cleared, and
//              any transfers in progress are signaled as terminated.
//              Downloads the firmware loader to the DSP in preparation
//              of downloading the firmware itself (you should probably
//              follow a call to this function with a call to
//              pd_download_firmware).
//
//  arguments:  The board (index) to reset.
//  
//    returns:  1 if all went well, and 0 if there was a problem.
//
int pd_reset_board(int board) 
{
   if (! pd_reset_dsp(board)) {
      return 0;
   }

   if (! pd_download_firmware_bootstrap(board)) {
      return 0;
   }

   return 1;
}

// 
//       name:  pd_download_firmware
//
//   function:  Download the firmware to the DSP on the specified board.
//
//  arguments:  The board (index) to download firmware to.
//  
//    returns:  1 if all went well, and 0 if there was a problem.
//
int pd_download_firmware(int board) 
{
   int i, j;
   u32 dwReply;
   u32 val;
   unsigned int *segments;
   unsigned int *execaddrs;
   FW_MEMSEGMENT *data;
   int subDevId = pd_board[board].PCI_Config.SubsystemID;

   if (pd_dsp_get_flags(board) != 1) {
      //printf("DSP is not ready for FW download\n");
      return 0;
   }

   switch( subDevId )
   {
   case 0x14e:  // AO-8/16
   case 0x24e:
   case 0x14f:  // AO-16/16
   case 0x24f:
   case 0x150:  // AO-32/16
   case 0x250:
   case 0x151:  // AO-96/16
   case 0x251:
       segments = (unsigned int *)&nFWMemSegmentsA;
       execaddrs = (unsigned int *)&dwFWExecAdrsA;
       data = FWDownloadDataA;
       //printf("AO: segments = %d, execaddr = 0x%x\n", *segments, *execaddrs );
       break;
   default:  // All the MF and MFS boards for now
       segments = (unsigned int *)&nFWMemSegmentsM;
       execaddrs = (unsigned int *)&dwFWExecAdrsM;
       data = FWDownloadDataM;
       //printf("MF: segments = %d, execaddr = 0x%x\n", *segments, *execaddrs );
       break;
   }

   for (i = 0; i < *segments; i ++) {

       //printf("seg: %ld type: %ld, adr: 0x%x, size: 0x%x\n",
       //       i, data[i].dwMemType, data[i].dwMemAdrs, data[i].dwMemSize );
    switch (data[i].dwMemType) 
    {
	 case 1:
	    pd_dsp_set_flags(board, 1);
	    break;

         case 2:
	    pd_dsp_set_flags(board, 3);
	    break;

         case 3:
	    pd_dsp_set_flags(board, 7);
	    break;

         default:
	    return 0;
    }

    pd_dsp_write(board, data[i].dwMemSize);
    pd_dsp_write(board, data[i].dwMemAdrs);

    pd_dsp_command(board, PCI_LOAD);

    if ( (val = pd_dsp_read(board)) != data[i].dwMemSize) {
        printf("pd_dsp_read(board) != data[i].dwMemSize\n");
        printf("read = %d, dwMemSize = %d\n", val, data[i].dwMemSize );
		return 0;
    }
    //    printf("read = 0x%x, dwMemSize = 0x%x\n", val, data[i].dwMemSize );

    for (j = 0; (u32)j < data[i].dwMemSize; j ++) {
        //if( j <4 )
        //    printf("0x%x ", data[i].dwMemData[j] );
	 pd_dsp_write(board, data[i].dwMemData[j]);
    }
    //printf("...0x%x\n", data[i].dwMemData[j-1] );

    dwReply = pd_dsp_read(board);
    if (dwReply != (data[i].dwMemAdrs + data[i].dwMemSize) ) {
       printf("pd_dsp_read(board) != (data[i].dwMemAdrs + data[i].dwMemSize)\n");
	   return 0;
    }
    //    printf("read = 0x%x, end = 0x%x\n", dwReply, data[i].dwMemAdrs + data[i].dwMemSize );
   }

   pd_dsp_set_flags(board, 1); 
   if (pd_dsp_get_flags(board) != 1) {
      printf("No flags during downloading\n");
      return 0;
   }

   pd_dsp_write(board, *execaddrs);
   pd_dsp_command(board, PCI_EXEC);
   dwReply = pd_dsp_read(board);
   if (dwReply != *execaddrs) {
      printf("dwReply doesn't match dwFWExecAddrss\n");
      return 0;
   }

   delay(120);

   val = 0; // something fishy val shall be == 1 !!!
   for (i = 0; (val != 1) && (val != 3) && (i < MAX_PCI_WAIT); i ++) 
   {
      val = pd_dsp_get_flags(board);
      delay(1);
   }

   if (i == MAX_PCI_WAIT) {
      //printf("MAX_PCI_WAIT is reached...DSP status (%d) = %d\n", board, val);
//      return 0;
   }

   return 1;
}

// 
//       name:  pd_echo_test
//
//   function:  A diagnostic test.  Sends a 24 bit data lump to the DSP and
//              tries to read the same lump back.
//
//  arguments:  The board to ping.
//
//    returns:  1 if it worked, and 0 if it didn't.
//
int pd_echo_test(int board) 
{
   u32 lump;

   pd_dsp_command(board, PD_DIAGPCIECHO);
   lump = pd_dsp_read(board);
   //printf("Echo test...lump = 0x%x\n", lump);
   if (lump != 1) {
    //printf("Exho test failed...lump = 0x%x\n", lump);
      return 0;
   }

   pd_dsp_write(board, 0xABCDEF);
   lump = pd_dsp_read(board);
   //printf("Second Echo test...lump = 0x%x\n", lump);
   if (lump == 0xABCDEF) {
    //printf("Echo test passed (with 0x%X)!\n", lump);
      return 1;
   }
    //printf("Echo test failed...\n");
   return 0;
}

// 
//       name:  pd_dsp_startup
//
//   function:  check the status for the first time and decides what to do
//
//  arguments:  The board
//
//    returns:  1 if it worked, and 0 if it didn't.
//
int pd_dsp_startup (int board)
{
   u32 pd_dsp_flags;
   //char* a1;
   //u32*  a4;

    //update HI32CtrlCfg
   pd_board[board].HI32CtrlCfg = (1L << HCTR_HTF0) | (1L << HCTR_HRF0);

    //printf("writing HI32CtrlCfg: 0x%08lX to 0x%08lX\n", (unsigned long)pd_board[board].HI32CtrlCfg, (unsigned long)((char*)pd_board[board].address + PCI_HCTR));

   writel(pd_board[board].HI32CtrlCfg, ((char*)pd_board[board].address + PCI_HCTR));
    //printf("wrote HI32CtrlCfg: 0x%08lX\n", (unsigned long)pd_board[board].HI32CtrlCfg );

   delay(20);

   // initialize the board, make sure the firmware is loaded
   pd_dsp_flags = pd_dsp_get_flags(board);

   //printf("current DSP flags: 0x%08lX\n", (unsigned long)pd_dsp_flags);


   switch (pd_dsp_flags) {
     case 0:
     //printf("ERROR! DSP not ready for firmware download\n");
     return 0;

     case 1:
     //printf("downloading firmware to DSP...");
     if (!pd_download_firmware(board)) {
        //printf("ERROR! cannot download firmware to DSP\n");
        return 0;
     }
     //printf("firmware download complete\n");
     break;

     case 3:
     case 7:
     //printf("resetting board...");
     if (! pd_reset_board(board)) {
        //printf( "ERROR! cannot reset board\n");
        return 0;
     }
     //printf("board reset complete\n");
     
     //printf("downloading firmware to DSP...");
   	 if (! pd_download_firmware(board)) {
        //printf( "ERROR! cannot download firmware to DSP\n");
        return 0;
     }
     //printf("firmware download complete\n");
     break;
      
     default:
     //printf( "ERROR! DSP is in an unknown state\n");
     return 0;
   }

   delay(10);

   pd_dsp_flags = pd_dsp_get_flags(board);
   //printf("current DSP flags: 0x%08lX\n", (unsigned long)pd_dsp_flags);
   if (pd_dsp_flags != 3) {
       printf( "ERROR! DSP is in an unknown state after firmware download\n");
      return 0;
   }

   // printf("board %d initalized\n", board);

   //if (!pd_echo_test(board)) {
   // printf( "ERROR! board detected an initialized, but echo test fails!\n");
   //   return 0;
   //}
   
   return 1;   
}

/* $Revision: 1.1 $ */
//===========================================================================
//
// NAME:    pdl_dio.c: 
//
// DESCRIPTION:
//
//          PowerDAQ QNX driver interface to Digital I/O FW functions
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
//


////////////////////////////////////////////////////////////////////////
//   
// DIGITAL INPUT/OUTPUT SECTION
//
////////////////////////////////////////////////////////////////////////

//      
//       NAME:  pd_din_set_config
//
//   FUNCTION:  Sets the configuration of the digital input subsystem.  Duh.
//
//  ARGUMENTS:  The board to configure, and the config word.
//
//    RETURNS:  1 if it worked, 0 if it failed.
//
int pd_din_set_config(int board, u32 config) {
   pd_dsp_command(board, PD_DICFG);
   if (pd_dsp_read(board) != 1) {
      return 0;
   }
   pd_dsp_write(board, config);
   return (pd_dsp_read(board) == 1) ? 1 : 0;
}

//
//       NAME:  pd_din_set_event_config()
//
//   FUNCTION:  Set DIn Event Mask bits to enable/disable individual
//              digital input line change of state events.
//
//  ARGUMENTS:  The board to configure, and the din event configuration word.
//
//    RETURNS:  1 if it worked and 0 if it failed.
//
int pd_din_set_event(int board, u32 events) 
{
    return pd_dsp_cmd_write_ack(board, PD_BRDSETEVNTS1, events);
}

//
//       NAME:  pd_din_clear_events()
//
//   FUNCTION:  Clears the DIn Event bits.
//
//  ARGUMENTS:  The board to clear, and the "DInEvent Clear Word", whatever
//              that is.
//
//    RETURNS:  1 if it worked and 0 if it failed.
//
int pd_din_clear_events(int board, u32 events) 
{
    return pd_dsp_cmd_write_ack(board, PD_BRDSETEVNTS1, events);
}

//
//       NAME:  pd_din_read_inputs()
//
//   FUNCTION:  Reads the current values on the digital input lines.
//
//  ARGUMENTS:  The board to read from, and a pointer to a u32 to hold the
//              values (in the bottom 8 bits).
//
//    RETURNS:  1 if it worked, 0 if it failed.
//
int pd_din_read_inputs(int board, u32 *pdwValue) 
{
   pd_dsp_command(board, PD_DIREAD);          
   *pdwValue = pd_dsp_read(board);
   if (*pdwValue == ERR_RET) {
      return 0;
   }
   return 1;
}

//
//       NAME:  pd_din_clear_data()
//
//   FUNCTION:  Clears all stored DIn data.
//
//  ARGUMENTS:  The board to clear.
//
//    RETURNS:  1 if it worked, 0 if it failed.
//
int pd_din_clear_data(int board)
{
   pd_dsp_command(board, PD_DICLRDATA);       
   return (pd_dsp_read(board) == 1) ? 1 : 0;
}

//
//       NAME:  pd_din_reset()
//
//   FUNCTION:  Resets the digital input subsystem to the default startup
//              configuration.
//
//  ARGUMENTS:  The board to reset.
//
//    RETURNS:  1 if it worked and 0 if it failed.
//
int pd_din_reset(int board) 
{
   pd_dsp_command(board, PD_DIRESET);   
   return (pd_dsp_read(board) == 1) ? 1 : 0;
}

//      
//       NAME:  pd_din_status()
//
//   FUNCTION:  Gets the current digital input levels and the currently
//              latched input change events of all the digital input lines.
//
//  ARGUMENTS:  The board to read from, and a pointer to where to put the
//              digital input status word.
//
//    RETURNS:  1 if it worked and 0 if it failed.
//
int pd_din_status(int board, u32 *pdwValue) 
{
   pd_dsp_command(board, PD_DISTATUS); 
   *pdwValue = pd_dsp_read(board);
   if (*pdwValue == ERR_RET) {
      return 0;
   }
   return 1;
}

//  
//       NAME:  pd_dout_write_outputs()
//
//   FUNCTION:  Sets the values of the digital output lines.
//
//  ARGUMENTS:  The value to write to the digital output lines.
//
//    RETURNS:  1 if it worked, 0 if it failed.
//
int pd_dout_write_outputs(int board, uint32_t val) 
{
   pd_dsp_command(board, PD_DOWRITE);         
   if (pd_dsp_read(board) != 1) {
      return 0;
   }
   pd_dsp_write(board, val);
   return (pd_dsp_read(board) == 1) ? 1 : 0;
}


//  
//       NAME:  pd_dio256_write_output()
//
//   FUNCTION:  Sets the values of the digital output lines
//
//  ARGUMENTS:  Command word and value to write to the digital output lines
//
//    RETURNS:  1 if it worked, 0 if it failed
//
int pd_dio256_write_output(int board, uint32_t cmd, uint32_t val)
{
    int ret;

    // Send write command receive acknoledge
    ret = pd_dsp_cmd_ret_ack(board, PD_DI0256WR);
    if (ret != 1) return 0;

    // Write command
    pd_dsp_write(board, cmd);

    // Write parameter and rcv ack
    ret = pd_dsp_write_ack(board, val);
    return (ret)?1:0;
}

//  
//       NAME:  pd_dio256_read_input()
//
//   FUNCTION:  Sets the values of the digital output lines
//
//  ARGUMENTS:  Command word and value read from the digital input lines
//
//    RETURNS:  1 if it worked, 0 if it failed
//
int pd_dio256_read_input(int board, uint32_t cmd, uint32_t* val)
{
    int ret;

    // Send write command receive acknoledge
    ret = pd_dsp_cmd_ret_ack(board, PD_DI0256RD);
    if (ret != 1) return 0;

    // Write command
    pd_dsp_write(board, cmd);

    // read value from the board
    *val = pd_dsp_read(board);

    return ret;
}

// -------------------------------------------------------------------------- 
//       NAME:  pd_din_read()
//
//   FUNCTION:  Reads current value on the 16-bit digital input
//
//  ARGUMENTS:  board number
//
//    RETURNS:  number of bytes read (4)
//
size_t pd_din_read(int board, char* buffer, size_t count)
{
    u32 res, dwValue;
    int i;

    if (count & 1) {
        count ^= 1;
        //printf_T("rounding read count down to %d\n", count);
    }

    for (i = 0; i < count; i += 2) {
	res = pd_din_read_inputs(board, &dwValue);
	if (res)
	{
	    *(u16*)buffer = dwValue;
	    buffer += 2;
	} else {
	    return i;
	}
    }

    return i;
}

//  
//       NAME:  pd_dout_write()
//
//   FUNCTION:  Writes current value into the 16-bit digital input
//
//  ARGUMENTS:  board number
//
//    RETURNS:  number of bytes actually written (4)
//
size_t pd_dout_write(int board, const char* buffer, size_t count)
{
    u32 res;
    uint16_t val;
    int i;

    for (i = 0; (i + 1) < count; i += 2) {
#ifndef _NO_USERSPACE    
	__get_user(val, (uint16_t*)(buffer+i));
#else
    val = *(buffer + i);
#endif
	res = pd_dout_write_outputs(board, val);
	if (!res) {
	    break;
	}
    }

    return i;
}



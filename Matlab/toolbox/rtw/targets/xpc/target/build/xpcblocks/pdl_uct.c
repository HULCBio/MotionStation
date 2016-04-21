/* $Revision: 1.1 $ */
//===========================================================================
//
// NAME:    pdl_uct.c: 
//
// DESCRIPTION:
//
//          PowerDAQ QNX driver interface to Counter-Timer FW functions
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

                    
////////////////////////////////////////////////////////////////////////
//   
// USER COUNTER-TIMER SECTION
//
////////////////////////////////////////////////////////////////////////

//
// Function:    int pd_uct_set_config(int board, u32 config)
//
// Parameters:  int board
//              u32 dwUctCfg  -- UCT configuration word
//
// Returns:     1 = SUCCESS
//
// Description: The set User Counter/Timer configuration command sets the
//              clock and gate for the specified user counter/timer.
//
// Notes: 
//
int pd_uct_set_config(int board, u32 config)
{
    // Issue PD_UCTCFG with param and check acknowledge.
    return pd_dsp_cmd_write_ack(board, PD_UCTCFG, config);         
}

//
// Function:    int pd_uct_set_event(int board, u32 events)
//
// Parameters:  int board
//              u32 events  -- UCT event configuration word
//
// Returns:     1 = SUCCESS
//
// Description: Set selected Uct Mask bits enabling/disabling
//              individual UCT output change of state events.
//
// Notes:       * This command is now handled by PD_BRDSETEVNTS1 *
//
int pd_uct_set_event(int board, u32 events)
{
    // Issue PD_UCTEVENTSET with param and check acknowledge.
    return pd_dsp_cmd_write_ack(board, PD_BRDSETEVNTS1, events);
}

//
// Function:    int pd_uct_clear_event(int board, u32 events)
//
// Parameters:  int board
//              u32 events  -- UCT event configuration word
//
// Returns:     1 = SUCCESS
//
// Description: Set selected Uct Mask bits enabling/disabling
//              individual UCT output change of state events.
//
// Notes:       * This command is now handled by PD_BRDSETEVNTS1 *
//
int pd_uct_clear_event(int board, u32 events)
{
    // Issue PD_UCTEVENTSET with param and check acknowledge.
    return pd_dsp_cmd_write_ack(board, PD_BRDSETEVNTS1, events);
}

//
// Function:    int pd_uct_get_status(int board, u32* status)
//
// Parameters:  int board
//              u32* status  -- UCT status word
//
// Returns:     1 = SUCCESS
//
// Description: The UCT status command obtains the output levels and
//              latched event bits that signaled an event of the three
//              user counter/timers (0, 1, 2).
//
//              UctStatus format:
//
//                  $000 00xx
//
//                      bbb bbb
//                       |   |__UCTxOut
//                       |_____UCTxIntrSC
// Notes:
//
int pd_uct_get_status(int board, u32* status)
{
    // Issue PD_UCTSTATUS command and get return value.
    *status = pd_dsp_cmd_ret_value(board, PD_UCTSTATUS);

    if ( *status > 0x8000 )
        return 0;
    return 1;
}

//
// Function:    int pd_uct_write(int board, u32 value)
//
// Parameters:  int board
//              u32 value  -- value to write to UCT
//
// Returns:     1 = SUCCESS
//
// Description: The UCT Write command writes two or three bytes to the
//              specified user counter/timer registers.
//
// Notes: 
//
int pd_uct_write(int board, u32 value)
{
    // Issue PD_UCTWRITE with param and check acknowledge.
    return pd_dsp_cmd_write_ack(board, PD_UCTWRITE, value);
}

//
// Function:    int pd_uct_read(int board, u32 config, u32* value)
//
// Parameters:  int board
//              u32 config  -- UCT Read format word
//              u32* value   -- UCT Word to store word read
//
// Returns:     1 = SUCCESS
//
// Description: The UCT Read command reads 0, 1, 2, or 3 bytes from the
//              specified user counter/timer registers.
//
// Notes:  
//
int pd_uct_read(int board, u32 config, u32* value)
{

    // Issue PD_UCTREAD command and check ack.
    if (!pd_dsp_cmd_ret_ack(board, PD_UCTREAD)) return 0;
    pd_dsp_write(board, config); // write read config word
    *value = pd_dsp_read(board);  // read data word

    return 1;
}

//
// Function:    int pd_uct_set_sw_gate(int board, u32 gate)
//
// Parameters:  int board
//              u32 gate_level  -- gate levels to set for each
//                                 counter/timer
//
// Returns:     1 = SUCCESS
//
// Description: The SW UCT gate setting command sets the UCT gate input
//              levels of the specified User Counter/Timers, thus enabling
//              or disabling counting by software command.
//
// Notes:
//
int pd_uct_set_sw_gate(int board, u32 gate_level)
{
    // Issue PD_UCTSWGATE with param and check acknowledge.
    return pd_dsp_cmd_write_ack(board, PD_UCTSWGATE, gate_level);    
}

//
// Function:    int pd_uct_sw_strobe(int board)
//
// Parameters:  int board
//
// Returns:     1 = SUCCESS
//
// Description: The SW UCT clock strobe command strobes the UCT clock
//              input of all User Counter/Timers that are configured for
//              the SW Command Clock Strobe.
//
// Notes:
//
int pd_uct_sw_strobe(int board)
{
    // Issue PD_UCTSWCLK command and check ack.
    return pd_dsp_cmd_ret_ack(board, PD_UCTSWCLK);
}

//
// Function:    int pd_uct_reset(int board)
//
// Parameters:  int board
//
// Returns:     1 = SUCCESS
//
// Description: The reset UCT command resets the UCT subsystem to the
//              default startup configuration.  All operations in progress
//              are stopped and all configurations are cleared.
//
// Notes:
//
int pd_uct_reset(int board)
{
    // Issue PD_UCTRESET command and check ack.
    return pd_dsp_cmd_ret_ack(board, PD_UCTRESET);
}


// end of pdl_uct.c

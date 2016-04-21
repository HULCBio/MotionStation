/* $Revision: 1.1.6.1 $ */
//===========================================================================
//
// NAME:    pdl_if.h
//
// DESCRIPTION:
//
//          PowerDAQ QNX driver firmware interface definition
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

#ifndef __PDL_IF_H__
#define __PDL_IF_H__

#define FW_MAXSEGSIZE 2048

typedef struct {
    DWORD dwMemType;
    DWORD dwMemAdrs;
    DWORD dwMemSize;
    DWORD dwMemData[FW_MAXSEGSIZE];
    } FW_MEMSEGMENT;

void pd_main();

// Start dealing with boards
extern int pd_find_devices(void);

// Cleanup boards after use
extern int pd_clean_devices(void);

// Get board capabilities
extern int pd_get_adapter_info(int board, Adapter_Info* pAdInfo)
;

// pdl_fwi.c
extern u32 pd_dsp_get_status(int board);
extern u32 pd_dsp_get_flags(int board);
extern void pd_dsp_set_flags(int board, u32 new_flags);
extern void pd_dsp_command(int board, int command);
extern void pd_dsp_cmd_no_ret(int board, u16 command);
extern void pd_dsp_write(int board, u32 data);
extern u32 pd_dsp_read(int board);
extern u32 pd_dsp_cmd_ret_ack(int board, u16 wCmd);
extern u32 pd_dsp_cmd_ret_value(int board, u16 wCmd);
extern u32 pd_dsp_read_ack(int board);
extern u32 pd_dsp_write_ack(int board, u32 dwValue);
extern u32 pd_dsp_cmd_write_ack(int board, u16 wCmd, u32 dwValue);
extern u32 pd_dsp_int_status(int board);
extern u32 pd_dsp_acknowledge_interrupt(int board);
extern int pd_dsp_startup(int board);
extern void  pd_init_calibration(int board);
extern int pd_reset_dsp(int board);
extern int pd_download_firmware_bootstrap(int board);
extern int pd_reset_board(int board);
extern int pd_download_firmware(int board);
extern int pd_echo_test(int board);

// pdl_ain.c
extern int pd_ain_set_config(int, u32, u32, u32);
extern int pd_ain_set_cv_clock(int board, u32 clock_divisor);
extern int pd_ain_set_cl_clock(int board, u32 clock_divisor);
extern int pd_ain_set_channel_list(int board, u32 num_entries, u32 list[]);
extern int pd_ain_set_events (int board, u32 dwEvents);
extern int pd_ain_get_status(int board, u32* status);
extern int pd_ain_sw_start_trigger(int board);
extern int pd_ain_sw_stop_trigger(int board);
extern int pd_ain_set_enable_conversion(int board, int enable);
extern int pd_ain_get_value(int board, u16* value);
extern int pd_ain_set_ssh_gain(int board, u32 dwCfg);
extern int pd_ain_get_samples(int board, int max_samples, uint16_t buffer[]);
extern int pd_ain_reset(int board);
extern int pd_ain_sw_cl_start(int board);
extern int pd_ain_sw_cv_start(int board);
extern int pd_ain_reset_cl(int board);
extern int pd_ain_clear_data(int board);
extern int pd_ain_flush_fifo(int board);
extern int pd_ain_get_xfer_samples(int board, int samples, uint16_t* buffer);
extern int pd_ain_set_xfer_size(int board, u32 size);


// pdl_aio.c
int pd_register_daq_buffer(int board, u32 ScanSize, u32 FrameSize, u32 NumFrames,
                           uint16_t* databuf, int bWrap, int bRecycle);
int pd_unregister_daq_buffer(int board);                           
int pd_clear_daq_buffer(int board, int subsystem);
int pd_ain_async_init(int board, PTAinAsyncCfg pAInCfg);
int pd_ain_async_term(int board);
int pd_ain_async_start(int board);
int pd_ain_async_stop(int board);
int pd_ain_get_scans(int board, PTScan_Info pScanInfo);
int pd_get_buf_status(int board, int subsystem, PTBuf_Info pDaqBuf);

// pdl_ao.c
int pd_aout_set_config(int board, u32 config, u32 posttrig);
int pd_aout_set_cv_clk(int board, u32 dwClkDiv);
int pd_aout_set_events(int board, u32 dwEvents);
int pd_aout_get_status(int board, u32* dwStatus);
int pd_aout_set_enable_conversion(int board, u32 dwEnable);
int pd_aout_sw_start_trigger(int board);
int pd_aout_sw_stop_trigger(int board);
int pd_aout_sw_cv_start(int board);
int pd_aout_clear_data(int board);
int pd_aout_reset(int board);
int pd_aout_put_value(int board, u32 dwValue);
int pd_aout_put_block(int board, u32 dwNumValues, u32* pdwBuf, u32* pdwCount);
       
int pd_aout_write_scan(
   int board,
   const char *buffer,
   int count);  // function for write() from aout
   
// pdl_dio.c
int pd_din_set_config(int board, u32 config);
int pd_din_set_event(int board, u32 events);
int pd_din_clear_events(int board, u32 events);
int pd_din_read_inputs(int board, u32 *pdwValue);
int pd_din_clear_data(int board);
int pd_din_reset(int board);
int pd_din_status(int board, u32 *pdwValue);
int pd_dout_write_outputs(int board, uint32_t val);
int pd_dio256_write_output(int board, uint32_t cmd, uint32_t val);
int pd_dio256_read_input(int board, uint32_t cmd, uint32_t* val);

int pd_din_read(int board, char* buffer, int count);
int pd_dout_write(int board, const char* buffer, int count);

// pdl_uct.c
int pd_uct_set_config(int board, u32 config);
int pd_uct_set_event(int board, u32 events);
int pd_uct_clear_event(int board, u32 events);
int pd_uct_get_status(int board, u32* status);
int pd_uct_write(int board, u32 value);
int pd_uct_read(int board, u32 config, u32* value);
int pd_uct_set_sw_gate(int board, u32 gate_level);
int pd_uct_sw_strobe(int board);
int pd_uct_reset(int board);

// pdl_event.c
int pd_enable_events(int board, PTEvents pEvents);
int pd_disable_events(int board, PTEvents pEvents);
int pd_set_user_events(int board, u32 subsystem, u32 events);
int pd_clear_user_events(int board, u32 subsystem, u32 events);
int pd_get_user_events(int board, u32 subsystem, u32* events);
int pd_immediate_update(int board);
void pd_debug_show_events (TEvents *Event, char* msg);

// pdl_brd.c
int pd_adapter_enable_interrupt(int board, u32 val);
int pd_adapter_acknowledge_interrupt(int board);
int pd_adapter_get_board_status(int board, PTEvents pEvent);
int pd_adapter_set_board_event1(int board, u32 dwEvents);
int pd_adapter_set_board_event2(int board, u32 dwEvents);
int pd_adapter_eeprom_read(int board, u32 dwMaxSize, uint16_t *pwReadBuf);
int pd_adapter_eeprom_write(int board, u32 dwBufSize, u16* pwWriteBuf);
int pd_cal_dac_write(int board, u32 dwCalDACValue);
int pd_adapter_test_interrupt(int board);

// pdl_int.c
void pd_stop_and_disable_ain(int board);
void pd_process_pd_ain_get_samples(int board, int bFHFState);
void pd_process_driver_events(int board, PTEvents pEvents);
int pd_notify_user_events(int board, PTEvents pNewFwEvents);
void pd_process_events(int board);

// pdl_init.c
void  pd_init_pd_board(int board);


#endif // _PDL_IF_H
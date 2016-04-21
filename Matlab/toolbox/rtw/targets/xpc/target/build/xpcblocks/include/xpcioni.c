/* $Revision: 1.15.4.1 $ */

/* Abstract: NI PCI-E functions
 *
 *  Copyright 1996-2003 The MathWorks, Inc.
 *
 */


#include "time_xpcimport.h"

static void DAQ_STC_Windowed_Mode_Write(volatile unsigned short *ioaddress,
                                        unsigned short uRegister_Address,
                                        unsigned short uData)
{
    ioaddress[0]=uRegister_Address;
    ioaddress[1]=uData;
}

static
unsigned short DAQ_STC_Windowed_Mode_Read(volatile unsigned short *ioaddress,
                                          unsigned short uRegister_Address)
{
    ioaddress[0]=uRegister_Address;
    return(ioaddress[1]);
}

static void Board_Write(volatile unsigned short *ioaddress, unsigned short uRegister_Address, unsigned short uData)
{
    ioaddress[uRegister_Address/2]=uData;
}


static unsigned short Board_Read(volatile unsigned short *ioaddress, unsigned short uRegister_Address)
{
    return(ioaddress[uRegister_Address/2]);
}


// *******************************************************************************************
// Analog Input

/*
 * Call this function to configure the timebase options.
 */

static void  AI_MSC_Clock_Configure(volatile unsigned short *ioaddress)
{
    /*
     * Writing to register Clock_and_FOUT_Register with address 56.
     *    Slow_Internal_Timebase <= p->msc_slow_int_tb_enable (1)
     *    Slow_Internal_Time_Divide_By_2 <= p->msc_slow_int_tb_divide_by_2 (1)
     *    Clock_To_Board <= p->msc_clock_to_board_enable (1)
     *    Clock_To_Board_Divide_By_2 <= p->msc_clock_to_board_divide_by_2 (1)
     * New pattern = 0x1B00
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, Clock_and_FOUT_Register,0x1B00);
    return;
}

/*
 * Call this function to access the first value in the configuration
 * FIFO.
 */

static void  AI_Initialize_Configuration_Memory_Output(volatile unsigned short *ioaddress)
{
    /*
     * Writing to register AI_Command_1_Register with address 8.
     *    AI_CONVERT_Pulse <= 1
     * New pattern = 0x0001
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, AI_Command_1_Register,0x0001);
    return;
}

/*
 * Call this function to stop any activities in progress.
 */

static void  AI_Reset_All(volatile unsigned short *ioaddress)
{
    /*
     * Writing to register Joint_Reset_Register with address 72.
     *    AI_Reset <= 1
     * New pattern = 0x0001
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, Joint_Reset_Register,0x0001);

    /*
     * Writing to register Joint_Reset_Register with address 72.
     *    AI_Configuration_Start <= 1
     * New pattern = 0x0010
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, Joint_Reset_Register,0x0010);

    /*
     * Writing to register Interrupt_A_Ack_Register with address 2.
     *    AI_SC_TC_Error_Confirm <= 1
     *    AI_SC_TC_Interrupt_Ack <= 1
     *    AI_START1_Interrupt_Ack <= 1
     *    AI_START2_Interrupt_Ack <= 1
     *    AI_START_Interrupt_Ack <= 1
     *    AI_STOP_Interrupt_Ack <= 1
     *    AI_Error_Interrupt_Ack <= 1
     * New pattern = 0x3F80
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, Interrupt_A_Ack_Register,0x3F80);

    /*
     * Writing to register AI_Command_1_Register with address 8.
     *    AI_Command_1_Register <= 0
     * New pattern = 0x0000
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, AI_Command_1_Register,0x0000);

    /*
     * Writing to register AI_Mode_1_Register with address 12.
     *    Reserved_One <= 1
     *    AI_Start_Stop <= 1
     * New pattern = 0x000C
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, AI_Mode_1_Register,0x000C);

    /*
     * Writing to register Joint_Reset_Register with address 72.
     *    AI_Configuration_Start <= 0
     *    AI_Configuration_End <= 1
     * New pattern = 0x0100
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, Joint_Reset_Register,0x0100);
    return;
}

/*
 * Call this function to setup the E-2.
 */

static void  AI_Board_Personalize(volatile unsigned short *ioaddress)
{
    /*
     * Writing to register Joint_Reset_Register with address 72.
     *    AI_Configuration_Start <= 1
     * New pattern = 0x0010
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, Joint_Reset_Register,0x0010);

    /*
     * Writing to register Clock_and_FOUT_Register with address 56.
     *    AI_Source_Divide_By_2 <= p->ai_source_divide_by_2 (0)
     *    AI_Output_Divide_By_2 <= p->ai_output_divide_by_2 (1)
     * New pattern = 0x1B80
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, Clock_and_FOUT_Register,0x1B80);

    /*
     * Writing to register AI_Personal_Register with address 77.
     *    AI_CONVERT_Pulse_Timebase <= p->ai_convert_pulse_timebase (0)
     *    AI_CONVERT_Pulse_Width <= p->ai_convert_pulse_width (1)
     *    AI_FIFO_Flags_Polarity <= p->ai_fifo_flags_polarity (0)
     *    AI_LOCALMUX_CLK_Pulse_Width <= p->ai_localmux_clk_pulse_width (1)
     *    AI_AIFREQ_Polarity <= p->ai_aifreq_polarity (0)
     *    AI_SHIFTIN_Polarity <= p->ai_shiftin_polarity (0)
     *    AI_SHIFTIN_Pulse_Width <= p->ai_shiftin_pulse_width (1)
     *    AI_EOC_Polarity <= p->ai_eoc_polarity (0)
     *    AI_SOC_Polarity <= p->ai_soc_polarity (1)
     *    AI_Overrun_Mode <= p->ai_overrun_mode (1)
     * New pattern = 0xA4A0
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, AI_Personal_Register,0xA4A0);

    /*
     * Writing to register AI_Output_Control_Register with address 60.
     *    AI_CONVERT_Output_Select <= p->ai_convert_output_select (2)
     *    AI_SC_TC_Output_Select <= p->ai_sc_tc_output_select (3)
     *    AI_SCAN_IN_PROG_Output_Select <= p->ai_scan_in_prog_output_select (3)
     *    AI_LOCALMUX_CLK_Output_Select <= p->ai_localmux_clk_output_select (2)
     * New pattern = 0x032E
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, AI_Output_Control_Register,0x032E);

    /*
     * Writing to register Joint_Reset_Register with address 72.
     *    AI_Configuration_Start <= 0
     *    AI_Configuration_End <= 1
     * New pattern = 0x0100
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, Joint_Reset_Register,0x0100);
    return;
}

/*
 * Call this function to setup for external hardware.
 */

static void  AI_Board_Environmentalize(volatile unsigned short *ioaddress)
{
    /*
     * Writing to register Joint_Reset_Register with address 72.
     *    AI_Configuration_Start <= 1
     * New pattern = 0x0010
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, Joint_Reset_Register,0x0010);

    /*
     * Writing to register AI_Mode_2_Register with address 13.
     *    AI_External_MUX_Present <= 0
     * New pattern = 0x0000
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, AI_Mode_2_Register,0x0000);

    /*
     * Writing to register AI_Output_Control_Register with address 60.
     *    AI_EXTMUX_CLK_Output_Select <= p->ai_extmux_clk_output_select (0)
     * New pattern = 0x032E
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, AI_Output_Control_Register,0x032E);

    /*
     * Writing to register Joint_Reset_Register with address 72.
     *    AI_Configuration_Start <= 0
     *    AI_Configuration_End <= 1
     * New pattern = 0x0100
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, Joint_Reset_Register,0x0100);
    return;
}

/*
 * Call this fuction to configure the FIFO condition for which
 * interrupts and DMA requests will be generated.
 */

static void  AI_FIFO_Request(volatile unsigned short *ioaddress)
{
    return;
}

/*
 * Call this function to enable and disable gating.
 */

static void  AI_Hardware_Gating(volatile unsigned short *ioaddress)
{
    return;
}

/*
 * Call this function to enable or disable retriggering.
 */

static void  AI_Trigger_Signals(volatile unsigned short *ioaddress)
{
    /*
     * Writing to register Joint_Reset_Register with address 72.
     *    AI_Configuration_Start <= 1
     * New pattern = 0x0010
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, Joint_Reset_Register,0x0010);

    /*
     * Writing to register AI_Mode_1_Register with address 12.
     *    AI_Trigger_Once <= 0
     * New pattern = 0x000D
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, AI_Mode_1_Register,0x000C);

    /*
     * Writing to register AI_Trigger_Select_Register with address 63.
     *    AI_START1_Select <= 0
     *    AI_START1_Polarity <= 0
     *    AI_START1_Edge <= 1
     *    AI_START1_Sync <= 1
     * New pattern = 0x0060
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, AI_Trigger_Select_Register,0x0060);

    /*
     * Writing to register Joint_Reset_Register with address 72.
     *    AI_Configuration_Start <= 0
     *    AI_Configuration_End <= 1
     * New pattern = 0x0100
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, Joint_Reset_Register,0x0100);
    return;
}

/*
 * Call this function to select the number of scans.
 */

static void  AI_Number_of_Scans(volatile unsigned short *ioaddress)
{
    /*
     * Writing to register Joint_Reset_Register with address 72.
     *    AI_Configuration_Start <= 1
     * New pattern = 0x0010
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, Joint_Reset_Register,0x0010);

    /*
     * Writing to register AI_SC_Load_A_Registers with address 18.
     *    AI_SC_Load_A <= p->ai_number_of_posttrigger_scans-1 (1)
     * New pattern = 0x00000000
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, AI_SC_Load_A_Registers,0x0000);
    DAQ_STC_Windowed_Mode_Write(ioaddress, AI_SC_Load_A_Registers+1,0x0000);

    /*
     * Writing to register AI_Command_1_Register with address 8.
     *    AI_SC_Load <= 1
     * New pattern = 0x0020
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, AI_Command_1_Register,0x0020);

    /*
     * Writing to register Joint_Reset_Register with address 72.
     *    AI_Configuration_Start <= 0
     *    AI_Configuration_End <= 1
     * New pattern = 0x0100
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, Joint_Reset_Register,0x0100);
    return;
}

/*
 * Call this function to select the scan start event.
 */


static void  AI_Scan_Start(volatile unsigned short *ioaddress)
{
    /*
     * Writing to register Joint_Reset_Register with address 72.
     *    AI_Configuration_Start <= 1
     * New pattern = 0x0010
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, Joint_Reset_Register,0x0010);

    /*
     * Writing to register AI_START_STOP_Select_Register with address 62.
     *    AI_START_Select <= 31
     *    AI_START_Edge <= 1
     *    AI_START_Sync <= 1
     *    AI_START_Polarity <= 0
     * New pattern = 0x007F
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, AI_START_STOP_Select_Register,0x007f);

    /*
     * Writing to register Joint_Reset_Register with address 72.
     *    AI_Configuration_Start <= 0
     *    AI_Configuration_End <= 1
     * New pattern = 0x0100
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, Joint_Reset_Register,0x0100);
    return;
}


/*
 * Call this function to select the end of scan event.
 */


static void  AI_End_of_Scan(volatile unsigned short *ioaddress)
{
    /*
     * Writing to register Joint_Reset_Register with address 72.
     *    AI_Configuration_Start <= 1
     * New pattern = 0x0010
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, Joint_Reset_Register,0x0010);

    /*
     * Writing to register AI_START_STOP_Select_Register with address 62.
     *    AI_STOP_Select <= p->ai_stop_select (19)
     *    AI_STOP_Edge <= 0
     *    AI_STOP_Polarity <= p->ai_stop_polarity (0)
     *    AI_STOP_Sync <= 1
     * New pattern = 0x29FF
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, AI_START_STOP_Select_Register,0x29FF);

    /*
     * Writing to register Joint_Reset_Register with address 72.
     *    AI_Configuration_Start <= 0
     *    AI_Configuration_End <= 1
     * New pattern = 0x0100
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, Joint_Reset_Register,0x0100);
    return;
}


/*
 * Call this function to select the convert signal.
 */

static void  AI_Convert_Signal(volatile unsigned short *ioaddress, int speed)
{
    /*
     * Writing to register Joint_Reset_Register with address 72.
     *    AI_Configuration_Start <= 1
     * New pattern = 0x0010
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, Joint_Reset_Register,0x0010);

    /*
     * Writing to register AI_SI2_Load_A_Register with address 23.
     *    AI_SI2_Load_A <= p->ai_si2_special_ticks-1 (1)
     * New pattern = 0x07CF
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, AI_SI2_Load_A_Register,0x0001);


    /*
     * Writing to register AI_SI2_Load_B_Register with address 25.
     *    AI_SI2_Load_B <= p->ai_si2_ordinary_ticks-1 (f)
     * New pattern = 0x07CF
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, AI_SI2_Load_B_Register,(unsigned short)speed);



    /*
     * Writing to register AI_Mode_2_Register with address 13.
     *    AI_SI2_Reload_Mode <= 1
     * New pattern = 0x0100
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, AI_Mode_2_Register,0x0100);

    /*
     * Writing to register AI_Command_1_Register with address 8.
     *    AI_SI2_Load <= 1
     * New pattern = 0x0800
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, AI_Command_1_Register,0x0800);

    /*
     * Writing to register AI_Mode_2_Register with address 13.
     *    AI_SI2_Initial_Load_Source <= 1
     * New pattern = 0x0300
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, AI_Mode_2_Register,0x0300);

    /*
     * Writing to register Joint_Reset_Register with address 72.
     *    AI_Configuration_Start <= 0
     *    AI_Configuration_End <= 1
     * New pattern = 0x0100
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, Joint_Reset_Register,0x0100);
    return;
}

/*
 * Call this function to clear the AI FIFO.
 */

static void  AI_Clear_FIFO(volatile unsigned short *ioaddress)
{
    /*
     * Writing to register Write_Strobe_1_Register with address 83.
     *    Write_Strobe_1 <= 1
     * New pattern = 0x0001
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, Write_Strobe_1_Register,0x0001);
    return;
}

/*
 * Call this function to enable interrupts.
 */

static void  AI_Interrupt_Enable(volatile unsigned short *ioaddress)
{
    return;
}

/*
 * Call this function to arm the analog input counters.
 */

static void  AI_Arming(volatile unsigned short *ioaddress)
{
    /*
     * Writing to register AI_Command_1_Register with address 8.
     *    AI_SC_Arm <= 1
     *    AI_SI_Arm <= arm_si (1)
     *    AI_SI2_Arm <= arm_si2 (1)
     *    AI_DIV_Arm <= arm_div (1)
     * New pattern = 0x1540
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, AI_Command_1_Register,0x1540);
    return;
}

/*
 * Call this function to start the acquistion.
 */


static void  AI_Start_The_Acquisition(volatile unsigned short *ioaddress)
{
    /*
     * Writing to register AI_Command_2_Register with address 4.
     *    AI_START1_Pulse <= 1
     * New pattern = 0x0001
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, AI_Command_2_Register,0x0001);

    DAQ_STC_Windowed_Mode_Write(ioaddress, AI_START_STOP_Select_Register,0xa9FF);
    DAQ_STC_Windowed_Mode_Write(ioaddress, AI_START_STOP_Select_Register,0x29FF);

    return;
}

// *****************************************************************************************
// Analog Output

static void AO_Reset_All(volatile unsigned short *ioaddress)
{

    /*
     * Writing to register Joint_Reset_Register with address 72.
     *    AO_Configuration_Start <= 1
     * New pattern = 0x0020
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, Joint_Reset_Register,0x0020);

    /*
     * Writing to register AO_Command_1_Register with address 9.
     *    AO_Disarm <= 1
     * New pattern = 0x2000
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, AO_Command_1_Register,0x2000);

    /*
     * Writing to register Interrupt_B_Enable_Register with address 75.
     *    AO_BC_TC_Interrupt_Enable <= 0
     *    AO_START1_Interrupt_Enable <= 0
     *    AO_UPDATE_Interrupt_Enable <= 0
     *    AO_START_Interrupt_Enable <= 0
     *    AO_STOP_Interrupt_Enable <= 0
     *    AO_Error_Interrupt_Enable <= 0
     *    AO_UC_TC_Interrupt_Enable <= 0
     *    AO_FIFO_Interrupt_Enable <= 0
     * New pattern = 0x0000
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, Interrupt_B_Enable_Register,0x0000);

    /*
     * Writing to register AO_Personal_Register with address 78.
     *    AO_BC_Source_Select <= 1
     * New pattern = 0x0010
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, AO_Personal_Register,0x0010);

    /*
     * Writing to register Interrupt_B_Ack_Register with address 3.
     *    AO_BC_TC_Trigger_Error_Confirm <= 1
     *    AO_BC_TC_Error_Confirm <= 1
     *    AO_UC_TC_Interrupt_Ack <= 1
     *    AO_BC_TC_Interrupt_Ack <= 1
     *    AO_START1_Interrupt_Ack <= 1
     *    AO_UPDATE_Interrupt_Ack <= 1
     *    AO_START_Interrupt_Ack <= 1
     *    AO_STOP_Interrupt_Ack <= 1
     *    AO_Error_Interrupt_Ack <= 1
     * New pattern = 0x3F98
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, Interrupt_B_Ack_Register,0x3F98);

    /*
     * Writing to register Joint_Reset_Register with address 72.
     *    AO_Configuration_Start <= 0
     *    AO_Configuration_End <= 1
     * New pattern = 0x0200
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, Joint_Reset_Register,0x0200);
}

static void AO_Board_Personalize(volatile unsigned short *ioaddress)
{
    /*
     * Writing to register Joint_Reset_Register with address 72.
     *    AO_Configuration_Start <= 1
     * New pattern = 0x0020
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, Joint_Reset_Register,0x0020);

    /*
     * Writing to register AO_Personal_Register with address 78.
     *    AO_Fast_CPU <= p->ao_fast_cpu (0)
     *    AO_UPDATE_Pulse_Timebase <= p->ao_update_pulse_timebase (0)
     *    AO_UPDATE_Pulse_Width <= p->ao_update_pulse_width (if E4 or E1 0 else 1)
     *    AO_DMA_PIO_Control <= p->ao_dma_pio_control (0)
     *    AO_AOFREQ_Polarity <= p->ao_dafreq_polarity (0)
     *    AO_TMRDACWR_Pulse_Width <= p->ao_tmrdacwr_pulse_width (1)
     *    AO_FIFO_Enable <= p->ao_fifo_enable (1)
     *    AO_FIFO_Flags_Polarity <= p->ao_fifo_flags_polarity (0)
     *    AO_Number_Of_DAC_Packages <= p->ao_number_of_dac_packages (0)
     * New pattern =  0x1410 (for E1 and E4) or 0x1430  (other boards)
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, AO_Personal_Register,0x1410); // for E1 and E4
    // DAQ_STC_Windowed_Mode_Write(ioaddress, AO_Personal_Register,0x1430) ; for other boards


    /*
     * Writing to register Clock_and_FOUT_Register with address 56.
     *    AO_Source_Divide_By_2 <= p->ao_source_divide_by_2 (0)
     *    AO_Output_Divide_By_2 <= p->ao_output_divide_by_2 (1)
     * New pattern = 0x1B20
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, Clock_and_FOUT_Register,0x1B20);

    /*
     * Writing to register AO_Output_Control_Register with address 86.
     *    AO_UPDATE_Output_Select <= p->ao_update_output_select (0)
     * New pattern = 0x0000
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, AO_Output_Control_Register,0x0000);

    /*
     * Writing to register AO_START_Select_Register with address 66.
     *    AO_AOFREQ_Enable <= p->ao_dafreq_enable (0)
     * New pattern = 0x0000
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, AO_START_Select_Register,0x0000);

    /*
     * Writing to register Joint_Reset_Register with address 72.
     *    AO_Configuration_Start <= 0
     *    AO_Configuration_End <= 1
     * New pattern = 0x0200
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, Joint_Reset_Register,0x0200);

}

/*
 * Use this function to set the source and update mode for the LDAC<0..1>
 * signals.
 */

static void AO_LDAC_Source_And_Update_Mode(volatile unsigned short *ioaddress)
{

    /*
     * Writing to register Joint_Reset_Register with address 72.
     *    AO_Configuration_Start <= 1
     * New pattern = 0x0020
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, Joint_Reset_Register,0x0020);

    /*
     * Writing to register AO_Command_1_Register with address 9.
     *    AO_LDAC0_Source_Select <= p->ao_ldac0_source_select (0)
     *    AO_DAC0_Update_Mode <= p->ao_dac0_update_mode (0)
     *    AO_LDAC1_Source_Select <= p->ao_ldac1_source_select (0)
     *    AO_DAC1_Update_Mode <= p->ao_dac1_update_mode (0)
     * New pattern = 0x0014
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, AO_Command_1_Register,0x0000);

    /*
     * Writing to register Joint_Reset_Register with address 72.
     *    AO_Configuration_Start <= 0
     *    AO_Configuration_End <= 1
     * New pattern = 0x0200
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, Joint_Reset_Register,0x0200);

}

static unsigned char readEEPROM(volatile unsigned char * ioaddress8, int address)
{

    double time;
    int pattern, i;
    unsigned char data, value;


    rl32eWaitDouble = (void*) GetProcAddress(GetModuleHandle(NULL), "rl32eWaitDouble");
    if (rl32eWaitDouble==NULL) {
        printf("Error 1\n");
        return -1;
    }

    pattern=0x0300 | (address & 0x00ff) | ((address & 0x0100) << 3) ;

    time=0.00001;

    ioaddress8[0xd]=0x0;
    rl32eWaitDouble(time);

    ioaddress8[0xd]=0x4;
    rl32eWaitDouble(time);

    for (i=0;i<16;i++) {
        data=((pattern >> (15-i)) & 0x1) << 1;
        // clock low & data
        ioaddress8[0xd]=0x4 | data;
        rl32eWaitDouble(time);
        //clock high & data
        ioaddress8[0xd]=0x4 | data | 0x1;
        rl32eWaitDouble(time);
        // clock low & data
        ioaddress8[0xd]=0x4 | data;
        rl32eWaitDouble(time);

    }

    //ioaddress8[0xd]=0x4;
    //rl32eWaitDouble(time);

    value=0;
    for (i=0;i<8;i++) {
        //clock high
        ioaddress8[0xd]=0x4 | 0x1;
        rl32eWaitDouble(time);
        // read value
        value=value | ((ioaddress8[0x1] & 0x1) << (7-i));
        // clock low
        ioaddress8[0xd]=0x4;
        rl32eWaitDouble(time);
    }

    ioaddress8[0xd]=0x0;
    rl32eWaitDouble(time);

    return(value);

}

//MB88341 SerDacLdLine = 0
static void writeCALDAC(volatile unsigned char * ioaddress8, int address, unsigned char value)
{

    double time;
    int i;
    unsigned char data;
    int address1;

    rl32eWaitDouble = (void*) GetProcAddress(GetModuleHandle(NULL), "rl32eWaitDouble");
    if (rl32eWaitDouble==NULL) {
        printf("Error 1\n");
        return;
    }

    time=0.00001;


    ioaddress8[0xd]=0x0;
    rl32eWaitDouble(time);

    address1= (address & 0x1)<<11 | (address & 0x2)<<9 | (address & 0x4)<<7 | (address & 0x8)<<5 | value;

    for (i=0;i<12;i++) {
        data=((address1 >> (11-i)) & 0x1) << 1;
        // clock low & data
        ioaddress8[0xd]= data;
        rl32eWaitDouble(time);
        //clock high & data
        ioaddress8[0xd]= data | 0x1;
        rl32eWaitDouble(time);
    }

    ioaddress8[0xd]=0x8;
    rl32eWaitDouble(time);

    ioaddress8[0xd]=0x0;
    rl32eWaitDouble(time);

}

//MB88341 SerDacLdLine = 1
static void writeCALDAC1(volatile unsigned char * ioaddress8, int address, unsigned char value)
{

    double time;
    int i;
    unsigned char data;
    int address1;

    rl32eWaitDouble = (void*) GetProcAddress(GetModuleHandle(NULL), "rl32eWaitDouble");
    if (rl32eWaitDouble==NULL) {
        printf("Error 1\n");
        return;
    }

    time=0.00001;

    ioaddress8[0xd]=0x0;
    rl32eWaitDouble(time);

    address1= (address & 0x1)<<11 | (address & 0x2)<<9 | (address & 0x4)<<7 | (address & 0x8)<<5 | value;

    for (i=0;i<12;i++) {
        data=((address1 >> (11-i)) & 0x1) << 1;
        // clock low & data
        ioaddress8[0xd]= data;
        rl32eWaitDouble(time);
        //clock high & data
        ioaddress8[0xd]= data | 0x1;
        rl32eWaitDouble(time);
    }

    ioaddress8[0xd]=0x10;
    rl32eWaitDouble(time);

    ioaddress8[0xd]=0x0;
    rl32eWaitDouble(time);

}


//DAC 8800 serDacLdLine = 0
static void writeCALDAC2(volatile unsigned char * ioaddress8, int address, unsigned char value)
{

    double time;
    int i;
    unsigned char data;

    rl32eWaitDouble = (void*) GetProcAddress(GetModuleHandle(NULL), "rl32eWaitDouble");
    if (rl32eWaitDouble==NULL) {
        printf("Error 1\n");
        return;
    }

    time=0.00001;

    ioaddress8[0xd]=0x0;
    rl32eWaitDouble(time);

    for (i=0;i<3;i++) {
        data=((address >> (2-i)) & 0x1) << 1;
        // clock low & data
        ioaddress8[0xd]= data;
        rl32eWaitDouble(time);
        //clock high & data
        ioaddress8[0xd]= data | 0x1;
        rl32eWaitDouble(time);
    }

    for (i=0;i<8;i++) {
        data=((value >> (7-i)) & 0x1) << 1;
        // clock low & data
        ioaddress8[0xd]= data;
        rl32eWaitDouble(time);
        //clock high & data
        ioaddress8[0xd]= data | 0x1;
        rl32eWaitDouble(time);
    }

    ioaddress8[0xd]=0x08;
    rl32eWaitDouble(time);

    ioaddress8[0xd]=0x0;
    rl32eWaitDouble(time);

}

// DAC 8808 on NI-6713, 2 chips
// chip = [0,1] to select DAC0 or DAC1
// address is [0,12] to select one of the 12 DAC's on each chip
static void writeCALDACN(volatile unsigned char * ioaddress8, int chip, int address, unsigned char value)
{
    double time;
    int i;
    unsigned char data;
    int chipselect;

    rl32eWaitDouble = (void*) GetProcAddress(GetModuleHandle(NULL), "rl32eWaitDouble");
    if (rl32eWaitDouble==NULL) {
        printf("Error 1\n");
        return;
    }

    switch( chip )
    {
    case 0:
        chipselect = 0x8;
        break;

    case 1:
        chipselect = 0x10;
        break;
    default:
        printf("Illegal chip select when writing to CAL DAC\n");
        break;
    }

    time=0.00001;

    ioaddress8[0xd] = 0; // chipselect;
    rl32eWaitDouble(time);

    for (i = 0 ; i < 4 ; i++ )
    {
        data=((address >> (3-i)) & 0x1) << 1;
        // clock low & data
        ioaddress8[0xd] = data;
        rl32eWaitDouble(time);
        //clock high & data
        ioaddress8[0xd] = data | 0x1;
        rl32eWaitDouble(time);
    }
    for (i = 0 ; i < 8 ; i++)
    {
        data = ((value >> (7-i)) & 0x1) << 1;
        // clock low & data
        ioaddress8[0xd] = data;
        rl32eWaitDouble(time);
        //clock high & data
        ioaddress8[0xd] = data | 0x1;
        rl32eWaitDouble(time);
    }

    ioaddress8[0xd] = chipselect;  // actually writes to the chip
    rl32eWaitDouble(time);

    ioaddress8[0xd] = 0x0;
    rl32eWaitDouble(time);
}

//DAC 8043 serDacLdLine = 1
static void writeCALDAC3(volatile unsigned char * ioaddress8, short value)
{

    double time;
    int i;
    unsigned char data;

    rl32eWaitDouble = (void*) GetProcAddress(GetModuleHandle(NULL), "rl32eWaitDouble");
    if (rl32eWaitDouble==NULL) {
        printf("Error 1\n");
        return;
    }

    time=0.00001;

    ioaddress8[0xd]=0x0;
    rl32eWaitDouble(time);

    for (i=0;i<12;i++) {
        data=((value >> (11-i)) & 0x1) << 1;
        // clock low & data
        ioaddress8[0xd]= data;
        rl32eWaitDouble(time);
        //clock high & data
        ioaddress8[0xd]= data | 0x1;
        rl32eWaitDouble(time);
    }

    ioaddress8[0xd]= 0x10;
    rl32eWaitDouble(time);

    ioaddress8[0xd]=0x0;
    rl32eWaitDouble(time);

}

/* DAQ-STC Counter/Timer functions */

typedef unsigned short ushort_T;

#define LOAD_A_REG           0
#define LOAD_B_REG           1
#define COMMAND_REG          2
#define MODE_REG             3
#define INPUT_SELECT_REG     4
#define AUTOINCREMENT_REG    5
#define INTERRUPT_ENABLE_REG 6
#define INTERRUPT_ACK_REG    7
#define HW_SAVE_REG          8
#define GATE_STATUS_REG      9

static ushort_T STCRegisters[2][10] = {
    {G0_Load_A_Registers,
     G0_Load_B_Registers,
     G0_Command_Register,
     G0_Mode_Register,
     G0_Input_Select_Register,
     G0_Autoincrement_Register,
     Interrupt_A_Enable_Register,
     Interrupt_A_Ack_Register,
     G0_HW_Save_Registers,
     AI_Status_1_Register
    },
    {G1_Load_A_Registers,
     G1_Load_B_Registers,
     G1_Command_Register,
     G1_Mode_Register,
     G1_Input_Select_Register,
     G1_Autoincrement_Register,
     Interrupt_B_Enable_Register,
     Interrupt_B_Ack_Register,
     G1_HW_Save_Registers,
     AO_Status_1_Register
    }};

#define GI_RESET_MASK        0
#define GPFO_I_OUTPUT_ENABLE 1
#define GI_BANK_ST           2
#define GI_HW_SAVE_ST        3
static ushort_T STCMasks[2][4] = {
    {0x0004,                            /* G0_Reset */
     0x4000,                            /* GPFO_0_Output_Enable */
     0x0001,                            /* G0_Bank_St */
     0x1000                             /* G0_HW_Save_St */
    },
    {0x0008,                            /* G1_Reset */
     0x8000,                            /* GPFO_1_Output_Enable */
     0x0002,                            /* G1_Bank_St */
     0x2000                             /* G1_HW_Save_St */
    }
};

static void writeLoadReg(volatile ushort_T *ioadd,
                         ushort_T reg, uint_T value) {
    DAQ_STC_Windowed_Mode_Write(ioadd, reg, (ushort_T)((value >> 16) & 0x00ff));
    DAQ_STC_Windowed_Mode_Write(ioadd, (ushort_T)(reg + 1), (ushort_T)(value & 0xffff));
}

/* reset all the registers which are needed to perform the operation */
static void Counter_Reset_All(volatile ushort_T *ioaddress, ushort_T *reg,
                              ushort_T *mask) {
    /* Gi_Reset <= 1 (Strobe) */
    DAQ_STC_Windowed_Mode_Write(ioaddress, Joint_Reset_Register,
                                mask[GI_RESET_MASK]);
    /* Clear various registers */
    DAQ_STC_Windowed_Mode_Write(ioaddress, reg[MODE_REG],             0x0000);
    DAQ_STC_Windowed_Mode_Write(ioaddress, reg[COMMAND_REG],          0x0000);
    DAQ_STC_Windowed_Mode_Write(ioaddress, reg[INPUT_SELECT_REG],     0x0000);
    DAQ_STC_Windowed_Mode_Write(ioaddress, reg[AUTOINCREMENT_REG],    0x0000);
    DAQ_STC_Windowed_Mode_Write(ioaddress, reg[INTERRUPT_ENABLE_REG], 0x0000);
    /* Gi_Synchronized_Gate <= 1 */
    DAQ_STC_Windowed_Mode_Write(ioaddress, reg[COMMAND_REG],          0x0100);
    /* Gi_Gate_Error_Confirm <= 1
     * Gi_TC_Error_Confirm   <= 1
     * Gi_TC_Interrupt_Ack   <= 1
     * Gi_Gate_Interrupt_Ack <= 1
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, reg[INTERRUPT_ACK_REG],    0xC060);
    /* Gi_Autoincrement <= 0 */
    DAQ_STC_Windowed_Mode_Write(ioaddress, reg[AUTOINCREMENT_REG],    0x0000);
    return;
}

/* Function will generate Cointinous pulses on the G_Out pin with three
 *  delay from the trigger,pulse interval of four  and pulsewidth of
 *  three. Using the G_in_timebase (20MHz) as the G_source signal.
 * The Waveform generation is started by trigger from G_Gate on PFI4.*/
static void Cont_Pulse_Train_Generation(volatile ushort_T *ioaddress,
                                        ushort_T *reg,
                                        ushort_T *mask,
                                        unsigned int *lowhigh) {

    /* Gi_Load              <= 1
     * Gi_Synchronized_Gate <= 1
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, reg[COMMAND_REG], 0x0104);

    /* Gi_Load_A <= low - 1 */
    writeLoadReg(ioaddress, reg[LOAD_A_REG], lowhigh[0]);

    /* Gi_Load_B <= high - 1 */
    writeLoadReg(ioaddress, reg[LOAD_B_REG], lowhigh[1]);

    /* Gi_Source_Select           <= 0 (G_In_Time_Base1)
     * Gi_Source_Polarity         <= 0 (rising edges)
     * Gi_Gate_Select             <= 5 (PFI4)
     * Gi_OR_Gate                 <= 0 (Dont OR with other ctrs gate)
     * Gi_Output_Polarity         <= 0 (initial high)
     * Gi_Gate_Select_Load_Source <= 0 (Dont select LOAD_[AB] based on gate)
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, reg[INPUT_SELECT_REG], 0x0280);

    /* Gi_Reload_Source_Switching    <= 1 (swap load_[ab] on ctr reload)
     * Gi_Loading_On_Gate            <= 0 (ctr doesnt reload on gate)
     * Gi_Gate_Polarity              <= 1 (active low)
     * Gi_Loading_On_TC              <= 1 (reload ctr on TC)
     * Gi_Counting_Once              <= 0 (Dont disarm ctr: keep going)
     * Gi_Output_Mode                <= 2 (toggle on TC)
     * Gi_Load_Source_Select         <= 1 (Load Reg B)
     * Gi_Stop_Mode                  <= 0 (stop on gate condition)
     * Gi_Trigger_Mode_For_Edge_Gate <= 2 (gate starts counting)
     * Gi_Gate_On_Both_Edges         <= 0 (Dont gate on both)
     * Gi_Gating_Mode                <= 0 (Gating disabled)
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, reg[MODE_REG], 0xb290);

    /* G0_Bank_Switch_Enable <= 1 (use bank y, since we have not armed)
     * G0_Bank_Switch_Mode   <= 1 (software)
     * G0_Synchronized_Gate  <= 1
     * G0_Up_Down            <= 0 (down counting)
     * G0_Load               <= 1 (Load the selected reg, i.e. load_reg_b)
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, reg[COMMAND_REG], 0x1904);

    /*
     *  G0_TC_Interrupt_Enable   <= 0
     *  G0_Gate_Interrupt_Enable <= 0
     */
    DAQ_STC_Windowed_Mode_Write(ioaddress, reg[INTERRUPT_ENABLE_REG], 0x0000);
    return;
}

// call this  function to start the operation
static void Ctr_Arm_All(volatile unsigned short *ioaddress, ushort_T *reg){
    /* G0_Arm<=1 */
    DAQ_STC_Windowed_Mode_Write(ioaddress, reg[COMMAND_REG], 0x1905);
    return;
}

// Function to enable the GPCTR0_OUT pin as output pin
static void Enable_Counters(volatile unsigned short *ioaddress,
                            int chan0, int chan1) {
    /* Writing to Analog_Trigger_Etc_Register with address 61
     * GPFO_0_Output_Enable<=1
     * GPFO_0_Output_Select <=0
     * pattern = 0x4000
     */
    ushort_T mask = 0;
    if (chan0) mask |= STCMasks[0][GPFO_I_OUTPUT_ENABLE];
    if (chan1) mask |= STCMasks[1][GPFO_I_OUTPUT_ENABLE];
    DAQ_STC_Windowed_Mode_Write(ioaddress, Analog_Trigger_Etc_Register, mask);
    return;
}

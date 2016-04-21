/* $Revision: 1.9.4.2 $ */

/* Abstract: include file for NI PCI-E functions
 *
 *  Copyright 1996-2003 The MathWorks, Inc.
 *
 */


#define Serial_Command                 13          /*address*/
#define Misc_Command                   15          /*address*/
#define Status                         1           /*address*/
#define Strobes_Register               1           /*address*/
#define AI_AO_Select_Register          9           /*address*/
#define Channel_A_Mode_Register        3           /*address*/
#define ADC_FIFO_Data_Register         28          /*address*/
#define Configuration_Memory_Low       16          /*address*/
#define Configuration_Memory_High      18          /*address*/
#define AO_Configuration_Register      22          /*address*/
#define AO_DAC_FIFO_Data               30          /*address*/
#define AO_DAC_0_Data_Register         24          /*address*/
#define AO_DAC_1_Data_Register         26          /*address*/
#define Strobes                        1           /*address*/
#define Channel_A_Mode                 3           /*address*/
#define Channel_B_Mode                 5           /*address*/
#define Channel_C_Mode                 7           /*address*/
#define AI_AO_Select                   9           /*address*/
#define G0_G1_Select                   11          /*address*/
#define Configuration_Memory_Clear     130         /*address*/
#define ADC_FIFO_Clear                 131         /*address*/
#define DAC_FIFO_Clear                 132         /*address*/
#define AI_Command_1_Register          8           /*address*/
#define AI_Command_2_Register          4           /*address*/
#define AI_DIV_Load_A_Register         64          /*address*/
#define AI_DIV_Save_Register           26          /*address*/
#define AI_Mode_1_Register             12          /*address*/
#define AI_Mode_2_Register             13          /*address*/
#define AI_Mode_3_Register             87          /*address*/
#define AI_Output_Control_Register     60          /*address*/
#define AI_Personal_Register           77          /*address*/
#define AI_SC_Load_B_Registers         20          /*address*/
#define AI_SC_Load_A_Registers         18          /*address*/
#define AI_SC_Save_Registers           66          /*address*/
#define AI_SI_Load_B_Registers         16          /*address*/
#define AI_SI_Load_A_Registers         14          /*address*/
#define AI_SI_Save_Registers           64          /*address*/
#define AI_SI2_Load_B_Register         25          /*address*/
#define AI_SI2_Load_A_Register         23          /*address*/
#define AI_SI2_Save_Register           25          /*address*/
#define AI_START_STOP_Select_Register  62          /*address*/
#define AI_Status_1_Register           2           /*address*/
#define AI_Status_2_Register           5           /*address*/
#define AI_Trigger_Select_Register     63          /*address*/
#define Analog_Trigger_Etc_Register    61          /*address*/
#define AO_BC_Load_B_Registers         46          /*address*/
#define AO_BC_Load_A_Registers         44          /*address*/
#define AO_BC_Save_Registers           18          /*address*/
#define AO_Command_1_Register          9           /*address*/
#define AO_Command_2_Register          5           /*address*/
#define AO_Mode_1_Register             38          /*address*/
#define AO_Mode_2_Register             39          /*address*/
#define AO_Mode_3_Register             70          /*address*/
#define AO_Output_Control_Register     86          /*address*/
#define AO_Personal_Register           78          /*address*/
#define AO_START_Select_Register       66          /*address*/
#define AO_Status_1_Register           3           /*address*/
#define AO_Status_2_Register           6           /*address*/
#define AO_Trigger_Select_Register     67          /*address*/
#define AO_UC_Load_B_Registers         50          /*address*/
#define AO_UC_Load_A_Registers         48          /*address*/
#define AO_UC_Save_Registers           20          /*address*/
#define AO_UI_Load_B_Registers         42          /*address*/
#define AO_UI_Load_A_Registers         40          /*address*/
#define AO_UI_Save_Registers           16          /*address*/
#define AO_UI2_Load_B_Register         55          /*address*/
#define AO_UI2_Load_A_Register         53          /*address*/
#define AO_UI2_Save_Register           23          /*address*/
#define Clock_and_FOUT_Register        56          /*address*/
#define DIO_Control_Register           11          /*address*/
#define DIO_Output_Register            10          /*address*/
#define DIO_Parallel_Input_Register    7           /*address*/
#define DIO_Serial_Input_Register      28          /*address*/
#define G_Status_Register              4           /*address*/
#define G0_Autoincrement_Register      68          /*address*/
#define G0_Command_Register            6           /*address*/
#define G0_HW_Save_Registers           8           /*address*/
#define G0_Input_Select_Register       36          /*address*/
#define G0_Load_B_Registers            30          /*address*/
#define G0_Load_A_Registers            28          /*address*/
#define G0_Mode_Register               26          /*address*/
#define G0_Save_Registers              12          /*address*/
#define G1_Autoincrement_Register      69          /*address*/
#define G1_Command_Register            7           /*address*/
#define G1_HW_Save_Registers           10          /*address*/
#define G1_Input_Select_Register       37          /*address*/
#define G1_Load_B_Registers            34          /*address*/
#define G1_Load_A_Registers            32          /*address*/
#define G1_Mode_Register               27          /*address*/
#define G1_Save_Registers              14          /*address*/
#define Generic_Control_Register       71          /*address*/
#define Interrupt_A_Ack_Register       2           /*address*/
#define Interrupt_B_Ack_Register       3           /*address*/
#define Interrupt_B_Enable_Register    75          /*address*/
#define Interrupt_Control_Register     59          /*address*/
#define Interrupt_A_Enable_Register    73          /*address*/
#define IO_Bidirection_Pin_Register    57          /*address*/
#define Joint_Reset_Register           72          /*address*/
#define Joint_Status_1_Register        27          /*address*/
#define Joint_Status_2_Register        29          /*address*/
#define RTSI_Board_Register            81          /*address*/
#define RTSI_Trig_B_Output_Register    80          /*address*/
#define RTSI_Trig_Direction_Register   58          /*address*/
#define RTSI_Trig_A_Output_Register    79          /*address*/
#define Second_Irq_A_Enable_Register   74          /*address*/
#define Second_Irq_B_Enable_Register   76          /*address*/
#define Window_Address_Register        0           /*address*/
#define Window_Data_Read_Register      1           /*address*/
#define Window_Data_Write_Register     1           /*address*/
#define Write_Strobe_0_Register        82          /*address*/
#define Write_Strobe_1_Register        83          /*address*/
#define Write_Strobe_2_Register        84          /*address*/
#define Write_Strobe_3_Register        85          /*address*/


// General
void DAQ_STC_Windowed_Mode_Write(volatile unsigned short *ioaddress,
                                 unsigned short uRegister_Address,
                                 unsigned short uData);
unsigned short  DAQ_STC_Windowed_Mode_Read(volatile unsigned short *ioaddress,
                                           unsigned short uRegister_Address) ;
void Board_Write(volatile unsigned short *ioaddress, unsigned short uRegister_Address, unsigned short uData);
unsigned short Board_Read(volatile unsigned short *ioaddress, unsigned short uRegister_Address);


// Analog Input
void AI_MSC_Clock_Configure(volatile unsigned short *ioaddress);
void AI_Reset_All(volatile unsigned short *ioaddress);
void  AI_Board_Personalize(volatile unsigned short *ioaddress);
void  AI_Initialize_Configuration_Memory_Output(volatile unsigned short *ioaddress);
void  AI_Board_Environmentalize(volatile unsigned short *ioaddress);
void  AI_FIFO_Request(volatile unsigned short *ioaddress);
void  AI_Hardware_Gating(volatile unsigned short *ioaddress);
void  AI_Trigger_Signals(volatile unsigned short *ioaddress);
void  AI_Number_of_Scans(volatile unsigned short *ioaddress);
void  AI_Scan_Start(volatile unsigned short *ioaddress);
void  AI_End_of_Scan(volatile unsigned short *ioaddress);
void  AI_Convert_Signal(volatile unsigned short *ioaddress, int speed);
void  AI_Clear_FIFO(volatile unsigned short *ioaddress);
void  AI_Interrupt_Enable(volatile unsigned short *ioaddress);
void  AI_Arming(volatile unsigned short *ioaddress);
void  AI_Start_The_Acquisition(volatile unsigned short *ioaddress);

// Analog Output
void AO_Reset_All(volatile unsigned short *ioaddress);
void AO_Board_Personalize(volatile unsigned short *ioaddress);
void AO_LDAC_Source_And_Update_Mode(volatile unsigned short *ioaddress);

// Calibration
unsigned char readEEPROM(volatile unsigned char * ioaddress8, int address);
void writeCALDAC(volatile unsigned char * ioaddress8, int address, unsigned char value);
void writeCALDAC1(volatile unsigned char * ioaddress8, int address, unsigned char value);
void writeCALDAC2(volatile unsigned char * ioaddress8, int address, unsigned char value);
void writeCALDACN(volatile unsigned char * ioaddress8, int chip, int address, unsigned char value);
void writeCALDAC3(volatile unsigned char * ioaddress8, short value);

/* $Revision: 1.4 $ */
#include <conio.h>
#include <dos.h>
#include <stdio.h>
#include <string.h>

// Board Registers
#define r_CLEAR_6430							0		// Clear Register (Read/Write)
#define r_STATUS_6430						2		// Status Register (Read)
#define r_CONTROL_6430						2		// Control Register (Write)
#define r_AD_6430								4		// AD Data (Read)
#define r_CHANNEL_GAIN_6430				4		// Channel/Gain Register (Write)
#define r_AD_TABLE_6430						4		// AD Table (Write)
#define r_DIGITAL_TABLE_6430				4		// Digital Table (Write)
#define r_START_CONVERSION_6430			6		// Start Conversion (Read)
#define r_TRIGGER_6430						6		// Trigger Register (Write)
#define r_IRQ_6430							8		// IRQ Register (Write)
#define r_DIN_FIFO_6430						10		// Digital Input FIFO Data (Read)
#define r_DIN_CONFIG_6430					10		// Config Digital Input FIFO (Write)
#define r_DAC1_6430							12		// DAC 1 Data (Write)
#define r_LOAD_AD_SAMPLE_COUNT_6430		14		// Load A/D Sample Counter (Read)
#define r_TIMER_CLCK0_6430					16		// Timer/Counter 0 (Read/Write)
#define r_TIMER_CLCK1_6430					18		// Timer/Counter 1 (Read/Write)
#define r_TIMER_CLCK2_6430					20		// Timer/Counter 2 (Read/Write)
#define r_TIMER_CTRL_6430					22		// Timer/Counter Control Word (Write)

#ifdef XPCMSVISUALC
#define inp		_inp
#define inpw	_inpw
#define outp	_outp
#define outpw	_outpw
#endif


// Defaults for the global variable.
//--------------------------------------------------

uint16  BaseAddress;

// Varibles to save board settings
static uint16 Control_Register_6430			= 0;      // Save Control Register
static uint16 Trigger_Register_6430			= 0;      // Save Trigger Register
static uint16	IRQ_Register_6430				= 0;      // Save IRQ Register
static uint16	DIN_Register_6430				= 0;      // Save Digital Input FIFO configuration Register





char* TitleString6430(void)
{
	return "DM6430 sample program.";
} //TitleString6430




//*************************************************************************
//	SetBaseAddress
//
//	This routine is used to set the variable BaseAddress.
//
//	Parameters:
//		Address:
//*************************************************************************
void SetBaseAddress(uint16 Address)
{
	BaseAddress = Address;
} // SetBaseAddress




//*************************************************************************
//	InitBoard6430
//
//	This Routine Should allways be called first.
//	This clears the board and varibles the driver uses.
//
//	Parameters:
//		None
//*************************************************************************
void InitBoard6430(void)
{
	ClearBoard6430();
	ClearADDMADone6430();
	ClearChannelGainTable6430();
	ClearADFIFO6430();
	// Clear Driver varibles.
	Control_Register_6430		= 0;      // Save Control Register
	Trigger_Register_6430  		= 0;      // Save Trigger Register
	IRQ_Register_6430          = 0;      // Save IRQ Register
	DIN_Register_6430          = 0;      // Save Digital Input Configuration Register
} // InitBoard6430




//************************ CLEAR ROUTINES *********************************
//	Read & Write at BA + 0

//*************************************************************************
//	ClearRegister6430
//
//	This routine is used to write the clear register with one command
// and issue a clear to the board.
//
//	Parameters:
//		ClearValue:		1 - 65535
//*************************************************************************
void ClearRegister6430(uint16 ClearValue)
{
	outpw((unsigned short)(BaseAddress + r_CLEAR_6430), (unsigned short)ClearValue);
	inpw((unsigned short)(BaseAddress + r_CLEAR_6430));
} // ClearRegister6430




//*************************************************************************
//	ClearBoard6430
//
//	This routine is used to clear board.
//
//	Parameters:
//		None
//*************************************************************************
void ClearBoard6430(void)
{
	outpw((unsigned short)(BaseAddress + r_CLEAR_6430), 0x0001);
	inpw((unsigned short)(BaseAddress + r_CLEAR_6430));
} // ClearBoard6430




//*************************************************************************
//	ClearADFIFO6430
//
//	This routine is used to clear all the data from the A/D FIFO.
//
//	Parameters:
//		None
//*************************************************************************
void ClearADFIFO6430(void)
{
	outpw((unsigned short)(BaseAddress + r_CLEAR_6430), 0x0002);
	inpw((unsigned short)(BaseAddress + r_CLEAR_6430));
} // ClearADFIFO6430




//*************************************************************************
//	ClearADDMADone6430
//
//	This routine is used to clear the A/D DMA done status bit.
//
//	Parameters:
//		None
//*************************************************************************
void ClearADDMADone6430(void)
{
	outpw((unsigned short)(BaseAddress + r_CLEAR_6430), 0x0004);
	inpw((unsigned short)(BaseAddress + r_CLEAR_6430));
} // ClearADDMADone6430




//*************************************************************************
//	ClearChannelGainTable6430
//
//	This routine is used to clear both the AD Table and the Digital Table.
//
//	Parameters:
//		None
//*************************************************************************
void ClearChannelGainTable6430(void)
{
	outpw((unsigned short)(BaseAddress + r_CLEAR_6430), 0x0008);
	inpw((unsigned short)(BaseAddress + r_CLEAR_6430));
} // ClearChannelGainTable6430




//*************************************************************************
//	ResetChannelGainTable6430
//
//	This routine is used to reset both the AD Table and the Digital Table
//	pointers to the first location in the table.
//
//	Parameters:
//		None
//*************************************************************************
void ResetChannelGainTable6430(void)
{
	outpw((unsigned short)(BaseAddress + r_CLEAR_6430), 0x0010);
	inpw((unsigned short)(BaseAddress + r_CLEAR_6430));
} // ResetChannelGainTable6430




//*************************************************************************
//	ClearDINFIFO6430
//
//	This routine is used to clear the Digital Input FIFO.
//
//	Parameters:
//		None
//*************************************************************************
void ClearDINFIFO6430(void)
{
	outpw((unsigned short)(BaseAddress + r_CLEAR_6430), 0x0020);
	inpw((unsigned short)(BaseAddress + r_CLEAR_6430));
} // ClearDIN1FIFO6430




//*************************************************************************
//	ClearIRQ16430
//
//	This routine is used to clear the IRQ 1 circuitry and status bit.
//
//	Parameters:
//		None
//*************************************************************************
void ClearIRQ16430(void)
{
	outpw((unsigned short)(BaseAddress + r_CLEAR_6430), 0x0040);
	inpw((unsigned short)(BaseAddress + r_CLEAR_6430));
} // ClearIRQ16430




//*************************************************************************
//	ClearIRQ26430
//
//	This routine is used to clear the IRQ 2 status bit.
//
//	Parameters:
//		None
//*************************************************************************
void ClearIRQ26430(void)
{
	outpw((unsigned short)(BaseAddress + r_CLEAR_6430), 0x0080);
	inpw((unsigned short)(BaseAddress + r_CLEAR_6430));
} // ClearIRQ26430




//************************ QUERY ROUTINES *********************************
//	Read at BA + 2

//*************************************************************************
//	ReadStatus6430
//
//	This routine returns the status from the board.
//
//	Returns:		16 bit unsigned integer
//*************************************************************************
uint16 ReadStatus6430(void)
{
 return(inpw((unsigned short)(BaseAddress + r_STATUS_6430)));
} // ReadStatus6430




//*************************************************************************
//	IsADFIFOEmpty6430
//
//	This routine checks to see if the A/D FIFO is empty.
//
//	Returns:				1 if FIFO is empty
//							0 if FIFO is not empty
//*************************************************************************
uint16 IsADFIFOEmpty6430(void)
{
	uint16 Status;

	Status = inpw((unsigned short)(BaseAddress + r_STATUS_6430));
	Status &= 1;
	return(!Status);
} // IsADFIFOEmpty6430




//*************************************************************************
//	IsADFIFOFull6430
//
//	This routine checks to see if the A/D FIFO is full.
//
//	Returns:				1 if FIFO is full
//							0 if FIFO is not full
//*************************************************************************
uint16 IsADFIFOFull6430(void)
{
	uint16 Status;

	Status = inpw((unsigned short)(BaseAddress + r_STATUS_6430));
	Status = (Status >> 1) & 1;
	return(!Status);
} // IsADFIFOFull6430




//*************************************************************************
//	IsADHalted6430
//
//	This routine checks to see if the AD is halted.
//
//	Returns:				1 if AD is halted
//							0 if AD is not halted
//*************************************************************************
uint16 IsADHalted6430(void)
{
	uint16 Status;

	Status = inpw((unsigned short)(BaseAddress + r_STATUS_6430));
	Status = (Status >> 2) & 1;
	return(Status);
} // IsADHalted6430




//*************************************************************************
//	IsADConverting6430
//
//	This routine checks to see if the AD converting.
//
//	Returns:				1 if AD is converting
//							0 if AD is not converting
//*************************************************************************
uint16 IsADConverting6430(void)
{
	uint16 Status;

	Status = inpw((unsigned short)(BaseAddress + r_STATUS_6430));
	Status = (Status >> 3) & 1;
	return(!Status);
} // IsADConverting6430




//*************************************************************************
//	IsADDMADone6430
//
//	This routine checks to see if the A/D DMA transfer is done.
//
//	Returns:				1 if DMA is done
//							0 if DMA is not done
//*************************************************************************
uint16 IsADDMADone6430(void)
{
	uint16 Status;

	Status = inpw((unsigned short)(BaseAddress + r_STATUS_6430));
	Status = (Status >> 4) & 1;
	return(Status);
} // IsADDMADone6430




//*************************************************************************
//	IsFirstADDMADone6430
//
//	This routine checks to see if the A/D DMA transfer is done on the first
//	channel.
//
//	Returns:				1 if DMA is done
//							0 if DMA is not done
//*************************************************************************
uint16 IsFirstADDMADone6430(void)
{
	uint16 Status;

	Status = inpw((unsigned short)(BaseAddress + r_STATUS_6430));
	Status = (Status >> 5) & 1;
	return(Status);
} // IsFirstADDMADone6430




//*************************************************************************
//	IsBurstClockOn6430
//
//	This routine checks to see if the burst clock is enabled.
//
//	Returns:				1 if Burst Clock is on
//							0 if Burst Clock is off
//*************************************************************************
uint16 IsBurstClockOn6430(void)
{
	uint16 Status;

	Status = inpw((unsigned short)(BaseAddress + r_STATUS_6430));
	Status = (Status >> 6) & 1;
	return(Status);
} // IsBurstClockOn6430




//*************************************************************************
//	IsPacerClockOn6430
//
//	This routine checks to see if the pacer clock is running.
//
//	Returns:				1 if Pacer Clock is on
//							0 if Pacer Clock is off
//*************************************************************************
uint16 IsPacerClockOn6430(void)
{
	uint16 Status;

	Status = inpw((unsigned short)(BaseAddress + r_STATUS_6430));
	Status = (Status >> 7) & 1;
	return(Status);
} // IsPacerClockOn6430




//*************************************************************************
//	IsAboutTrigger6430
//
//	This routine checks to see if the about trigger has occurred.
//
//	Returns:				1 if trigger has occurred
//							0 if trigger has not occurred
//*************************************************************************
uint16 IsAboutTrigger6430(void)
{
	uint16 Status;

	Status = inpw((unsigned short)(BaseAddress + r_STATUS_6430));
	Status = (Status >> 8) & 1;
	return(Status);
} // IsboutTrigger6430




//*************************************************************************
//	IsDigitalIRQ6430
//
//	This routine checks to see if the digital I/O chip has generated
//	an interrupt.
//
//	Returns:				1 if IRQ has been generated
//							0 if no IRQ
//*************************************************************************
uint16 IsDigitalIRQ6430(void)
{
	uint16 Status;

	Status = inpw((unsigned short)(BaseAddress + r_STATUS_6430));
	Status = (Status >> 9) & 1;
	return(Status);
} // IsDigitalIRQ6430




//*************************************************************************
//	IsDINFIFOEmpty6430
//
//	This routine checks to see if the Digital Input FIFO is empty.
//
//	Returns:				1 if FIFO is empty
//							0 if FIFO is not empty
//*************************************************************************
uint16 IsDINFIFOEmpty6430(void)
{
	uint16 Status;

	Status = inpw((unsigned short)(BaseAddress + r_STATUS_6430));
	Status &= (Status >> 10) & 1;
	return(!Status);
} // IsDINFIFOEmpty6430




//*************************************************************************
//	IsDINFIFOHalf6430
//
//	This routine checks to see if the Digital Input FIFO is half full.
//
//	Returns:				1 if FIFO is half full
//							0 if FIFO is not half full
//*************************************************************************
uint16 IsDINFIFOHalf6430(void)
{
	uint16 Status;

	Status = inpw((unsigned short)(BaseAddress + r_STATUS_6430));
	Status &= (Status >> 11) & 1;
	return(!Status);
} // IsDINFIFOHalf6430




//*************************************************************************
//	IsDINFIFOFull6430
//
//	This routine checks to see if the Digital Input FIFO is full.
//
//	Returns:				1 if FIFO is full
//							0 if FIFO is not full
//*************************************************************************
uint16 IsDINFIFOFull6430(void)
{
	uint16 Status;

	Status = inpw((unsigned short)(BaseAddress + r_STATUS_6430));
	Status = (Status >> 12) & 1;
	return(!Status);
} // IsDINFIFOFull6430




//*************************************************************************
//	IsIRQ16430
//
//	This routine checks the IRQ 1 status bit.
//
//	Returns:				1 if IRQ has been generated
//							0 if no IRQ
//*************************************************************************
uint16 IsIRQ16430(void)
{
	uint16 Status;

	Status = inpw((unsigned short)(BaseAddress + r_STATUS_6430));
	Status = (Status >> 13) & 1;
	return(Status);
} // IsIRQ16430




//*************************************************************************
//	IsIRQ26430
//
//	This routine checks the IRQ 2 status bit.
//
//	Returns:				1 if IRQ has been generated
//							0 if no IRQ
//*************************************************************************
uint16 IsIRQ26430(void)
{
	uint16 Status;

	Status = inpw((unsigned short)(BaseAddress + r_STATUS_6430));
	Status = (Status >> 14) & 1;
	return(Status);
} // IsIRQ26430




//************************ CONTROL REGISTER *******************************
//	Write at BA + 2

//*************************************************************************
//	LoadControlRegister6430
//
//	This routine loads the control register with one write operation.
//
//	Parameters:
//		Value:		0 - 65535
//*************************************************************************
void LoadControlRegister6430(uint16 Value)
{
	Control_Register_6430 = Value;
	outpw((unsigned short)(BaseAddress + r_CONTROL_6430), (unsigned short)Control_Register_6430); // send to board
} // LoadControlRegister6430




//*************************************************************************
//	EnableTables6430
//
//	This Routine Enables and Disables both the AD and Digital Tables.
//
//	Parameters:
//			Enable_AD_Table:			0 = disable
//    	                	   	1 = enable
// 		Enable_Digital_Table:	0 = disable
//    	                  	 	1 = enable
//*************************************************************************
void EnableTables6430(uint16 Enable_AD_Table, uint16 Enable_Digital_Table)
{
	Control_Register_6430 &= 0xFFF3;
	Control_Register_6430 |= ((Enable_AD_Table<<2) | (Enable_Digital_Table <<3));
	outpw((unsigned short)(BaseAddress + r_CONTROL_6430), (unsigned short)Control_Register_6430);
} // EnableTables6430




//*************************************************************************
//	ChannelGainDataStore6430
//
//	This routine enables the Channel Gain Data Store feature of the board.
//
//	Parameters:
//			Enable:		0 = Disable
//							1 = Enable
//*************************************************************************
void ChannelGainDataStore6430(uint16 Enable)
{
	Control_Register_6430 &= 0xFFEF;
	Control_Register_6430 |= (Enable << 4);
	outpw((unsigned short)(BaseAddress + r_CONTROL_6430), (unsigned short)Control_Register_6430); // send to board
} // ChannelGainDataStore6430




//*************************************************************************
//	SelectTimerCounter6430
//
//	This routine selects one of the four 8254 timer chips.
//
//	Parameters:
//		Select:	0 = Clock TC (Pacer & Burst clocks)
//					1 = User TC (A/D sample counter & User timer/counters)
//					2 = reserved
//					3 = reserved
//*************************************************************************
void SelectTimerCounter6430(uint16 Select)
{
	Control_Register_6430 &= 0xFF9F;
	Control_Register_6430 |= (Select << 5);
	outpw((unsigned short)(BaseAddress + r_CONTROL_6430), (unsigned short)Control_Register_6430); // send to board
} // SelectTimerCounter6430




//*************************************************************************
//	SetADSampleCounterStop6430
//
//	This routine enables and disables the A/D sample counter stop bit.
//
//	Parameters:
//		Enable:	0 = Enable
//  				1 = Disable
//*************************************************************************
void SetSampleCounterStop6430(uint16 Enable)
{
	Control_Register_6430 &= 0xFF7F;
	Control_Register_6430 |= (Enable << 7);
	outpw((unsigned short)(BaseAddress + r_CONTROL_6430), (unsigned short)Control_Register_6430); // send to board
} // SetSampleCounterStop6430




//*************************************************************************
//	SetADPauseEnable6430
//
//	This routine enables and disables the A/D pause bit.
//
//	Parameters:
//		Enable:	0 = Enable
//  				1 = Disable
//*************************************************************************
void SetPauseEnable6430(uint16 Enable)
{
	Control_Register_6430 &= 0xFEFF;
	Control_Register_6430 |= (Enable << 8);
	outpw((unsigned short)(BaseAddress + r_CONTROL_6430), (unsigned short)Control_Register_6430); // send to board
} // SetPauseEnable6430




//*************************************************************************
//	SetADDMA6430
//
//	This routine sets the A/D DMA channels.
//
//	Parameters:
//		Channel1:	0 = disabled
//  					1 = DRQ 5
//						2 = DRQ 6
//						3 = DRQ 7
//
//		Channel2:	0 = disabled
//  					1 = DRQ 5
//						2 = DRQ 6
//						3 = DRQ 7
//*************************************************************************
void SetADDMA6430(uint16 Channel1, uint16 Channel2)
{
	switch(Channel1){
		case 5: Channel1 = 1;
		break;
		case 6: Channel1 = 2;
		break;
		case 7: Channel1 = 3;
		break;
		default: Channel1 = 0;
	}
	switch(Channel2){
		case 5: Channel2 = 1;
		break;
		case 6: Channel2 = 2;
		break;
		case 7: Channel2 = 3;
		break;
		default: Channel2 = 0;
	}

	Control_Register_6430 &= 0x0FFF;
	Control_Register_6430 |= (Channel1 << 12) | (Channel2 << 14);
	outpw((unsigned short)(BaseAddress + r_CONTROL_6430), (unsigned short)Control_Register_6430); // send to board
} // SetADDMA6430




//************************ READ A/D DATA **********************************
//	Read at BA + 4

//*************************************************************************
//	ReadADData6430
//
//	This Routine Reads the Data from the FIFO.
//
//	Returns signed 16 bit AD Data.
//*************************************************************************
int16  ReadADData6430(void)
{
	return((int16) inpw((unsigned short)(BaseAddress + r_AD_6430)));
} // ReadADData6430




//*************************************************************************
//	ReadChannelGainDataStore6430
//
//	This Routine Reads the Channel/Gain Data from the FIFO when the
// Channel Gain Data Store feature of the board is enabled.
//
//	Returns a 16 bit value: Bottom 8 bits = A/D table value
//									Upper 8 bits  = digital table value
//*************************************************************************
uint16  ReadChannelGainDataStore6430(void)
{
	return((uint16) inpw((unsigned short)(BaseAddress + r_AD_6430)));
} // ReadChannelGainDataStore6430




//************************ LOAD CHANNEL/GAIN ******************************
//	Write at BA + 4

//*************************************************************************
//	SetChannelGain6430
//
//	This routine loads the channel/gain latch.
//
//	Parameters:
//			Channel:		0 - 15
//
//			Gain:			0 = x1
//							1 = x2
//							2 = x4
//							3 = x8
//							4 = reserved
//							5 = reserved
//							6 = reserved
//							7 = reserved
//
//			Se_Diff:		0 = single ended
//							1 = differential
//*************************************************************************
void SetChannelGain6430(uint16 Channel, uint16 Gain, uint16 Se_Diff)
{
	uint16 B;
	B = (Channel) | (Gain << 4) | (Se_Diff << 9);
	outpw((unsigned short)(BaseAddress + r_CHANNEL_GAIN_6430), (unsigned short)B);  // send to board
} // SetChannelGain6430




//*************************************************************************
//	LoadADTable6430
//
//	This routine loads the AD Table with the given number of Entrys.
//
//	Parameters:
//	The struct ADTableRow is define in DRVR6430.h
//	typedef struct
//	{
//		uint16 Channel:	0 - 15
//
//		uint16 Gain:		0 = x1
//								1 = x2
//								2 = x4
//								3 = x8
//								4 = reserved
//								5 = reserved
//								6 = reserved
//								7 = reserved
//
//		uint16 Se_Diff:	0 = single ended
//								1 = differential
//
//		uint16 Pause:		0 = disabled
//								1 = enabled
//
//		uint16 Skip:		0 = disabled
//								1 = enabled
//} ADTableRow;
//		Num_of_Entry:	1-1024
//*************************************************************************
void LoadADTable6430(uint16 Num_of_Entry, ADTableRow *ADTable)
{
	uint16 i;
	uint16 ADEntry;

	Control_Register_6430 &= 0xFFFC;
	Control_Register_6430 |= 0x1;             //Enable loading AD table.
	outpw((unsigned short)(BaseAddress + r_CONTROL_6430), (unsigned short)Control_Register_6430);

	for (i  = 0 ;i < Num_of_Entry;i++)
	{
		ADEntry = (ADTable[i].Channel) |
					 (ADTable[i].Gain << 4) |
					 (ADTable[i].Se_Diff << 9) |
					 (ADTable[i].Pause << 10) |
					 (ADTable[i].Skip << 11);
		outpw((unsigned short)(BaseAddress + r_AD_TABLE_6430), (unsigned short)ADEntry);
	} // for
	Control_Register_6430 &= 0xFFFC;             //Disable loading AD table.
	outpw((unsigned short)(BaseAddress + r_CONTROL_6430), (unsigned short)Control_Register_6430);
} // LoadADTable6430




//*************************************************************************
//	LoadDigitalTable6430
//
//	This routine loads the Digital Table with the given number of Entrys.
//
//	Parameters:
//		Channel:			0 - 255
//		Num_of_Chan:	1 -1024
//*************************************************************************
void LoadDigitalTable6430( uint16 Num_of_Chan, uchar8 *Channel)
{
	uint16 i;
	Control_Register_6430 &= 0xFFFC;
	Control_Register_6430 |= 0x2;             //Enable loading digital table.
	outpw((unsigned short)(BaseAddress + r_CONTROL_6430), (unsigned short)Control_Register_6430);
	for (i  = 0 ;i < Num_of_Chan;i++)
	{
		 outpw((unsigned short)(BaseAddress + r_DIGITAL_TABLE_6430), (unsigned short)Channel[i]);
	} // for
	Control_Register_6430 &= 0xFFFC;           //Disable loading digital table.
	outpw((unsigned short)(BaseAddress + r_CONTROL_6430), (unsigned short)Control_Register_6430);
} // LoadDigitalTable6430




//************************ START CONVERSION *******************************
//	Read at BA + 6

//*************************************************************************
//	StartConversion6430
//
//	This routine is used to create software triggers or enable hardware
//	triggers depending on the conversion mode.
//
//	Parameters:
//		None
//*************************************************************************
void StartConversion6430(void)
{
	inpw((unsigned short)(BaseAddress + r_START_CONVERSION_6430));
} // StartConversion6430




//************************ TRIGGER REGISTER *******************************
//	Write at BA + 6

//*************************************************************************
//	LoadTriggerRegister6430
//
//	This routine loads the trigger register with one write operation.
//
//	Parameters:
//		Value:			0 - 65535
//*************************************************************************
void LoadTriggerRegister6430(uint16 Value)
{
	Trigger_Register_6430 = Value;
	outpw((unsigned short)(BaseAddress + r_TRIGGER_6430), (unsigned short)Trigger_Register_6430); // send to board
} // LoadTriggerRegister6430




//*************************************************************************
//	SetConversionSelect6430
//
//	This routine selects the conversion mode.
//
//	Parameters:
//		Select:	0 = software trigger
//					1 = pacer clock
//					2 = burst clock
//					3 = digital interrupt
//*************************************************************************
void SetConversionSelect6430(uint16 Select)
{
	Trigger_Register_6430 &= 0xFFFC;
	Trigger_Register_6430 |= Select;
	outpw((unsigned short)(BaseAddress + r_TRIGGER_6430), (unsigned short)Trigger_Register_6430); // send to board
} // SetConversionSelect6430




//*************************************************************************
//	SetStartTrigger6430
//
//	This routine selects the start trigger.
//
//	Parameters:
//		Start_Trigger:		0 = software trigger
//  							1 = external trigger
//  							2 = digital interrupt
//  							3 = User TC Counter 1 out
//  							4 = reserved
//  							5 = reserved
//  							6 = reserved
//  							7 = gate mode
//*************************************************************************
void SetStartTrigger6430(uint16 Start_Trigger)
{
	Trigger_Register_6430 &= 0xFFE3;
	Trigger_Register_6430 |= Start_Trigger << 2;
	outpw((unsigned short)(BaseAddress + r_TRIGGER_6430), (unsigned short)Trigger_Register_6430); // send to board
} // SetStartTrigger6430




//*************************************************************************
//	SetStopTrigger6430
//
//	This routine selects the stop trigger.
//
//	Parameters:
//		Stop_Trigger:		0 = software trigger
//  							1 = external trigger
//  							2 = digital interrupt
//  							3 = sample counter
//  							4 = about software trigger
//  							5 = about external trigger
//  							6 = about digital interrupt
//  							7 = about user TC counter 1 out
//*************************************************************************
void SetStopTrigger6430(uint16 Stop_Trigger)
{
	Trigger_Register_6430 &= 0xFF1F;
	Trigger_Register_6430 |= Stop_Trigger << 5;
	outpw((unsigned short)(BaseAddress + r_TRIGGER_6430), (unsigned short)Trigger_Register_6430); // send to board
} // SetStopTrigger6430




//*************************************************************************
//	SetPacerClockSource6430
//
//	This routine sets the pacer clock source.
//
//	Parameters:
//		Source:	0 = Internal
//  				1 = External
//*************************************************************************
void SetPacerClockSource6430(uint16 Source)
{
	Trigger_Register_6430 &= 0xFDFF;
	Trigger_Register_6430 |= Source << 9;
	outpw((unsigned short)(BaseAddress + r_TRIGGER_6430), (unsigned short)Trigger_Register_6430); // send to board
} // SetPacerClockSource6430




//*************************************************************************
//	SetBurstTrigger6430
//
//	This routine selects the burst trigger.
//
//	Parameters:
//		Burst_Trigger:		0 = Software trigger
//  							1 = pacer clock
//  							2 = external trigger
//  							3 = digital interrupt
//*************************************************************************
void SetBurstTrigger6430(uint16 Burst_Trigger)
{
	Trigger_Register_6430 &= 0xF3FF;
	Trigger_Register_6430 |= Burst_Trigger << 10;
	outpw((unsigned short)(BaseAddress + r_TRIGGER_6430), (unsigned short)Trigger_Register_6430); // send to board
} // SetBurstTrigger6430




//*************************************************************************
//	SetTriggerPolarity6430
//
//	This routine sets the external trigger polarity.
//
//	Parameters:
//		Polarity:	0 = positive edge
//  					1 = negative edge
//*************************************************************************
void SetTriggerPolarity6430(uint16 Polarity)
{
	Trigger_Register_6430 &= 0xEFFF;
	Trigger_Register_6430 |= (Polarity << 12);
	outpw((unsigned short)(BaseAddress + r_TRIGGER_6430), (unsigned short)Trigger_Register_6430); // send to board
} // SetTriggerPolarity6430




//*************************************************************************
//	SetTriggerRepeat6430
//
//	This routine sets the trigger repeat bit.
//
//	Parameters:
//		Repeat:	0 = Single Cycle
//  				1 = Repeat Cycle
//*************************************************************************
void SetTriggerRepeat6430(uint16 Repeat)
{
	Trigger_Register_6430 &= 0xDFFF;
	Trigger_Register_6430 |= Repeat << 13;
	outpw((unsigned short)(BaseAddress + r_TRIGGER_6430), (unsigned short)Trigger_Register_6430); // send to board
} // SetTriggerRepeat6430




//************************ RESERVED ************************
//	Read at BA + 8





//************************ IRQ REGISTER ***********************************
//	Write at BA + 8

//*************************************************************************
//	LoadIRQRegister6430
//
//	This routine loads the interrupt register with one write operation.
//
//	Parameters:
//		Value:			0 - 65535
//*************************************************************************
void LoadIRQRegister6430(uint16 Value)
{
	IRQ_Register_6430 = Value;
	outpw((unsigned short)(BaseAddress + r_IRQ_6430), (unsigned short)IRQ_Register_6430); // send to board
} // LoadIRQRegister6430




//*************************************************************************
//	SetIRQ16430
//
//	This routine sets the source and channel for interrupt 1.
//
//	Parameters:
//		Source:		0 = A/D sample counter
//  					1 = A/D start convert
//						2 = A/D End-of-Convert
//						3 = A/D Write FIFO
//						4 = A/D FIFO half full
//						5 = A/D DMA done
//						6 = Reset channel/gain table
//						7 = Pause channel/gain table
//						8 = External Pacer Clock
//						9 = External trigger
//						10 = Digital chip interrupt
//						11 = User TC out 0
//						12 = User TC out 0 inverted
//						13 = User TC out 1
//						14 = Digital Input FIFO half full
//						15 = DIN Write FIFO
//						16 .. 31 = reseved
//
// 	Channel:		0 = disabled
//						1 = IRQ 3
//						2 = IRQ 5
//						3 = IRQ 9
//						4 = IRQ 10
//						5 = IRQ 11
//						6 = IRQ 12
//						7 = IRQ 15
//*************************************************************************
void SetIRQ16430(uint16 Source, uint16 Channel)
{
	switch(Channel) {
		case 3:Channel = 1;
		break;
		case 5: Channel = 2;
		break;
		case 9: Channel = 3;
		break;
		case 10: Channel = 4;
		break;
		case 11: Channel = 5;
		break;
		case 12: Channel = 6;
		break;
		case 15: Channel = 7;
		break;
		default: Channel = 0;
		break;
	}

	IRQ_Register_6430 &= 0xFF00;
	IRQ_Register_6430 |= Source | (Channel << 5);
	outpw((unsigned short)(BaseAddress + r_IRQ_6430), (unsigned short)IRQ_Register_6430);
} // SetIRQ16430




//*************************************************************************
//	SetIRQ26430
//
//	This routine sets the source and channel for interrupt 2.
//
//	Parameters:
//		Source:		0 = A/D sample counter
//  					1 = A/D start convert
//						2 = A/D End-of-Convert
//						3 = A/D Write FIFO
//						4 = A/D FIFO half full
//						5 = A/D DMA done
//						6 = Reset channel/gain table
//						7 = Pause channel/gain table
//						8 = External Pacer Clock
//						9 = External trigger
//						10 = Digital chip interrupt
//						11 = User TC out 0
//						12 = User TC out 0 inverted
//						13 = User TC out 1
//						14 = Digital Input FIFO half full
//						15 = DIN Write FIFO
//						16 .. 31 = reseved
//
// 	Channel:		0 = disabled
//						1 = IRQ 3
//						2 = IRQ 5
//						3 = IRQ 9
//						4 = IRQ 10
//						5 = IRQ 11
//						6 = IRQ 12
//						7 = IRQ 15
//*************************************************************************
void SetIRQ26430(uint16 Source, uint16 Channel)
{


	switch(Channel) {
		case 3:Channel = 1;
		break;
		case 5: Channel = 2;
		break;
		case 9: Channel = 3;
		break;
		case 10: Channel = 4;
		break;
		case 11: Channel = 5;
		break;
		case 12: Channel = 6;
		break;
		case 15: Channel = 7;
		break;
		default: Channel = 0;
		break;
	}
	IRQ_Register_6430 &= 0x00FF;
	IRQ_Register_6430 |= (Source << 8) | (Channel << 13);
	outpw((unsigned short)(BaseAddress + r_IRQ_6430), (unsigned short)IRQ_Register_6430);
} // SetIRQ26430




//************************ READ DIGITAL INPUT FIFO **********************************
//	Read at BA + 10

//*************************************************************************
//	ReadDINFIFO6430
//
//	This Routine Reads the Data from the Digital Input FIFO.
//
//	Returns 8 bit value.
//*************************************************************************
uint16  ReadDINFIFO6430(void)
{
	return((uint16) inp((unsigned short)(BaseAddress + r_DIN_FIFO_6430)));
} // ReadDINFIFO6430




//************************ DIN CONFIG REGISTER ****************************
//	Write at BA + 10

//*************************************************************************
//	LoadDINConfigRegister6430
//
//	This routine loads the Digital Input config register with one write operation.
//
//	Parameters:
//		Value:			0 - 65535
//*************************************************************************
void LoadDINConfigRegister6430(uint16 Value)
{
	DIN_Register_6430 = Value;
	outpw((unsigned short)(BaseAddress + r_DIN_CONFIG_6430), (unsigned short)DIN_Register_6430); // send to board
} // LoadDACConfigRegister6430




//*************************************************************************
//	ConfigDINClock6430
//
//	This routine configures the Digital Input FIFO clock source.
//
//	Parameters:
//		DIN_Clock:		0 = user T/C out 0
//  						1 = user T/C out 1
//  						2 = write A/D FIFO
//  						3 = external pacer clock
//  						4 = external trigger
//  						5 = reserved
//  						6 = reserved
//  						7 = reserved
//*************************************************************************
void ConfigDINClock6430(uint16 DIN_Clock)
{
	DIN_Register_6430 &= 0xFFF8;
	DIN_Register_6430 |= DIN_Clock;
	outpw((unsigned short)(BaseAddress + r_DIN_CONFIG_6430), (unsigned short)DIN_Register_6430); // send to board
} // ConfigDINClock6430




//*************************************************************************
//	DINClockEnable6430
//
//	This routine enables the Digital Input FIFO clock.
//
//	Parameters:
//		DIN_Clock:		0 = disabled
//  						1 = enabled
//*************************************************************************
void DINClockEnable6430(uint16 DIN_Clock)
{
	DIN_Register_6430 &= 0xFFF7;
	DIN_Register_6430 |= (DIN_Clock << 3);
	outpw((unsigned short)(BaseAddress + r_DIN_CONFIG_6430), (unsigned short)DIN_Register_6430); // send to board
} // DINClockEnable6430




//************************ RESERVED *************************
//	Read at BA + 12





//************************ DAC 1 REGISTER *********************************
//	Write at BA + 12

//*************************************************************************
//	LoadDAC6430
//
//	This routine loads the DAC value.
//
//	Parameters:
//		Data:			0 - 65535
//*************************************************************************
void LoadDAC6430(int16 Data)
{
	outpw((unsigned short)(BaseAddress + r_DAC1_6430), (unsigned short)Data); // send to board
} // LoadDAC6430




//************************ LOAD A/D SAMPLE COUNTER ************************
//	Read at BA + 14

//*************************************************************************
//	LoadADSampleCounter6430
//
//	This routine loads the A/D sample counter.
//
//	Parameters:
//		NumOfSamples:		0 - 65535
//*************************************************************************
void LoadADSampleCounter6430(uint16 NumOfSamples)
{
	SelectTimerCounter6430(1);
	ClockMode6430(2, 2);
	ClockDivisor6430(2, NumOfSamples);
	inpw((unsigned short)(BaseAddress + r_LOAD_AD_SAMPLE_COUNT_6430));
	inpw((unsigned short)(BaseAddress + r_LOAD_AD_SAMPLE_COUNT_6430));
} // LoadADSampleCounter6430




//************************ TIMER COUNTER ROUTINES **************************

//*************************************************************************
//	ClockMode6430
//
//	This routine is used to set the mode of a designated counter
//	in the 8254 programmable interval timer (PIT).
//
//	Parameters:
//		Timer:		0,1,2
//		Mode:			0,1,2,3,4,5
//*************************************************************************
void ClockMode6430(uchar8 Timer, uchar8 Mode)
{
	uchar8 StatusByte;

	StatusByte = (Timer << 6) + (Mode << 1) + 0x30;
	outp((unsigned short)(BaseAddress + r_TIMER_CTRL_6430), (unsigned short)StatusByte);
} // ClockMode6430




//*************************************************************************
//	ClockDivisor6430
//
//	This routine is used to set the divisor of a designated
//	counter on the 8254 programmable interval timer (PIT).  This procedure
//	assumes that the counter has already been set to receive the least
//	significant uchar8 (LSB) of the divisor followed by the most significant
//	uchar8 (MSB).
//
//	Parameters:
//		Timer:		0,1,2
//		Divisor:	0 - 65535
//*************************************************************************
void ClockDivisor6430(uchar8 Timer, uint16 Divisor)
{
	uchar8 MSB, LSB;

	LSB = Divisor & 0xff;
	MSB = (Divisor & 0xff00) >> 8;
	outp((unsigned short)(BaseAddress + r_TIMER_CLCK0_6430 + (Timer * 2)), (unsigned short)LSB);
	outp((unsigned short)(BaseAddress + r_TIMER_CLCK0_6430 + (Timer * 2)), (unsigned short)MSB);
} // ClockDivisor6430




//*************************************************************************
//	SetPacerClock6430
//
//	This routine sets the pacer clock rate. It will automatically decide
//	whether to use a 16 or 32 bit clock depending on the rate.
//
//	Parameters:
//		ClockRate:		500 KHz or less
// Returns:
//		The actual clock frequency that is programmed.
//*************************************************************************
float32 SetPacerClock6430(float32 ClockRate)
{
	unsigned long    i, number,loopvalue;
	unsigned long    one, two;
	uint16           mode = 0;

	if (ClockRate > 8000000L/65535L)							// use 16 if you can.
	{
			Trigger_Register_6430 &= 0xFEFF;	              // 16 bit pacer clock
			mode = 0;
	}
	else
	{
			Trigger_Register_6430 |= 0x0100;		            // 32 bit pacer clock
			mode = 1;
	}
	outpw((unsigned short)(BaseAddress + r_TRIGGER_6430), (unsigned short)Trigger_Register_6430);

	SelectTimerCounter6430(0);
	ClockMode6430(0, 2);
	if (mode)
	{																						// 32 bit mode
			number = 8000000L / ClockRate;
			if ((number/2) > 65535L )
				loopvalue = 65535L;
			else
				loopvalue = number / 2;
	 for (i = 2 ;i <= loopvalue; i++)
		{
			one = i;
			two = number / one;
			if (one*two == number)
				if (two <= 65535L)
			 break;
		} // for
	 if (one*two != number)
		{
			if ((number/2) > 65535L )
				loopvalue = 65535L;
			else
				loopvalue = number / 2;
			for (i = 2 ;i <= loopvalue; i++)
			{
				one = i;
				two = number / one;
				if (two <= 65535L)
				break;
			} // for
		} // if
		ClockDivisor6430(0, (uint16)one);					// set divisor clock 0
																		// this should be the smallest number
																		// of the two.
		ClockMode6430(1, 2);
		ClockDivisor6430(1, (uint16)(two));					// set divisor clock 1
		return(8000000.0 / (float)(one * two));
	} // if (mode)
	else
	{																	//16 bit mode
		ClockDivisor6430(0, (8000000L/ClockRate));
		return(8000000.0 / (int)(8000000L/ClockRate));
	} // else
} // SetPacerClock6430




//*************************************************************************
//	SetBurstClock6430
//
//	This routine sets the burst clock rate.
//
//	Parameters:
//		Burst Rate:		500 KHz or less
// Returns:
//		The actual clock frequency that is programmed.
//*************************************************************************
float32 SetBurstClock6430(float32 BurstRate)
{
	SelectTimerCounter6430(0);
	ClockMode6430(2, 2);
	ClockDivisor6430(2, (8000000L / BurstRate));
	return(8000000.0 / (int)(8000000L/BurstRate));
} // SetBurstClock6430




//*************************************************************************
//	SetUserClock6430
//
//	This routine sets the user timer counters.
//
//	Parameters:
//		Timer:		0, 1, 2
//		InputRate:	Input clock to selected timer.
//		OutputRate:	Desired output rate from selected timer.
//
// Returns:
//		The actual clock frequency that is programmed.
//*************************************************************************
float32 SetUserClock6430(uchar8 Timer, float32 InputRate, float32 OutputRate)
{
	SelectTimerCounter6430(1);

	ClockMode6430(Timer, 2);
	ClockDivisor6430(Timer, (InputRate/OutputRate));

	return(InputRate / (int)(InputRate/OutputRate));

} // SetUserClock6430




//*************************************************************************
//	ReadTimerCounter6430
//
//	This routine is used to read the contents of the selected timer/counter.
//
//	Parameters:
//		Timer:		0,1
//		Clock:		0,1,2
//		Returns:	uint16
//*************************************************************************
uint16 ReadTimerCounter6430(uchar8 Timer, uchar8 Clock)
{
	uchar8 MSB, LSB;

	SelectTimerCounter6430(Timer);

	outp((unsigned short)(BaseAddress + r_TIMER_CTRL_6430), (unsigned short)(Clock << 6));		//send latch command
	LSB = inp((unsigned short)(BaseAddress + r_TIMER_CLCK0_6430 + (Clock * 2)));
	MSB = inp((unsigned short)(BaseAddress + r_TIMER_CLCK0_6430 + (Clock * 2)));
	return((256 * MSB) + LSB);
} // ReadTimerCounter6430




//*************************************************************************
//	DoneTimer6430
//
//	Initialize the timers for high speed to ensure the immediate load.
//
//	Parameters:
//		None
//*************************************************************************
void DoneTimer6430(void)
{
	SelectTimerCounter6430(1);

	ClockMode6430(0, 2);
	ClockMode6430(1, 2);
	ClockDivisor6430(0, 2);
	ClockDivisor6430(1, 2);
} // DoneTimer6430

/* $Revision: 1.2 $ */
#if !defined(__DRVR6420_H)
#define __DRVR6420_H

typedef unsigned char uchar8;		// 8 bit unsigned integer.
typedef char char8;					// 8 bit signed integer.
typedef unsigned int uint16;		// 16 unsigned integer.
typedef int int16;					// 16 bit signed integer.
typedef float float32;				// 32 bit floating point.

// Structure for A/D Table
typedef struct
			{
			 uint16 Channel;
			 uint16 Gain;
			 uint16 ADRange;
			 uint16 Se_Diff;
			 uint16 Pause;
			 uint16 Skip;
			} ADTableRow;


extern uint16  BaseAddress;


char* TitleString6420(void);




//*************************************************************************
//	SetBaseAddress
//
//	This routine is used to set the variable BaseAddress.
//
//	Parameters:
//		Address:		Base address of board.
//*************************************************************************
void SetBaseAddress(uint16 Address);




//*************************************************************************
//	InitBoard6420
//
//	This Routine Should allways be called first.
//	This clears the board and varibles the driver uses.
//
//	Parameters:
//		None
//*************************************************************************
void InitBoard6420(void);




//************************ CLEAR ROUTINES *********************************
//	Read & Write at BA + 0

//*************************************************************************
//	ClearRegister6420
//
//	This routine is used to write the clear register with one command
// and issue a clear to the board.
//
//	Parameters:
//		ClearValue:		1 - 65535
//*************************************************************************
void ClearRegister6420(uint16 ClearValue);




//*************************************************************************
//	ClearBoard6420
//
//	This routine is used to clear board.
//
//	Parameters:
//		None
//*************************************************************************
void ClearBoard6420(void);




//*************************************************************************
//	ClearADFIFO6420
//
//	This routine is used to clear all the data from the A/D FIFO.
//
//	Parameters:
//		None
//*************************************************************************
void ClearADFIFO6420(void);




//*************************************************************************
//	ClearADDMADone6420
//
//	This routine is used to clear the A/D DMA done status bit.
//
//	Parameters:
//		None
//*************************************************************************
void ClearADDMADone6420(void);




//*************************************************************************
//	ClearChannelGainTable6420
//
//	This routine is used to clear both the AD Table and the Digital Table.
//
//	Parameters:
//		None
//*************************************************************************
void ClearChannelGainTable6420(void);




//*************************************************************************
//	ResetChannelGainTable6420
//
//	This routine is used to reset both the AD Table and the Digital Table
//	pointers to the first location in the table.
//
//	Parameters:
//		None
//*************************************************************************
void ResetChannelGainTable6420(void);




//*************************************************************************
//	ClearDINFIFO6420
//
//	This routine is used to clear the Digital Input FIFO.
//
//	Parameters:
//		None
//*************************************************************************
void ClearDINFIFO6420(void);




//*************************************************************************
//	ClearIRQ16420
//
//	This routine is used to clear the IRQ 1 circuitry and status bit.
//
//	Parameters:
//		None
//*************************************************************************
void ClearIRQ16420(void);




//*************************************************************************
//	ClearIRQ26420
//
//	This routine is used to clear the IRQ 2 status bit.
//
//	Parameters:
//		None
//*************************************************************************
void ClearIRQ26420(void);




//************************ QUERY ROUTINES *********************************
//	Read at BA + 2

//*************************************************************************
//	ReadStatus6420
//
//	This routine returns the status from the board.
//
//	Returns:		16 bit unsigned integer
//*************************************************************************
uint16 ReadStatus6420(void);




//*************************************************************************
//	IsADFIFOEmpty6420
//
//	This routine checks to see if the A/D FIFO is empty.
//
//	Returns:				1 if FIFO is empty
//							0 if FIFO is not empty
//*************************************************************************
uint16 IsADFIFOEmpty6420(void);




//*************************************************************************
//	IsADFIFOFull6420
//
//	This routine checks to see if the A/D FIFO is full.
//
//	Returns:				1 if FIFO is full
//							0 if FIFO is not full
//*************************************************************************
uint16 IsADFIFOFull6420(void);




//*************************************************************************
//	IsADHalted6420
//
//	This routine checks to see if the AD is halted.
//
//	Returns:				1 if AD is halted
//							0 if AD is not halted
//*************************************************************************
uint16 IsADHalted6420(void);




//*************************************************************************
//	IsADConverting6420
//
//	This routine checks to see if the AD converting.
//
//	Returns:				1 if AD is converting
//							0 if AD is not converting
//*************************************************************************
uint16 IsADConverting6420(void);




//*************************************************************************
//	IsADDMADone6420
//
//	This routine checks to see if the A/D DMA transfer is done.
//
//	Returns:				1 if DMA is done
//							0 if DMA is not done
//*************************************************************************
uint16 IsADDMADone6420(void);




//*************************************************************************
//	IsFirstADDMADone6420
//
//	This routine checks to see if the A/D DMA transfer is done on the first
//	channel.
//
//	Returns:				1 if DMA is done
//							0 if DMA is not done
//*************************************************************************
uint16 IsFirstADDMADone6420(void);




//*************************************************************************
//	IsBurstClockOn6420
//
//	This routine checks to see if the burst clock is enabled.
//
//	Returns:				1 if Burst Clock is on
//							0 if Burst Clock is off
//*************************************************************************
uint16 IsBurstClockOn6420(void);




//*************************************************************************
//	IsPacerClockOn6420
//
//	This routine checks to see if the pacer clock is running.
//
//	Returns:				1 if Pacer Clock is on
//							0 if Pacer Clock is off
//*************************************************************************
uint16 IsPacerClockOn6420(void);




//*************************************************************************
//	IsAboutTrigger6420
//
//	This routine checks to see if the about trigger has occurred.
//
//	Returns:				1 if trigger has occurred
//							0 if trigger has not occurred
//*************************************************************************
uint16 IsAboutTrigger6420(void);




//*************************************************************************
//	IsDigitalIRQ6420
//
//	This routine checks to see if the digital I/O chip has generated
//	an interrupt.
//
//	Returns:				1 if IRQ has been generated
//							0 if no IRQ
//*************************************************************************
uint16 IsDigitalIRQ6420(void);




//*************************************************************************
//	IsDINFIFOEmpty6420
//
//	This routine checks to see if the Digital Input FIFO is empty.
//
//	Returns:				1 if FIFO is empty
//							0 if FIFO is not empty
//*************************************************************************
uint16 IsDINFIFOEmpty6420(void);




//*************************************************************************
//	IsDINFIFOHalf6420
//
//	This routine checks to see if the Digital Input FIFO is half full.
//
//	Returns:				1 if FIFO is half full
//							0 if FIFO is not half full
//*************************************************************************
uint16 IsDINFIFOHalf6420(void);




//*************************************************************************
//	IsDINFIFOFull6420
//
//	This routine checks to see if the Digital Input FIFO is full.
//
//	Returns:				1 if FIFO is full
//							0 if FIFO is not full
//*************************************************************************
uint16 IsDINFIFOFull6420(void);




//*************************************************************************
//	IsIRQ16420
//
//	This routine checks the IRQ 1 status bit.
//
//	Returns:				1 if IRQ has been generated
//							0 if no IRQ
//*************************************************************************
uint16 IsIRQ16420(void);




//*************************************************************************
//	IsIRQ26420
//
//	This routine checks the IRQ 2 status bit.
//
//	Returns:				1 if IRQ has been generated
//							0 if no IRQ
//*************************************************************************
uint16 IsIRQ26420(void);




//************************ CONTROL REGISTER *******************************
//	Write at BA + 2

//*************************************************************************
//	LoadControlRegister6420
//
//	This routine loads the control register with one write operation.
//
//	Parameters:
//		Value:		0 - 65535
//*************************************************************************
void LoadControlRegister6420(uint16 Value);




//*************************************************************************
//	EnableTables6420
//
//	This Routine Enables and Disables both the AD and Digital Tables.
//
//	Parameters:
//			Enable_AD_Table:			0 = disable
//    	                	   	1 = enable
// 		Enable_Digital_Table:	0 = disable
//    	                  	 	1 = enable
//*************************************************************************
void EnableTables6420(uint16 Enable_AD_Table, uint16 Enable_Digital_Table);




//*************************************************************************
//	ChannelGainDataStore6420
//
//	This routine enables the Channel Gain Data Store feature of the board.
//
//	Parameters:
//			Enable:		0 = Disable
//							1 = Enable
//*************************************************************************
void ChannelGainDataStore6420(uint16 Enable);




//*************************************************************************
//	SelectTimerCounter6420
//
//	This routine selects one of the four 8254 timer chips.
//
//	Parameters:
//		Select:	0 = Clock TC (Pacer & Burst clocks)
//					1 = User TC (A/D sample counter & User timer/counters)
//					2 = reserved
//					3 = reserved
//*************************************************************************
void SelectTimerCounter6420(uint16 Select);




//*************************************************************************
//	SetADSampleCounterStop6420
//
//	This routine enables and disables the A/D sample counter stop bit.
//
//	Parameters:
//		Enable:	0 = Enable
//  				1 = Disable
//*************************************************************************
void SetSampleCounterStop6420(uint16 Enable);




//*************************************************************************
//	SetADPauseEnable6420
//
//	This routine enables and disables the A/D pause bit.
//
//	Parameters:
//		Enable:	0 = Enable
//  				1 = Disable
//*************************************************************************
void SetPauseEnable6420(uint16 Enable);




//*************************************************************************
//	SetADDMA6420
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
void SetADDMA6420(uint16 Channel1, uint16 Channel2);




//************************ READ A/D DATA **********************************
//	Read at BA + 4

//*************************************************************************
//	ReadADData6420
//
//	This Routine Reads the Data from the FIFO.
//
//	Returns signed 12 bit AD Data.
//*************************************************************************
int16  ReadADData6420(void);




//*************************************************************************
//	ReadChannelGainDataStore6420
//
//	This Routine Reads the Channel/Gain Data from the FIFO when the
// Channel Gain Data Store feature of the board is enabled.
//
//	Returns a 16 bit value: Bottom 8 bits = A/D table value
//									Upper 8 bits  = digital table value
//*************************************************************************
uint16  ReadChannelGainDataStore6420(void);




//*************************************************************************
//	ReadADDataWithMarker6420
//
//	This Routine Reads the Data from the FIFO.
//
//	Returns signed 12 bit AD Data and 3 bit Data Marker.
//*************************************************************************
int16  ReadADDataWithMarker6420(void);




//*************************************************************************
//	ReadADDataMarker6420
//
//	This Routine Reads the Data Marker from the FIFO.
//
//	Returns 3 bit Data Marker.
//*************************************************************************
uint16  ReadADDataMarker6420(void);



//************************ LOAD CHANNEL/GAIN ******************************
//	Write at BA + 4

//*************************************************************************
//	SetChannelGain6420
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
//			Range:		0 = +/- 5v
//							1 = +/- 10v
//							2 = 0v - 10v
//							3 = reserved
//
//			Se_Diff:		0 = single ended
//							1 = differential
//*************************************************************************
void SetChannelGain6420(uint16 Channel, uint16 Gain, uint16 Range, uint16 Se_Diff);




//*************************************************************************
//	LoadADTable6420
//
//	This routine loads the AD Table with the given number of Entrys.
//
//	Parameters:
//	The struct ADTableRow is define in DRVR6420.h
//	typedef struct
//	{
//		uint16 Channel:	0 - 15
//
//		uint16 Gain:		0 = x1
//							1 = x2
//							2 = x4
//							3 = x8
//							4 = reserved
//							5 = reserved
//							6 = reserved
//							7 = reserved
//
//		uint16 ADRange:	0 = +/- 5v
//							1 = +/- 10v
//							2 = 0v - 10v
//							3 = reserved
//
//		uint16 Se_Diff:	0 = single ended
//							1 = differential
//
//		uint16 Pause:		0 = disabled
//							1 = enabled
//
//		uint16 Skip:		0 = disabled
//							1 = enabled
//} ADTableRow;
//		Num_of_Entry:	1-1024
//*************************************************************************
void LoadADTable6420(uint16 Num_of_Entry, ADTableRow *ADTable);




//*************************************************************************
//	LoadDigitalTable6420
//
//	This routine loads the Digital Table with the given number of Entrys.
//
//	Parameters:
//		Channel:			0 - 255
//		Num_of_Chan:	1 -1024
//*************************************************************************
void LoadDigitalTable6420( uint16 Num_of_Chan, uchar8 *Channel);




//************************ START CONVERSION *******************************
//	Read at BA + 6

//*************************************************************************
//	StartConversion6420
//
//	This routine is used to create software triggers or enable hardware
//	triggers depending on the conversion mode.
//
//	Parameters:
//		None
//*************************************************************************
void StartConversion6420(void);




//************************ TRIGGER REGISTER *******************************
//	Write at BA + 6

//*************************************************************************
//	LoadTriggerRegister6420
//
//	This routine loads the trigger register with one write operation.
//
//	Parameters:
//		Value:			0 - 65535
//*************************************************************************
void LoadTriggerRegister6420(uint16 Value);




//*************************************************************************
//	SetConversionSelect6420
//
//	This routine selects the conversion mode.
//
//	Parameters:
//		Select:	0 = software trigger
//					1 = pacer clock
//					2 = burst clock
//					3 = digital interrupt
//*************************************************************************
void SetConversionSelect6420(uint16 Select);




//*************************************************************************
//	SetStartTrigger6420
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
void SetStartTrigger6420(uint16 Start_Trigger);




//*************************************************************************
//	SetStopTrigger6420
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
void SetStopTrigger6420(uint16 Stop_Trigger);




//*************************************************************************
//	SetPacerClockSource6420
//
//	This routine sets the pacer clock source.
//
//	Parameters:
//		Source:	0 = Internal
//  				1 = External
//*************************************************************************
void SetPacerClockSource6420(uint16 Source);




//*************************************************************************
//	SetBurstTrigger6420
//
//	This routine selects the burst trigger.
//
//	Parameters:
//		Burst_Trigger:		0 = Software trigger
//  							1 = pacer clock
//  							2 = external trigger
//  							3 = digital interrupt
//*************************************************************************
void SetBurstTrigger6420(uint16 Burst_Trigger);




//*************************************************************************
//	SetTriggerPolarity6420
//
//	This routine sets the external trigger polarity.
//
//	Parameters:
//		Polarity:	0 = positive edge
//  					1 = negative edge
//*************************************************************************
void SetTriggerPolarity6420(uint16 Polarity);




//*************************************************************************
//	SetTriggerRepeat6420
//
//	This routine sets the trigger repeat bit.
//
//	Parameters:
//		Repeat:	0 = Single Cycle
//  				1 = Repeat Cycle
//*************************************************************************
void SetTriggerRepeat6420(uint16 Repeat);




//************************ RESERVED ************************
//	Read at BA + 8





//************************ IRQ REGISTER ***********************************
//	Write at BA + 8

//*************************************************************************
//	LoadIRQRegister6420
//
//	This routine loads the interrupt register with one write operation.
//
//	Parameters:
//		Value:			0 - 65535
//*************************************************************************
void LoadIRQRegister6420(uint16 Value);




//*************************************************************************
//	SetIRQ16420
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
void SetIRQ16420(uint16 Source, uint16 Channel);




//*************************************************************************
//	SetIRQ26420
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
void SetIRQ26420(uint16 Source, uint16 Channel);




//************************ READ DIGITAL INPUT FIFO **********************************
//	Read at BA + 10

//*************************************************************************
//	ReadDINFIFO6420
//
//	This Routine Reads the Data from the Digital Input FIFO.
//
//	Returns 8 bit value.
//*************************************************************************
uint16  ReadDINFIFO6420(void);




//************************ DIN CONFIG REGISTER ****************************
//	Write at BA + 10

//*************************************************************************
//	LoadDINConfigRegister6420
//
//	This routine loads the Digital Input config register with one write operation.
//
//	Parameters:
//		Value:			0 - 65535
//*************************************************************************
void LoadDINConfigRegister6420(uint16 Value);




//*************************************************************************
//	ConfigDINClock6420
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
void ConfigDINClock6420(uint16 DIN_Clock);




//*************************************************************************
//	DINClockEnable6420
//
//	This routine enables the Digital Input FIFO clock.
//
//	Parameters:
//		DIN_Clock:		0 = disabled
//  						1 = enabled
//*************************************************************************
void DINClockEnable6420(uint16 DIN_Clock);




//************************ RESERVED *************************
//	Read at BA + 12





//************************ DAC 1 REGISTER *********************************
//	Write at BA + 12

//*************************************************************************
//	LoadDAC6420
//
//	This routine loads the DAC value.
//
//	Parameters:
//		Channel:		0 = DAC 1
//  					1 = DAC 2
//
//		Data:			0 - 4095
//*************************************************************************
void LoadDAC6420(uint16 Channel, int16 Data);




//************************ LOAD A/D SAMPLE COUNTER ************************
//	Read at BA + 14

//*************************************************************************
//	LoadADSampleCounter6420
//
//	This routine loads the A/D sample counter.
//
//	Parameters:
//		NumOfSamples:		0 - 65535
//*************************************************************************
void LoadADSampleCounter6420(uint16 NumOfSamples);




//************************ DAC 2 REGISTER *********************************
//	Write at BA + 14

// See BA + 12




//************************ TIMER COUNTER ROUTINES **************************

//*************************************************************************
//	ClockMode6420
//
//	This routine is used to set the mode of a designated counter
//	in the 8254 programmable interval timer (PIT).
//
//	Parameters:
//		Timer:		0,1,2
//		Mode:			0,1,2,3,4,5
//*************************************************************************
void ClockMode6420(uchar8 Timer, uchar8 Mode);




//*************************************************************************
//	ClockDivisor6420
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
void ClockDivisor6420(uchar8 Timer, uint16 Divisor);




//*************************************************************************
//	SetPacerClock6420
//
//	This routine sets the pacer clock rate. It will automatically decide
//	whether to use a 16 or 32 bit clock depending on the rate.
//
//	Parameters:
//		ClockRate:		500 KHz or less
// Returns:
//		The actual clock frequency that is programmed.
//*************************************************************************
float32 SetPacerClock6420(float32 ClockRate);




//*************************************************************************
//	SetBurstClock6420
//
//	This routine sets the burst clock rate.
//
//	Parameters:
//		Burst Rate:		500 KHz or less
// Returns:
//		The actual clock frequency that is programmed.
//*************************************************************************
float32 SetBurstClock6420(float32 BurstRate);




//*************************************************************************
//	SetUserClock6420
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
float32 SetUserClock6420(uchar8 Timer, float32 InputRate, float32 OutputRate);




//*************************************************************************
//	ReadTimerCounter6420
//
//	This routine is used to read the contents of the selected timer/counter.
//
//	Parameters:
//		Timer:		0,1
//		Clock:		0,1,2
//		Returns:	uint16
//*************************************************************************
uint16 ReadTimerCounter6420(uchar8 Timer, uchar8 Clock);




//*************************************************************************
//	DoneTimer6420
//
//	Initialize the timers for high speed to ensure the immediate load.
//
//	Parameters:
//		None
//*************************************************************************
void DoneTimer6420(void);


#endif  // __DRVR6420_H

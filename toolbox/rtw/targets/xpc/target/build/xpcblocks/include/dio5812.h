/* $Revision: 1.1 $ */
#if !defined(__DIO5812_H)
#define __DIO5812_H

#include "DRVR6430.h"

//*************************************************************************
//	SelectRegister5812
//
//	This routine picks the different registers on the selected DIO chip.
//
//	Parameters:
//		SelectedChip:	0, 1, 2 .....
//		Select:			0 = Clear mode
//							1 = Port 0 direction
//							2 = Port 0 mask
//							3 = Port 0 compare
//*************************************************************************
void SelectRegister5812(uchar8 SelectedChip, uchar8 Select);




//*************************************************************************
//	ClearChip5812
//
//	This routine clears the selected DIO chip.
//
//	Parameters:
//		SelectedChip:		0, 1, 2 .....
//*************************************************************************
void ClearChip5812(uchar8 SelectedChip);




//*************************************************************************
//	ClearIrq5812
//
//	This routine clears the selected DIO chips IRQ status bit.
//
//	Parameters:
//		SelectedChip:		0, 1, 2 .....
//*************************************************************************
void ClearIrq5812(uchar8 SelectedChip);




//*************************************************************************
//	EnableIrq5812
//
//	This routine enables the selected DIO chips interrupt.
//
//	Parameters:
//		SelectedChip:		0, 1, 2 .....
//		Enable:				0 = Disabled
//								1 = Enabled
//*************************************************************************
void EnableIrq5812(uchar8 SelectedChip, uchar8 Enable);




//*************************************************************************
//	SetPort1Direction5812
//
//	This routine sets the selected DIO chips port 1 direction.
//
//	Parameters:
//		SelectedChip:		0, 1, 2 .....
//		Direction:			0 = In
//								1 = Out
//*************************************************************************
void SetPort1Direction5812(uchar8 SelectedChip, uchar8 Direction);




//*************************************************************************
//	SetPort0Direction5812
//
//	This routine sets the selected DIO chips port 0 direction.
//
//	Parameters:
//		SelectedChip:		0, 1, 2 .....
//		Direction:			0 - 255
//								0 = In
//								1 = Out
//*************************************************************************
void SetPort0Direction5812(uchar8 SelectedChip, uchar8 Direction);




//*************************************************************************
//	LoadMask5812
//
//	This routine loads the selected DIO chips mask register.
//
//	Parameters:
//		SelectedChip:		0, 1, 2 .....
//		Mask:					0 - 255
//*************************************************************************
void LoadMask5812(uchar8 SelectedChip, uchar8 Mask);




//*************************************************************************
//	LoadCompare5812
//
//	This routine loads the selected DIO chips compare register.
//
//	Parameters:
//		SelectedChip:		0, 1, 2 .....
//		Compare:				0 - 255
//*************************************************************************
void LoadCompare5812(uchar8 SelectedChip, uchar8 Compare);




//*************************************************************************
//	ReadDIO5812
//
//	This routine reads the selected DIO chips port.
//
//	Parameters:
//		SelectedChip:		0, 1, 2 .....
//		Port:					0, 1
//*************************************************************************
uchar8 ReadDIO5812(uchar8 SelectedChip, uchar8 Port);




//*************************************************************************
//	ReadCompareRegister5812
//
//	This routine reads the selected DIO chips compare register.
//
//	Parameters:
//		SelectedChip:		0, 1, 2 .....
//*************************************************************************
uchar8 ReadCompareRegister5812(uchar8 SelectedChip);




//*************************************************************************
//	SelectClock5812
//
//	This routine sets the selected DIO chips clock source.
//
//	Parameters:
//		SelectedChip:		0, 1, 2 .....
//		Clock:				0 = 8 MHz
//								1 = Programmable clock
//*************************************************************************
void SelectClock5812(uchar8 SelectedChip, uchar8 Clock);



//*************************************************************************
//	SelectIrqMode5812
//
//	This routine sets the selected DIO chips Irq mode.
//
//	Parameters:
//		SelectedChip:		0, 1, 2 .....
//		IrqMode:				0 = Event mode
//								1 = Match mode
//*************************************************************************
void SelectIrqMode5812(uchar8 SelectedChip, uchar8 IrqMode);




//*************************************************************************
//	WriteDIO5812
//
//	This routine writes the selected DIO chips port.
//
//	Parameters:
//		SelectedChip:		0, 1, 2 .....
//		Port:					0, 1
//		Data:					0 - 255
//*************************************************************************
void WriteDIO5812(uchar8 SelectedChip, uchar8 Port, uchar8 Data);




//*************************************************************************
//	IsChipIRQ5812
//
//	This routine checks to see if the selected DIO chip has generated
//	an interrupt.
//
//	Parameters:
//		SelectedChip:		0, 1, 2 .....
//		Returns:				1 if IRQ has been generated
//								0 if no IRQ
//*************************************************************************
uchar8 IsChipIrq5812(uchar8 SelectedChip);

#endif  // __DIO5812_H

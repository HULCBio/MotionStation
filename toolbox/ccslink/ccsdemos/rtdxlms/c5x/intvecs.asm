;*   $Revision: 1.2.2.1 $  $Date: 2003/11/30 23:05:03 $ 
;**********************************************************************
;*		 											 				  *
;*		Copyright (c) 2000 Texas Instruments Incorporated        	  *
;*		Interrupt Vector Assignments for 'C54x						  *
;**********************************************************************
	.title "Interrupt Vectors w/ RTDX for C5XX"
	.tab	4
	.file	"intvecs.asm"

	.mmregs
	.ref _c_int00
	.ref ATRAP_H

;**********************************************************************
;*	   Interrupt/TRAP vectors
;* 
;* Note that not all interupt names will apply to any given target.
;* This serves only as a multi-purpose example across the C54x family.
;* Consult the TI DSP Reference manual to determine which interrupts 
;*   apply to a given target.
;**********************************************************************
	.sect	".intvecs"
RS_V:				; Hardware Reset Vector
SINTR_V:			; Software Reset Vector
	; Note: no need to push XPC here - reset clears XPC
	.if ((__far_mode) & ($isdefed("_BIOSHWINEAR") = 0))
	FBD		_c_int00			; Branch to MainLine.
	.else
	BD		_c_int00			; Branch to MainLine.
	.endif
	STM		#0100h, SP			; initialize Stack Pointer

NMI_V:				; Non-maskable interrupt Vector
SINT16_V:			; Software Interrupt #16 Vector
	B		$
	NOP
	NOP

SINT17_V:			; Software Interrupt #17 Vector
	B		$
	NOP
	NOP

SINT18_V:			; Software Interrupt #18 Vector
	B		$
	NOP
	NOP

SINT19_V:			; Software Interrupt #19 Vector
	B		$
	NOP
	NOP

SINT20_V:			; Software Interrupt #20 Vector
	B		$
	NOP
	NOP

SINT21_V:			; Software Interrupt #21 Vector
	B		$
	NOP
	NOP

SINT22_V:			; Software Interrupt #22 Vector
	B		$
	NOP
	NOP

SINT23_V:			; Software Interrupt #23 Vector
	B		$
	NOP
	NOP

SINT24_V:			; Software Interrupt #24 Vector
	B		$
	NOP
	NOP

SINT25_V:			; Software Interrupt #25 Vector
	B		$
	NOP
	NOP

SINT26_V:			; Software Interrupt #26 Vector
	B		$
	NOP
	NOP

SINT27_V:			; Software Interrupt #27 Vector
	B		$
	NOP
	NOP

SINT28_V:			; Software Interrupt #28 Vector
	B		$
	NOP
	NOP

SINT29_V:			; Software Interrupt #29 Vector (reserved)
MTRAP_V:			; Message TRAP Vector
	B		$
	NOP
	NOP

SINT30_V:			; Software Interrupt #30 Vector (reserved)
ATRAP_V:			; Analysis TRAP Vector
	.if ((__far_mode) & ($isdefed("_BIOSHWINEAR") = 0))
	; ATRAP ISR MUST Be on same page as RTDX Monitor.
	; because this SWI trap can only NEAR return, so storing
	; the XPC on the stack would only corrupt it as there is no
	; FRET from the ATRAP handler which would pop it off.
	;PSHM	XPC					; so do NOT save XPC
	FBD		ATRAP_H				; far branch anyway in case ISR mis-located
	.else
	BD		ATRAP_H 			; Delayed branch to handler
	.endif
	PSHM	ST0					; save Status before branch
	SSBX	CPL 				; switch to stack-based addressing

INT0_V:				; External User Interrupt #0 Vector
SINT0_V:			; Software Interrupt #0 Vector
	B		$
	NOP
	NOP

INT1_V:				; External User Interrupt #1 Vector
SINT1_V:			; Software Interrupt #1 Vector
	B		$
	NOP
	NOP

INT2_V:				; External User Interrupt #2 Vector
SINT2_V:			; Software Interrupt #2 Vector
	B		$
	NOP
	NOP

TINT_V:				; Internal Timer Interrupt Vector
SINT3_V:			; Software Interrupt #3 Vector
	B		$
	NOP
	NOP

RINT0_V:			; Serial Port 0 Receive Interrupt Vector
BRINT0_V:			; Buffered Serial Port 0 Receive Interrupt Vector
SINT4_V:			; Software Interrupt #4 Vector
	B		$
	NOP
	NOP

XINT0_V:			; Serial Port 0 Transmit Interrupt Vector
BXINT0_V:			; Buffered Serial Port Transmit Interrupt Vector
SINT5_V:			; Software Interrupt #5 Vector
	B		$
	NOP
	NOP

RINT1_V:			; Serial Port 1 Receive Interrupt Vector
TRINT_V:			; TDM Serial Port Receive Interrupt
SINT6_V:			; Software Interrupt #6 Vector
	B		$
	NOP
	NOP

XINT1_V:			; Serial Port 1 Transmit Interrupt Vector
TXINT_V:			; TDM Serial Port Transmit Interrupt
SINT7_V:			; Software Interrupt #7 Vector
	B		$
	NOP
	NOP

INT3_V:				; External User Interrupt #3 Vector
SINT8_V:			; Software Interrupt #8 Vector
	B		$    
	NOP
	NOP

HPINT_V:			; HPI Interrupt Vector
SINT9_V:			; Software Interrupt #9 Vector
	B		$
	NOP
	NOP

BRINT1_V:			; Buffered Serial Port 1 Receive Interrupt Vector
SINT10_V:			; Software Interrupt #10 Vector
	B		$
	NOP
	NOP

BXINT1_V:			; Buffered Serial Port 1 Transmit Interrupt Vector
SINT11_V:			; Software Interrupt #11 Vector
	B		$
	NOP
	NOP

RESERVED_V:			; Reserved Interrupt Vectors
	B		$
	NOP
	NOP

	.end
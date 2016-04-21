; Taken from <TIDIR>\examples\dsk6416\rtdx\shared\intvecs6416.asm 
;*************************************************************************
; $Revision: 1.1.6.1 $
; $Date: 2003/11/30 23:06:12 $
; Copyright (c) 2000 Texas Instruments Incorporated
;
; Interrupt Vector Assignments for RTDX.
; - JTAG RTDX defined by default.
; - Also has assignments for High Speed RTDX on C6211 DSK.
;*************************************************************************
	.title "C6x Interrupt Vectors w/ RTDX"
	.tab	4
	
SP			.set	B15			; Redefine for convenience

	.if	$isdefed("JTAGRTDX")
	.mmsg	"INFO -- Compiling for JTAG RTDX.."
	.elseif $isdefed("HSRTDX")
	.mmsg	"INFO -- Compiling for HSRTDX..."
	.else
	.mmsg	"INFO -- Compiling for JTAG RTDX by default."
JTAGRTDX	.set	1
	.endif
	
;************************************************************************
;	Interrupt Service Table (IST)
; 
; This is a table of Interrupt Service Fetch Packets (ISFP) which
; contain code for servicing the interrupts.
; This serves as a multi-purpose example for the C6x family.
; Consult the TI DSP Reference manual to determine which interrupts 
; apply to a given target and/or application.
; The IST consists of 16 consecutive fetch ISFPs.
* Each ISFP contains 8 32-bit instructions, or 32bytes of code.
;************************************************************************
	.sect	".intvecs"
	.align	32*8*4				; must be aligned on 256 word boundary
	.def RESET_V
RESET_V:			; Reset
	.ref	_c_int00			; program reset address
	MVKL 	_c_int00, B3
	MVKH	_c_int00, B3
	B		B3
	MVC 	PCE1, B0			; get address of interrupt vectors
	MVC 	B0, ISTP			; set table to point here
	NOP 	
	NOP 	
	NOP 	
	
	.align	32
	.def NMI_V
NMI_V:				; Non-maskable interrupt Vector
	B		$
	NOP 	
	NOP 	
	NOP 	
	NOP 	
	NOP 	
	NOP 	
	NOP 	
	
	.align	32
	.def AINT_V
AINT_V:				; Analysis Interrupt Vector (reserved)
	B		$
	NOP 	
	NOP 	
	NOP 	
	NOP 	
	NOP 	
	NOP 	
	NOP 	
	
	.align	32
	.def MSGINT_V
MSGINT_V:			; Message Interrupt Vector (reserved)
	.if $isdefed("HSRTDX")
	.ref	_HSRTDX_msgint_isr		; MSGINT interrupt
	STW		B0,*SP--[2]				; save B0 temporarily
||	MVKL 	_HSRTDX_msgint_isr, B0	; load ISR address
	MVKH	_HSRTDX_msgint_isr, B0
	B		B0						; execute ISR;
	LDW		*++SP[2],B0				; restore B0
	NOP 	2
	NOP
	NOP
	.elseif	$isdefed("JTAGRTDX")
	.ref	RTEMU_msg
	STW 	B0, *SP--[2]
||	MVKL 	RTEMU_msg, B0
	MVKH	RTEMU_msg, B0
	B		B0
	LDW 	*++SP[2], B0
	NOP 	2
	NOP
	NOP
	.else
	B		$
	NOP 	
	NOP 	
	NOP 	
	NOP 	
	NOP 	
	NOP 	
	NOP 	
	.endif	
	
	.align	32
	.def INT4_V
INT4_V:				; Maskable Interrupt #4
	B		$
	NOP 	
	NOP 	
	NOP 	
	NOP 	
	NOP 	
	NOP 	
	NOP 	
	
	.align	32
	.def INT5_V
INT5_V:				; Maskable Interrupt #5
	B		$
	NOP 	
	NOP 	
	NOP 	
	NOP 	
	NOP 	
	NOP 	
	NOP 	
	
	.align	32
	.def INT6_V
INT6_V:				; Maskable Interrupt #6
	B		$
	NOP 	
	NOP 	
	NOP 	
	NOP 	
	NOP 	
	NOP 	
	NOP 	
	
	.align	32
	.def INT7_V
INT7_V:				; Maskable Interrupt #7
	B		$
	NOP 	
	NOP 	
	NOP 	
	NOP 	
	NOP 	
	NOP 	
	NOP 	
	
	.align	32
	.def INT8_V
INT8_V:				; Maskable Interrupt #8
	B		$
	NOP 	
	NOP 	
	NOP 	
	NOP 	
	NOP 	
	NOP 	
	NOP 	
	
	.align	32
	.def INT9_V
INT9_V:				; Maskable Interrupt #9
	.if	$isdefed("JTAGRTDX")
	.ref	RTEMU_msg
	STW 	B0, *SP--[2]
||	MVKL 	RTEMU_msg, B0
	MVKH	RTEMU_msg, B0
	B		B0
	LDW 	*++SP[2], B0
	NOP 	2
	NOP
	NOP
	.else
	B		$
	NOP 	
	NOP 	
	NOP 	
	NOP 	
	NOP 	
	NOP 	
	NOP 	
	.endif

	.align	32
	.def INT10_V
INT10_V: 			; Maskable Interrupt #10
	B		$
	NOP 	
	NOP 	
	NOP 	
	NOP 	
	NOP 	
	NOP 	
	NOP 	
	
	.align	32
	.def INT11_V
INT11_V: 			; Maskable Interrupt #11
	.if $isdefed("HSRTDX")
	.def RTDX_XMT_INTV
RTDX_XMT_INTV:		; HSRTDX Xmit Complete
	.ref	_HSRTDX_xmt_isr
	STW		B0,*SP--[2]				; save B0 temporarily
||	MVKL 	_HSRTDX_xmt_isr, B0		; load ISR address
	MVKH	_HSRTDX_xmt_isr, B0
	B		B0						; execute ISR;
	LDW		*++SP[2],B0			; restore B0
	NOP 	2
	NOP
	NOP
	.else
	B		$
	NOP 	
	NOP 	
	NOP 	
	NOP 	
	NOP 	
	NOP 	
	NOP 	
	.endif	
	
	.align	32
	.def INT12_V
INT12_V: 			; Maskable Interrupt #12
	.if $isdefed("HSRTDX")
	.def RTDX_REC_INTV
RTDX_REC_INTV:		; HSRTDX Rcvd Complete
	.ref	_HSRTDX_rec_isr
	STW		B0,*SP--[2]			; save B0 temporarily
||	MVKL 	_HSRTDX_rec_isr, B0		; load ISR address
	MVKH	_HSRTDX_rec_isr, B0
	B		B0						; execute ISR;
	LDW		*++SP[2],B0			; restore B0
	NOP 	2
	NOP
	NOP
	.else
	B		$
	NOP 	
	NOP 	
	NOP 	
	NOP 	
	NOP 	
	NOP 	
	NOP 	
	.endif	
	
	.align	32
	.def INT13_V
INT13_V: 			; Maskable Interrupt #13
	B		$
	NOP 	
	NOP 	
	NOP 	
	NOP 	
	NOP 	
	NOP 	
	NOP 	
	
	.align	32
	.def INT14_V
INT14_V: 			; Maskable Interrupt #14
	B		$
	NOP 	
	NOP 	
	NOP 	
	NOP 	
	NOP 	
	NOP 	
	NOP 	
	
	.align	32
	.def INT15_V
INT15_V: 			; Maskable Interrupt #15
	B		$
	NOP 	
	NOP 	
	NOP 	
	NOP 	
	NOP 	
	NOP 	
	NOP 	
	
; the remainder of the vector table is reserved
	.end

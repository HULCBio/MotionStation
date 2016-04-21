; File taken from <TIDIR>\examples\dsk2812\rtdx\shared\intvecs.asm
;
;****************************************************************************
;* VECTORS.ASM  v##### - Prototype Interrupt Vector Table for C28X C Runtime
;* $RCSFile: ,v $
;* $Revision: 1.1.6.1 $
;* $Date: 2003/11/30 23:06:07 $
;* Copyright (c) 2000 Texas Instruments Incorporated
;****************************************************************************
    .title "C28xx Interrupt Vectors w/ RTDX"
    .tab    4

JTAGRTDX	.set	1


;****************************************************************************
; Interrupt Vector Table
;
; 32 interrupt vector addresses - Each 32 bits long.  
; - First 32 bits = 24-bit address of Interrupt Service Routine (ISR).
; - Second 32 bits executed before transferring control to the ISR.
; - Must be aligned on a 256 boundary.
;****************************************************************************
    .sect   ".intvecs"
    .align  256


;****************************************************************************
;* Point Reset Vector to C Environment Entry Point                           
;****************************************************************************
    .def    RESETIV
RESETIV:    .long RESET_ISR

;****************************************************************************
;* Other interrupt vector definitions go here
;****************************************************************************
IV01:   .long _no_handler   ; Maskable hardware interrupt
IV02:   .long _no_handler   ; Maskable hardware interrupt
IV03:   .long _no_handler   ; Maskable hardware interrupt
IV04:   .long _no_handler   ; Maskable hardware interrupt
IV05:   .long _no_handler   ; Maskable hardware interrupt
IV06:   .long _no_handler   ; Maskable hardware interrupt
IV07:   .long _no_handler   ; Maskable hardware interrupt
IV08:   .long _no_handler   ; Maskable hardware interrupt
IV09:   .long _no_handler   ; Maskable hardware interrupt
IV10:   .long _no_handler   ; Maskable hardware interrupt
IV11:   .long _no_handler   ; Maskable hardware interrupt    
IV12:   .long _no_handler   ; Maskable hardware interrupt
IV13:   .long _no_handler   ; Maskable hardware interrupt
IV14:   .long _no_handler   ; Maskable hardware interrupt

	.ref	_datalog_isr
DLOGIV:
IV15:   .long _datalog_isr  ; DLOGINT

IV16:   .long _no_handler   ; RTOSINT
IV17:   .long _no_handler   ; Reserved
IV18:   .long _no_handler   ; NMI
IV19:   .long _no_handler   ; Illegal Instruction Trap
IV21:   .long _no_handler   ; User defined Software Interrupt
IV22:   .long _no_handler   ; User defined Software Interrupt
IV23:   .long _no_handler   ; User defined Software Interrupt
IV24:   .long _no_handler   ; User defined Software Interrupt
IV25:   .long _no_handler   ; User defined Software Interrupt
IV26:   .long _no_handler   ; User defined Software Interrupt
IV27:   .long _no_handler   ; User defined Software Interrupt
IV28:   .long _no_handler   ; User defined Software Interrupt
IV29:   .long _no_handler   ; User defined Software Interrupt
IV30:   .long _no_handler   ; User defined Software Interrupt
IV31:   .long _no_handler   ; User defined Software Interrupt


;****************************************************************************
; Interrupt Service Routines
;
; Just a few interrupt service routines that may be useful.
;****************************************************************************

	.text
    ; Just in case we decide to move the vectors, this ISR will force 
    ; the IVPD, IVPH to point to our vector table.
    ; - Hardware Reset forces IVPD/IVPH = 0xFFFF.
    .def RESET_ISR
    .ref _c_int00
RESET_ISR:  
    CLRC VMAP
    B _c_int00,UNC

    .def _no_handler
_no_handler:
    B _no_handler,UNC

    .end


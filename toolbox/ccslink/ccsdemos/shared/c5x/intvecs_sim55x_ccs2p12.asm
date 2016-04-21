;****************************************************************************
;* VECTORS.ASM  v##### - Prototype Interrupt Vector Table for C55X C Runtime
;* $RCSFile: dualread.c,v $
;* $Revision: 1.1.6.1 $
;* $Date: 2004/04/01 16:01:48 $
;* Copyright (c) 2000 Texas Instruments Incorporated
;****************************************************************************
    .title "C55x Interrupt Vectors w/ RTDX"
    .tab    4

    .model  call=internal

;****************************************************************************
; Interrupt Vector Table
;
; 32 interrupt vector addresses - Each 64 bits long.  
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
RESETIV:    .ivec RESET_ISR, USE_RETA

;****************************************************************************
;* Other interrupt vector definitions go here
;****************************************************************************
NMIV:   .ivec _no_handler  ; Non-maskable hardware interrupt
IV02:   .ivec _no_handler
IV03:   .ivec _no_handler
IV04:   .ivec _no_handler
IV05:   .ivec _no_handler
IV06:   .ivec _no_handler
IV07:   .ivec _no_handler
IV08:   .ivec _no_handler
IV09:   .ivec _no_handler
IV10:   .ivec _no_handler
IV11:   .ivec _no_handler
IV12:   .ivec _no_handler
IV13:   .ivec _no_handler
IV14:   .ivec _no_handler
IV15:   .ivec _no_handler
IV16:   .ivec _no_handler
IV17:   .ivec _no_handler
IV18:   .ivec _no_handler
IV19:   .ivec _no_handler
IV20:   .ivec _no_handler
IV21:   .ivec _no_handler
IV22:   .ivec _no_handler
IV23:   .ivec _no_handler
BERRIV:
IV24:   .ivec _no_handler  ; Bus error interrupt

    .ref  _datalog_isr 
DLOGIV:
IV25:   .ivec _datalog_isr  ; Data log (RTDX) interrupt

RTOSIV:
IV26:   .ivec _no_handler  ; Real-time OS interrupt
IV27:   .ivec _no_handler  ; General-purpose software-only interrupt
IV28:   .ivec _no_handler  ; General-purpose software-only interrupt
IV29:   .ivec _no_handler  ; General-purpose software-only interrupt
IV30:   .ivec _no_handler  ; General-purpose software-only interrupt
IV31:   .ivec _no_handler  ; General-purpose software-only interrupt


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
	.if .ALGEBRAIC
    @IVPD_L = #(RESETIV >> 8) || mmap()
    @IVPH_L = #(RESETIV >> 8) || mmap()
    goto _c_int00
	.elseif .MNEMONIC
    MOV #RESETIV >> 8, mmap(IVPD)
    MOV #RESETIV >> 8, mmap(IVPH)
    B _c_int00
	.else
	.emsg "Macros not defined"
	.endif

    .def _no_handler
_no_handler:
	.if .ALGEBRAIC
    goto _no_handler
	.elseif .MNEMONIC
    B _no_handler
	.else
	.emsg "Macros not defined"
	.endif

    .end

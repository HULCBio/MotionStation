; Simple Vector table for c54xx processor
;
; Copyright 2001-2003 The MathWorks, Inc.
; $Revision: 1.4.4.1 $ $Date: 2003/11/30 23:03:39 $
;
;  ======== vectors.asm ========
;  Plug in the entry point at RESET in the interrupt vector table
;
;
;  ======== unused ========
;  plug inifinite loop -- with nested branches to
;  disable interrupts -- for all undefined vectors
;

        .sect ".vectors"

        .ref _c_int00           ; C entry point

        .align  0x80            ; must be aligned on page boundary

RESET:                          ; reset vector
        BD _c_int00                             ; branch to C entry point
        STM #200,SP                             ; stack size of 200
nmi:    RETE                    ; enable interrupts and return from one
                NOP
                NOP
                NOP                                     ;NMI~

                ; software interrupts
sint17 .space 4*16
sint18 .space 4*16
sint19 .space 4*16
sint20 .space 4*16
sint21 .space 4*16
sint22 .space 4*16
sint23 .space 4*16
sint24 .space 4*16
sint25 .space 4*16
sint26 .space 4*16
sint27 .space 4*16
sint28 .space 4*16
sint29 .space 4*16
sint30 .space 4*16

int0:   RETE
                NOP
                NOP
                NOP
int1:   RETE
                NOP 
                NOP
                NOP
int2:   RETE
                NOP
                NOP
                NOP
tint:   RETE
                NOP
                NOP
                NOP
rint0:  RETE
                NOP
                NOP
                NOP
xint0:  RETE
                NOP
                NOP
                NOP
rint1:  RETE
                NOP
                NOP
                NOP
xint1:  RETE
                NOP
                NOP
                NOP
int3:   RETE
                NOP
                NOP
                NOP
                .end

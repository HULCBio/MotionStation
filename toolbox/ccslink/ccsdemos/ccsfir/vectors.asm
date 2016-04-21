; CCSFIR demo for Code Composer Studio(R)
;   Simple Vector table for C6xxx series

; Copyright (c) 2000 Texas Instruments Incorporated
; $Revision: 1.5.4.1 $  $Date: 2003/11/30 23:03:37 $
unused  .macro id

        .global unused:id:
unused:id:
        b unused:id:    ; nested branches to block interrupts
        nop 4
        b unused:id:
        nop
        nop
        nop
        nop
        nop

        .endm

        .sect ".vectors"

        .ref _c_int00           ; C entry point

        .align  32*8*4          ; must be aligned on 256 word boundary

RESET:                          ; reset vector
        mvkl _c_int00,b0        ; load destination function address to b0
        mvkh _c_int00,b0
        b b0                    ; start branch to destination function
        mvc PCE1,b0             ; address of interrupt vectors
        mvc b0,ISTP             ; set table to point here
        nop 3                   ; fill delay slot
        nop
        nop

        ;
        ;  plug unused interrupts with infinite loops to
        ;  catch stray interrupts
        ;
        unused 1
        unused 2
        unused 3
        unused 4
        unused 5
        unused 6
        unused 7
        unused 8
        unused 9
        unused 10
        unused 11
        unused 12
        unused 13
        unused 14
        unused 15

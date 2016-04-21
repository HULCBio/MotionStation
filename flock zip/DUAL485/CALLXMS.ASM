;************************************************
;*                                              *
;* File: CALLXMS.ASM                            *
;*                                              *
;* Description:                                 *
;* Provide C-language interface to XMS driver.  *
;* Used with CXMS.C                             *
;*                                              *
;************************************************
.MODEL SMALL,C

; REGS structure surrogate
WR         STRUC
RAX        DW ?
RBX        DW ?
RCX        DW ?
RDX        DW ?
RSI        DW ?
RDI        DW ?
CFLAG      DW ?
WR         ENDS

.DATA

; Entry point to XMS driver
xms_addr   EQU THIS DWORD
xms_off    DW ?
xms_seg    DW ?

; parameters for block copy
COPYBLK    DW 8 DUP(?)

; Get pointer argument
LOADP      MACRO P1
           IF @DataSize
           LDS BX,P1
           ELSE
           MOV BX,P1
           ENDIF
           ENDM

.CODE
        PUBLIC xms_init,xms_call,xms_copy,xms_addr
; detect and set up xXMS driver
xms_init   PROC
           MOV AX,4300H
           INT 2FH
           CMP AL,80H
           MOV AL,0
           JNZ NOXMS
           MOV AX,4310H
           INT 2FH
           MOV XMS_OFF,BX
           MOV BX,ES
           MOV XMS_SEG,BX
           MOV AX,1
NOXMS:     RET
xms_init   ENDP

; generic XMS call
xms_call   PROC RPTR:PTR WR
           LOADP RPTR
           MOV AX,[BX].RBX
           PUSH AX
           MOV AX,[BX].RAX
           PUSH AX
           MOV CX,[BX].RCX
           MOV DX,[BX].RDX
           POP AX
           POP BX
           CALL [XMS_ADDR]
           PUSH BX
           LOADP RPTR
           POP [BX].RBX
           MOV [BX].RAX,AX
           MOV [BX].RCX,CX
           MOV [BX].RDX,DX
           RET
xms_call   ENDP

; Copy a block
xms_copy   PROC H1:WORD,O1:DWORD,H2:WORD,O2:DWORD,LEN:DWORD
           PUSH SI
           PUSH DS
; MOVE ARGS TO THE RIGHT PLACE IN COPY BLOCK
           MOV AX,WORD PTR LEN
           MOV [COPYBLK],AX
           MOV AX,WORD PTR LEN+2
           MOV [COPYBLK+2],AX
           MOV AX,H2
           MOV [COPYBLK+4],AX
           MOV AX,WORD PTR O2
           MOV [COPYBLK+6],AX
           MOV AX,WORD PTR O2+2
           MOV [COPYBLK+8],AX
           MOV AX,H1
           MOV [COPYBLK+10],AX
           MOV AX,WORD PTR O1
           MOV [COPYBLK+12],AX
           MOV AX,WORD PTR O1+2
           MOV [COPYBLK+14],AX
           MOV SI,OFFSET COPYBLK
           MOV AX,@DATA
           MOV DS,AX
           MOV AH,0BH
           CALL XMS_ADDR
           DEC AX      ; 0 = SUCCESS, FFFF=FAIL
           POP DS
           POP SI
           RET
xms_copy   ENDP

           END

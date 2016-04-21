;
;   FBBTEST.inc		- FBB TEST code Include File
;
;   Modification History
;
;      5/15/91	jf	- created
;      10/10/91 jf  - modified birdposmode defintions
;      7/2/92   jf  - added quaternion mode
;
;
;
; FBB Command Types
;
BROAD			   	EQU	7						; Broadcast
DIP					EQU	0						; DIP Switch Address
ALL					EQU	0						; Broadcast or DIP

;
; FBB Config Modes
;
STANDALONE          EQU 0
ONEXMTRNRCVRS       EQU 1
TIMESHARE           EQU 2
SIMULTANEOUSXMTRS   EQU 3

;
; FBB birdposmode values
;
POSMODE	    		EQU	00000000b
ANGLEMODE           EQU	00000001b
POSANGLEMODE        EQU	00000010b
MATRIXMODE   		EQU	00000011b
POSMATRIXMODE       EQU	00000100b
QUATERNIONMODE      EQU	00000101b
POSQUATERNIONMODE   EQU	00000110b

;
; Transmitter Configuration Structure
;
XMTRCONFIGSTRUCT   STRUC
XC                 DW    9 DUP(0) ;XMTR GAIN, ORTHOG CORRECTION MATRIX
XBR                DW    9 DUP(0) ;XMTR Base Rotation
XSC11              DW    0        ;TRANSMITTER X AXIS FINITE SIZE CONSTANT
XSC22              DW    0        ;Y AXIS FINITE SIZE
XSC33              DW    0        ;Z AXIS FINITE SIZE
FUDGSHFT           DW    0        ;SCALING SHIFT COUNT FOR FINITESIZE
RNGSCALE           DW    0        ;Range Scale Factor
XMTRCONFIGSTRUCT   ENDS
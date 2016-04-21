;
; FBBSER.inc    Serial Include File for FBBTEST
;
; Modification History
;		5/14/91		- created from \BIRDSOFT\ASM\SERIAL.inc
;       9/17/91     - modified for COM1-COM4
;       10/31/91    - added CTSON
;       2/18/93     - modified timeout to be 2 seconds
;
;   Misc
;
RXTIMEOUTINTICKS    EQU     36         ; approximately 2.0 seconds at 18.2 ticks/sec
;
; Circular Buffers for TX and RX
;
RXBUFSIZE           EQU     1000h       ; circular buffer sizes
TXBUFSIZE           EQU     1000h
;
;   Serial (8250) Port Base Addresses on PC compatible
;
COM1BASE            EQU     3f8h        ; base address of COM1 on PC/PCAT
COM2BASE            EQU     2f8h        ; base address of COM2 on PC/PCAT
COM3BASE            EQU     3e8h        ; base address of COM3 on PC/PCAT
COM4BASE            EQU     2e8h        ; base address of COM4 on PC/PCAT

;
; Labels for the Com Ports
;
COM1                EQU     0           ; com port 1
COM2                EQU     1           ; com port 2
COM3                EQU     2           ; com port 3
COM4                EQU     3           ; com port 4

;
; Serial Port Control Registers
;
MODEMSTATUS         EQU     6           ; modem status reg
LINESTATUS          EQU     5           ; line status register
MODEMCONT           EQU     4           ; modem control register
LINECONT            EQU     3           ; line control register
INTERIDENT          EQU     2           ; Interupt Identification register
INTERENABLE         EQU     1           ; interrupt register
DIVISORHIGH         EQU     1           ; baud rate divisor high
DIVISORLOW          EQU     0           ; baud rate divisor low
TXDATAREG           EQU     0           ; transmit register
RXDATAREG           EQU     0           ; receive register

;
;   Serial Port Bit Specifics
;
DLAB                EQU     80h         ; DLAB bit pos
DTR                 EQU     01h         ; DTR bit pos
DATARDY             EQU     01h         ; Data Ready bit pos
TXHOLDEMPTY         EQU     20h         ; Tx Holding Register Empty bit pos
TXSHIFTEMPTY        EQU     40h         ; Tx Shift Register Empty bit pos

RXERRORMSK          EQU     0eh         ; Rx Error Mask
DTRON               EQU     01h         ; bit 0 of Modem Control reg
RTSON               EQU     02h         ; bit 1 of Modem Control reg
OUT2                EQU     08h         ; bit 3 of Modem Control reg
CTSON               EQU     10h         ; bit 4 of Modem Status reg


;
;   UART Interrupt Enable Register
;
RXDATAAVAILINTENABLE EQU    01h
TXHOLDINTENABLE      EQU    02h
RXLINESTATUSINTENABLE EQU   04h
MODEMSTATUSINTENABLE EQU    08h

;
;   Serial Port Return Values
;
NODATAAVAIL         EQU     -1
RXERRORS            EQU     -2
RXTIMEOUT           EQU     -3
RXBUFOVERRUN        EQU     -4
TXBUFOVERRUN        EQU     -5
TXNOTEMPTY          EQU     -6
RXPHASEERROR        EQU     -7
TXBUFFERFULL        EQU     -8
TIMEOUTERR          EQU     -9

;
;   UART Identification Register definition
;   ....lsb = 0 implies interrupt pending = TRUE
;
RXLINESTATUS        EQU     6
RXDATAAVAIL         EQU     4
TXEMPTY             EQU     2
MODEMSTATUSCHG      EQU     0

;
;   Serial Port Configuration Constants
;
STOP_WORDLEN_NOPARITY 		EQU     3h     ; 1 start, 8 data, 1 stop, no parity
STOP_WORDLEN_SPACEPARITY 	EQU     3bh    ; 1 start, 8 data, 1 stop, SPACE parity
STOP_WORDLEN_MARKPARITY 	EQU     2bh    ; 1 start, 8 data, 1 stop, MARK parity

;
; Interrupt Controller (8259) Definitions
;
INT_CNTRL_OCW1      EQU     21h             ; operational control addresses
INT_CNTRL_OCW2      EQU     20h
INT_CNTRL_OCW3      EQU     20h
INT_MSK_REG         EQU     INT_CNTRL_OCW1  ; mask register address
INT_EOI             EQU     20h             ; end of interrupt command
INT_RD_IRR          EQU     0ah             ; read Interrupt request reg
INT_RD_ISR          EQU     0bh             ; read Interrupt service reg

;
; Interrupt Register (8259) definitions
;
IRQ2                EQU     04h             ; bit pos for IRQ 2
IRQ3                EQU     08h             ; bit pos for IRQ 3, COM2
IRQ4                EQU     10h             ; bit pos for IRQ 4, COM1
IRQ5                EQU     20h             ; bit pos for IRQ 5

IRQ2INTERRUPT       EQU     0ah             ; vector # for IRQ 2
IRQ3INTERRUPT       EQU     0bh             ; vector # for IRQ 3
IRQ4INTERRUPT       EQU     0ch             ; vector # for IRQ 4
IRQ5INTERRUPT       EQU     0dh             ; vector # for IRQ 5

COM1INTERRUPT       EQU     IRQ4INTERRUPT   ; vector # for COM1
COM2INTERRUPT       EQU     IRQ3INTERRUPT   ; vector # for COM2
COM3INTERRUPT       EQU     IRQ4INTERRUPT   ; vector # for COM3
COM4INTERRUPT       EQU     IRQ3INTERRUPT   ; vector # for COM4

;
; Note: Fill in the Host interrupt and the Host Combase for other than
;       the default com4, irq2
;
IFDEF QUATECH_8MHZ
HOSTRS485IRQBIT	    EQU		IRQ2			; bit pos for IRQ 2, HOST comport
HOSTRS485INTVEC     EQU     IRQ2INTERRUPT   ; vector # for the HOST comport - IRQ2
HOSTCOMBASE         EQU     COM4BASE        ; host comport setup for com4
HOSTCOMPORT         EQU     COM4            ; com4
ENDIF

IFDEF QUATECH_20MHZ
HOSTRS485IRQBIT	    EQU		IRQ5			; bit pos for IRQ 5, HOST comport
HOSTRS485INTVEC     EQU     IRQ5INTERRUPT   ; vector # for the HOST comport - IRQ2
HOSTCOMBASE         EQU     COM3BASE        ; host comport setup for com4
HOSTCOMPORT         EQU     COM3            ; com4
ENDIF

DISABLESERIALMSK    EQU     IRQ3+IRQ4       ; MSK to disable serial Interrupts
                                            ; IRQ3 and IRQ4 on 8259

;
; Local Macro
;
;
;   KILLINGTIME - adds write cycle delay for writes to the 8250 UART and
;                 8259 Interrupt Controller
;
KILLTIME    MACRO
            jmp     $+2
            jmp     $+2
            ENDM

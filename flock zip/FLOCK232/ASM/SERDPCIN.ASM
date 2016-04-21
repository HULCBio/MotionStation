title   SERDPCIN.asm
subttl  Assembly Serial Routines for ABIRD
page    50,132
;
;****************************************************************************
;****************************************************************************
;   serdpcin.asm    - Serial Port Routines in Assembly Language
;
;   written for:    Ascension Technology Corporation
;                   PO Box 527
;                   Burlington, Vermont  05402
;                   802-655-7879
;
;   written by:     Jeff Finkelstein
;
;   Modification History:
;
;   10/18/90        jf  - released
;   4/16/91         jf  - renamed module to SERDPCIN.asm
;   6/18/91         jf  - added FOB baudrates
;   10/10/91        jf  - changed default baud to 9600
;   10/29/91        jf  - removed the assertion of RTS just in case the
;                         user's cable has the RTS signal, so we don't hold
;                         the BIRD in RESET
;   4/6/92          jf  - added RS232 to FBB Command addr to send serial
;                         command
;
;          <<<< Copyright 1990 Ascension Technology Corporation >>>>
;*****************************************************************************
;*****************************************************************************
                INCLUDE asctech.inc         ; general Ascension Tech. stuff
                INCLUDE menudef.inc         ; menu stuff
                INCLUDE serial.inc          ; include serial I/O stuff
                .8086                       ; 8086 instructions only
;
;...public symbols
;
                PUBLIC  configserialport
                PUBLIC  saveserialconfig
                PUBLIC  restoreserialconfig
                PUBLIC  clear_rx
                PUBLIC  clearserialints
                PUBLIC  get_serial_record
                PUBLIC  get_serial_data
                PUBLIC  send_serial_cmd
                PUBLIC  send_serial_char
                PUBLIC  get_serial_char
                PUBLIC  waitforphase
                PUBLIC  waitforchar
                PUBLIC  checktime
                PUBLIC  getdosticks
;
;...menu external routines
;
                EXTRN   hitkeycontinue:NEAR
                EXTRN   putstring:NEAR
                EXTRN   putchr:NEAR
                EXTRN   getchr:NEAR
                EXTRN   newline:NEAR
                EXTRN   displayunsigned:NEAR
;
;...birdmain external variables
;
                EXTRN   outputmode:WORD
                EXTRN   buttonmode:WORD

;*****************************************************************************
_DATA           SEGMENT WORD PUBLIC 'DATA'

;
; Com Port Globals
;
com_base        dw  COM1BASE                ; holds the address of the comport
comport         dw  COM1                    ; holds the comport number (COM1)

;
; RS232 to FBB Command Destination Address
;
rs232tofbbaddr  db  0


;
; Holds the Default and Current Baud Rate
;
baudsel         dw  4                       ; holds the baud rate selection (19200)
;
; Serial Port Baud Divisor Table..for FOB Birds
;
;
bauddivisortbl  dw  1                       ; 115200 baud
                dw  2                       ; 57600 baud
                dw  3                       ; 38400 baud
                dw  6                       ; 19200 baud
                dw  12                      ; 9600 baud
                dw  24                      ; 4800 baud
                dw  48                      ; 2400 baud

;
; Storage for the 'old' serial port configuration
;
olddivisorlow   db  0                       ; holds the old baud divisor low
olddivisorhigh  db  0                       ; holds the old baud divisor high
oldlinecont     db  0                       ; holds the old line control
oldinterenable  db  0                       ; holds the old interrupt enable reg
oldmodemcont    db  0                       ; holds the old modem control reg
oldirqmsk       db  0                       ; holds the old interrupt cont mask
;
; Storage for the old serial interrupt vector
;
oldserialintveclow dw ?                     ; old serial vector low
oldserialintvechigh dw ?                    ; old serial vector high
;
; Error Counters/Flags
;
phaseerror_count dw 0                       ; holds the phase errors
rxbufoverrunflg dw  FALSE                   ; rx buffer overruns flag
rxerrorflg      dw  FALSE                   ; rx line errors flag
txbufemptyflg   dw  TRUE                    ; tx buffer empty flag
rxerrval        db  0                       ; holds the rx line errors
;
; a few bytes to store time
;
starttimelow    dw  0                       ; start time
starttimehigh   dw  0
timenowlow      dw  0                       ; current time
timenowhigh     dw  0
;
; Rx circular buffer and pointers
;
rxbuf           db  RXBUFSIZE DUP(?)        ; allocate the RX buffer
rxbufinptr      dw  rxbuf                   ; rx buffer input pointer
rxbufoutptr     dw  rxbuf                   ; rx buffer output pointer

;
; Tx circular buffer and pointers
;
txbuf           db  TXBUFSIZE DUP(?)        ; allocate the TX buffer
txbufinptr      dw  txbuf                   ; tx buffer input pointer
txbufoutptr     dw  txbuf                   ; tx buffer output pointer
;
; Error Messages
;
rxtimeoutmsg         db '**ERROR** receiver timed out','$'
rxbufoverrunerrormsg db '**ERROR** rx buffer overrun',CR,LF,'$'
rxerrormsg           db '**ERROR** rx line errors have occured',CR,LF,'$'
badrxdatamsg         db '**ERROR** could not read data from the Bird',CR,LF,'$'

;
; Public Variables
;
                PUBLIC  phaseerror_count
                PUBLIC  com_base
                PUBLIC  comport
                PUBLIC  baudsel
                PUBLIC  bauddivisortbl
                PUBLIC  txbufemptyflg
                PUBLIC  rs232tofbbaddr

_DATA           ENDS

;*****************************************************************************

_TEXT           SEGMENT WORD PUBLIC 'CODE'
                ASSUME  cs:_TEXT,ds:_DATA
;
;=============================================================================
;   configserialport    Configure the Serial Port connected to the BIRD
;   ----------------
;
;   Parameters Passed:  divisor in AX, unsigned int used by 8250 for the
;                       divisor register
;                       (global) comport, (global) com_base
;   Return Value:       none
;   Registers Modified: AX
;   Remarks:            Unfortunately, the PC ROM BIOS does NOT support baud
;                       rates upto 19200. Therefore, this routine must talk
;                       directly to the hardware to configure the serial port
;                       ...this is not a problem in a PC environment since the
;                       I/O map is fixed for COM1 and COM2.
;
;                               *** NOTE ***
;
;   The 8250 UART cannot withstand back to back writes (OUTs). If written in
;   assembly language, the typical BIOS type delay is a 'jmp' to the next
;   instruction. For example...
;                               out dx,al       ; output to serial port
;                               jmp $+2
;                               out dx,al       ; output to serial port
;                       or
;                               out dx,al       ; output to serial port
;                               clc             ; clear carry
;                               jmp $+2
;                               out dx,al       ; output to serial port
;
;   NOTE:   a macro KILLTIME is used to implement the 'jmp $+2'
;=============================================================================
;
configserialport    proc    NEAR
                push    bx                  ; save reg
                push    cx
                push    dx
                push    es

                cli                         ; disable while configuring
                mov     bx,ax               ; BX now has the divisor
                mov     dx,com_base         ; use DX to hold com_base
;
; disable the interrupts
;
                xor     al,al               ; AL = 0
                add     dx,INTERENABLE      ; offset to the interrupt reg
                out     dx,al               ; update the hdw
                KILLTIME
;
; assume that there are NO CHARACTERS CURRENTLY in the Tx Buffer
; and change the baud rate
;
                inc     dx                  ; point DX to the LINECONT
                inc     dx
                or      al,DLAB             ; set the DLAB bit
                out     dx,al               ; update the hdw
                KILLTIME
;
; Set the least significant byte and then the most significant
; byte of the baud rate divisor
;
                mov     dx,com_base         ; dx will be the port pointer
                mov     al,bl               ; set AL to the divisor low
                out     dx,al               ; update the hdw
                KILLTIME
                inc     dx                  ; point to the divisor high
                mov     al,bh               ; set AL to the divisor high
                out     dx,al               ; update the hdw
                KILLTIME
;
; Set the Stop Bits = 1, Word Length = 8 and Parity = None
;
                inc     dx                  ; point to the line control reg
                inc     dx
                mov     al, STOP_WORDLEN_PARITY
                out     dx,al
                KILLTIME
;
; Assert DTR...just in case the cable uses the DTR signal
; Assert OUT2...needed to allow interrupts to occur on PC compatible
;   serial I/O cards.....this fact is not very well documented !!!
;
                inc     dx
                mov     al,DTRON + OUT2 ; assert the DTR, OUT2 bits
                out     dx,al               ; update the hdw
                KILLTIME
;
; Clear the Rx characters and errors...if any
;
                call    clear_rx            ; note: doesn't destroy DX
;
; Clear Pending Serial Interrupts
;
                call    clearserialints     ; clears pending interrupts
;
; Set up the Serial Interrupt Vector as per comport
;
                xor     ax,ax               ; AX = 0
                mov     es,ax               ; ES = 0
                mov     bx,COM1INTERRUPT    ; set BX to the Interrupt vector
                sub     bx,comport          ; adjust BX for the comport
                shl     bx,1                ; multiply BX by 2 ...
                shl     bx,1                ; .. for 4 bytes/vector
                mov     es:[bx],OFFSET serialisr ; set the vector low
                mov     es:[bx]+2,cs          ; set the vector high
;
; Enable the 8259 Mask register for serial interrupts
; ...IRQ4 ~(10h) for COM1, IRQ3 ~(08h) for COM2
;
                mov     al,IRQ4             ; start mask for COM1
                mov     cx,comport          ; cx = 0 if COM1, 1 if COM2
                shr     al,cl               ; shift if CL = COM2 == 1
                not     al                  ; only 1 bit is a 0
                and     al,oldirqmsk        ; AND w/original mask value
                out     INT_MSK_REG,al      ; out he/she goes!
                KILLTIME
;
; Back to the calling routine
;
                sti                         ; enable interrupts
                pop     es
                pop     dx                  ; restore regs
                pop     cx
                pop     bx
                ret
configserialport endp
        
;=============================================================================
;   saveserialconfig    save serial port configuration
;   ----------------
;
;   Parameters Passed:  (global) comport, (global) com_base
;   Return Value:       none
;   Registers Modified: AX, DX
;   Remarks:            save the current configuration of the serial port
;=============================================================================
saveserialconfig    proc NEAR
                push    bx                  ; save reg
                push    es
                cli                         ; disable ints while reading regs
;
; save the current interrupt vector
;
                xor     ax,ax               ; AX = 0
                mov     es,ax               ; ES = 0
                mov     bx,COM1INTERRUPT    ; set BX to the Interrupt vector
                sub     bx,comport          ; adjust BX for the comport #
                shl     bx,1                ; multiply BX by 2 ...
                shl     bx,1                ; .. for 4 bytes/vector
                mov     ax,es:[bx]             ; get the low part
                mov     oldserialintveclow,ax  ; store the vector low
                mov     ax,es:[bx]+2           ; get the high part
                mov     oldserialintvechigh,ax ; store the vector high
;
; save the 8259 Mask register
;
                in      al,INT_MSK_REG      ; get the current data
                mov     oldirqmsk,al        ; save the data
;
; get the current line control reg
;
                mov     dx,com_base         ; get the port address
                add     dx,LINECONT         ; offset by the LINE control
                in      al,dx               ; get current line control
                KILLTIME
                mov     oldlinecont,al      ; save value
;
; get the current Divisor
;
                mov     al,DLAB             ; set the DLAB bit
                out     dx,al               ; set the DLAB bit in hdw
                KILLTIME

                dec     dx                  ; point to the divisor high
                dec     dx
                in      al,dx               ; get the data
                KILLTIME
                mov     olddivisorhigh,al   ; store the value
                dec     dx                  ; point to the divisor low
                in      al,dx               ; get the data
                KILLTIME
                mov     olddivisorlow,al    ; store the value
;
; reset the DLAB bit
;
                inc     dx                  ; point to the Line Control reg
                inc     dx
                inc     dx
                xor     al,al               ; AL = 0
                out     dx,al               ; clear the DLAB bit
                KILLTIME
;
; get the modem control reg
;
                inc     dx                  ; point to the modem control reg
                in      al,dx               ; read the data
                KILLTIME
                mov     oldmodemcont,al     ; store the value
;
; get the interrupt reg
;
                dec     dx                  ; point to the Interrupt Enable reg
                dec     dx
                dec     dx
                in      al,dx               ; read the data
                KILLTIME
                mov     oldinterenable,al   ; store the value

                sti                         ; reenable ints
                pop     es                  ; restore regs
                pop     bx
                ret                         ; all done
saveserialconfig endp

;=============================================================================
;   restoreserialconfig     Restore the original serial port configuration
;   ----------------
;
;   Parameters Passed:      (global) comport, (global) com_base
;   Return Value:           none
;   Registers Modified:     AX, DX
;   Remarks:                restores the serial port configuration to
;                           the configuration when saveserialconfig was called
;=============================================================================
;
restoreserialconfig proc NEAR
                cli                         ; disable ints during restoration
                push    bx                  ; save regs
                push    es
;
; Restore the Com Port Configuration Regs including:
; Divisor, Interrupt Enable, Line Control, Modem Control
;
;
; restore the current line control reg
;
                mov     dx,com_base         ; get the port address
                add     dx,LINECONT         ; offset by the LINE control
                mov     oldlinecont,al      ; get value
                out     dx,al               ; update the hdw
                KILLTIME
;
; restore the current Divisor
;
                mov     al,DLAB             ; set the DLAB bit
                out     dx,al               ; set the DLAB bit in hdw
                KILLTIME

                dec     dx                  ; point the the Divior high reg
                dec     dx
                mov     al,olddivisorhigh   ; get the value
                out     dx,al               ; store the data in hdw
                KILLTIME

                dec     dx                  ; point to the divisor low
                mov     al,olddivisorlow    ; get the value
                out     dx,al               ; store the data in hdw
                KILLTIME
;
; reset the DLAB bit
;
                inc     dx                  ; point to the Line Control reg
                inc     dx
                inc     dx
                xor     al,al               ; AL = 0
                out     dx,al               ; clear the DLAB bit
                KILLTIME
;
; restore the modem control reg
;
                inc     dx                  ; point to the modem control reg
                mov     al,oldmodemcont     ; get the value
                out     dx,al               ; read the data
                KILLTIME
;
; get the interrupt reg
;
                dec     dx                  ; point to the Interrupt Enable reg
                dec     dx
                dec     dx
                mov     al,oldinterenable   ; get the value
                out     dx,al               ; store the data
                KILLTIME
;
; restore the interrupt vector
;
                xor     ax,ax               ; AX = 0
                mov     es,ax               ; ES = 0
                mov     bx,COM1INTERRUPT    ; set BX to the Interrupt vector
                sub     bx,comport          ; adjust BX for the comport
                shl     bx,1                ; multiply BX by 2 ...
                shl     bx,1                ; .. for 4 bytes/vector
                mov     ax,oldserialintveclow  ; get the old vector low
                mov     es:[bx],ax             ; set the vector low
                mov     ax,oldserialintvechigh ; get the old vector high
                mov     es:[bx]+2,ax           ; set the vector high
;
; restore the 8259 interrupt mask reg
;
                mov     al,oldirqmsk        ; get the data
                out     INT_MSK_REG,al      ; restore the mask reg
                KILLTIME

                sti                         ; reenable ints when done!
                pop     es                  ; restore regs
                pop     bx
                ret                         ; all done
restoreserialconfig endp

;=============================================================================
;   clear_rx            Clear the Rx Buffer Variables
;   --------
;
;   Parameters Passed:  none
;   Return Value:       none
;   Registers Modified: AX
;   Remarks:            resets all the RX buffer Variables and leaves the 
;                       UART RX interrupts enabled
;=============================================================================
;
clear_rx        proc    NEAR
                push    dx                  ; save regs
;
; initialize Receive Flags/Counters
;
                xor     ax,ax               ; clear AX
                mov     phaseerror_count,ax ; clear the phase error cntr
                mov     rxerrval,al         ; clear the rx error value
                mov     rxerrorflg,ax       ; clear the rx error flag
                mov     rxbufoverrunflg,ax  ; clear the rx overrun flag
;
; Reset the RX buffer
;
                mov     rxbufinptr,OFFSET rxbuf  ; initialize rx input ptr
                mov     rxbufoutptr,OFFSET rxbuf ; initialize rx output ptr
;
; Reset the TX buffer
;
;               mov     txbufemptyflg,TRUE       ; always starts off empty
;               mov     txbufinptr,OFFSET txbuf  ; initialize tx input ptr
;               mov     txbufoutptr,OFFSET txbuf ; initialize tx output ptr
;
; Setup the 8250 Interrupt Enable register, RXDATA and RXLINESTATUS
; are turned on...but NOT TXHOLDINTENABLE since it will be turned on
; when we send the first character
;
                mov     dx,com_base
                inc     dx                  ; point to interrupt enable reg
                mov     al,RXLINESTATUSINTENABLE + RXDATAAVAILINTENABLE
                out     dx,al               ; tickle the hardware
                KILLTIME
                out     dx,al               ; tickle the hardware again
                KILLTIME
clearrxret:
                pop     dx                  ; restore regs
                ret                         ;...later
clear_rx        endp

;=============================================================================
;   clearserialints     Clear pending serial interrupts
;   --------
;
;   Parameters Passed:  none
;   Return Value:       none
;   Registers Modified: AX
;   Remarks:            clears pending interrupts on the serial port 
;=============================================================================
;
clearserialints proc    NEAR
                push    cx
                push    dx
;
; Clear any pending 8250 interrupts..if the int request reg isn't a 1
;
clrserints1:    mov     dx,com_base         ; get com base address
                inc     dx                  ; point to the int req reg
                inc     dx
                in      al,dx               ; ck interrupt request reg
                KILLTIME
                and     al,1                ; no more ints when AL = 1
                jnz     clrserintret
                dec     dx
                dec     dx
                in      al,dx               ; clear receive character
                KILLTIME
                add     dx,5                ; point to LINE status
                in      al,dx               ; clear LINE status
                KILLTIME
                inc     dx
                in      al,dx               ; clear Modem status
                KILLTIME
                jmp     clrserints1         ; continue until cleared
clrserintret:
                pop     dx
                pop     cx
                ret
clearserialints endp

;=============================================================================
;   get_serial_record   Get a record from the serial port
;   ----------------
;
;   Parameters Passed:  number of bytes in Record in CX
;                       pointer to rxbuf in BX
;                       outputmode (global), POINT, CONTINUOUS or STREAM
;   Return Value:
;   Return Value:       If successful, returns recsize in AX
;                       else, RXERRORS if Rx errors were detected while
;                       receiving data, or RXPHASEERRORS if in POINT or
;                       CONTINUOUS mode and a phase error is detected.
;   Registers Modified: AX
;   Remarks:            A record of data has the MSB of the first
;                       character set to a 1.  The routine verifies that
;                       the first character received is in PHASE.  If
;                       in STREAM mode, the routine resynches and tries
;                       to capture the data into the rxbuf.  If in POINT
;                       or CONTINUOUS mode, then the routine returns
;                       indicating a RXPHASEERROR.
;=============================================================================
;
get_serial_record proc  NEAR
                push    bx                  ; save regs
                push    cx
                push    si
                xor     si,si               ; clear SI for use as a counter
;
; Get the First Character
; .. if rxerror and in STREAM mode and NOT RXTIMEOUT continue
;
                call    waitforchar         ; get a character
                cmp     ax,0                ; see if char OK
                jge     char_ok1            ; if OK continue
                cmp     outputmode,STREAM   ; in STREAM mode?
                je      ckrxtimeout         ; if in STREAM ck timeout
                jmp     torecordfalseret    ; else return with error condition
ckrxtimeout:    cmp     ax,RXTIMEOUT        ; was it a timeout error
                jne     stream_ok           ; if not TIMEOUT continue
torecordfalseret:
                mov     ax,RXERRORS         ; Assume not in STREAM mode and indicate error...
                jmp     getrecordfalseret   ; else return with error condition
;
; Check to make sure the the phase bit is a '1', if not, then if STREAM mode
; resynch, else return with errors
;
char_ok1:       mov     ah,al               ; save character
                and     ah,80h              ; see if MSB of char = 1
                jnz     charok2             ; if 1, in PHASE
;
; if out of phase and if in STREAM mode, resynch, else, return with error
;
stream_ok:      cmp     outputmode,STREAM   ; in STREAM mode, dx = outputmode
                je      streamresynch       ; resynch if in STREAM
                mov     ax,RXPHASEERROR     ; indicate error...
                jmp     getrecordfalseret   ; .. and return
;
; Wait for the phase bit to be set
;
streamresynch:  xor     si,si               ; zero counter/pointer
                inc     phaseerror_count    ; keep track of error count
                call    waitforphase        ; wait for char in PHASE
                cmp     ax,0                ; ck for errors
                jge     charok2             ; if OK continue
                cmp     ax,RXTIMEOUT
                jne     streamresynch       ; else try to synch again
                jmp     getrecordfalseret   ; ...bad news...
;
; Store the characater, updata pointer and counter
;
charok2:        mov     [bx][si],al         ; store the character
                inc     si                  ; inc receive counter
;
; Get remainder of Block of data from the serial port, recsize characters
; and store them in rxbuf
;
getmorerxchars:
                call    waitforchar         ; get next char
                cmp     ax,0                ; ck for errors
                jge     charok3             ; char OK
                mov     ax,RXERRORS         ; indicate errors
                jmp     getrecordfalseret
;
; character is OK... but check to make sure still in PHASE
;
charok3:        cmp     al,0                ; now ck for phase bit
                jge     charok4             ; continue if OK
                cmp     outputmode,STREAM   ; in STREAM mode?
                je      streamresynch       ; if so, resynch
                mov     ax,RXPHASEERROR     ; else, return with error condition
                jmp     getrecordfalseret
;
; store the character, updata pointer and counter, then return
;
charok4:        mov     [bx][si],al         ; store the character
                inc     si                  ; increment the counter
                cmp     cx,si               ; see if done
                jne     getmorerxchars
                mov     ax,si               ; return the number of chars received
                jmp     getrecordret
;
; If exiting in an Error condition, clear the serial port
;
getrecordfalseret:
;               call    clear_rx

getrecordret:   pop     si                  ; restore regs
                pop     cx
                pop     bx
                ret
get_serial_record endp

;=============================================================================
;   get_serial_data     Get Serial Data from the bird
;   ----------------
;   Parameters Passed:  receiver buffer pointer in BX
;                       bytes to receive CX
;   Return Value:       if OK, AX is TRUE
;                       else, AX is FALSE
;   Registers Modified: AX
;   Remarks:            Routine will read CX bytes from the Bird and
;                       the data in a buffer pointed to by BX
;=============================================================================
;
get_serial_data proc    near
                push    si                      ; save regs
                mov     si,bx                   ; use SI as a pointer
getrxdatabyte:
                call    waitforchar             ; get a character
                cmp     ax,0                    ; get good data?
                jge     storerxdata              ; if good, store the data
                mov     dx,OFFSET badrxdatamsg  ; else, put up error msg
                call    putstring               ; msg to console
                call    hitkeycontinue          ; wait for confirm
                jmp     getserialfalseret
storerxdata:    mov     [si],al                 ; char in AL -> array
                inc     si                      ; increment array pointer
                loop    getrxdatabyte           ; keep gettin' data
                mov     ax,TRUE                 ; return TRUE
                jmp     getserialret
getserialfalseret:
                mov     ax,FALSE                ; return FALSE
getserialret:   pop     si
                ret
get_serial_data endp

;=============================================================================
;   send_serial_cmd     Send Serial Command to the Bird port
;   ----------------
;   Parameters Passed:  cmd in BX   -   string to send to the serial point
;                       cmdsize CX  -   size of the cmd string (cmd is NOT
;                                       NULL terminated, since the data can
;                                       be NULL)
;   Return Value:       number of characters transmitted in AX
;   Registers Modified: AX,CX
;   Remarks:            Routine will send a string of characters to the serial
;                       port.  The string is pointed to by cmd and all
;                       characters will be sent upto but NOT including
;                       the NULL
;=============================================================================
;
send_serial_cmd proc    NEAR
                push    dx
                push    si                  ; save reg
                xor     si,si               ; SI = 0
;
; disable interrupts while filling the txbuffer
;
                cli
;
; Check if the RS232 to FBB Command is in effect
;
                cmp     rs232tofbbaddr,0    ; if 0 the command is OFF
                je      sendcmd1            ;
sendrs232tofbbcmd:
                mov     al,0F0h             ; set the command
                or      al,rs232tofbbaddr   ; set the command addr
                call    send_serial_char    ; send the char
                cmp     ax,TXNOTEMPTY       ; see if char went out
                je      sendrs232tofbbcmd   ; try to send char again
;
; send character for character until done
;
sendcmd1:       mov     al,[bx]             ; get the first character
                call    send_serial_char    ; send the char
                cmp     ax,TRUE             ; see if char went out
                jne     sendcmdret          ; return...if no good
                inc     si                  ; keep a counter
                inc     bx                  ; point to next character
                loop    sendcmd1            ; continue until done
;
; Verify that the TX interrupt is enabled
; .. if not, enable it so that the ISR will execute
;
cktxintstate:
                mov     dx,com_base         ; get the 8250 address
                inc     dx                  ; point DX to the INTERENABLE reg
                in      al,dx               ; get the data
                and     al,TXHOLDINTENABLE  ; see if TX interrupts are on
                jnz     sendcmdret          ; if on..go home
;
; Enable the TX interrupts
;
                mov     al,TXHOLDINTENABLE + RXDATAAVAILINTENABLE + RXLINESTATUSINTENABLE
                out     dx,al               ; out to the hardware
                KILLTIME
                out     dx,al               ; out to the hardware
                KILLTIME                    ;
sendcmdret:     sti                         ; reenable when buffer is filled
                mov     ax,si               ; set AX to number of chars sent
                pop     si                  ; restore reg
                pop     dx
                ret                         ; home...
send_serial_cmd endp

;============================================================================
;   send_serial_char        Send one serial char to the serial port
;   ----------------
;
;   Parameters Passed:  chr to send in AL
;   Return Value:       in AX, returns TRUE if successful, or TXBUFFERFULL if
;                       the TXBUF is full
;   Registers Modified: AX
;   Remarks:            The routine is used to send a single character
;                       out to the UART if there is room in the output buffer.
;                       The routine checks to see if the Transmit interrupts
;                       are presently enabled...if not they are turned out
;                       so the ISR will get the character.
;=============================================================================
;
send_serial_char proc   NEAR
                push    bx                  ; save reg
                push    dx
;
; Check for buffer overrun
;       ... 2 ways the txbufinptr can = the txbufoutptr:
;               1) if the buffer is empty, which is OK
;               2) if the buffer is full, which is not OK
;
                mov     bx,txbufinptr       ; compare input and output ptrs
                cmp     bx,txbufoutptr      ; .....
                jne     writetxchar         ; if not equal go on
;
; is the tx buffer empty..if so go on
;
                cmp     txbufemptyflg,TRUE  ; see what the flag says
                je      writetxchar         ; if empty go on
                mov     ax,TXBUFFERFULL     ; set the error condition
                jmp     sendcharret         ; return with the error
;
; Write the character to the inbufptr and increment
;
writetxchar:    mov     [bx],al             ; put the character in the buffer
                inc     bx                  ; increment the pointer
                mov     txbufinptr,bx       ; store the pointer
                mov     txbufemptyflg,FALSE ; reset the empty flag
;
; Check for buffer end...wrap around if at end
;
                cmp     bx,OFFSET txbuf + TXBUFSIZE ; see if at the end
                jne     sendchartrueret             ; if not at end..continue
                mov     txbufinptr, OFFSET txbuf    ; reset the pointer

sendchartrueret: mov    ax,TRUE             ; return TRUE
sendcharret:    pop     dx                  ; restore reg
                pop     bx
                ret
send_serial_char endp


;=============================================================================
;   get_serial_char -   Get 1 Character from the serial port if one is available
;   ----------------
;
;   Parameters Passed:  none
;   Return Value:       returns the receive character if successful in AX
;                       RXERRORS if recieve errors
;                       NODATAAVAIL if no characer available
;   Registers Modified: AX
;   Remarks:            routine trys to read a char from the RX buffer.
;=============================================================================
;
get_serial_char proc    NEAR
                push    bx                  ; save reg
                push    dx
;
; First, ck to see if an error has occured at the ISR
;
                xor     ax,ax               ; clear AX
                mov     ax,rxerrorflg       ; get the rx error flg
                or      ax,rxbufoverrunflg  ; ck both flags
                jz      ckrxptrs            ; if OK, try to get a char
                jmp     clrrxerrors         ; else, return error condition
;
; See if character is available..if not return
;
ckrxptrs:       mov     bx,rxbufoutptr      ; compare input and output ptrs
                cmp     bx,rxbufinptr       ; see if the pointers are equal
                jne     getrxchar           ; if different, get the char
                mov     ax,NODATAAVAIL      ; return with condition
                jmp     getcharret          ; return
;
; get the character and increment the pointer
;
getrxchar:      mov     al,[bx]             ; get the character
                inc     bx                  ; increment the pointer
                mov     rxbufoutptr,bx      ; store the pointer

                cmp     bx,OFFSET rxbuf + RXBUFSIZE ; see if at buffer end
                jne     getcharret          ; if OK return the character
                                            ; AH = 0
                mov     rxbufoutptr,OFFSET rxbuf ; reset the ptr
                jmp     getcharret          ; return the char
;
; If errors have occured, put up the message and clear the flag(s)
;
clrrxerrors:    cmp     rxerrorflg,TRUE     ; ck the flag
                jne     ckrxoverrun         ; if OK, ck other flag
                mov     rxerrorflg,FALSE    ; reset the flag
                mov     dx,OFFSET rxerrormsg    ; get the error msg
                call    putstring               ; put msg to the screen

ckrxoverrun:    cmp     rxbufoverrunflg,TRUE    ; ck the flag
                jne     getcharfalseret         ; if OK, return error condition
                mov     rxbufoverrunflg,FALSE   ; reset the flag
                mov     dx,OFFSET rxbufoverrunerrormsg ; get the error msg
                call    putstring           ; put msg to the screen
getcharfalseret: call   clearserialints     ; clear pending serial interrupts
                mov     al,RXDATAAVAILINTENABLE + RXLINESTATUSINTENABLE
                mov     dx,com_base         ; reenable rx interrupts
                inc     dx                  ; point to interrupt enable reg
                out     dx,al               ; out to the hardware
                KILLTIME
                mov     ax,RXERRORS         ; return RXERRORS

getcharret:     pop     dx                  ; restore reg
                pop     bx
                ret
get_serial_char endp

;=============================================================================
;   waitforchar         Wait for a Character from the Serial Port
;   -----------
;
;   Parameters Passed:  none
;   Return Value:       In AX, returns the receive character if successful,
;                       RXERRORS if recieve errors,
;                       RXTIMEOUT if a time out occurs before a
;                       character is ready
;   Registers Modified: AX
;   Remarks:            Routine waits for TIMEOUTINSECS
;=============================================================================
;
waitforchar     proc    NEAR
                push    cx                  ; save regs
                push    dx
;
; Get the time now
;
                call    getdosticks             ; get the start time
                mov     starttimelow,dx     ; low word of tick count
                mov     starttimehigh,cx    ; high word of tick count

waitforchar1:   call    get_serial_char     ; try to get a character
                cmp     ax,NODATAAVAIL      ; is data available?
                jne     waitforchar2        ; check for errors/read character
                call    checktime           ; see if time is OK
                cmp     ax,TIMEOUTERR       ; did a timeout occur
                jne     waitforchar1
                mov     dx,OFFSET rxtimeoutmsg ; get user message
                call    putstring
                call    hitkeycontinue
                mov     ax,RXTIMEOUT        ; indicate a timeout error
                jmp     waitforcharret
waitforchar2:   cmp     ax,0                ; see if an errors
                jge     waitforcharret      ; no errors, so ret char
                mov     ax,RXERRORS         ; indicate a RX error

waitforcharret: pop     dx                  ; restore regs
                pop     cx
                ret
waitforchar     endp

;=============================================================================
;   waitforphase        Wait for a Character with phase bit set
;   ------------
;
;   Parameters Passed:  none
;   Return Value:       returns the received character if successful,
;                       RXERRORS if an error occurs
;                       RXTIMEOUT if a TIMEOUT occurs
;   Registers Modified: AX
;   Remarks:            waits for a character to be received with the
;                       most significant bit (bit 7) set to a '1'.  Characters
;                       received with bit 7 = '0' are thrown away.
;=============================================================================
;
waitforphase    proc    NEAR
;
; get a character
;
waitphase1:     call    waitforchar         ; wait for character
                cmp     ax, 0               ; see if errors
                jge     waitphase2          ; if not check phase
                jmp     waitforphaseret     ; return with error in AX
;
; check the phase of the character if no errors
;
waitphase2:     cmp     al,0                ; see if MSB is set
                jge     waitphase1          ; get more characters
waitforphaseret:                            ; return character in AX
                ret                         ; gotta go..
waitforphase    endp

;=============================================================================
;   checktime           Check Start time to Time Now
;   ------------
;
;   Parameters Passed:  starttimelow,startimehigh must have be previously set
;   Return Value:       In AX, TRUE if OK
;                       TIMEOUTERR if a time out occured
;   Registers Modified: AX
;   Remarks:            reads time now and sees if the diffence between
;                       timenow and starttime exceeds RXTIMEOUTINTICKS
;
;=============================================================================

checktime       proc    NEAR
                push    cx                  ; save reg
                push    dx

                call    getdosticks             ; get time now
                mov     ax,TRUE             ; assume a positive result
;
; Subtract the time Starttime from the Current time
; currently in CX (ms) and DX (ls)
;
                sub     dx,starttimelow     ; sub least sig
                sbb     cx,starttimehigh    ; sub most with borrow
;
; The result is in CX and DX.... ch only the least sig word, DX
;
                cmp     dx,RXTIMEOUTINTICKS
                jl      checktimeret
                mov     ax,TIMEOUTERR       ; assert the error condition
checktimeret:   pop     dx                  ; restore reg
                pop     cx
                ret
checktime       endp

;=============================================================================
;   getdosticks         Get DOS Tick Count
;   -----------
;
;   Parameters Passed:  none
;   Return Value:       DX low word of tick count
;                       CX high word of tick count
;                       AL midnight signal
;   Registers Modified: AX,CX,DX
;   Remarks:            reads time now using int 1ah function 0
;
;=============================================================================
;
getdosticks     proc    NEAR
                xor     ah,ah               ; set up for function 0
                int     1ah                 ; do the BIOS call
                ret                         ;
getdosticks     endp

;=============================================================================
;   serialisr           Serial Interrupt Service Routine
;   ---------
;
;   Parameters Passed:  none
;   Return Value:       none
;   Registers Modified: none
;   Remarks:            Routine processes the interrupt request from the
;                       8250 UART.  There are four possible interrupts from
;                       the UART (in highest to lowest priority)...
;                       RX Line Errors, RX Data Available, TX Data Buffer
;                       Empty, and Modem Status Change......all are processed
;                       while in the ISR.
;=============================================================================
;
; Jump table to get to specific section of the Serial ISR
;
serialisrtbl    dw      modemstatus         ; 0..MODEM STATUS change
                dw      serialisrret        ; 1..REAL isr ret
                dw      txdatairq           ; 2..TX DATA is ready
                dw      serialisrret        ; 3..invalid ID reg
                dw      rxdatairq           ; 4..RX DATA is ready
                dw      serialisrret        ; 5..invalid ID reg
                dw      rxlinestatusirq     ; 6..RX LINE ERRORS occured
                dw      serialisrret        ; 7..invalid ID reg

serialisr       proc    NEAR
                push    ax                  ; Save ALL regs used
                push    bx
                push    dx
                push    ds                  ; ...save

                mov     ax,_DATA            ; Need to get DS since we could
                mov     ds,ax               ; be in DOS when the interrupt
                                            ; occurred
;
; ck the 8250 interrupt request register
;
getintid:       sti                         ; enable higher priority ints
                xor     ax,ax               ; clear AX
                mov     dx,com_base         ; get the 8250 address
                inc     dx                  ; point DX to the inter request
                inc     dx                  ;
                in      al,dx               ; get the inter request data
                and     al,7h               ; ..should not be needed since
                KILLTIME                    ; ...but be safe!
;
; Use the serialisrtbl to get to proper action
;
                shl     ax,1                ; adjust for word table
                mov     bx,ax               ; use BX for Table offset
                jmp     serialisrtbl[bx]    ; process the interrupt
;
; Process Line Errors..
; On a line error read the Line Status reg and look for rx errors
; .. if error, set the flag and continue
;
rxlinestatusirq:
                inc     dx                  ; point dx to the Line Status reg
                inc     dx
                inc     dx
                in      al,dx               ; get the line status
                KILLTIME
                and     al,RXERRORMSK       ; look for rx errors
                jz      getintid            ; if OK, ck for more pending int
                mov     rxerrval,al         ; save the error condition
                mov     rxerrorflg,TRUE     ; set the error flag
                sub     dx,4                ; point to interrupt enable reg
                xor     al,al               ; AX = 0
                out     dx,al               ; disable further interrupts
                KILLTIME
                jmp     getintid            ; process pending ints
;
; Process Rx Data..
; ..get the character and store it in the RX circular buffer if there is
;   room...
;
rxdatairq:      dec     dx                  ; point to the rx data reg
                dec     dx
                cli                         ; disable ints while changing ptrs
                in      al,dx               ; get the data
                mov     bx,rxbufinptr       ; get the input pointer
                mov     [bx],al             ; store the data
                inc     bx                  ; increment the ptr
                mov     rxbufinptr,bx       ; store the ptr
;
; ck for rx buffer overruns
;
                cmp     bx,rxbufoutptr       ; if input = output..error
                jne     ckrxtop          ; if OK see if at buffer end
                mov     rxbufoverrunflg,TRUE ; else, set the error flag
;
; ck for top of buffer ...reset if at the top
;
ckrxtop:        cmp     rxbufinptr,OFFSET rxbuf + RXBUFSIZE ; see if at buffer end
                jne     getintid                ; if OK ck for ints pending
                mov     rxbufinptr,OFFSET rxbuf ; reset pointer
                jmp     getintid            ; ck for more ints pending
;
; Process the TX data request...get the data from the circular buffer and
; send it out to the UART
;
txdatairq: 
;
; Get the data from the txbuf, adjust the ptr 
;
                mov     bx,txbufoutptr      ; get the tx buffer ptr
                mov     ah,[bx]             ; get the currrent data
                inc     bx                  ; increment ptr
                cli                         ; disable ints while chging ptrs
                mov     txbufoutptr,bx      ; store the ptr
;
; ck for top of buffer ...reset if at the top
;
                cmp     bx,OFFSET txbuf + TXBUFSIZE ;
                jne     ckmoretxdata        ; if not at top ck for more tx data
                mov     bx, OFFSET txbuf    ; reset the ptr
                mov     txbufoutptr,bx      ; store the ptr
ckmoretxdata:   cmp     bx,txbufinptr       ; if input = output, no more data
                je      disabletxints                                          
                dec     dx                  ; point to the Tx data reg
                dec     dx              
                jmp     sendtxdataout       ; send out the Tx data
;
; shut down the Tx interrupts until more data is available
;
disabletxints:  dec     dx                  ; point to the interrupt enable reg
                mov     al, RXDATAAVAILINTENABLE + RXLINESTATUSINTENABLE
                out     dx,al               ; tx ints NOT enabled
                KILLTIME
                out     dx,al               ; done twice !!
                KILLTIME
                mov     txbufemptyflg,TRUE  ; set the empty flag  
                dec     dx                  ; point to the Tx data reg
;
; Send out the Tx Character
;
sendtxdataout:
                xchg    al,ah               ; get the data
                out     dx,al               ; output to the tx data reg
                KILLTIME                                   
                jmp     getintid            ; ck for more ints pending
;
; Process Modem Status changes
; ...note: should never get here since it is never enabled
;          but if we do, clear the request by reading modem status
;
modemstatusirq: add     dx,4                ; point the the Modem Status reg
                in      al,dx               ; read to clear
                KILLTIME
                jmp     getintid            ; ck for more ints pending
;
; At the end....Send the 8259 a Non Specific End of Interrupt
;
serialisrret:   pop     ds
                pop     dx                  ; restore ALL used regs
                pop     bx
                mov     al,INT_EOI          ; AL = non specific end of int
                out     INT_CNTRL_OCW2,al   ; out to the 8259
                KILLTIME
                pop     ax
                iret
serialisr       endp


;****************************************************************************
_TEXT           ENDS

                END

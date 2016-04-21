title   SERDPCPL.asm
subttl  Assembly Serial Routines for ABIRD
page    50,132
;
;****************************************************************************
;****************************************************************************
;   serdpcpl.asm    - Serial Port Routines in Assembly Language, polled mode
;
;   written for:    Ascension Technology Corporation
;                   PO Box 527
;                   Burlington, Vermont  05402
;
;                   802-655-7879
;
;   written by:     Jeff Finkelstein
;
;   Modification History:
;
;   10/18/90        jf  - created
;   4/16/91         jf  - renamed module to SERDPCPL.asm
;   6/18/91         jf  - added FOB baud rates
;   10/10/91        jf  - changed the default baud to 9600
;   10/29/91        jf  - removed the assertion of RTS just in case the
;                         user's cable has the RTS signal, so we don't hold
;                         the BIRD in RESET
;   4/6/92          jf  - added RS232 to FBB Command addr to send serial
;                         command
;
;
;          <<<< Copyright 1990 Ascension Technology Corporation >>>>
;*****************************************************************************
;*****************************************************************************
                INCLUDE menudef.inc         ; menu stuff
                INCLUDE serial.inc          ; include serial I/O stuff
                INCLUDE asctech.inc         ;

                .8086                       ; 8086 instructions only
;
;...public symbols
;
                PUBLIC  configserialport
                PUBLIC  saveserialconfig
                PUBLIC  restoreserialconfig
                PUBLIC  clear_rx
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
;
;...birdmain external variables
;
                EXTRN   outputmode:WORD
                EXTRN   buttonmode:WORD

;*****************************************************************************
_DATA           SEGMENT WORD PUBLIC 'DATA'


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
;
; Error Counters/Flags
;
phaseerror_count dw 0                       ; holds the phase errors
rxerrval        db 0                        ; holds the rx line errors
;
; a few bytes to store time
;
starttimelow    dw      0                   ; start time
starttimehigh   dw      0
timenowlow      dw      0                   ; current time
timenowhigh     dw      0

;
; Error Messages
;
rxtimeoutmsg    db  '**ERROR** receiver timed out','$'
badrxdatamsg    db  '**ERROR** could not read data from the BIRD',CR,LF,'$'

;
; Public Variables
;
                PUBLIC  phaseerror_count
                PUBLIC  com_base
                PUBLIC  comport
                PUBLIC  baudsel
                PUBLIC  bauddivisortbl
                PUBLIC  rs232tofbbaddr


_DATA           ENDS

;*****************************************************************************

_TEXT           SEGMENT WORD PUBLIC 'CODE'
                ASSUME  cs:_TEXT,ds:_DATA

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
;                               jmp $+2         ; jump to the PC + 2
;                               out dx,al       ; output to serial port
;                       or
;                               out dx,al       ; output to serial port
;                               clc             ; clear carry
;                               jnc $+2         ; jump to the PC + 2
;                               out dx,al       ; output to serial port
;=============================================================================
;
configserialport    proc    NEAR
                push    dx                  ; save reg
                push    bx
                mov     bx,ax               ; BX now has the divisor
                mov     dx,com_base         ; use DX to hold com base address
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
; Clear the Rx characters and errors...if any
;
                call    clear_rx            ; note: doesn't destroy DX
;
; Assert DTR...just in case the cable uses the DTR signal
;   side and the Host software needs CTS..this software doesn't!
;
                inc     dx                  ; point to the Modem Control reg
                mov     al,DTRON            ; assert the DTR bit
                out     dx,al               ; update the hdw
                KILLTIME
;
; Back to the calling routine
;
                pop     dx                  ; restore ret
                pop     bx
                ret
configserialport endp
        
;=============================================================================
;   saveserialconfig    save serial port configuration
;   ----------------
;
;   Parameters Passed:  (global) com_base
;   Return Value:       none
;   Registers Modified: DX,AX
;   Remarks:            save the current configuration of the serial port
;=============================================================================
saveserialconfig    proc NEAR
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

                ret                         ; all done
saveserialconfig endp

;=============================================================================
;   restoreserialconfig     Restore the original serial port configuration
;   ----------------
;
;   Parameters Passed:      (global) com_base
;   Return Value:           none
;   Registers Modified:     AX, DX
;   Remarks:                restores the serial port configuration to
;                           the configuration when saveserialconfig was called
;=============================================================================
;
restoreserialconfig proc NEAR
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

                ret                         ; all done
restoreserialconfig endp

;=============================================================================
;   clearrx             Read the characters out of the Rx buffer if available
;   --------
;
;   Parameters Passed:  (global) com_base
;   Return Value:       none
;   Registers Modified: AX
;   Remarks:            reads the data from the serial port and
;                       clears status errors if any
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
;
; read in the data..two reads should cover worst case
;
                mov     dx,com_base         ; get port address
                in      al,dx               ; read rx buffer
                KILLTIME
                in      al,dx               ; read rx buffer
                KILLTIME
;
; read the status reg
;
                add     dx,5                ; point to the status reg
                in      al,dx               ; reset the line status errors
                KILLTIME
                pop     dx                  ; restore regs
                ret                         ;...later
clear_rx        endp

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
                jmp     streamresynch       ; else try to synch again
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
;   Registers Modified: AX,CX,DX
;   Remarks:            Routine will send a string of characters to the serial
;                       port.  The string is pointed to by cmd and all
;                       characters will be sent upto but NOT including
;                       the NULL
;=============================================================================
;
send_serial_cmd proc    NEAR
                push    si                  ; save reg
                xor     si,si               ; SI = 0
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
                cmp     ax,TXNOTEMPTY       ; see if char went out
                je      sendcmd1            ; send char again
                inc     si                  ; keep a counter
                inc     bx                  ; point to next character
                loop    sendcmd1            ; continue until done
                mov     ax,si               ; return the counter
                pop     si                  ; restore reg
                ret                         ; home James..
send_serial_cmd endp

;=============================================================================
;   get_serial_char -   Get 1 Character from the serial port if one is available
;   ----------------
;
;   Parameters Passed:
;   Return Value:       returns the receive character if successful in AX
;                       RXERRORS if recieve errors
;                       NODATAAVAIL if no characer available
;   Registers Modified: AX
;   Remarks:            routine trys to read the serial port and returns if
;                       a character is NOT available
;=============================================================================
;
get_serial_char proc    NEAR
                push    dx                  ; save reg
;
; Get line status and check if character is available
; else return
;
                mov     dx,com_base         ; get the port address
                add     dx,LINESTATUS       ; offset to line status
                in      al,dx               ; get the line status
                KILLTIME
                mov     ah,al               ; save AL
ckrxerrors:     and     ah,RXERRORMSK       ; any Rx errors?
                jz      getchar1
                mov     ax,RXERRORS         ; return error condition
                jmp     getcharret          ;

;
; ck if data is available...if so, read it
;
getchar1:
                and     al,DATARDY          ; is data rdy?
                jz      getchar2            ; set the NODATAAVAIL condition
                sub     dx,LINESTATUS       ; point to the rxbuf
                in      al,dx               ; get the char
                xor     ah,ah               ; AH = 0
                KILLTIME
                jmp     getcharret          ; return the character
getchar2:       mov     ax, NODATAAVAIL     ; indicate no data is available
getcharret:     pop     dx                  ; restore reg
                ret
get_serial_char endp

;=============================================================================
;   send_serial_char        Send one serial char to the serial port
;   ----------------
;
;   Parameters Passed:      chr to send in AL
;   Return Value:           In AX, TRUE is sent OK, or TXNOTEMPTY if can't send
;   Registers Modified:     AX,DX
;   Remarks:                trys to send character to the UART
;=============================================================================
;
send_serial_char proc   NEAR
                push    dx                  ; save reg
;
; Get line status and check if transmit holding register is empty
; else return TXNOTEMPTY
;
                xchg    al,ah               ; save character to send
                mov     dx,com_base         ; get pointer to port
                add     dx,LINESTATUS       ; offset to point to the line status reg
                in      al,dx               ; reg status
                KILLTIME
                and     al,TXHOLDEMPTY      ; ready to send?
                jnz     sendchar1           ; send char
                mov     ax,TXNOTEMPTY       ; indicate not empty
                jmp     sendcharret         ; ret
sendchar1:      sub     dx,LINESTATUS       ; point to txbuf
                xchg    al,ah               ; get char to send
                out     dx,al               ; send the char to hdw
                KILLTIME
sendcharret:
                pop     dx                  ; restore reg
                ret
send_serial_char endp

;=============================================================================
;   waitforchar         Wait for a Character from the Serial Port
;   -----------
;
;   Parameters Passed:
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
                call    hitkeycontinue      ;
                mov     ax,RXTIMEOUT        ; indicate a timeout error
                jmp     waitforcharret      ;

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
;   Parameters Passed:
;   Return Value:       returns the received character if successful,
;                       or RXERRORS if an error occurs
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
                mov     ax,RXERRORS         ; indicate error condition
                jmp     waitforphaseret     ;
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
                call    getdosticks             ; get time now,
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
                ret
getdosticks     endp

;****************************************************************************
_TEXT           ENDS

        END

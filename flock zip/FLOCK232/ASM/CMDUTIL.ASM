title   ABIRD
subttl  Assembly Bird Utilites for ABIRD
page    50,132

;****************************************************************************
;****************************************************************************
;   CMDUTIL         Bird Commands Utilities
;
;                   Ascension Technology Corporation
;                   PO Box 527
;                   Burlington, Vermont  05402
;                   802-655-7879
;
;   written by:     Jeff Finkelstein
;
;   Modification History:
;       10/9/91     jf - created from BIRDCMDS.asm
;       4/22/92     mo - added function printquaternions
;
;          <<<< Copyright 1990 Ascension Technology Corporation >>>>
;*****************************************************************************
;*****************************************************************************
                INCLUDE menudef.inc             ; get menu definitions
                INCLUDE asctech.inc             ; Ascension Technology definitions
                INCLUDE serial.inc              ; serial definitions
                .8086                           ; 8086 instructions only
;
; Public Symbols
;
                PUBLIC  read_bird_data
                PUBLIC  check_done
                PUBLIC  converttounits
                PUBLIC  convert
                PUBLIC  getcrystalfreq
                PUBLIC  getaddrmode
                PUBLIC  printmatrix
                PUBLIC  printquaternions
;
; Public Variables
;
                PUBLIC  format
                PUBLIC  div_const
                PUBLIC  conv_const
                PUBLIC  anglecmd
                PUBLIC  getangle
                PUBLIC  crystalfreq
                PUBLIC  posk
;
; External Menuing Routines
;
                EXTRN   getfloatnumber:NEAR
                EXTRN   putstring:NEAR
                EXTRN   getstring:NEAR
                EXTRN   putchr:NEAR
                EXTRN   displayunsigned:NEAR
                EXTRN   hitkeycontinue:NEAR
                EXTRN   ckkeyrdy:NEAR
                EXTRN   clearkey:NEAR
                EXTRN   getchr:NEAR
                EXTRN   newline:NEAR
;
; External Serial Routines
;
                EXTRN   get_serial_record:NEAR
                EXTRN   get_serial_data:NEAR
                EXTRN   send_serial_cmd:NEAR
                EXTRN   waitforchar:NEAR
                EXTRN   clear_rx:NEAR
;
; External Birdcmds Variables
;
                EXTRN   birdstreamcmd:BYTE
                EXTRN   birdpointcmd:BYTE
                EXTRN   birdexmvaluecmd:BYTE
                EXTRN   txdatabuf:byte
                EXTRN   rxdatabuf:byte

;
; External Birdmain Variables
;
                EXTRN   buttonmode:WORD
                EXTRN   buttonvalue:WORD
                EXTRN   outputmode:WORD
;
; External Serial Variables
;
                EXTRN   phaseerror_count:WORD


;*****************************************************************************

_DATA               SEGMENT WORD PUBLIC 'DATA'

;
; Bird Status Message
;
birdstatusmsg       db  CR,LF,'Checking Bird Status...',CR,LF,'$'


;
; Conversion Variables/Storage
;
tempbuf             db  TBUFSIZE dup(?)     ; temporary output buffer
div_const           dw  32768               ; division constant for conversion
format              dw  0                   ; format of data..#'s past decimal
conv_const          dw  0                   ; converion constant
crystalfreq         dw  0                   ; Bird CPU cyrstal frequency
posk                dw  POSK36              ; position variable

;
; Get angle Table for Questions and Validation
; MAX/MIN are normalized angles...7fffh = 179.99, 8000h = -180.00
;
getangletbl         dw  azimuthmsg,7fffh,8000h  ; question, MAX, MIN
                    dw  elevationmsg,4000h,0C000h
                    dw  rollmsg,7fffh,8000h
azimuthmsg          db  'Input the Azimuth (###.##):','$'
elevationmsg        db  'Input the Elevation (##.##):','$'
rollmsg             db  'Input the Roll (###.##):','$'

;
; Angle Conversion Storage
;
anglecmd            db  0                   ; temporary storage for the cmds
sinazimuth          dw  0                   ; sine of azimuth
cosazimuth          dw  0                   ; holds the cosine of azimuth
sinelevation        dw  0                   ; sine of elevation
coselevation        dw  0                   ; cos of elevation
sinroll             dw  0                   ; sine of roll
cosroll             dw  0                   ; cos of roll

;
; Error Messages
;
phaseerrormsg       db  '*NOTE* Phase Errors have occured: ','$'
serialrecorderrmsg  db  '** ERROR ** could not read record data from the BIRD',CR,LF,'$'
angleerrormsg       db  '** ERROR ** invalid Euler Angle',CR,LF,'$'
crtsyncerrmsg       db  '** ERROR ** could not read crystal data from the Bird',CR,LF,'$'
birdstatuserrmsg    db  '** ERROR ** could not read the Bird Status',CR,LF,'$'

_DATA               ENDS

;*****************************************************************************

;*****************************************************************************

_TEXT           SEGMENT WORD PUBLIC 'CODE'
                ASSUME  cs:_TEXT,ds:_DATA


;=============================================================================
;   read_bird_data      Read Bird Data and convert to 2's complement
;   ----------------
;
;   Parameters Passed:  birddata in BX, pointer to integer array to store data
;                       numwords in CX, number of words (16 bits) to read
;                       outputmode  (global), POINT, CONTINUOUS, or STREAM
;                       buttonmode (global), 0 if off, 1 if on (send button value)
;
;   Return Value:       TRUE if successful
;                       FALSE otherwise
;   Registers Modified: AX
;   Remarks:            routine reads a record from the bird, and adjusts
;                       the least and most significant Bird bytes into 2's
;                       complemented words.
;=============================================================================
;
read_bird_data  proc    near
                push    bx                  ; save reg
                push    cx
;
; Read 2*numbwords characters from the bird, check for errors
;       ...add one character buttonmode == 1
;
                push    cx                  ; will need word count later
                shl     cx,1                ; multiply CX by 2
                add     cx,buttonmode       ; add 1 to CX if buttonmode = 1
                call    get_serial_record   ; get a complete record
                cmp     ax,0
                jl      displayrxerrors
;
; go though the birddata and make into two's complemented
;   16 bit integers by:
;       - shifting the least sig byte 1 position
;       - shifting the complete word 1 position
;
norxerrors:     pop     cx                  ; get word count
convertbirddata:
                mov     ax,[bx]             ; get the complete word
                shl     al,1                ; shift lsb 1
                shl     ax,1                ; shift whole word 1
                mov     [bx],ax             ; store the converted word
                inc     bx                  ; point to next word
                inc     bx
                loop    convertbirddata     ; do for CX number of words
                jmp     ckbuttonmode
;
; Errors have occured so display appropriate messages
;
displayrxerrors:
                mov     dx,OFFSET serialrecorderrmsg
                call    putstring           ; send error message
;
; If in STREAM mode, send a B to shut off
;
ckoutputmode:   cmp     outputmode,STREAM   ; see if stream mode
                jne     readbirdfalseret
                mov     bx,OFFSET birdpointcmd ; send point cmd to SHUT off
                mov     cx,1                ; 1 character command
                call    send_serial_cmd     ; out she goes
                cmp     phaseerror_count,0  ; see if phase errors occured
                je      readbirdfalseret
                mov     dx,OFFSET phaseerrormsg
                call    putstring           ; send phase error message
                mov     ax,phaseerror_count
                call    displayunsigned     ; display number of phase errors
                call    newline             ; CR LF
readbirdfalseret:
                mov     ax,FALSE            ; indicate error
                pop     cx                  ; clean up stack
                jmp     readbirdret
ckbuttonmode:    cmp        buttonmode,0           ; check if button mode is OFF
                je      readbirdtrueret        ; if off, return TRUE
                mov        ax,[bx]             ; get the button value
                xor        ah,ah                ; clear AH
                mov        buttonvalue,ax        ; store the button value

readbirdtrueret:
                mov     ax,TRUE             ; indicate a good record
readbirdret:    pop     cx                  ; restore regs
                pop     bx
                ret                         ; ...homeret       ; ..home
read_bird_data  endp

;=============================================================================
;   check_done          Check to see if Data Output Done
;   ----------------
;
;   Parameters Passed:  outputmode (global) POINT, CONTINUOUS, STREAM
;   Return Value:       TRUE if done, else FALSE
;   Registers Modified: AX
;   Remarks:            POINT mode:
;                           - wait for key hit
;                           - if B/b return FALSE
;                             else, return TRUE
;
;                       CONTINUOUS mode:
;                           - if key hit return TRUE
;                             else, return FALSE
;
;                       STREAM mode:
;                           - if key hit
;                               send 'B' command to turn off stream mode
;                               return TRUE
;                             else, return FALSE
;=============================================================================
;
check_done      proc    near
                push    si                  ; save reg
                mov     si,outputmode       ; use SI to hold outputmode
;
; Do this as a function of POINT, CONTINUOUS, or STREAM outputmode
;
; Stream mode
;
                cmp     si, STREAM          ; in STREAM mode?
                jne     ckcontinuous        ; if not, ck CONTINUOUS
                call    ckkeyrdy            ; has there been a kit hit?
                cmp     ax,TRUE             ; if key hit,
                jne     ckdonefalseret
;
; Shut off the stream...via sending the POINT command
;
                mov     cx,1                ; send a 'B' to shut off
                mov     bx, OFFSET birdpointcmd ; get cmd string
                call    send_serial_cmd     ; send the cmd
                call    clearkey            ; clear the keyboard
                cmp     phaseerror_count,0  ; have phase errors occured
                je      ckdonetrueret       ; if not return done
                mov     dx,offset phaseerrormsg
                call    putstring           ; put up phase error msg
                mov     ax,phaseerror_count ; get count
                call    displayunsigned     ; display number of phase errs
                jmp     ckdonetrueret       ; return done
;
; Continuous Mode
;
ckcontinuous:   cmp     si, CONTINUOUS      ; in CONTINUOUS mode?
                jne     pointmode           ; if not, must be in POINT mode
                call    ckkeyrdy            ; is key ready
                cmp     ax,TRUE             ; if so return TRUE
                jne     getmorepoints1      ; else get another set of points
                call    clearkey            ; clear the key board
                jmp     ckdonetrueret       ; return TRUE
getmorepoints1: mov     cx,1                ; send a 'B' to get more points
                mov     bx, OFFSET birdpointcmd ; get cmd string
                call    send_serial_cmd     ; send the cmd
                jmp     ckdonefalseret      ; return TRUE
;
; Point Mode
;
pointmode:      call    getchr              ; wait for a key
                cmp     al,'B'              ; hit a B?
                je      getmorepoints2      ; yep..get more data
                cmp     al,'b'              ; hit a b?
                je      getmorepoints2      ; yep..get more data
                jmp     ckdonetrueret       ; else return TRUE
getmorepoints2: mov     cx,1                ; send a 'B' to get more points
                mov     bx, OFFSET birdpointcmd ; get cmd string
                call    send_serial_cmd     ; send the cmd

ckdonefalseret: mov     ax,FALSE            ; return FALSE, not done
                jmp     ckdoneret
ckdonetrueret:  call    hitkeycontinue
                mov     ax,TRUE             ; return TRUE, done
ckdoneret:      pop     si                  ; restore reg
                ret
check_done      endp

;=============================================================================
;   converttounits      Convert Raw Data to Units
;   --------------
;
;   Parameters Passed:  BX points to the receive buffer data
;                       CX contains the number of words to convert
;                       conv_const (global), conversion constant
;                       div_const (global)...set to 32768
;   Return Value:       none
;   Registers Modified: AX,BX,BP
;   Remarks:            Convert CX number of word(s) pointed to by BX to
;                       using the conv_const and the print the data on the
;                       console using convert (to ascii)
;
;                       BX is left pointing to the end of the last displayed
;                       word
;
;                       number = ([BX] * conv_const)/div_const
;=============================================================================
;
converttounits  proc    near
                push    dx              ; save regs

conv_loop:
                mov     ax,[bx]         ; get the data
;
; get absolute value of number for output
;
                cwd                     ; set all bits in DX to AX's sign bit
                xor     ax,dx           ; 1's comp if AX was neg
                sub     ax,dx           ; now 2's comp if AX was neg
                mov     bp,dx           ; save DX in BP (acts as negative flag)
;
; multiply data word by conversion constant
;
                mul     conv_const      ; multiply by the constant
                div     div_const       ; divide by 32768 (only way), into AX
                mov     dx,ax           ; convert routine wants input in DX
                call    convert         ; convert to ASCII format and print
                                        ; w/format already set
                inc     bx              ; point to next data point
                inc     bx
                loop    conv_loop       ; repeat until done with request

                pop     dx              ; restore regs
                ret                     ; home....

converttounits  endp

;=============================================================================
;   convert             convert unit data to format data
;   -------
;
;   Parameters Passed:  On entry abs(number) is in DX.
;                       Sign of Data is in BP
;                       format (global) must be set to proper number of
;                       decimal points
;   Return Value:       none
;   Registers Modified: AX
;   Remarks:            Routine converts data word in DX to ASCII format,
;                       then prints
;=============================================================================
;
convert         proc    near
                push    bx                  ; save regs
                push    cx
                push    dx
                push    di
                push    si
;
; fill the buffer with spaces
;
                mov     al,' '
                lea     di,tempbuf
                mov     cx,tbufsize
                rep     stosb
;
; strip digits from number in DX and put in buffer
;
                xor     si,si               ;SI at 0 index
fillloop:
                mov     ax,dx               ;divide AX by BX
                xor     dx,dx               ;need DX clear
                mov     bx,10               ;divisor of 10
                div     bx                  ;divide
                xchg    ax,dx               ;get quotient
                add     al,'0'              ;add ASCII 0..convert to ASCII
                mov     tempbuf[si],al      ;put in buffer
                inc     si                  ;next byte into buffer
                cmp     format,si           ;check if up to decimal point
                jg      fillloop            ;not there yet, go back to top
                jl      check_done1          ;past it, so check if DX=0
                mov     tempbuf[si],'.'     ;put decimal point in buffer
                inc     si                  ;next byte into buffer
                jmp     fillloop            ;go back to top for at least another digit
check_done1:
                cmp     dx,0                ;done?
                jnz     fillloop
;
; put negative sign in buffer if necessary
;
                cmp     bp,0                ;check if number was negative
                je      startout            ;nope, jump
                mov     tempbuf[si],'-'     ;print '-' for negative output
;
; now print value to screen
;
startout:
                mov     si,TBUFSIZE         ;start SI just past end of buffer
                mov     cx,TBUFSIZE         ;loop counter for output
outloop:
                dec     si                  ;move down through temp buffer
                mov     al,tempbuf[si]      ;get byte
                call    putchr              ;print it
                loop    outloop             ;done?

                pop     si                  ; restore regs
                pop     di
                pop     dx
                pop     cx
                pop     bx
                ret

convert         endp

;===============================================================================
;   printmatrix         Print Formatted Matrix Data
;   ----------------
;
;   Parameters Passed:  Matrix Data to Convert and print pointed to by BX
;   Return Value:       none
;   Registers Modified: AX,BX
;   Remarks:            converts 9 matrixs points to units and prints
;                       matrix data on the console
;=============================================================================
;
printmatrix     proc    near
                    push    cx
                    push di
                    push    si

;
; Print the 3 Columns of data on each row
;
                    mov     di,bx               ; store the array pointer
                    mov     si,3                ; setup for 3 rows
nextrow:
                    mov     cx,1                ; 1 number for convertounits
                    mov     format,MATRIXFORMAT ; set up decimal point for matrix
                    mov     conv_const,MATK     ; set up conversion constant
                    mov     bx,di
                    call    converttounits      ; convert and display
                    mov     cx,1                ; 1 number for convertounits
                    mov     format,MATRIXFORMAT ; set up decimal point for matrix
                    mov     conv_const,MATK     ; set up conversion constant
                    add     bx,4                ; point to the next column data
                    call    converttounits      ; convert and display
                    mov     cx,1                ; 1 number for convertounits
                    mov     format,MATRIXFORMAT ; set up decimal point for matrix
                    mov     conv_const,MATK     ; set up conversion constant
                    add     bx,4                ; point to the next column data
                    call    converttounits      ; convert and display
                    dec     si
                    inc     di                  ; point to the next row data point
                    inc     di
                    cmp     si,0                ; see if on the last row
                    je      ckbuttonmode1       ; if not, do the next row
                    call    newline             ; else, send a newline
                    jmp     nextrow             ; continue to the next row

;
; Display button value if in button mode
;
ckbuttonmode1:      cmp     buttonmode,0        ; ck if in Button Mode
                    je      printmatrix1        ; if not..move on

                    mov     al,TAB              ; else, send at TAB
                    call    putchr              ; .. to the console
                    call    putchr              ; .. two times
                    mov     ax,buttonvalue      ; get the buttonvalue
                    call    displayunsigned     ; display the button value
                    call    newline
printmatrix1:
                    call    newline             ; send a newline
                    call    newline

                    pop     si
                    pop       di
                    pop     cx
                    ret
printmatrix     endp


;===============================================================================
;   printquaternions         Print Formatted Quaternions Data
;   ----------------
;
;   Parameters Passed:  Quaternions Data to Convert
;                       and print pointed to by BX
;   Return Value:       none
;   Registers Modified: AX,BX
;   Remarks:            converts 4 quaternions points to units and prints
;                       quaternions data on the console
;=============================================================================
;
printquaternions    proc    near
                    push    cx
                    push    di
                    push    si

;
; Print the 3 Columns of data on each row
;
                    mov     di,bx               ; store the array pointer
                    mov     si,4                ; setup for 1 row
nextrow2:
                    mov     cx,1                ; 1 number for convertounits
                    mov     format,MATRIXFORMAT ; set up decimal point for matrix
                    mov     conv_const,MATK     ; set up conversion constant
                    mov     bx,di
                    call    converttounits      ; convert and display
                    dec     si
                    inc     di                  ; point to the next row data point
                    inc     di
                    cmp     si,0                ; see if on the last row
                    je      ckbuttonmode2       ; if not, do the next row
                    ;call    newline             ; else, send a newline
                    jmp     nextrow2             ; continue to the next row

;
; Display button value if in button mode
;
ckbuttonmode2:      cmp     buttonmode,0        ; ck if in Button Mode
                    je      printquaternions1        ; if not..move on

                    mov     al,TAB              ; else, send at TAB
                    call    putchr              ; .. to the console
                    call    putchr              ; .. two times
                    mov     ax,buttonvalue      ; get the buttonvalue
                    call    displayunsigned     ; display the button value
                    call    newline
printquaternions1:
                    call    newline             ; send a newline
                    call    newline

                    pop     si
                    pop       di
                    pop     cx
                    ret
printquaternions     endp

;===============================================================================
;   getangle            Get 3 angles from the user
;   --------
;
;   Parameters Passed:  none
;   Return Value:       In AX, TRUE if successful
;                       ESC_SEL if the user selects ESC
;   Registers Modified: AX
;                       (globals) cosazimuth,sinazimuth
;                       coselevation,sinelevation,cosroll,sinroll
;                       format
;   Remarks:            Queries the User for Azimuth, Elevation and Roll..
;
;                       NOTE: the routine DOES NOT PROVIDE robust input 
;                       error checking....it is possible to get a DIVIDE BY
;                       ZERO (DOS) message or a DIVIDE OVERFLOW message if
;                       invalid angle values are input
;=============================================================================
;
getangle        proc    near
                mov     format,2            ; setup for 2 places past decimal
                mov     conv_const,ANGK     ; setup for angle conversion
                mov     bx,OFFSET getangletbl ; get question and validation ptr
                mov     si,OFFSET sinazimuth  ; use SI as ptr for cos/sine
                mov     cx,3                ; get 3 angles: AZIMUTH,ELEV,ROLL

getangle1:      mov     dx,[bx]             ; get the question
                call    putstring           ; put up question
                call    getfloatnumber      ; get angle
                cmp     ax,TRUE             ; float number OK?
                je      validateangle       ; if so, validate the number
                jmp     getangleescret      ; else, return with ESC_SEL
;
; Validate Angle  .... -MIN <= ANGLE <= MAX
;
validateangle:  cmp     dx,[bx] + 2         ; is angle > MAX
                jg      angleerr            ; if so, error
                cmp     dx,[bx] + 4         ; else, is angle >= -MIN
                jge     convertangle        ; if so, convert to sin and cos
angleerr:       mov     dx,OFFSET angleerrormsg ; else send angle error msg
                call    putstring           ; put message to screen
                call    hitkeycontinue      ; confirm error
                jmp     getangle1           ; do again
;
; call routine to convert to sin and cosine
;
convertangle:   mov     ax,dx               ; trig funcs want angle in AX
                call    sinangle            ; get the sin
                mov     [si],ax             ; store the sin
                inc     si                  ; point to cosine storage
                inc     si
                mov     ax,dx               ; AX, got smashed during sinangle
                call    cosangle            ; get the cosine
                mov     [si],ax             ; store the cosine
                inc     si                  ; point to sin storage
                inc     si
                add     bx,6                ; point to next angle question
                loop    getangle1           ; continue getting angles
                jmp     getangletrueret

getangleescret: mov     ax,ESC_SEL
                jmp     getangleret
getangletrueret:
                mov     ax,TRUE
getangleret:
                ret
getangle        endp

;===============================================================================
;   getcrystalfreq      Get the CPU crystal frequency from the Bird
;   --------
;
;   Parameters Passed:  none
;   Return Value:       In AX, TRUE if successful
;                       else, FALSE
;   Registers Modified: AX, sets (global) crystalfreq
;   Remarks:            Routine sends down the Examine Command to the Bird
;=============================================================================
;
getcrystalfreq  proc    near
                push    bx                  ; save regs
                push    cx

                mov     bx,OFFSET txdatabuf ; use the txdatabuf for the cmd
                mov     al,birdexmvaluecmd  ; get the command byte into AL
                mov     ah,2                ; cmd to get crystal frequency
                mov     [bx],ax             ; store both the cmd and data
                mov     cx,2                ; setup for a 2 byte cmd
                call    send_serial_cmd     ; send the cmd
                cmp     ax,2                ; ck cmd went out OK
                je      getcrystaldata      ; continue if OK
                jmp     getcrystalfalseret  ; else ...quit
;
; Get the 4 Byte response into the rxdatabuf
;
getcrystaldata: mov     cx,2                ; setup to receive 2 bytes
                mov     bx,OFFSET rxdatabuf ; receive data into the rxdatabuf
                call    get_serial_data     ; get the data
                cmp     ax,TRUE             ; verify all went OK
                jne     getcrystalfalseret
                mov     bx,WORD PTR [rxdatabuf] ; get the data
                mov     crystalfreq,bx      ; store the data
                jmp     getcrystalret       ;..done
getcrystalfalseret:
                mov     dx,OFFSET crtsyncerrmsg ; get the error msgtab
                call    putstring           ; put up an error msg
                call    hitkeycontinue
                mov     ax,FALSE
getcrystalret:  pop     cx
                pop     bx
                ret
getcrystalfreq  endp

;===============================================================================
;   getaddrmode         Get Address Mode
;   -----------
;
;   Parameters Passed:  none
;   Return Value:       In AX, the number of receivers
;   Registers Modified: AX
;   Remarks:            Routine sends down the Examine Command to the Bird
;=============================================================================
;
getaddrmode     proc    near
                push    bx                  ; save regs
                push    cx

                mov     dx,OFFSET birdstatusmsg
                call    putstring

                mov     ax,WORD PTR birdexmvaluecmd  ; get the command byte into AL
                mov     WORD PTR txdatabuf,ax ; store both the cmd and data
                mov     txdatabuf+1,0       ; cmd to get Bird Status
                mov     bx,OFFSET txdatabuf ; use the txdatabuf for the cmd
                mov     cx,2                ; setup for a 2 byte cmd
                call    send_serial_cmd     ; send the cmd
                cmp     ax,2                ; ck cmd went out OK
                je      getaddrmodedata     ; continue if OK
                jmp     getaddrmodefalseret ; else ...quit
;
; Get the 1 Byte response into the rxdatabuf
;
getaddrmodedata:
                mov     cx,2                ; setup to receive 2 bytes
                mov     bx,OFFSET rxdatabuf ; receive data into the rxdatabuf
                call    get_serial_data     ; get the data
                cmp     ax,TRUE             ; verify all went OK
                jne     getaddrmodefalseret
                mov     bx,WORD PTR [rxdatabuf] ; get the data
                mov     ax,14               ; assume normal addressing mode
                and     bh,00000100b        ; check if in Expanded address mode
                jz      getaddrmoderet
                mov     ax,30
                jmp     getaddrmoderet

getaddrmodefalseret:
                mov     dx,OFFSET birdstatuserrmsg ; get the error msgtab
                call    putstring           ; put up an error msg
                call    hitkeycontinue
                mov     ax,FALSE
getaddrmoderet:
                pop     cx
                pop     bx
                ret


getaddrmode     endp


;===========================================================================
;                   TRIG FUNCTIONS...SINE and COSINE
;===========================================================================
;
; Slope Table for Cosine and Sin;....SIN/COS(input) = (slope*input)+intercept
;
; NOTE: sinslopetbl[62] modified from 316 to 315 to prevent overflow
;
sinslopetbl         DW  25733 , 25718 , 25687 , 25640 , 25579 , 25501 , 25409 , 25301
                    DW  25177 , 25039 , 24886 , 24717 , 24534 , 24336 , 24123 , 23895
                    DW  23654 , 23398 , 23128 , 22844 , 22546 , 22235 , 21910 , 21572
                    DW  21221 , 20857 , 20481 , 20093 , 19692 , 19279 , 18855 , 18420
                    DW  17973 , 17516 , 17048 , 16569 , 16081 , 15583 , 15076 , 14559
                    DW  14034 , 13501 , 12959 , 12409 , 11852 , 11288 , 10717 , 10140
                    DW  9556 , 8967 , 8372 , 7772 , 7168 , 6559 , 5946 , 5330
                    DW  4711 , 4088 , 3463 , 2837 , 2208 , 1578 , 947 , 315
                    DW    0                 ; First entry for reverse table access
cosslopetble        EQU $-2                 ; Define cosine slope table
                                            ; as previous table...backwards
;
; Intercept Table for Cosine and Sin
;
sinintercepttbl     DW  0 , 1 , 2 , 7 , 15 , 27 , 44 , 68
                    DW  99 , 138 , 186 , 244 , 312 , 393 , 486 , 593
                    DW  713 , 849 , 1001 , 1170 , 1356 , 1560 , 1784 , 2027
                    DW  2290 , 2574 , 2880 , 3208 , 3558 , 3932 , 4330 , 4752
                    DW  5198 , 5670 , 6167 , 6691 , 7240 , 7816 , 8418 , 9047
                    DW  9704 , 10388 , 11099 , 11837 , 12603 , 13397 , 14217 , 15066
                    DW  15941 , 16843 , 17772 , 18728 , 19711 , 20719 , 21753 , 22812
                    DW  23896 , 25005 , 26137 , 27293 , 28471 , 29672 , 30894 , 32138
                    DW  32767               ; First entry for reverse table access
cosintercepttbl     EQU $-2                 ; Define cosine intercept table
                                            ; as previous table...backwards

;===============================================================================
;   sinangle            Sin of Angle
;   --------
;
;   Parameters Passed:  In AX, angle as 2's comp
;                         (8000h = -180.00, 7fffh = 179.9996)
;   Return Value:       In AX, Sin of Angle in 2's comp
;                         (-1.0000 -> 0.99996)
;   Registers Modified: AX
;   Remarks:            Routine uses the SIN slope and intercept table to
;                       determine the sin of the angle input in AX.
;                           SIN(input) = (slope*input)+intercept
;                       Prior to using the tables, the angle must be
;                       'brought' into 0->90 degrees.
;                               input =    0  sin(input) = 0
;                          0 <  input <   90  sin(input) = sin(input)
;                               input =   90  sin(input) = 7fffh
;                         90 <= input <  180  sin(input) = cos(input-90)
;                               input = -180  sin(input) = 0
;                       -180 <  input <  -90  sin(input) = -cos(|input|-90)
;                        -90 <= input <    0  sin(input) = -sin(|input|)
;
;                       Implement the COS(input) by using the SIN table
;                       backwards! (ie. sinslopetbl[1] = cosslopetbl[-62] )
;=============================================================================
;
sinangle        proc    near
                push    bx    ; save regs
                push    dx
                push    bp
                push    di
                push    si
                xor        bp,bp ; use BP for sign
                xor        di,di ; use DI to access the
                              ; tables in reverse if DI = 0ffh
;
; First, Determine Quadrant ... trap out -180 as special
;
            mov     si,ax     ;save the angle in SI
            cmp     ax,4000h  ;see if 90 degrees
            jne     seeifneg90
            mov     ax,7fffh  ; else, return 0.99996
            jmp     sinret
seeifneg90: cmp     ax,0c000h ;see if -90 degrees
            jne     seeif180  ;if not, continue
            and     ax,8000h  ;else, return -1.0000
            jmp     sinret
seeif180:   and     ax,7fffh  ;see if 0 or -180.00 degrees
            jz      sinret    ;if so, return 0
            mov     ax,si     ;get back angle in AX
            and     si,0c000h  ;get quadrant bits
            cmp     si,0      ;is it QI
            je      sinquad1
            cmp     si,4000h  ;Q2?
            je      sinquad2
            cmp     si,8000h  ;Q3?
            je      sinquad3
            jmp     sinquad4  ;else, it must be Q4...SI=0C000h
;
; -180 < Input < -90
;
sinquad3:   cwd               ; extend sign bit to DX
            xor     ax,dx     ; do absolute value...stay positive if pos
            sub     ax,dx     ; ...if negative -> positive
            mov     bp,0ffffh ; set sign to negative
;
; 90 < Input < 180
;
sinquad2:   mov     dx,8000h  ; set DX to 180 degrees
            sub     dx,ax     ; DX = DX - AX, get angle in Q1
            sub     ax,4000h  ; subtract 90 degrees from AX
            mov     di,0ffh   ; use SIN table backwards ...COS table
            jmp     dosin     ; do the SIN calculation with the lookup
                              ; using the Angle in AX and the input
                              ; angle in DX
;
; -90 <= Input < 0
;
sinquad4:   cwd               ; extend sign bit to DX
            xor     ax,dx     ; do absolute value...stay positive if pos
            sub     ax,dx     ; ...if negative -> positive
            mov     bp,0ffffh ; set sign to negative

;
; Get info from table using 6 bits for Address, then adjusted
; for word values (2 bytes) in tables....
; ... at this point, AX is a normilized angle 0 to 3FFFh (0 to 90 degrees)
;
sinquad1: mov       dx,ax     ;use DX to hold current angle value
dosin:    xor       bx,bx     ;init bx with zero
          mov       bl,ah     ;move high byte of lookup angle to ls byte
                              ;of BX to affect a shift right by 8 bits.
          xor       bx,di     ;negate ONLY if a reverse table access (Q2,Q3)
          and       bl,3fh    ;mask off to leave 6 bits...64 choices
          or        di,di      ;ck if reverse access
          jz        forwardaccess ;if not, go on
          inc        bl        ;else add one to the table lookup index
forwardaccess:
          sal       bl,1      ;adjust for word access in table

;
; FORM (SLOPE)*(INPUT) then multiply by 4 since table slope is Slope/4
;        ...do extra multiply by 2 to compensate for sign bit
;
          mov       ax,cs:sinslopetbl[bx] ;get slope (S-1) of line in AX.
          mul       dx        ;DX:AX(S-2) = slope * input angle
                              ;
          sal       ax,1      ;Multiply DX:AX by 2
          rcl       dx,1      ;
          sal       ax,1      ;Multiply DX:AX by 2
          rcl       dx,1      ;
          sal       ax,1      ;Multiply DX:AX by 2 ...for sign bit
          rcl       dx,1      ;
;
;ADD INTERCEPT
;
          mov       ax,cs:sinintercepttbl[bx] ;get line intercept with axis
          add       dx,ax     ;sin(input) = (slope*input)+intercept
;
; now correct for Quadrant sign...result currently in DX
; .. fixup using sign data from BP
;
correctsinquad:
          xor       dx,bp     ;convert to 1's comp if negative
          sub       dx,bp     ;convert to 2's comp
          mov       ax,dx     ;...result in AX

sinret:   pop       si                      ; restore regs
          pop       di
          pop       bp
          pop       dx
          pop       bx
          ret
sinangle        endp

;===============================================================================
;   cosangle            Cosine of Angle
;   --------
;
;   Parameters Passed:  In AX, angle as 2's comp
;                         (8000h = -180.00, 7fffh = 179.9996)
;   Return Value:       In AX, Cosine of Angle in 2's comp
;                         (-1.0000 -> 0.9999)
;   Registers Modified: AX
;   Remarks:            Routine uses the Trig identity:
;                             COS(X) = SIN (X+90)
;                       Therefore, sinangle is alway used
;=============================================================================
;
cosangle        proc    near
                add     ax,4000h            ; add 90 degrees to input
                call    sinangle            ; get the sin of the input
                ret                         ; ret with COS(input) in AX
cosangle        endp

;*****************************************************************************
_TEXT           ENDS
                                                                                                                                       

   
                end

title   ABIRD
subttl  Assembly Menuing Routines for ABIRD
page    50,132
;
;****************************************************************************
;****************************************************************************
;   menu.asm        - Menu Routines in Assembly Language
;
;   written for:    Ascension Technology Corporation
;                   PO Box 527
;                   Burlington, Vermont  05402
;
;                   802-655-7879
;
;   Written by:     Jeff Finkelstein
;
;   Modification History:
;
;   10/18/90        jf  - released
;   11/11/90        jf  - modified getnumber to return value in DX and
;                         ESC detection in AX
;   10/9/91         jf  - added display binary byte
;   4/4/92          jf  - modified sendmenu to use two rows if the
;                         menu count is greater than 16
;
;          <<<< Copyright 1990 Ascension Technology Corporation >>>>
;*****************************************************************************
;*****************************************************************************

;*****************************************************************************
                INCLUDE asctech.inc
                INCLUDE menudef.inc             ; menu definitions
                .8086                           ; 8086 instructions only

                PUBLIC  sendmenuhdr
                PUBLIC  sendmenu
                PUBLIC  askyesno
                PUBLIC  getnumber
                PUBLIC  getfloatnumber
                PUBLIC  hitkeycontinue
                PUBLIC  putchr
                PUBLIC  putstring
                PUBLIC  getstring
                PUBLIC  getchr
                PUBLIC  clearscreen
                PUBLIC  displayunsigned
                PUBLIC  displaybinarybyte
                PUBLIC  clearkey
                PUBLIC  ckkeyrdy
                PUBLIC  newline
                PUBLIC  openfile
                PUBLIC  closefile
                PUBLIC  readfile
                PUBLIC  readfileline
                PUBLIC  asciitohex

                EXTRN   format:WORD
                EXTRN   conv_const:WORD
                EXTRN   div_const:WORD

;*****************************************************************************
_DATA           SEGMENT PUBLIC 'DATA'       ; setup a data segment

asciibuf        db  ASCIIBUFSIZE DUP(0)         ; reserve 81 bytes for ASCII buf
hitanykeymsg    db  CR,LF,LF,'...hit any key to continue',CR,LF,'$'
enterselmsg     db  CR,LF,'Enter Selection: ','$'
yesnomsg        db  ' (Y/N)?','$'               ; yes no message
filecharbuf     db  0                           ; reserve 1 byte for file char
consolechar     db  ?                           ; reserve 1 byte for putchr
menulinebuf     db  MENUBUFSIZE DUP(0)          ; reserve 81 bytes for MENU buf
menucount       dw  0                           ; menu size
tempcounter     dw  0                           ; temporary counter

;
; Error Messages
;
invalidentrymsg db  CR,LF,'** ERROR ** invalid entry',CR,LF,'$'
badfileformatmsg db CR,LF,'** ERROR ** invalid fileformat',CR,LF,'$'
;
; Public Variables
;
                PUBLIC    asciibuf

_DATA            ENDS
;*****************************************************************************


;*****************************************************************************

_TEXT           SEGMENT WORD PUBLIC 'CODE'
                ASSUME  cs:_TEXT,ds:_DATA

;=============================================================================
;   sendmenuhdr         Send Menu Header
;   Parameters Passed:  hdrstring       string to be placed at the top of the
;                                       screen pointed to by DS:DX
;   Return Value:       void
;   Remarks:            routine clears the screen and then places the hdrstring
;                       at the top of the screen
;=============================================================================
sendmenuhdr     proc    near
                call    clearscreen         ; clear the screen
                call    putstring           ; put up header message
                ret
sendmenuhdr     endp

;=============================================================================
;   sendmenu            Send Menu to the Console Screen
;   Parameters Passed:  menu selections pointers, pointed to by DS:DX
;                       where, the prompt message is the string
;                       at DS:[DX], the first selection message is at ds:[DX+2]
;                       and so on...
;                       CX contains the number of menu selections
;   Return Value:       menu selection in AX
;   Registers Modified: AX,CX,DX
;   Remarks:
;=============================================================================
sendmenu        proc    near
                push    bx                  ; use as a pointer
                push    si                  ; use as a temp loop counter
newmenuloop:
                push    dx                  ; save the address of the menu
                mov     si,0                ; init loop counter
                mov     bx,dx               ; get the address
;
; Put up the selection header
;
                mov     dx,[bx]             ; get the first address
                call    newline
                call    putstring           ; put string to the console
                inc     bx                  ; point to the next string
                inc     bx                  ; incrementing is faster the adding
                call    newline             ; leave some space
;
; Now determine if 1 column or 2 columns
;
                cmp     cx,16
                jg      twomenurows
;
; First put up the selection numbers and select string
;
                push    cx                  ; save for later
menuloop:       mov     al,TAB              ; put up a few of tabs
                call    putchr              ; 2 tabs to the console
                mov     al,TAB
                call    putchr              ;
                mov     ax,si               ; get loop counter
                call    displayunsigned     ; display loop counter

;
; Put up a '.' and two spacess
;
                mov     al,'.'              ; AL get ASCII '.'
                call    putchr              ; put to the console
                mov     al,' '              ; AL get ASCII ' '
                call    putchr              ; put to the console
                cmp     si,9                ; ck to skip second space
                jg      skipsecondspace     ; only put one space if > 9
                mov     al,' '              ; AL get ASCII ' '
                call    putchr              ; put to the console
skipsecondspace:
;
; Now put up the String selection
;
                mov     dx,[bx]             ; get the first address
                call    putstring           ; put string to the console
                inc     bx                  ; point to the next string
                inc     bx                  ; incrementing is faster the adding
                call    newline
                inc     si                  ; increment the loopcounter
                loop    menuloop            ; do while CX > 0
                jmp     getmenuselection
;
; Do 2 Menu Rows ..if the Menu is Large
;
twomenurows:    
;
; Figure out the menusidelength
;
                push    cx
                mov     tempcounter,si      ; use as a counter
                mov     menucount,cx        ; store the menucount
                dec     cx                  ;
                clc                         ; clc
                mov     bp,cx               ; use BP for menusidelength
                ror     bp,1                ; divide by 2
                and     bp,00ffh            ; keep LS byte
                adc     bp,0                ; add in the carry flag
;
; Fill the Line with Spaces... Use the menuline buffer
;
menuloop1:
                mov     cx,MENUBUFSIZE
                mov     di,OFFSET menulinebuf
                mov     al,SPACE
                rep     stosb               ; fill the line buf with ' '

                mov     ax,tempcounter      ; get loop counter
                push    ax
                mov     di,OFFSET menulinebuf+3
                call    converttounsigned   ; convert loop counter.. in ASCII
                pop     ax
;
; Put up a '.' and spaces
;
                mov     si,di               ; get the current menuline position
                mov     BYTE PTR [si],'.'   ; store the '.'
                cmp     ax,9                ; ck to skip second space
                jg      skipsecondspace1    ; only put one space if > 9
                inc     si
skipsecondspace1:
                inc     si
;
; Now store the String selection
;
storestringleft:
                mov     di,[bx]             ; get the first address
storestringleft1:
                mov     al,[di]             ;
                cmp     al,'$'              ; check for end of string
                je      fillmenuright
                mov     [si],al             ; store the character in the buf
                inc     di
                inc     si
                jmp     storestringleft1
;
; Fill the string with the second half of the menu
;
fillmenuright:
                mov     ax,tempcounter
                add     ax,bp               ; add in the side length
                inc     ax
                cmp     ax,menucount
                jge     printmenulinebuf

                push    ax
                mov     di,OFFSET menulinebuf+37
                call    converttounsigned   ; convert loop counter.. in ASCII
                pop     ax
                mov     si,di               ; get the current menuline position
                mov     BYTE PTR [si],'.'   ; store the '.'
                cmp     ax,9                ; ck to skip second space
                jg      skipsecondspace2    ; only put one space if > 9
                inc     si
skipsecondspace2:
                inc     si

                push    si
                mov     si,bp               ; get offset into table
                shl     si,1                ; ..times 2 for word access
                mov     di,[bx][si]+2       ; get the menu selection
                pop     si

storestringright:
                mov     al,[di]             ;
                cmp     al,'$'              ; check for end of string
                je      printmenulinebuf
                inc     si
                mov     [si],al             ; store the character in the buf
                inc     di
                jmp     storestringright
;
; Print the String..in the menulinebuf to the console
;
printmenulinebuf:
                mov     menulinebuf+78,CR
                mov     menulinebuf+79,LF
                mov     menulinebuf+80,'$'
                mov     dx,OFFSET menulinebuf
                call    putstring

                inc     tempcounter         ; increment the loopcounter
                inc     bx                  ; point to the next menu selection
                inc     bx

                cmp     tempcounter,bp      ; check if done
                jg      getmenuselection
                jmp     menuloop1           ; continue until done
;
; Prompt for selection
;
getmenuselection:
                pop     cx                  ; cx contains number of selections
                mov     dx,OFFSET enterselmsg ; get message
                call    putstring           ; put string to the console

;
; Get the User's Response
;
                call    getnumber           ; get the number from the user
;
; Do minimal error checking
;
                cmp     ax,ESC_SEL          ; did the user hit ESC
                jne     ckmenulow
                jmp     sendmenuret         ; return with ESC_SEL
ckmenulow:      mov     ax,dx               ; get the result
                cmp     ax,0                ; selection < 0 ?
                jl      sendinvalidmsg      ; send invalid message
                cmp     ax,cx               ; greater than the number of choices
                jge     sendinvalidmsg      ; send invalid message
                jmp     sendmenuret         ; return with selection
;
; put up the invalid msg
;
sendinvalidmsg:
                mov     dx,OFFSET invalidentrymsg   ; get the message
                call    putstring           ; send it to the console
                call    getchr              ; wait for a key hit
                pop     dx                  ; get the menu selections
                jmp     newmenuloop         ; send a new menu
sendmenuret:
                pop     dx                  ;
                pop     si                  ; restore the regs used
                pop     bx
                ret                         ; ...outa here!
sendmenu        endp

;=============================================================================
;   askyesno            Ask Yes or No (or ESC)
;   Parameters Passed:  Prompt String in pointed to by DX
;   Return Value:       TRUE, FALSE or ESC_SEL in AX
;   Remarks:            routine prompts the user and then waits for a Y,
;                       N or the ESC
;=============================================================================
askyesno        proc    near
                call    putstring           ; put up the user string
                mov     dx,OFFSET yesnomsg  ; get the (Y/N)?
                call    putstring           ; put up the (Y/N)?
askyesno1:
                call    getchr              ; get a char
                cmp     al,'Y'              ; is it a yes
                je      askyesno2
                cmp     al,'y'
                je      askyesno2
                cmp     al,'N'              ; is it a no
                je      askyesno3
                cmp     al,'n'
                je      askyesno3
                cmp     al,ESCKEY           ; is it ESC
                je      askyesno4
                jmp     askyesno1           ; bad char.. get another

askyesno2:      call    putchr              ; return TRUE
                mov     ax,TRUE
                ret

askyesno3:      call    putchr              ; return FALSE
                mov     ax,FALSE
                ret

askyesno4:      mov     ax,ESC_SEL          ; return ESC_SEL
                ret
askyesno        endp

;=============================================================================
;   getnumber               get a number from the console
;   ----------
;
;   Parameters Passed:      none
;   Parameters Returned:    if AX = ESC_SEL, the user selected ESC
;                           else, the number is in DX
;   Registers Modified:     AX,DX
;   Remarks:                reads user input and converts to an unsigned
;                           number
;=============================================================================
getnumber       proc    near
                push    bx                  ; save regs
                push    cx
                xor     dx,dx               ; DX = 0
                mov     bx,dx               ; BX = 0...character counter
getnum1:
                call    getchr              ; get a char
                cmp     al,'0'              ; see if a valid number
                jl      getnum2             ; ck the character
                cmp     al,'9'
                jg      getnum2
                call    putchr              ; echo char
                inc     bx                  ; inc character counter
                sub     al,'0'              ; subtract to make a binary num
                cbw                         ; convert to a word
                push    ax                  ; save the current number
                mov     ax,dx               ; get the current sum
                mov     cx,10               ; multiply by 10
                mul     cx                  ; multiply the current sum by 10
                mov     dx,ax               ; store result in DX
                pop     ax                  ; get current number
                add     dx,ax               ; add number to sum
                jmp     getnum1             ; continue
getnum2:
                cmp     al,ESCKEY           ; ESC key?
                jne     getnum3             ; nope... see if a CR
                mov     ax,ESC_SEL          ; indicate the ESC was selected
                jmp     getnumberret

getnum3:
                cmp     al,CR               ; CR key?
                jne     getnum4             ; nope...see if BS
                call    putchr              ; put up a CR
                mov     al,LF               ; get a LF
                call    putchr              ; put up a LF
                xor     ax,ax               ; clear AX prior to return
                jmp     getnumberret        ; all set, go home

getnum4:        cmp     al,BS               ; BACKSPACE key?
                jne     getnum5             ; nope.. bad char..BEEPem
                cmp     bx,0                ; are there characters?
                je      getnum1             ; if no characters don't BS
                dec     bx                  ; update character counter
                call    putchr              ; put up a BS
                mov     al,' '              ; put up a space
                call    putchr              ;
                mov     al,BS               ; adjust the cursor
                call    putchr              ;
                mov     cx,10               ; get ready for a divide
                xor     ax,ax               ; clear AX
                xchg    ax,dx               ; get the current sum into AX
                div     cx                  ; DX:AX / CX = AX:DX
                xchg    ax,dx               ; put quotient back in DX
                jmp     getnum1             ; current sum back in DX

getnum5:        mov     al,BEL              ;

                call    putchr              ; send a BEEP
                jmp     getnum1
getnumberret:
                pop     cx                  ; restore regs
                pop     bx
                ret                         ; home
getnumber       endp

;=============================================================================
;   getfloatnumber          Get a Formatted Float number from the console
;   --------------
;
;   Parameters Passed:      format (global), digits past decimal
;                           conv_const (global)
;   Parameters Returned:    if AX = TRUE, result in DX
;                           if AX = ESC_SEL, the user selected ESC
;   Registers Modified:     AX,DX,BP
;                           asciibuf (global)
;   Remarks:                reads user input and converts to 2's complement
;                           number
;=============================================================================
getfloatnumber  proc    near
                push    cx                  ; save regs
                push    di
                push    si
;
; set the asciibuff to all '0'
;
                mov     al,'0'              ; set the character
                lea     di,asciibuf         ; set the destination
                mov     cx,ASCIIBUFSIZE     ; set the count
                rep     stosb               ; do the work... store '0's
;
; setup decimal pointer, and buffer pointer...respectively
;
                mov     si,-1               ; SI will point to decimal in
                                            ; ascibuf if >= 0
                lea     di,asciibuf         ; set the destination
                mov     bp,0                ; use BP for sign..assume +
;
; Loop to get Chars until a CR
;
getfloatnum1:
                call    getchr              ; get a char
                cmp     al,ESCKEY           ; is it a ESC
                je      getfloatescret      ;
                cmp     al,'+'              ; is it a plus
                je      setsign
                cmp     al,'-'              ; is it a minus
                je      setsign
                cmp     al,'.'              ; is it a decimal point
                je      decimalsel
                cmp     al,CR               ; is it a CR
                je      setcr
                cmp     al,'9'              ; is it a number
                jg      invalidentry
                cmp     al,'0'
                jge     validentry          ; else, invalid entry
;
; invalid entry get a beep
;
invalidentry:   mov     al,BEL              ; send a beep
                call    putchr
                jmp     getfloatnum1
;
; User hit ESC so return ESC_SEL
;
getfloatescret: mov     ax,ESC_SEL          ; return ESC_SEL
                jmp     getfloatret
;
; decimal selected
;
decimalsel:     mov     si,di               ; si no holds the decimal position
                call    putchr
                jmp     getfloatnum1        ; get more chars
;
; set sign
;
setsign:        cmp     di,OFFSET asciibuf  ; was it the first char
                jne     invalidentry        ; if not don't echo
                call    putchr              ; echo the char
                cmp     al,'-'              ; ck if minus
                jne     getfloatnum1        ; if not minus continue
                mov     bp,0ffffh           ; else, set bp to all 1's
                jmp     getfloatnum1        ; get more chars
;
; valid entry
;
validentry:     call    putchr              ; echo char
                mov     [di],al             ; store decimal char
                inc     di                  ; adjust buffer pointer
                jmp     getfloatnum1        ; get more chars
;
; CR selected... see if the user selected w/o any characters on the line
; ...if OK, convert using format
;
setcr:          cmp     di,OFFSET asciibuf  ; at buff start?
                je      invalidentry        ; if so, do nothing
                call    newline             ; echo a new line
;
; see if a decimal was found...
; ....truncate past the number of decimal places specified by format
;
                cmp     si,-1               ; is there a decimal point?
                je      nodecimal           ; if not, no decimal
;
; terminate the string a format characters past the decimal
;
                add     si,format           ; add the number of places past
                                            ; the decimal
                mov     BYTE PTR [si],0     ; null terminate 'format' digits
                jmp     strtohex            ; past the decimal
;
; terminate format characters past where a decimal should be
;
nodecimal:      add     di,format           ; add the number of places past
                                            ; the last digit
                mov     BYTE PTR [di],0     ; null terminate 'format' past
                                            ; the last digit
;
; convert the string number to a hex number in AX
;
strtohex:       xor     ax,ax               ; clear AX...use for SUM
                mov     cx,ax               ; clear CX too!
                lea     di, asciibuf        ; use DI to point to the ascii char
                mov     si, 10              ; use SI to hold multiplier
;
; go through the ascii string until a NULL
;
dectohex:       mov     cl,[di]             ; get the ascii data
                cmp     cl,0                ; see if data is a NULL
                je      getfloattrueret     ; if NULL, return result
                sub     cl,'0'              ; convert data to decimal
                mul     si                  ; SUM = SUM * 10
                add     ax,cx               ; add to current SUM
                inc     di                  ; point to the next char
                jmp     dectohex            ; continue until NULL

;
; Normalize data and convert data to 2's complement and return TRUE
;
getfloattrueret:
                mul     div_const           ; DX:AX = AX * 32768
                div     conv_const          ; AX = DX:AX / conv_const
                xor     ax,bp               ; convert to 1's
                sub     ax,bp               ; convert to 2's
                mov     dx,ax               ; store result in DX
                mov     ax,TRUE             ; return TRUE
getfloatret:    pop     si                  ; restore regs
                pop     di
                pop     cx
                ret                         ; home
getfloatnumber  endp

;=============================================================================
;   converttounsigned       convert unsigned Integer to ASCII
;   ----------
;
;   Parameters Passed:      integer to convert in the AX register
;                           destination buffer in DI
;   Parameters Returned:    none... asciibuf is destroyed
;                           returns the STRING size in CX
;                           DI incremented to the end of the buffer
;   Registers Modified:     AX,CX,DI
;   Remarks:                Converts the number in AX to an ASCII (Decimal)
;                           string in the asciibuf
;
;=============================================================================
converttounsigned proc    near
                push    bx                  ; save regs..
                push    dx
                push    si

                mov     cx,0                ; init counter
                mov     bx, OFFSET asciibuf ; get the address of the Dest buffer
cnvrtuchrs1:
                push    cx                  ; save counter
                mov     dx, 0               ; zero upper half
                mov     cx,10               ; set divisor to 10
                div     cx                  ; divide.. DX:AX / CX
                xchg    ax, dx              ; get quotient
                add     al, '0'             ; offset for ASCII
                mov     [bx], al            ; store the data
                inc     bx                  ; point to next buffer loc
                pop     cx                  ; restore counter
                inc     cx                  ; inc counter
                cmp     dx,0                ; done?
                mov     ax, dx              ; get the number
                jnz     cnvrtuchrs1          ; continue
;
; store the buffer reverse ordered
; stored least significant first
;
                push    cx
cnvrtuchrs2:    dec     bx                  ; point to the first char
                mov     al,[bx]             ; get the first char
                mov     [di],al             ; store in the ASCIBUFF
                inc     di
                loop    cnvrtuchrs2          ; continue til done
                pop     cx

                pop     si
                pop     dx                  ; restore regs
                pop     bx
                ret                         ; home
converttounsigned endp

;=============================================================================
;   displayunsigned         display unsigned Integer to ASCII
;   ----------
;
;   Parameters Passed:      integer to convert in the AX register
;   Parameters Returned:    none... asciibuf is destroyed
;   Registers Modified:     AX
;   Remarks:                Converts the number in AX to an ASCII (Decimal)
;                           string in the asciibuf...then displays
;
;=============================================================================
displayunsigned proc    near
                push    bx                  ; save regs..
                push    cx
                push    dx
                mov     cx,0                ; init counter
                mov     bx, OFFSET asciibuf ; get the address of the Dest buffer
dplyuchrs1:
                push    cx                  ; save counter
                mov     dx, 0               ; zero upper half
                mov     cx,10               ; set divisor to 10
                div     cx                  ; divide.. DX:AX / CX
                xchg    ax, dx              ; get quotient
                add     al, '0'             ; offset for ASCII
                mov     [bx], al            ; store the data
                inc     bx                  ; point to next buffer loc
                pop     cx                  ; restore counter
                inc     cx                  ; inc counter
                cmp     dx,0                ; done?
                mov     ax, dx              ; get the number
                jnz     dplyuchrs1          ; continue
;
; print out the buffer reverse ordered
; stored least significant first
;
dplyuchrs2:     dec     bx                  ; point to the first char
                mov     al,[bx]             ; get the first char
                call    putchr              ; display the char
                loop    dplyuchrs2          ; continue til done

                pop     dx                  ; restore regs
                pop     cx
                pop     bx
                ret                         ; home
displayunsigned endp

;=============================================================================
;   hitkeycontinue          Wait until a key is hit..with 'hit any..' prompt
;   --------------
;
;   Parameters Passed:      none
;   Parameters Returned:    none
;   Registers Modified:     AX
;   Remarks:                Use DOS to wait for a key stroke.
;=============================================================================
hitkeycontinue  proc    near
                push    dx                      ; save regs
                mov     dx, OFFSET hitanykeymsg ; get message
                call    putstring               ; display message
                call    getchr                  ; wait for a key hit
                call    clearkey                ; clear keyboard
hitkeyret:      pop     dx                      ; restore reg
                ret
hitkeycontinue  endp


;=============================================================================
;   getstring               Get a String from the Console Screen
;   -----------
;
;   Parameters Passed:      buffer for string pointed to by DS:DX
;   Parameters Returned:    string pointed to by DS:DX
;   Registers Modified:     AX
;   Remarks:                Get a string from the console and NULL terminate
;                           allow any character in the string and allow
;                           BACKSPACE for minimal line editing
;=============================================================================
;
getstring       proc    near
                push    bx
                push    cx                  ; save regs
                mov     bx,dx               ; use BX as string ptr
;
; get chars from the console
;
getstring1:
                call    getchr              ; get a char
                cmp     al,CR               ; did they hit CR
                jne     getstring2          ; nope...see if ESC
                call    putchr              ; echo CR char
                mov     al,LF               ; get a LF
                call    putchr              ; put up a LF
                mov     BYTE PTR [bx],0     ; null terminate the string
                jmp     getstringret        ; all set, go home

getstring2:
                cmp     al,ESCKEY           ; ESC key?
                jne     getstring3          ; nope... see if a BS
                mov     ax,ESC_SEL          ; indicate the ESC was selected
                jmp     getstringret

getstring3:     cmp     al,BS               ; BS key?
                jne     getstring4          ; nope... keep ckecking
                call    putchr              ; backup cursor
                dec     bx                  ; adjust pointer
                mov     al,' '              ; put up a space
                call    putchr
                mov     al,BS
                call    putchr              ; backup cursor
                jmp     getstring1

getstring4:     mov     [bx],al             ; store char in buffer
                call    putchr              ; enough checking
                inc     bx                  ; point to next position
                jmp     getstring1

getstringret:
                pop     cx                  ; restore reg
                pop     bx
                ret                         ; home
getstring       endp

;=============================================================================
;   putstring           Displays a String on the Console Screen
;   -----------
;
;   Parameters Passed:      string pointed to by DS:DX
;   Parameters Returned:    none
;   Registers Modified:     AX
;   Remarks:                Use DOS to put a string to the console
;=============================================================================
putstring       proc    near
                push    bx                  ; save regs
                push    cx
;
; Figure out the number of bytes to write
;
                mov     bx,dx               ; get the buffer
                xor     cx,cx               ; use CX as a counter
lookforend:
                cmp     BYTE PTR [bx],'$'   ; look for string termination
                je      sendstring          ; if at end...put to std out
                inc     bx                  ; point to next 
                inc     cx                  ; inc counter
                jmp     lookforend      
sendstring:     mov     bx,1                ; console handle
                DOSINT  40h                 ; do DOS call, func 40h

                pop     cx                  ; restore regs
                pop     bx
                ret
putstring       endp

;=============================================================================
;   putchr                  Displays a Character on the Console Screen
;   ------
;
;   Parameters Passed:      character in reg al
;   Parameters Returned:    none
;   Registers Modified:     none
;   Remarks:                Use DOS to put a character to the stdout
;=============================================================================
;
putchr          proc    near
                push    ax                  ; save regs
                push    bx
                push    cx
                push    dx

                mov     consolechar,al      ; get the character
                mov     dx,OFFSET consolechar ; store in the output buffer
                mov     cx,1                ; do one character
                mov     bx,1                ; console handle
                DOSINT  40h                 ; do DOS call, func 40h

                pop     dx                  ; restore regs
                pop     cx
                pop     bx
                pop     ax
                ret
putchr          endp

;=============================================================================
;   getchr                  Gets a Character from the Console
;   ------
;
;   Parameters Passed:      none
;   Parameters Returned:    character in AL
;   Registers Modified:     AX
;   Remarks:                Use DOS to get a character from the console
;                           NOTE: if AL is 0 upon return, getchr should be
;                                 called again
;=============================================================================
getchr          proc    near
                DOSINT  8                  ; do DOS call, func     
                ret
getchr          endp

;=============================================================================
;   ckkeyrdy                Checks if a key is ready from the console
;   ------
;
;   Parameters Passed:      none
;   Parameters Returned:    TRUE is AX if key ready, else FALSE
;   Registers Modified:     AX
;   Remarks:                Use DOS to see if a key is ready
;=============================================================================
ckkeyrdy        proc    near
                DOSINT  0bh                 ; do DOS call, func b
                and     ax,1                ; return a 1 (TRUE) if AL = 1
                ret
ckkeyrdy        endp

;=============================================================================
;   clearkey                Clear the keyboard
;   ------
;
;   Parameters Passed:      none
;   Parameters Returned:    none
;   Registers Modified:     AX
;   Remarks:                Use DOS to read keys from the keyboard until no
;                           keys are available
;=============================================================================
clearkey        proc    near
getkeys:        call    ckkeyrdy            ; check for available keys
                cmp     ax,TRUE             ; if no key ready..
                jne     clearkeyret         ; .. just return
                call    getchr              ; else, get the key
                jmp     getkeys             ; continue until no more keys
clearkeyret:    ret
clearkey        endp

;=============================================================================
;   clearscreen         Clear the Console Screen
;   -----------
;
;   Parameters Passed:      none
;   Parameters Returned:    none
;   Registers Modified:     AX
;   Remarks:                do a get video mode and set video mode to
;                           clear the screen
;=============================================================================
clearscreen     proc    near
                push    bx                  ; int 10, kills BX
                mov     ah,0fh              ; func f, get video mode
                int     10h                 ; do Video BIOS call
                xor     ah,ah               ; func 0, set video mode
                int     10h                 ; do Video BIOS call
                pop     bx                  ; restore reg
                ret
clearscreen     endp

;=============================================================================
;   newline             Put a CR LF to the console
;   -----------
;
;   Parameters Passed:      none
;   Parameters Returned:    none
;   Registers Modified:     AX
;   Remarks:                put a newline to the screen
;=============================================================================
newline         proc    near
                mov     al,CR               ; put a CR
                call    putchr
                mov     al,LF               ; put a LF
                call    putchr
                ret
newline         endp

;=============================================================================
;   asciitohex              ASCII to Hexidecimal
;   -----------
;
;   Parameters Passed:      pointer to asciistring in DS:BX
;   Parameters Returned:    hex value of string in AX
;   Registers Modified:     AX
;   Remarks:                converts string in the asciibuf to a hexidecimal
;                           number.   The string is converted up to the
;                           first none digit character
;                           Leading spaces are OK
;=============================================================================
asciitohex      proc    near
                push    bx                  ; save regs
                push    cx
                push    dx
                xor     ax,ax               ; clear AX
                mov     cx,ax               ; clear CX
;
; Get characters from the buffer...skip leading spaces
;
ckforspace:     mov     cl,BYTE PTR [bx]    ; get the next char
                cmp     cl,' '              ; is space?
                jne     atoh2               ; if not a space go on
                inc     bx                  ; else continue until ..
                jmp     ckforspace          ; ..not a space
;
; convert the string to a hex number
;
atoh1:          mov     cl,BYTE PTR [bx]    ; get the next char
atoh2:          sub     cl,'0'              ; ascii adjust the data
                and     cl,07fh             ; mask to make positive
                cmp     cl,9                ; see if it is a digit
                jg      atohret             ; end of string
                mov     dx,10               ; multiply by 10
                mul     dx                  ; multiply current value
                add     ax,cx               ; add new digit value
                inc     bx                  ; increment buffer pointer
                jmp     atoh1

atohret:        pop     dx                  ; restore
                pop     cx
                pop     bx
                ret
asciitohex      endp

;=============================================================================
;   openfile                Open a File and return a handle
;   -----------
;
;   Parameters Passed:      access mode in AX = FILEREAD, FILEWRITE, or
;                                               FILEREADWRITE
;                           filename string pointed to by DS:DX..null term
;   Parameters Returned:    carry flag set if unsuccessful
;                           file handle in AX if successful
;   Registers Modified:     AX
;   Remarks:                opens the specified file in given mode and returns
;                           a 16 bit file handle for subsequent reads or writes
;=============================================================================
;
openfile        proc    near
                push    dx                  ; save the filename pointer
                DOSINT  3dh                 ; do DOS call
                pop     dx                  ; restore pointer
                ret                         ; return with AX and/or carry set
openfile        endp


;=============================================================================
;   closefile               Close a File w/ handle
;   -----------
;
;   Parameters Passed:      file hanle in AX
;   Parameters Returned:    carry flag clear if successful
;                           carry flag set if unsuccessful
;   Registers Modified:     AX
;   Remarks:                opens the specified file in given mode and returns
;                           a 16 bit file handle for subsequent reads/writes
;=============================================================================
;
closefile       proc    near
                push    bx
                mov     bx,ax               ; get file handle
                DOSINT  3eh                 ; do DOS call
                pop     bx
                ret                         ; return with AX and/or carry set
closefile       endp

;=============================================================================
;   readfile                Read Data from a File
;   -----------
;
;   Parameters Passed:      file hanle in AX
;   Parameters Returned:    carry flag clear if successful, AL has the char
;                           carry flag set if unsuccessful
;   Registers Modified:     AX,BX,DX
;                           (global) filecharbuf
;   Remarks:                read 1 byte from file and return
;=============================================================================
;
readfile        proc    near
                push    bx
                push    cx
                push    dx
                mov     dx,OFFSET filecharbuf ; assign dx the buffer address
                mov     cx,1                ; read 1 byte
                mov     bx,ax               ; get file handle
                DOSINT  3fh                 ; do DOS call
                mov     al,filecharbuf      ; get the char read..even if bad
                pop     dx
                pop     cx
                pop     bx
                ret                         ; return with AX and/or carry set
readfile        endp

;=============================================================================
;   readfileline            Read Line of Data from a File
;   ------------
;
;   Parameters Passed:      file hanle in AX
;                           maximum number of chars to read in CX
;                           pointer to buffer for data in DS:BX
;   Parameters Returned:    in AX, TRUE if Successful, FALSE otherwise
;   Registers Modified:     AX,CX
;   Remarks:                read a characters from file with handle specified
;                           in AX while placing data in DS:[BX], upto but NOT
;                           including the CR LF..append a '$' to the buffer
;                           for termination
;=============================================================================
;
readfileline    proc    near
                push    bx                  ; save regs
                push    dx
                push    si
;
; File opened OK so read first line to a maximum of 80 characters
;
fileok:         mov     si,ax               ; use SI to hold the handle
                inc     cx                  ; add 1 to account for CR

readfileline1:  mov     ax,si               ; get file handle
                call    readfile            ; read file char
                jc      readfilefalseret    ; break out
                cmp     al,CR               ; see if CR
                je      lineread            ; if so... terminate
                mov     [bx],al             ; store the character
                inc     bx                  ; point to next char position
                loop    readfileline1       ; continue
;
; If more the 80 characters were read without a CR than send a format error
; Or if readfile failed
;
lineread:       mov     BYTE PTR [bx],'$'   ; terminate
                mov     ax,si               ; get file handle
                call    readfile            ; get the LF
                jc      readfilefalseret    ; make sure read OK
                mov     ax,TRUE             ; return TRUE
                jmp     readfileret

readfilefalseret:
                mov    ax,FALSE             ; return FALSE
readfileret:
                pop     si
                pop     dx                  ; restore regs
                pop     bx
                ret
readfileline    endp

;=============================================================================
;   displaybinarybyte         display byte a binary
;   -----------------
;
;   Parameters Passed:      integer to convert in the AL register
;   Parameters Returned:    none...
;   Registers Modified:     AX
;   Remarks:
;=============================================================================
displaybinarybyte proc    near
                push    cx
                mov        cx,8

nextbit:
                test    al,80h
                jz        displayzero
                push    ax
                mov        al,'1'
                jmp        displaybit
displayzero:    push    ax
                mov        al,'0'
displaybit:
                call    putchr
                pop        ax
                shl        al,1
                loop    nextbit

                pop        cx
                ret

displaybinarybyte endp


;***************************************************************************
_TEXT           ENDS
        END

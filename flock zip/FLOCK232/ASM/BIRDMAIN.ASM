title   ABIRD
subttl  Assembly Main Module Routines for ABIRD
page    50,132
;
;****************************************************************************
;****************************************************************************
;   birdmain.asm    Main Module Routines for ASMBIRD
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
;   11/5/90         jf  - removed the 'Q' and the 'M' command from the
;                         Bird initialization
;   11/11/90        jf  - added new commands to the Main Menu
;   2/4/91          jf  - added buttonvalue to globals
;   2/20/91         jf  - moved initialization of factory test mode to
;                         the birdloadconfig in BIRDCMDS.asm
;   5/20/91         jf  - added Revision Number to Menu Header
;   6/17/91         jf  - new revision 2.01, bug fix in BIRDCMDS.asm
;   6/18/91         jf  - add FOB FOB baud rates
;   8/19/91         jf  - updated for FOB preliminary release 3.0
;   10/10/91        jf  - updated new commands for Flock..rev 3.01
;   10/29/91        jf  - removed the assertion of RTS in serial routines
;                         ..rev 3.02
;   11/1/91         jf  - added exm/chg alpha max and glitch checking
;                         ..rev 3.03
;   11/7/91         jf  - added exm model..rev 3.04
;   3/23/92         jf  - updated alpha min/max.. rev 3.05
;   4/6/92          jf  - added nextmaster, nexttransmitter, rs232tofbbcmd
;   4/7/92          jf  - added selection for xmtr type ..rev 3.06
;   4/22/92         mo  - added functions quaternions and pos quaternions
;   5/5/92          jf  - added system test menu selections ..rev 3.07
;   6/1/92          jf  - updated examine value to reflect new status
;                         definitions ..rev 3.08
;   10/12/92        jf  - modified printmatrix ..rev 3.09
;   2/18/93         jf  - updated bird_examine value status definitions
;                         ..rev 3.10
;   3/9/93          jf  - updated for rev 3.41 and 4.22 ROMs ..rev 3.11
;   3/22/93         jf  - added note to expanded error mode ..rev 3.12
;
;          <<<< Copyright 1990 Ascension Technology Corporation >>>>
;*****************************************************************************
;*****************************************************************************
;...Misc. directives
                INCLUDE asctech.inc         ; misc definitions for the Bird
                INCLUDE menudef.inc         ; menu definitions
                INCLUDE serial.inc          ; serial port definitions
                .8086                       ; 8086 instructions only
;
; Public Routines
;
                PUBLIC      asmbird
;
; Public Variables
;
                PUBLIC      outputmode
                PUBLIC      buttonmode
                PUBLIC      buttonvalue
                PUBLIC      posfrmt
;
; Menuing routines used
;
                EXTRN   askyesno:NEAR
                EXTRN   sendmenuhdr:NEAR
                EXTRN   sendmenu:NEAR
                EXTRN   displayunsigned:NEAR
                EXTRN   putstring:NEAR
                EXTRN   putchr:NEAR
                EXTRN   hitkeycontinue:NEAR
                EXTRN   newline:NEAR
                EXTRN   getnumber:NEAR
                EXTRN   ckkeyrdy:NEAR
                EXTRN   clearkey:NEAR
                EXTRN   getchr:NEAR
;
; Serial Routines Used
;
                EXTRN   configserialport:NEAR
                EXTRN   restoreserialconfig:NEAR
                EXTRN   saveserialconfig:NEAR
                EXTRN   send_serial_cmd:NEAR
                EXTRN   clear_rx:NEAR
                EXTRN   get_serial_data:NEAR
;
; Bird Commands used
;
                EXTRN   bird_position:NEAR
                EXTRN   bird_angle:NEAR
                EXTRN   bird_matrix:NEAR
                EXTRN   bird_quaternions:NEAR
                EXTRN   bird_positionangle:NEAR
                EXTRN   bird_positionmatrix:NEAR
                EXTRN   bird_posquaternions:NEAR
                EXTRN   bird_anglealign:NEAR
                EXTRN   bird_hemisphere:NEAR
                EXTRN   bird_reference:NEAR
                EXTRN   bird_reportrate:NEAR
                EXTRN   bird_sleep:NEAR
                EXTRN   bird_mousebuttons:NEAR
                EXTRN   bird_xonxoff:NEAR
                EXTRN   bird_changevalue:NEAR
                EXTRN   bird_examinevalue:NEAR
                EXTRN   bird_crtsync:NEAR
;
; External Data
;
                EXTRN   phaseerror_count:WORD
                EXTRN   comport:WORD
                EXTRN   com_base:WORD
                EXTRN   baudsel:WORD
                EXTRN   bauddivisortbl:WORD
                EXTRN   rs232tofbbaddr:BYTE
                EXTRN   posk:WORD

;*****************************************************************************
STACK           SEGMENT PARA STACK 'STACK'  ; set up a stack segment
                db      400h dup (?)        ; 1k bytes long, uninitialized
STACK           ENDS
;*****************************************************************************

;*****************************************************************************

_DATA           SEGMENT PUBLIC 'DATA'       ; setup a data segment

;
; Flags
;
exitflag        db  FALSE                   ; if TRUE, program exits

;
; Position Scaling
;
posfrmt         dw  POSFORMAT               ; default to Flock format

;
; Bird Commands
;
nextmastercmdchar       db  0               ; for nextmaster command
nextxmtrcmdchar         db  '0 '            ; for nextxmtr command

;
; Messages
;
quitmsg         db  'Are you sure you want to quit','$'
baudratemsg1    db  CR,LF,'Current Serial Port Configuration: COM','$'
baudratemsg2    db  ' at ','$'
;
; Error Messages
;
serialconfigerrormsg db   '** ERROR ** could not initialize serial port',CR,LF,'$'
buttoniniterrormsg   db   '** ERROR ** could not send button mode cmd',CR,LF,'$'
maxrateerrormsg      db   '** ERROR ** could not set max report rate',CR,LF,'$'
illegalentryerrmsg   db   '** ERROR ** invalid entry',CR,LF,'$'
readerrmsg           db   '** ERROR ** could not read data from the Bird',CR,LF,'$'
senderrmsg           db   '** ERROR ** could not send data to the Bird',CR,LF,'$'


;
; Main Menu
;
mainmenuhdr     db  '****************************************************************************',CR,LF
                db  '* ASCENSION TECHNOLOGY CORPORATION - Bird Main Menu          Revision 3.13 *',CR,LF
                db  '****************************************************************************',CR,LF,'$'
mainmenu        dw  mainmenuprompt,mainmenu0,mainmenu1,mainmenu2,mainmenu3
                dw  mainmenu4,mainmenu5,mainmenu6,mainmenu7,mainmenu8
                dw  mainmenu9,mainmenu10,mainmenu11,mainmenu12,mainmenu13
                dw  mainmenu14,mainmenu15,mainmenu16
                dw  mainmenu17,mainmenu18,mainmenu19,mainmenu20,mainmenu21
                dw  mainmenu22,mainmenu23
mainmenuprompt  db  'Menu Selections:','$'
mainmenu0       db  'Quit','$'
mainmenu1       db  'Position','$'
mainmenu2       db  'Angle','$'
mainmenu3       db  'Matrix','$'
mainmenu4       db  'Quaternions','$'
mainmenu5       db  'Position/Angles','$'
mainmenu6       db  'Position/Matrix','$'
mainmenu7       db  'Position/Quaternions','$'
mainmenu8       db  'Angle Align','$'
mainmenu9       db  'Hemisphere','$'
mainmenu10      db  'Reference Frame','$'
mainmenu11      db  'Report Rate','$'
mainmenu12      db  'Sleep/Wakeup','$'
mainmenu13      db  'Mouse Buttons','$'
mainmenu14      db  'XON/XOFF','$'
mainmenu15      db  'Change Values','$'
mainmenu16      db  'Examine Values','$'
mainmenu17      db  'CRT Sync','$'
mainmenu18      db  'FBB Next Master','$'
mainmenu19      db  'FBB Next Transmitter','$'
mainmenu20      db  'RS232 to FBB Command','$'
mainmenu21      db  'Set Transmitter Type','$'
mainmenu22      db  'System Tests','$'
mainmenu23      db  'Serial Port Configuration','$'
;
; Jump Table for the Main Menu Selections
;
mainmenusubs    dw  quitsel,tobird_position,tobird_angle,tobird_matrix
                dw  tobird_quaternions,tobird_positionangle
                dw  tobird_positionmatrix,tobird_positionquaternions
                dw  tobird_anglealign
                dw  tobird_hemisphere,tobird_reference,tobird_reportrate,tobird_sleep
                dw  tobird_mousebuttons,tobird_xonxoff,tobird_changevalue
                dw  tobird_examinevalue,tobird_crtsync
                dw  to_nextmastercmd, to_nextxmtrcmd, to_rs232tofbbcmd
                dw  tosetxmtrtype, tosystests, toserialinit
;
; Next Master Question
;
nextmasterques  db  CR,LF,'Enter the Next Master Address (1 - 14): ','$'
nextmastermsg   db  CR,LF,'Next Master Command Sent..','$'

;
; Next Transmitter Questions
;
nextxmtrques1   db  CR,LF,'Enter the Next Transmitter Address (1 - 14): ','$'
nextxmtrques2   db  CR,LF,'Enter the Next Transmitter Number (0 - 3): ','$'
nextxmtrmsg     db  CR,LF,'Next Transmitter Command Sent..','$'

;
; RS232 to FBB Questions
;
rs232tofbbques1 db  CR,LF,'Do you want to use the RS232 TO FBB Command','$'
rs232tofbbques2 db  CR,LF,'Enter the Destination FBB Address (1 - 14): ','$'

;
; Set XMTR Type Menu
;
xmtrtypemenuptr dw  xmtrtypemenuprompt,xmtrtypemenu0,xmtrtypemenu1
xmtrtypemenuprompt db  'Select Transmitter Type:','$'
xmtrtypemenu0   db  'Short Range Transmitter','$'
xmtrtypemenu1   db  'Extended Range Transmitter','$'

;
; Main Globals
;
outputmode      dw  POINT           ; output mode (POINT,CONTINUOUS,STREAM)
buttonmode      dw  0               ; button mode
buttonvalue     dw  0               ; button value
;
; System Tests Menu
;
systestmenu     dw  systestprompt,systestmenu0,systestmenu1,systestmenu2
                dw  systestmenu3,systestmenu4
systestprompt   db  'Select System Test:','$'
systestmenu0    db  'Return to Main Menu','$'
systestmenu1    db  'Bird Output Test','$'
systestmenu2    db  'Bird Echo Test','$'
systestmenu3    db  'Host Read Test','$'
systestmenu4    db  'Host Read Block Test','$'

;
; Corresponding Test Number for each menu entry
;
systestnum      db  0,3,5,7,9

testbuf         db  256 DUP(?)          ; buffer for receive chars

systestmsg1     db  CR,LF,'** NOTE ** The DIP switch should be set to Test Number: ','$'
birdoutputmsg1  db  CR,LF,'Hit any key to End the Test',CR,LF,'$'
birdechomsg1    db  CR,LF,'Hit any key to ECHO, <ESC> to End the Test',CR,LF,'$'
hostreadmsg1    db  CR,LF,'Hit any key to Read Character, <ESC> to End the Test',CR,LF,'$'
hostreadmsg2    db  CR,LF,'Bird Output: ','$'
hostreadblockmsg1 db CR,LF,'Hit any key to Read Block, <ESC> to End the Test',CR,LF,'$'

;
; Serial Menu
;
serialmenu      dw  serialprompt,serialmenu0,serialmenu1,serialmenu2
                dw  serialmenu3,serialmenu4,serialmenu5,serialmenu6
                dw  serialmenu7,serialmenu8,serialmenu9
serialprompt    db  'Serial Port Options:','$'

serialmenu0     db  'No Change','$'
serialmenu1     db  '115200','$'
serialmenu2     db  '57600','$'
serialmenu3     db  '38400','$'
serialmenu4     db  '19200','$'
serialmenu5     db  '9600','$'
serialmenu6     db  '4800','$'
serialmenu7     db  '2400','$'
serialmenu8     db  'COM1','$'
serialmenu9     db  'COM2','$'

;
; Output Mode Menu
;
getoutmodemenu  dw  getoutmodeprompt,getoutputmenu0
                dw  getoutputmenu1,getoutputmenu2
getoutmodeprompt db 'Data Output Modes:','$'
getoutputmenu0  db  'Point Mode ','$'
getoutputmenu1  db  'Continuous Point Mode','$'
getoutputmenu2  db  'Stream Mode','$'

_DATA           ENDS

;*****************************************************************************

_TEXT           SEGMENT WORD PUBLIC 'CODE'
                ASSUME cs:_TEXT, ds:_DATA, ss:STACK

;=============================================================================
;   asmbird     Main Module for ASMBIRD
;   -------
;
;=============================================================================
;
asmbird         proc far
                mov     ax, _DATA               ; get data segment value
                mov     ds, ax                  ; store in DS
                mov     es, ax                  ; point ES to the data segment
;
; Allow the user change the serial port configuration
;
setupserial:    call    saveserialconfig        ; save current serial config
                call    serialinit              ; send serial menu
                cmp     ax,FALSE                ; see if init went OK
                jne     asmbirdmenu             ; if OK, continue
                jmp     asmbirdexit             ; else, exit
;
; Put up the Main Menu
;
asmbirdmenu:
;
; Prior to each test, clear the receive buffer/port
;
                call    clear_rx                ; clear the receiver
;
; Send the Main Menu
;
                mov     dx, OFFSET mainmenuhdr  ; get screen header
                call    sendmenuhdr             ; send header to screen
                mov     cx, 24                  ; number of main menu entries
                mov     dx, OFFSET mainmenu     ; get main menu
                call    sendmenu                ; put up main menu
                cmp     ax,ESC_SEL              ; see if the use hit ESC
                jne     domenucmd               ; if not continue
                jmp     asmbirdmenu             ; else redisplay
domenucmd:      shl     ax,1                    ; multilply by 2 for words
                mov     bx, OFFSET mainmenusubs ; get code address
                add     bx,ax                   ; add ax to bx
                jmp     [bx]                    ; call the roution
;
; If the User hit quit, ask confirmation question
;
quitsel:        mov     dx,OFFSET quitmsg       ; get the quit msg
                call    askyesno                ; ask them if they want to quit
                cmp     al,TRUE                 ; ck the user's answer
                jne     asmbirdmenu             ; if not redisplay
                jmp     asmbirdexit             ; else exit
;
; Else, go on and do the specific menu command via a jump table
;
tobird_position:
                call    get_output_mode
                cmp     ax,ESC_SEL
                je      asmbirdmenu
                call    bird_position
                jmp     ckexitflag

tobird_angle:
                call    get_output_mode
                cmp     ax,ESC_SEL
                je      asmbirdmenu
                call    bird_angle
                jmp     ckexitflag

tobird_matrix:
                call    get_output_mode
                cmp     ax,ESC_SEL
                je      asmbirdmenu
                call    bird_matrix
                jmp     ckexitflag

tobird_quaternions:
                call    get_output_mode
                cmp     ax,ESC_SEL
                je      asmbirdmenu
                call    bird_quaternions
                jmp     ckexitflag

tobird_positionangle:
                call    get_output_mode
                cmp     ax,ESC_SEL
                je      asmbirdmenu
                call    bird_positionangle
                jmp     ckexitflag

tobird_positionmatrix:
                call    get_output_mode
                cmp     ax,ESC_SEL
                je      asmbirdmenu
                call    bird_positionmatrix
                jmp     ckexitflag


tobird_positionquaternions:
                call    get_output_mode
                cmp     ax,ESC_SEL
                je      extend_je
                call    bird_posquaternions
                jmp     ckexitflag
extend_je:
                jmp     asmbirdmenu

tobird_anglealign:
                call    bird_anglealign
                jmp     ckexitflag

tobird_hemisphere:
                call    bird_hemisphere
                jmp     ckexitflag

tobird_reference:
                call    bird_reference
                jmp     ckexitflag

tobird_reportrate:
                call    bird_reportrate
                jmp     ckexitflag

tobird_sleep:
                call    bird_sleep
                jmp     ckexitflag

tobird_mousebuttons:
                call    bird_mousebuttons
                jmp     ckexitflag

tobird_xonxoff:
                call    bird_xonxoff
                jmp     ckexitflag

tobird_changevalue:
                call    bird_changevalue
                jmp     ckexitflag

tobird_examinevalue:
                call    bird_examinevalue
                jmp     ckexitflag

tobird_crtsync:
                call    bird_crtsync
                jmp     ckexitflag

to_nextmastercmd:
                call    nextmastercmd
                jmp     ckexitflag

to_nextxmtrcmd:
                call    nextxmtrcmd
                jmp     ckexitflag

to_rs232tofbbcmd:
                call    rs232tofbbcmd
                jmp     ckexitflag

tosetxmtrtype:
                call    setxmtrtype
                jmp     ckexitflag

tosystests:
                call    systemtests
                jmp     ckexitflag

toserialinit:
                call    serialinit
;
; See if we are ready to quit
;
ckexitflag:
                cmp     exitflag,TRUE           ; ck exitflag
                je      asmbirdexit             ; yep..it is set so quit
                jmp     asmbirdmenu             ; nope...continue
asmbirdexit:
                call    restoreserialconfig     ; restore serial config
                DOSINT  4ch                     ; return to DOS
asmbird         endp                            ; ....done

;=============================================================================
;    nextmastercmd      Next Master Command
;   ---------------
;
;   Parameters Passed:  none
;   Return Value:       in AX, TRUE if every went OK
;                       FALSE, if the command could not be sent
;                       ESC_SEL if the user selected ESC
;   Registers Modified: AX,BX,CX,DX
;   Remarks:
;=============================================================================
;
nextmastercmd   proc    near
;
; Ask the user for the NEXT MASTER Address
;
                mov     dx,OFFSET nextmasterques
                call    putstring
                call    getnumber
                cmp     ax,ESC_SEL
                je      nextmastercmdret
                cmp     dx,1
                jl      illegalnextmaster
                cmp     dx,14
                jg      illegalnextmaster
;
; DX contains the address 1 - 14
; .. so add the address info to '0' to develop the command byte
;
                add     dl, '0'
                mov     nextmastercmdchar,dl ; store the char for output
                mov     cx,1                ; 1 character in cmd
                mov     bx,OFFSET nextmastercmdchar ; get cmd
                call    send_serial_cmd     ; send the bird the cmd
                cmp     ax,1                ; did cmd go out OK?
                je      nextmastercmdtrueret ; if ok, continue
;
; Indicate the Error condition
;
                mov     ax,FALSE
                call    hitkeycontinue
                jmp     nextmastercmdret     ; return false

;
; Indicate the Illegal Address condition
;
illegalnextmaster:
                mov     dx, OFFSET illegalentryerrmsg
                call    putstring
                jmp     nextmastercmd
;
; Indicate that everything is OK..and return
;
nextmastercmdtrueret:
                mov     dx, OFFSET nextmastermsg
                call    putstring
                mov     ax,TRUE
                call    hitkeycontinue
nextmastercmdret:
                ret

nextmastercmd   endp

;=============================================================================
;   nextxmtrcmd         Next Transmitter Command
;   -----------
;
;   Parameters Passed:  none
;   Return Value:       in AX, TRUE if every went OK
;                       FALSE, if the command could not be sent
;                       ESC_SEL if the user selected ESC
;   Registers Modified: AX,BX,CX,DX
;   Remarks:
;=============================================================================
;
nextxmtrcmd     proc    near
;
; Ask the user for the NEXT TRANSMITTER Address
;
                mov     dx,OFFSET nextxmtrques1
                call    putstring
                call    getnumber
                cmp     ax,ESC_SEL
                je      nextxmtrcmdret
                cmp     dx,1                 ; check 1 - 14
                jl      illegalnextxmtr1
                cmp     dx,14
                jg      illegalnextxmtr1
;
; DX contains the address 1 - 14
; ..store it in the Most Significant nibble of the command data
;
                mov     cl,4
                shl     dl,cl
                mov     nextxmtrcmdchar+1,dl ; store the char for output
;
; Now get the TRANSMITTER NUMBER
;
nextxmtrnumberques:
                mov     dx,OFFSET nextxmtrques2
                call    putstring
                call    getnumber
                cmp     ax,ESC_SEL
                je      nextxmtrcmdret
                cmp     dx,0                 ; check 0 - 3
                jl      illegalnextxmtr2
                cmp     dx,3
                jg      illegalnextxmtr2
;
; The XMTR number is now in DL..so store in the LS nibble of the the
; command data
;
                or      nextxmtrcmdchar+1,dl
;
; Send the commnand
;
                mov     cx,2                ; 2 character in cmd
                mov     bx,OFFSET nextxmtrcmdchar  ; get cmd
                call    send_serial_cmd     ; send the bird the cmd
                cmp     ax,2                ; did cmd go out OK?
                je      nextxmtrcmdtrueret ; if ok, continue
;
; Indicate the Error condition
;
                mov     ax,FALSE
                call    hitkeycontinue
                jmp     nextxmtrcmdret     ; return false

;
; Indicate the Illegal Address condition
;
illegalnextxmtr1:
                mov     dx, OFFSET illegalentryerrmsg
                call    putstring
                jmp     nextxmtrcmd
;
; Indicate the Illegal Number condition
;
illegalnextxmtr2:
                mov     dx, OFFSET illegalentryerrmsg
                call    putstring
                jmp     nextxmtrnumberques
;
; Indicate that everything is OK..and return
;
nextxmtrcmdtrueret:
                mov     dx, OFFSET nextxmtrmsg
                call    putstring
                mov     ax,TRUE
                call    hitkeycontinue
nextxmtrcmdret:
                ret
nextxmtrcmd     endp

;=============================================================================
;   rs232tofbbcmd       RS232 To FBB Command
;   -------------
;
;   Parameters Passed:  none
;   Return Value:       in AX, ESC_SEL if the user hit ESC
;   Registers Modified: AX,BX,CX,DX
;   Remarks:            When the rs232tofbbaddr = 0, the command is NOT
;                       being used
;=============================================================================
;
rs232tofbbcmd   proc    near
;
; Ask the User if they want to use the RS232 to FBB command
;
                mov     dx,OFFSET rs232tofbbques1 ; get the  msg
                call    askyesno                ; .. use the command?
                cmp     al,TRUE                 ; ck the user's answer
                je      getrs232tofbbaddr       ; if YES, get the addr
                cmp     al,ESC_SEL              ; else, check ESC
                je      rs232tofbbcmdret        ; if ESC..return
;
; If NO, shut OFF the RS232 to FBB Command
;
                mov     rs232tofbbaddr,0        ; else, must be NO
                jmp     rs232tofbbcmdret
;
; Ask the user for the Destination Address
;
getrs232tofbbaddr:
                mov     dx,OFFSET rs232tofbbques2
                call    putstring
                call    getnumber
                cmp     ax,ESC_SEL
                je      rs232tofbbcmdret
                cmp     dx,1
                jl      illegalrs232tofbbaddr
                cmp     dx,14
                jg      illegalrs232tofbbaddr
;
; Store the RS232 to FBB address for the serial routines to use
;
                mov     rs232tofbbaddr,dl
                jmp     rs232tofbbcmdret

;
; Indicate the illegal FBB address
;
illegalrs232tofbbaddr:
                mov     dx, OFFSET illegalentryerrmsg
                call    putstring
                jmp     getrs232tofbbaddr

rs232tofbbcmdret:
                ret
rs232tofbbcmd   endp

;=============================================================================
;   setxmtrtype         Set the XMTR Type
;   -----------
;
;   Parameters Passed:  none
;   Return Value:       in AX, ESC_SEL if the user selected ESC
;   Registers Modified: AX,BX,CX,DX
;   Remarks:            Set posk and posfrmt to be either POSK36 & POSFORMT36
;                       or POSK144 & POSFORMAT144
;=============================================================================
;
setxmtrtype     proc    near
                mov     cx, 2                   ; number of menu entries
                mov     dx, OFFSET xmtrtypemenuptr ; get xmtr type menu
                call    sendmenu                ; put up menu
                cmp     ax,ESC_SEL              ; see if the use hit ESC
                jne     setxmtrtype1 
                ret
;
; Check the User's Entry
;
setxmtrtype1:
                cmp     ax, 0                   ; check if Flock XMTR
                jne     seterxmtr               ;..else ER XMTR
                mov     posk,POSK36
                mov     posfrmt,POSFORMAT
                mov     ax,TRUE
                ret
seterxmtr:
                mov     posk,POSK144
                mov     posfrmt,POSFORMAT144
                mov     ax,TRUE
                ret

setxmtrtype     endp

;=============================================================================
;   systemtests         System Tests
;   -----------
;
;   Parameters Passed:  none
;   Return Value:       in AX, TRUE if the test ends normally
;                       FALSE otherwise
;   Registers Modified: AX,BX,CX,DX
;   Remarks:
;=============================================================================
;
systesttbl      dw      birdoutputtest
                dw      birdechotest
                dw      hostreadtest
                dw      hostreadblocktest

systemtests     proc    near

;
; Put up the Test Selection Menu
;
                mov     cx, 5                   ; number of menu entries
                mov     dx, OFFSET systestmenu  ; get menu
                call    sendmenu                ; put up menu
                cmp     ax,0                    ; see if the use hit ESC or 0
                jle     systestret              ; if not continue

;
; Tell the User the DIP switch setting
;
                push    ax                      ; save the menu selection
                mov     dx, OFFSET systestmsg1
                call    putstring
                pop     ax                      ; restore the menu selection
                push    ax
                mov     bx, OFFSET systestnum   ; get the table start
                add     bx,ax                   ; offset for test number
                mov     al,[bx]                 ; get the test number
                call    displayunsigned         ; display the test number
                call    hitkeycontinue          ; confirm
;
; Do the Test Selected by the User
;
                pop     ax
                dec     ax                      ; first select is exit
                mov     bx,OFFSET systesttbl    ; look up test in table
                shl     ax,1
                add     bx,ax
                call    cs:[bx]                 ; do the test

systestret:
                mov     ax,TRUE
                ret

systemtests     endp

;=============================================================================
;   birdoutputtest      Bird Output Test
;   ----------------
;
;   Parameters Passed:  none
;   Return Value:       in AX, TRUE if the test ends normally
;                       FALSE otherwise
;   Registers Modified: AX,BX,CX,DX
;   Remarks:
;=============================================================================
;
birdoutputtest  proc    near
;
; Test the User to Hit any key to end the test
;
                mov     dx, OFFSET birdoutputmsg1
                call    putstring
;
; Now, Stay in a loop displaying the output of the Bird
; ..until a key is hit
;
; First, clear the receiver
;
                call    clear_rx            ; clear input buffer
waitforbirdoutput:
                call    ckkeyrdy
                cmp     ax,TRUE
                je      birdoutputret       ; continue until keyhit

;
; Get the 4 chars from the BIRD and display them
;
                mov     cx,4
                mov     bx,OFFSET testbuf
                call    get_serial_data
                cmp     ax,TRUE             ; check that we got 4 chars
                jne     birdoutputerr       ; ..else error condition
;
; Display the string on the console
;
                mov     testbuf+4,'$'       ; terminate the string
                mov     dx,OFFSET testbuf
                call    putstring
                jmp     waitforbirdoutput
;
; Normal Return
;
birdoutputret:
                call    clearkey
                mov     ax,TRUE
                ret
;
; Return with error condition
;
birdoutputerr:  call    hitkeycontinue
                mov     ax,FALSE
                ret

birdoutputtest  endp

;=============================================================================
;   birdechotest        Bird Echo Test
;   ------------
;
;   Parameters Passed:  none
;   Return Value:       in AX, TRUE if the test ends normally
;                       FALSE otherwise
;   Registers Modified: AX,BX,CX,DX
;   Remarks:
;=============================================================================
;
birdechotest  proc    near
;
;  Tell the User to hit any key for the Bird to echo.. <ESC> to end test
;
                mov     dx,OFFSET birdechomsg1
                call    putstring
;
; Wait for key to be hit
;
waitforechoinput:
                call    getchr
                cmp     al,ESCKEY
                je      birdechoret         ; end test on ESC
;
; Send the Character to the Bird..first echo to console
;
                call    putchr
                mov     testbuf,al          ; store the char
                mov     cx,1
                mov     bx,OFFSET testbuf   ;
                call    send_serial_cmd     ; send the character
                cmp     ax,1
                jne     birdechoerr1
;
; Now wait for the echoed character
;
                mov     cx,1
                mov     bx,OFFSET testbuf
                call    get_serial_data
                cmp     ax,TRUE             ; check that we got 4 chars
                jne     birdechoerr2
;
; Display the character read back from the Bird
;
                mov     al,testbuf
                call    putchr
                jmp     waitforechoinput

;
; Inform user of an Error if we could not send the character
;
birdechoerr1:
                mov     dx,OFFSET senderrmsg
                jmp     birdechoerrret
;
; Inform user of an Error if we could not read the character
;
birdechoerr2:
                mov     dx,OFFSET readerrmsg
birdechoerrret:
                call    putstring
                call    hitkeycontinue
                mov     ax,FALSE            ; return with the FALSE condition
                ret

birdechoret:
                mov     ax,TRUE
                ret

birdechotest  endp

;=============================================================================
;   hostreadtest        Host Read Test
;   ------------
;
;   Parameters Passed:  none
;   Return Value:       in AX, TRUE if the test ends normally
;                       FALSE otherwise
;   Registers Modified: AX,BX,CX,DX
;   Remarks:
;=============================================================================
;
hostreadtest  proc    near
;
;  Tell the User to hit any key for the Bird to output the block
;  .. <ESC> to end test
;
                mov     dx,OFFSET hostreadmsg1
                call    putstring
;
; Wait for key to be hit
;
waitforreadinput:
                call    getchr
                cmp     al,ESCKEY
                je      hostreadret         ; end test on ESC
;
; Send the ' ' Character to the Bird..
;
                mov     testbuf,' '         ; store the char
                mov     cx,1
                mov     bx,OFFSET testbuf   ;
                call    send_serial_cmd     ; send the character
                cmp     ax,1
                jne     hostreaderr1

;
; Now wait for the Output char
;
                mov     cx,1
                mov     bx,OFFSET testbuf
                call    get_serial_data
                cmp     ax,TRUE             ; check that we got 1 chars
                jne     hostreaderr2
;
; Display the data read back from the Bird as a decimal number
;
                mov     dx,OFFSET hostreadmsg2
                call    putstring
                mov     al,testbuf          ; get  char from the buffer
                xor     ah,ah
                call    displayunsigned     ; display as decimal
                jmp     waitforreadinput    ; wait for user input

;
; Inform user of an Error if we could not send the character
;
hostreaderr1:
                mov     dx,OFFSET senderrmsg
                jmp     hostreaderrret
;
; Inform user of an Error if we could not read the block
;
hostreaderr2:
                mov     dx,OFFSET readerrmsg
hostreaderrret:
                call    putstring
                call    hitkeycontinue
                mov     ax,FALSE            ; return with the FALSE condition
                ret

hostreadret:
                mov     ax,TRUE
                ret

hostreadtest  endp


;=============================================================================
;   hostreadblocktest        Host Read Block Test
;   -----------------
;
;   Parameters Passed:  none
;   Return Value:       in AX, TRUE if the test ends normally
;                       FALSE otherwise
;   Registers Modified: AX,BX,CX,DX,SI
;   Remarks:
;=============================================================================
;
hostreadblocktest  proc    near
;
;  Tell the User to hit any key for the Bird to output the block
;  .. <ESC> to end test
;
                mov     dx,OFFSET hostreadblockmsg1
                call    putstring
;
; Wait for key to be hit
;
waitforreadblockinput:
                call    getchr
                cmp     al,ESCKEY
                je      hostreadblockret         ; end test on ESC
;
; Send the ' ' Character to the Bird..
;
                mov     testbuf,' '          ; store the char
                mov     cx,1
                mov     bx,OFFSET testbuf   ;
                call    send_serial_cmd     ; send the character
                cmp     ax,1
                jne     hostreadblockerr1

;
; Now wait for the Output block
;
                mov     cx,256
                mov     bx,OFFSET testbuf
                call    get_serial_data
                cmp     ax,TRUE             ; check that we got 256 chars
                jne     hostreadblockerr2
;
; Display the Block of data read back from the Bird as decimal numbers
;
                mov     dx,OFFSET hostreadmsg2
                call    putstring
                mov     si,OFFSET testbuf
                mov     al,[si]             ; get next char from the buffer
                xor     ah,ah
                call    displayunsigned     ; display as decimal
                mov     cx,255              ; 256-1 chars to display
nextreadblockchar:
                mov     al,','              ; put up a ','
                call    putchr
                inc     si
                mov     al,[si]             ; get next char from the buffer
                xor     ah,ah
                call    displayunsigned     ; display as decimal
                loop    nextreadblockchar   ; continue for 256 byte block

                jmp     waitforreadblockinput   ; wait for user input

;
; Inform user of an Error if we could not send the character
;
hostreadblockerr1:
                mov     dx,OFFSET senderrmsg
                jmp     hostreadblockerrret
;
; Inform user of an Error if we could not read the block
;
hostreadblockerr2:
                mov     dx,OFFSET readerrmsg
hostreadblockerrret:
                call    putstring
                call    hitkeycontinue
                mov     ax,FALSE            ; return with the FALSE condition
                ret

hostreadblockret:
                mov     ax,TRUE
                ret

hostreadblocktest  endp

;=============================================================================
;   get_output_mode     Get Output Mode
;   ---------------
;
;   Parameters Passed:  none
;   Return Value:       outputmode in AX = POINT, CONTINUOUS, or STREAM
;                       if mode is selected or ESC_SEL if ESC is selected,
;                       sets (global) outputmode if not ESC_SEL
;   Registers Modified: AX
;   Remarks:            prompts the user to enter the outputmode from the
;                       bird.
;=============================================================================
;
get_output_mode proc    NEAR
                push    cx
                push    dx                  ; save regs
;
; Put up the menu and return the selection
;
                mov     cx,3                ; setup the menu
                mov     dx,OFFSET getoutmodemenu
                call    sendmenu            ; put up the menu
                cmp     ax,ESC_SEL          ; ck for ESC
                je      getoutmoderet
                xor     ah,ah               ; clear AH
                mov     outputmode,ax       ; assign outputmode the return Value
getoutmoderet:  pop     dx                  ; restore regs
                pop     cx
                ret
get_output_mode endp

;=============================================================================
;   serialinit          Serial Port Initialization
;   -----------
;
;   Parameters Passed:  (global) comport, (global) baudrate
;   Return Value:       In AX, TRUE if successful
;                       FALSE if unsuccessful
;   Registers Modified: AX
;   Remarks:            Routine prompts the user for the serial port
;                       configuration parameters of COM1 or COM2 and
;                       tries to configure the port via configserialport()
;=============================================================================
;
serialinit      proc    NEAR
                push    bx                  ; save regs
                push    cx
                push    dx
                push    di
                push    si
;
; Configure the serial port w/comport and bauddivisor
;
sendserialconfig:
                mov     di,baudsel              ; get in the current value
                shl     di,1                    ; table is 2 bytes wide
                mov     ax,bauddivisortbl[di]   ; get the divisor
                call    configserialport        ; configure the hardware
;                                               ; ..AX = DIVISOR
; Put up the current baudrate and comport
;
displayserialconfig:
                mov     dx,OFFSET baudratemsg1
                call    putstring
;
; Display the comport message
;
                mov     ax,comport              ; get the comport
                inc     ax                      ; add one to reflect COM1 or COM2
                call    displayunsigned         ; display the number
;
; Display the Baudrate msg
;
                mov     dx,OFFSET baudratemsg2  ; get baud msg
                call    putstring               ; put up msg
;
; Display the current baud rate from the menu
;
                mov     bx,OFFSET serialmenu
                mov     dx,[bx][di]+4           ; get the address of the
                                                ; baudrate string
                                                ; +4 for the menuprompt
                                                ; and the NO CHANGE selection
                call    putstring
                call    newline
;
; Put up the menu Choices
;
                mov     dx,OFFSET serialmenu    ; get serial choices
                mov     cx,10                   ; 10 choices available
                call    sendmenu                ; send the menu to the screen
;
; Look at the User selection
;
                cmp     ax,0                    ; no change selected
                jg      ckforbaudchg            ; see if baud rate chg
                jmp     serialinitret           ; home...
;
; See if a Baud rate change was selected
;
ckforbaudchg:   cmp     ax,7                    ; Baud Rate Change Selected
                jg      ckforcomportchg
                dec     ax                      ; adjust for NO CHANGE selection
                mov     baudsel,ax              ; store the new selection
                jmp     sendserialconfig
;
; See if Comport1 Change
;
ckforcomportchg:
                cmp     ax,8                    ; set up for COM1?
                jne     comport2chg             ; if not.. must be COM2
                call    restoreserialconfig     ; restore current port
                mov     com_base,COM1BASE       ; setup comport address
                mov     comport,COM1            ; else, assign global COM1
                call    saveserialconfig        ; save new port
                jmp     sendserialconfig        ; off to chg
;
; Comport2 Change...gotta be this one since we've checked everything else
;
comport2chg:    call    restoreserialconfig     ; restore current port
                mov     com_base,COM2BASE       ; setup comport address
                mov     comport,COM2            ; Assign global COM2
                call    saveserialconfig        ; save new port
                jmp     sendserialconfig        ; off to chg
;
; Couldn't configure the Port, so put up a message
;
sendserialconfigerrormsg:
                mov     dx,OFFSET serialconfigerrormsg    ; get the message
                call    putstring               ; send it to the console
                call    hitkeycontinue          ; wait for confirmation
                mov     ax,FALSE                ; return FALSE
                jmp     serialinitret1

serialinitret:  mov     ax,TRUE                 ; return TRUE
serialinitret1: pop     si                      ; restore the regs
                pop     di
                pop     dx
                pop     cx
                pop     bx
                ret
serialinit      endp

;***************************************************************************

_TEXT           ENDS
                END     asmbird

title   FBBTEST
subttl  Assembly Main Module Routines for FBBTEST
page    50,132
;
;****************************************************************************
;****************************************************************************
;   FBBTEST.asm          Assembly Main Module Routines for FBBTEST
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
;   5/14/91     jf  - created from BIRDSOFT\ASM\BIRDMAIN.asm
;   5/30/91     jf  - added code for seperate host and bird com commands
;   8/19/91     jf  - updated for USER Distribution.. revision 1.00
;   9/17/91     jf  - removed references to comport..revision 1.01
;   10/6/91     eb  - changed default output from point to contineous, changed
;                     menues that say 'once' to 'point'. Deleted commands to wait 
;                     or not wait for bird response
;   10/10/91    jf  - added CMDUTIL.asm module ..revision 1.02
;                   - modified FBB Baudrates
;   10/22/91    jf  - modified newirq0_proc to send a NON SPECIFIC EOI
;                     to the Interrupt Controller prior to calling DOS IRQ0 
;                     .. revision 1.03
;   11/1/91     jf  - added fbb_nextmaster_cmd, chg/exm Filter Constant,
;                     alpha max, chg/exm glitch checking on/off.. rev 1.04
;   11/7/91     jf  - added exm model.. rev 1.05
;   12/27/91    jf  - fixed bug in button code ..rev 1.06
;   6/2/92      jf  - added set xmtr type ..rev 1.07
;   8/11/92     jf  - added extended address mode capability
;               jf  - added data gathering capability ..rev 1.08
;   2/18/93     jf  - removed extended address mode menu selection
;                   - modified the code so that all the Host commands
;                     have the same command set for both the extended mode
;                     and the normal addressing mode
;               jf  - updated definitions for the bird_examine value status
;               jf  - added system tests to this module ..rev 1.09
; 3/22/93       jf  - fixed the displaying of button value at the end of
;                     position/data display ..rev 1.10
;
;
;   *** IMPORTANT *** this code with work on 80286/386/486 PCs but not on
;   8086 PCs...pusha/popa instructions are used!!
;
;   You really need a 33MHz 386 (at least) to communicate at full speed,
;   w/ back to back serial characters, with the QUATECH DS302.*  RS485 card
;
;
;          <<<< Copyright 1990 Ascension Technology Corporation >>>>
;*****************************************************************************
;*****************************************************************************
;...Misc. directives
                INCLUDE asctech.inc         ; misc definitions for the Bird
                INCLUDE menudef.inc         ; menu definitions
                INCLUDE fbbser.inc          ; serial port definitions
                .286                        ; 80286 instructions allowed
;
; Public Routines
;
                PUBLIC  fbbtest
                PUBLIC  ckdoagain
                PUBLIC  get_output_mode
;
; Public Variables
;
                PUBLIC  outputmode
                PUBLIC  buttonmode
                PUBLIC  buttonvalue
                PUBLIC  fbb_address
                PUBLIC  fbb_startaddress
                PUBLIC  fbb_stopaddress
                PUBLIC  fbb_currentmaster
                PUBLIC  fbbaddrmask
                PUBLIC  numfbbaddresses
                PUBLIC  tick
                PUBLIC  dosirq0cntlow
                PUBLIC  dosirq0cnthigh
                PUBLIC  dostickcounter
                PUBLIC  multitimestartflg
                PUBLIC  posfrmt
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
                EXTRN   getnumber:NEAR
                EXTRN   ckkeyrdy:NEAR
                EXTRN   clearkey:NEAR
                EXTRN   clearscreen:NEAR
                EXTRN   getchr:NEAR
;
; Serial Routines Used
;
                EXTRN   hostconfigserialport:NEAR
                EXTRN   hostconfigserialport:NEAR
                EXTRN   hostrestoreserialconfig:NEAR
                EXTRN   hostsaveserialconfig:NEAR
                EXTRN   hostsend_serial_cmd:NEAR
                EXTRN   hostsend_serial_data:NEAR
                EXTRN   hostget_serial_data:NEAR
                EXTRN   hostclear_rx:NEAR

;
; FBB Commands used
;
                EXTRN   fbb_hostsenderrcode_cmd:NEAR
                EXTRN   fbb_hostsenddata_cmd:NEAR
                EXTRN   fbb_hostsendstatus_cmd:NEAR
                EXTRN   fbb_hostrs232_cmd:NEAR
;
; External Data.....NOTE variables are for the HOST comport
;
                EXTRN   baudrate:DWORD
                EXTRN   baudratetbl:DWORD
                EXTRN   bauddivisortbl:WORD
                EXTRN   posk:WORD

                EXTRN   fbb_hostcmd_tbl:BYTE

;*****************************************************************************
STACK           SEGMENT PARA STACK 'STACK'  ; set up a stack segment
                db      400h dup (?)        ; 1k bytes long, uninitialized
STACK           ENDS
;*****************************************************************************

;*****************************************************************************

_DATA           SEGMENT PUBLIC 'DATA'       ; setup a data segment

nullptr             dw  illegalmenucall           ; bad subroutine call

;
; Flags
;
exitflag            db  FALSE                   ; if TRUE, program exits
hostbaudset         db  FALSE                     ; TRUE if host com initialized
birdbaudset         db  FALSE                   ; TRUE if bird com initialized

;
; Position Scaling
;
posfrmt             dw  POSFORMAT           ; default to Flock format

;
; Interrupt Vector Data
;
; NOTE:  oldirq0 is stored in the Code Segment in the newirq0_intproc
;
CTRLBRK_IRQ     EQU 1bh                     ; Control Break Interrupt vector
CTRLC_IRQ       EQU 23h                     ; Control C interrupt vector

PCTIMERCTLREG   EQU 43h                     ; 8253 control reg
PCTIMER0        EQU 40h                     ; 8253 timer 0 reg
PCINTMSKREG     EQU 20h                     ; 8259 interrupt mask reg
NSEOI           EQU 20h                     ; 8259 non-specific end of interrupt
IRQ0ADDR        EQU 20h                     ; address 20 hex, vector location
newirq0_proc    dw  0                       ; called by newirq0_intproc
newtimercount   dw  0                       ; new 8253 counter/timer value
dosirq0counter  dw  0                       ; rollover counter for DOS IRQ0
dosirq0cntlow   dw  0                       ; counter for DOS Time Update - LOW Word
dosirq0cnthigh  dw  0                       ; counter for DOS Time Update - HIGH Word
oldctrlbrk      dd  ?                       ; temp storage for CTRL BREAK vector
oldctrlc        dd  ?                       ; temp storage for CTRL C vector
tick            db  FALSE                   ; tick
multitimestartflg db FALSE

dostickcounter  dw  0                       ; tickcounter for timing
dosendtickcounter  dw  182                  ; tickcounter for timing (10 secs)
birdaccesscounter dw 0                      ;

;
; Messages
;
quitmsg         db  'Are you sure you want to quit','$'
getnewtimermsg  db  CR,LF,'Enter the data request repetition rate period in mS (1 - 54): ','$'
getmultitimemsg db  CR,LF,'Enter the Test Time in DOS Ticks (18.2 ticks/sec, 182 - 1820): ','$'
baudratemsg1    db  CR,LF,'Current HOST serial port configuration: COM','$'
baudratemsg2    db  ' at ','$'
userctrlbrkmsg  db  CR,LF,'** USER CONTROL BREAK *** exiting FBBTEST',CR,LF,LF,'$'
userctrlcmsg    db  CR,LF,'** USER CONTROL C *** exiting FBBTEST',CR,LF,LF,'$'
multitimecompletemsg db  CR,LF,'** Multi Bird Test Complete ** ',CR,LF,LF,'$'
multitimemsg1   db   CR,LF,'Accessed FLOCK units ','$'
multitimemsg2   db   ' times in ','$'
multitimemsg3   db   ' DOS ticks',CR,LF, '$'

;
; Error Messages
;
serialconfigerrormsg db CR,LF,'** ERROR ** could not initialize serial port',CR,LF,'$'
illegalmenumsg  db   CR,LF,'** RUNTIME ERROR ** illegal menu call',CR,LF,'$'
illegalentrymsg db   CR,LF,'** ERROR ** illegal value, please try again','$'

;
; Main Menu
;



hostmenuhdr     db  '****************************************************************************',CR,LF
                db  '* ASCENSION TECHNOLOGY CORPORATION - Flock 485 Main Menu          rev 1.10 *',CR,LF
                db  '****************************************************************************',CR,LF
IFDEF QUATECH_8MHZ
                db  CR,LF
                db  'NOTE: This is test program for controlling a Flock of Birds'
                db  CR,LF,'      from a PCAT/Compatible Computer.. it assumes a'
                db  CR,LF,'      Quatech DS302 RS485 card is installed in the PC'
                db  CR,LF,'      as COM4, using IRQ2',CR,LF,'$'
ENDIF
IFDEF QUATECH_20MHZ
                db  CR,LF
                db  'NOTE: This is test program for controlling a Flock of Birds'
                db  CR,LF,'      from a PCAT/Compatible Computer.. it assumes a'
                db  CR,LF,'      Quatech DS302 RS485 card is installed in the PC'
                db  CR,LF,'      as COM3, using IRQ5',CR,LF,'$'
ENDIF

IFDEF FACTORYTEST
NUMMAINMENUSEL     EQU 11
OUTPUTMODEMENUSEL  EQU 5
ELSE
NUMMAINMENUSEL     EQU 8
OUTPUTMODEMENUSEL  EQU 3
ENDIF

hostmenu        dw  hostmenuprompt,hostmenu0,hostmenu1,hostmenu2,hostmenu3
                dw  hostmenu4,hostmenu5,hostmenu6,hostmenu7,hostmenu8
                dw  hostmenu9,hostmenu10

hostmenuprompt  db  'Host FBB menu selections:','$'
hostmenu0       db  'Quit','$'
hostmenu1       db  'Send FBB SENDDATA command','$'
hostmenu2       db  'Send FBB SENDSTATUS command','$'
hostmenu3       db  'Send FBB SENDERRORCODE command','$'
hostmenu4       db  'Send FBB RS232CMD command','$'
hostmenu5       db  'Set START/STOP destination address','$'
hostmenu6       db  'Set Transmitter Type','$'
hostmenu7       db  'HOST serial port configuration','$'
hostmenu8       db  'Set output mode (POINT/CONTINOUS, DISP ON/OFF)','$'
hostmenu9       db  'Set Default Data Sample Rate','$'
hostmenu10      db  'Multiple Device FBB Timing','$'

hostmenusubs    dw  doquit
                dw  fbb_hostsenddata_cmd
                dw  fbb_hostsendstatus_cmd
                dw  fbb_hostsenderrcode_cmd
                dw  fbb_hostrs232_cmd
                dw  set_fbbstartstopaddress
                dw  setxmtrtype
                dw  serialinit
                dw  get_output_mode 
                dw  getnewtimerval
                dw  multifbbtiming

;
; Main Globals
;
outputmode      dw  CONTINUOUS + DISPLAYON   ; output mode (CONTINUOUS + DISPLAY ON)
buttonmode      dw  0                        ; button mode
buttonvalue     dw  0                        ; button value

;
; FBB Variables
;
fbb_address         db  1
fbb_startaddress    db  1
fbb_stopaddress     db  1
fbb_currentmaster   db  1
numfbbaddresses     dw  32                  ; ** ALL MODES have 32 addrs **
fbbaddrmask         db  11100000b           ; ..therefore 5 lower bits are addr

;
; Set XMTR Type Menu
;
xmtrtypemenuptr dw  xmtrtypemenuprompt,xmtrtypemenu0,xmtrtypemenu1
xmtrtypemenuprompt db  'Select Transmitter Type:','$'
xmtrtypemenu0   db  'Short Range Transmitter','$'
xmtrtypemenu1   db  'Extended Range Transmitter','$'


;
; Serial Menu
;
serialmenu      dw  serialprompt,serialmenu0,serialmenu1,serialmenu2
                dw  serialmenu3
serialprompt    db  'HOST Serial Port Options:','$'
serialmenu0     db  'No Change','$'

IFDEF QUATECH_8MHZ
serialmenu1     db  '250000','$'
serialmenu2     db  '115200','$'
serialmenu3     db  '57600','$'
ENDIF

IFDEF QUATECH_20MHZ
serialmenu1     db  '312500','$'
serialmenu2     db  '156250','$'
serialmenu3     db  '57600','$'
ENDIF

;
; Output Mode Menu
;
getoutmodemenu  dw  getoutmodeprompt,getoutputmenu0
                dw  getoutputmenu1,getoutputmenu2,getoutputmenu3
                dw  getoutputmenu4
getoutmodeprompt db 'FBB Data Output Modes:','$'
getoutputmenu0  db  'Previous Menu','$'
getoutputmenu1  db  'Point mode - output once ','$'
getoutputmenu2  db  'Continuously output','$'
getoutputmenu3  db  'Display OFF','$'
getoutputmenu4  db  'Display ON','$'


;
; Set FBB Address
;
tellfbbaddressmsg db CR,LF,LF,'Default FBB address set to ','$'
queryfbbaddressmsg db CR,LF,LF,'Enter new address:','$'
tellfbbstartaddressmsg db CR,LF,LF,'FBB START address set to ','$'
queryfbbstartaddressmsg db CR,LF,LF,'Enter new START address:','$'
tellfbbstopaddressmsg db CR,LF,LF,'FBB STOP address set to ','$'
queryfbbstopaddressmsg db CR,LF,LF,'Enter new STOP address:','$'
illegalfbbaddresserrmsg db CR,LF,LF,'** ERROR ** illegal address',CR,LF,'$'

_DATA           ENDS

;*****************************************************************************

_TEXT           SEGMENT WORD PUBLIC 'CODE'
                ASSUME cs:_TEXT, ds:_DATA, ss:STACK


;=============================================================================
;   fbbtest     Main Module for FBBTEST
;   -------
;
;=============================================================================
;
fbbtest         proc far
                mov     ax, _DATA               ; get data segment value
                mov     ds, ax                  ; store in DS
                mov     es, ax                  ; point ES to the data segment

;
; Take over the CTRL C and CTRL Break interrupt
;

                call    setupctrlbrkirq

;
; Take over the Interrupt IRQ0
;
                call    setupirq0

;
; Allow the user change the serial port configuration
;
                call    hostsaveserialconfig    ; save current serial config
;
; Do the Main Menu
;
                call    dofbbhostmenu
;
; Restore the Timer Interrupt
;
                call    restoreirq0
;
; Restore the Control Break
;
                call    restorectrlbrkirq
;
; Restore the Serial Configuratoin
;
                call    hostrestoreserialconfig
;
; Exit the Program
;
                DOSINT  4ch                     ; return to DOS
fbbtest         endp                            ; ....done

;=============================================================================
;   doquit              - QUIT procedure
;   ------
;
;   Parameters Passed:   none
;   Return Value:        exitflag = TRUE if a ERROR occurs
;   Registers Modified:  none
;   Remarks:
;=============================================================================
;
doquit          proc near
                mov     dx,OFFSET quitmsg       ; get the quit msg
                call    askyesno                ; ask them if they want to quit
                cmp     al,TRUE                 ; ck the user's answer
                jne     quitret
                mov     exitflag,TRUE           ; set the exitflag
quitret:        ret
doquit          endp

;=============================================================================
;   dofbbhostmenu       - FBB HOST Menu
;   -------------
;
;   Parameters Passed:   none
;   Return Value:        exitflag = TRUE if a ERROR occurs
;   Registers Modified:  none
;   Remarks:
;=============================================================================
;
dofbbhostmenu  proc near
                cmp     hostbaudset,TRUE
                je      clearhostport

                call    serialinit              ; send serial menu
                mov     hostbaudset,TRUE         ; set the flag = TRUE
                cmp     ax,FALSE                ; see if init went OK
                jne     clearhostport
                mov     exitflag,TRUE            ; return if Error
                ret
;
; Prior to each test, clear the receive buffer/port
;
clearhostport:  call    hostclear_rx            ; clear the receiver

;
; Reinitialize some variables before each command
;
                mov     multitimestartflg,FALSE
                mov     al, fbb_startaddress
                mov     fbb_address,al
;
; Put up the FBB Host Menu
;
                mov     dx, OFFSET hostmenuhdr  ; get screen header
                call    sendmenuhdr             ; send header to screen
                mov     cx,NUMMAINMENUSEL                   ; number of menu entries
                mov     dx, OFFSET hostmenu     ; get menu
                call    sendmenu                ; put up main menu
                cmp     ax,0                    ; if the selects escape
                jl      clearhostport           ; ..redisplay the menu

dohostmenucmd:  shl     ax,1                    ; multilply by 2 for words
                mov     bx, OFFSET hostmenusubs ; get code address
                add     bx,ax                   ; add ax to bx
;
; Do the User Selected Command
;
dousercmd:
                call    ds:[bx]                 ; call the routine
;
; If the User selected Quit and Confirmed Quit...then Quit
;
                cmp     exitflag,TRUE           ; see if we should quit
                jne     clearhostport

                ret

dofbbhostmenu   endp

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
;   set_fbbaddress
;   ----------------
;
;   Parameters Passed:   none
;   Return Value:        (global) fbb_address set with the desired address <1-15>
;   Registers Modified:  none
;   Remarks:
;=============================================================================
;
set_fbbaddress          proc  NEAR

                    push      ax
                    push      dx
getfbbaddress:
                    mov       dx, OFFSET tellfbbaddressmsg
                    call      putstring
                    mov       al,fbb_address
                    xor       ah,ah
                    call      displayunsigned
                    mov       dx, OFFSET queryfbbaddressmsg
                    call      putstring
                    call      getnumber
                    cmp       ax,ESC_SEL
                    je        setfbbaddressret
                    cmp       dx, 0
                    je        illegaladdress
                    cmp       dx,numfbbaddresses
                    jl        setfbbaddress
;
; Display the error message
;
illegaladdress:     mov       dx, OFFSET illegalfbbaddresserrmsg
                    call      putstring
                    call      hitkeycontinue
                    jmp       getfbbaddress
;
; Set the address
;
setfbbaddress:
                    mov       fbb_address,dl

setfbbaddressret:
                    pop       dx
                    pop       ax
                    ret
set_fbbaddress          endp

;=============================================================================
;   set_fbbstartstopaddress
;   ----------------
;
;   Parameters Passed:   none
;   Return Value:        (global) fbb_address set with the desired address <1-15>
;   Registers Modified:  none
;   Remarks:
;=============================================================================
;
set_fbbstartstopaddress          proc  NEAR

                    push      ax
                    push      dx
getfbbstartaddress:
                    mov       dx, OFFSET tellfbbstartaddressmsg
                    call      putstring
                    mov       al,fbb_startaddress
                    xor       ah,ah
                    call      displayunsigned
                    mov       dx, OFFSET queryfbbstartaddressmsg
                    call      putstring
                    call      getnumber
                    cmp       ax,ESC_SEL
                    je        setfbbstartstopaddressret
                    cmp       dx, 0
                    je        illegalstartaddress
                    cmp       dx,numfbbaddresses
                    jl        setfbbstartaddress
;
; Display the error message
;
illegalstartaddress:
                    mov       dx, OFFSET illegalfbbaddresserrmsg
                    call      putstring
                    call      hitkeycontinue
                    jmp       getfbbstartaddress
;
; Set the address
;
setfbbstartaddress:
                    mov       fbb_startaddress,dl
                    mov       fbb_address,dl

getfbbstopaddress:
                    mov       dx, OFFSET tellfbbstopaddressmsg
                    call      putstring
                    mov       al,fbb_stopaddress
                    xor       ah,ah
                    call      displayunsigned
                    mov       dx, OFFSET queryfbbstopaddressmsg
                    call      putstring
                    call      getnumber
                    cmp       ax,ESC_SEL
                    je        setfbbstartstopaddressret
                    cmp       dx, 0
                    je        illegalstopaddress
                    cmp       dx,numfbbaddresses
                    jl        setfbbstopaddress
;
; Display the error message
;
illegalstopaddress:     
                    mov       dx, OFFSET illegalfbbaddresserrmsg
                    call      putstring
                    call      hitkeycontinue
                    jmp       getfbbstopaddress
;
; Set the address
;
setfbbstopaddress:
                    mov       fbb_stopaddress,dl


setfbbstartstopaddressret:
                    pop       dx
                    pop       ax
                    ret
set_fbbstartstopaddress          endp


;=============================================================================
;   get_output_mode     Get Output Mode
;   ---------------
;
;   Parameters Passed:  none
;   Return Value:       if mode is selected or ESC_SEL if ESC is selected,
;                       sets (global) outputmode if not ESC_SEL
;   Registers Modified: AX
;   Remarks:             Do only ONCE or Continuous
;=============================================================================
;
get_output_mode proc    NEAR
                push    cx
                push    dx                  ; save regs
;
; Put up the menu and return the selection
;
sendoutputmodemenu:
                mov     cx,OUTPUTMODEMENUSEL   ; number of menu items
                mov     dx,OFFSET getoutmodemenu
                call    sendmenu            ; put up the menu
                cmp     ax,0                ; ck for 0 or ESC
                jle     getoutmoderet

ckoncedispoff:
                cmp     ax, 1                    ; POINT MODE - OUTPUT ONCE
                jne     ckcontdispoff
                and     outputmode, NOT CONTINUOUS
                jmp     getoutmoderet

ckcontdispoff:
                cmp     ax, 2                    ; CONTINUOUSLY OUTPUT
                jne     ckoncedispon
                or      outputmode,CONTINUOUS
                jmp     getoutmoderet
ckoncedispon:
                cmp     ax, 3                    ; Display OFF
                jne     contdispon
                and     outputmode,NOT DISPLAYON
                jmp     getoutmoderet
contdispon:
                cmp     ax, 4                    ; Display ON
                jne     getoutmoderet
                or      outputmode,DISPLAYON
                jmp     getoutmoderet


getoutmoderet:  pop     dx                  ; restore regs
                pop     cx
                ret

get_output_mode endp


;=============================================================================
;   multifbbtiming      Multi Device Timing
;   --------------
;
;   Parameters Passed:
;   Return Value:
;   Registers Modified:
;   Remarks:
;=============================================================================
;
multifbbtiming  proc    near
;
; Turn the Timing On and Display Off and Continuous Mode
;
                or      outputmode,MULTIBIRDTIMEON
                and     outputmode,NOT DISPLAYON
                or      outputmode,CONTINUOUS

;
; Get the Timing Value from the User
;
                call    getmultitime

;
; Get the Data
;
                call    fbb_hostsenddata_cmd
                call    hitkeycontinue
;
; Turn the Timing Off
;
                and     outputmode,NOT MULTIBIRDTIMEON
                or      outputmode,DISPLAYON

                ret

multifbbtiming  endp

;=============================================================================
;   serialinit          Serial Port Initialization
;   -----------
;
;   Parameters Passed:  (global) baudrate
;   Return Value:       In AX, TRUE if successful
;                       FALSE if unsuccessful
;   Registers Modified: AX
;   Remarks:
;=============================================================================
;
serialinit      proc    NEAR
                pusha
;
; Configure the Host serial port w/comport and bauddivisor
;
                mov     si,1 * 0                    ; DEFAULT Baud Rate Divisor
                                                    ; 1st tbl entry..250000
                                                    ; ..word access
sendserialconfig:
                push    si
                mov     ax,bauddivisortbl[si]       ; get the divisor
                call    hostconfigserialport        ; configure the hardware

                cmp     hostbaudset,TRUE            ; skip menu display
                je      displayserialconfig         ; ..if first time
                pop     si
                jmp     serialinitret

; Put up the current baudrate and comport
;
displayserialconfig:
                mov     dx,OFFSET baudratemsg1
                call    putstring
;
; Display the comport message
;
                mov     ax,HOSTCOMPORT          ; USE COM1-4
                inc     ax                      ; COM1 -> 1, COM2 -> 2..
                call    displayunsigned         ; display the number
;
; Display the Baudrate msg
;
                mov     dx,OFFSET baudratemsg2  ; get baud msg
                call    putstring               ; put up msg
;
; Display the current baud rate
;
                pop     si
                add     si,4                    ; offset from the menu lookup
                mov     dx,serialmenu[si]       ;
                call    putstring               ; put up the baudrate
                mov     al,CR                   ; send a CR
                call    putchr
                mov     al,LF                   ; send a LF
                call    putchr
;
; Put up the menu Choices
;
                mov     dx,OFFSET serialmenu    ; get serial choices
                mov     cx,4                    ; 4 choices available
                call    sendmenu                ; send the menu to the screen
;
; Look at the User selection
;
                cmp     ax,0                    ; no change selected
                jg      ckforbaudchg            ; see if baud rate chg
                jmp     serialinitret           ; ask to send auto baud char
;
; See if a Baud rate change was selected
;
ckforbaudchg:   mov     bx,OFFSET baudratetbl   ; get baud Table address
                mov     si,ax                   ; use SI as offset to table
                dec     si                      ; adjust to table start
                mov     cx,2
                shl     si,cl                   ; ...table is 4 bytes wide
                mov     ax,[bx][si]             ; get the baud rate from table
                mov     WORD PTR [baudrate],ax  ; store the new baud rate
                mov     ax,[bx][si]+2           ; get the baud rate from table
                mov     WORD PTR [baudrate+2],ax ; store the new baud rate
                shr     si,1                    ; readjust for the divisor tbl
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
serialinitret1: popa
                ret
serialinit      endp

;=============================================================================
;   ckdoagain           Check if the command should be Run again
;   ---------
;
;   Parameters Passed:  (global) outputmode
;   Return Value:       TRUE, if the command should run again
;                       FALSE, otherwise
;   Registers Modified: AX
;   Remarks:            The routine will only return TRUE when the
;                       repetition counter (tick) has been set by the
;                       interrupt service routine
;=============================================================================
;
ckdoagain       proc    near

                test    outputmode,CONTINUOUS
                jnz     ckmultimode
                mov     al,fbb_address
                cmp     al,fbb_startaddress
                jne     ckmultimode
                mov     ax,FALSE
                ret
ckmultimode:
                test    outputmode,MULTIBIRDTIMEON
                jz      ckuserkeyhit
                cmp     multitimestartflg,TRUE
                je      domultitimework

                mov     multitimestartflg,TRUE
                mov     ax,dostickcounter     ; get tick now
waitfordostick:
                mov     bx,dostickcounter     ; wait until tick increments
                cmp     bx,ax
                je      waitfordostick
                mov     birdaccesscounter,0   ; reset counters
                mov     dostickcounter,0
                mov     ax,TRUE
                ret

domultitimework:
                inc     birdaccesscounter
                mov     ax,dosendtickcounter
                cmp     dostickcounter,ax
                jle     timenotdone

                mov     ax,dostickcounter
                push    ax
                mov     al,BEL
                call    putchr
                mov     al,BEL
                call    putchr
                mov     al,BEL
                call    putchr
                mov     dx,OFFSET multitimecompletemsg
                call    putstring
                mov     dx,OFFSET multitimemsg1
                call    putstring
                mov     ax,birdaccesscounter
                call    displayunsigned
                mov     dx,OFFSET multitimemsg2
                call    putstring
                pop     ax
                call    displayunsigned
                mov     dx,OFFSET multitimemsg3
                call    putstring
                call    hitkeycontinue
                mov     multitimestartflg,FALSE
                mov     ax,FALSE
                ret
timenotdone:
                mov     ax,TRUE
                ret

ckuserkeyhit:
                call    ckkeyrdy
                cmp     ax,TRUE
                jne     waittick
                call    clearkey
                mov     ax,FALSE
                ret

waittick:
;
; Do NOT do work in Real Time if not assembled for FACTORYTEST
;
IFDEF FACTORYTEST
                cmp     tick,TRUE
                jne     waittick
ENDIF
                mov     tick,FALSE
                mov     ax,TRUE
                ret

ckdoagain       endp

;=============================================================================
;   getmultitime         Get the Time for a Multiple Bird Test
;   ------------
;
;   Parameters Passed:   none
;   Return Value:        none
;   Registers Modified:  none
;   Remarks:
;=============================================================================
;
getmultitime    proc    near

            mov   dx,OFFSET getmultitimemsg
            call  putstring
            call  getnumber
            cmp   ax,ESC_SEL
            je    getmultitimeret
;
; Validate the answer
;
            cmp   dx,182
            jl    illegalmultitimeval
            cmp   dx,1820
            jle   setmultitimeval
illegalmultitimeval:
            mov   dx,OFFSET illegalentrymsg
            call  putstring
            call  hitkeycontinue
            jmp   getmultitime
;
; Set the new timer value
;
setmultitimeval:
            mov   dosendtickcounter,dx

getmultitimeret:
  
            ret
getmultitime  endp

;=============================================================================
;   getnewtimerval       Get the Sample Time Interval from the User
;   --------------
;
;   Parameters Passed:   none
;   Return Value:        none
;   Registers Modified:  (global) newtimer
;   Remarks:             modifies the Timer Interrupt request rate with a
;                        rate select by the user
;
;=============================================================================
;
getnewtimerval    proc    near

            mov   dx,OFFSET getnewtimermsg
            call  putstring
            call  getnumber
            cmp   ax,ESC_SEL
            je    getnewtimerret
;
; Validate the answer
;
            cmp   dx,0
            jle   illegaltimerval
            cmp   dx,54
            jle   setnewtimerval
illegaltimerval:
            mov   dx,OFFSET illegalentrymsg
            call  putstring
            call  hitkeycontinue
            jmp   getnewtimerval
;
; Set the new timer value
;
setnewtimerval:
            mov     ax,1190             ; 1190 counts per millisecond
            mul     dx                  ; ...XTAL is 1.19 MHZ
            mov     newtimercount,ax    ; store the tick count
            call    setupirq0timer      ; setup the timer

getnewtimerret:

            ret
getnewtimerval    endp

;=============================================================================
;   illegalmenucall     Illegal Menu Call .. debug only
;   ---------------
;
;   Parameters Passed:   none
;   Return Value:        none
;   Registers Modified:  none
;   Remarks:
;=============================================================================
;
illegalmenucall     proc near
                    mov     dx,OFFSET illegalmenumsg
                    call    putstring
                    call    hitkeycontinue
                    call    restoreirq0             ; restore IRQ0
                    call    restorectrlbrkirq       ; restore control break irqs
                    call    hostrestoreserialconfig ; restore serial config
                    DOSINT  4ch                     ; return to DOS
illegalmenucall     endp

;=============================================================================
;   setupctrlbrkirq  Setup New/Save Old Control Break/Control Interrupts
;   -------------
;
;   Parameters Passed:   none
;   Return Value:        none
;   Registers Modified:  none
;   Remarks:
;=============================================================================
setupctrlbrkirq proc    near
                cli
                pusha
;
; Take over CTRL BREAK...first store the old vector
;
                push    es
                xor     ax,ax
                mov     es,ax                   ; ES = 0



                mov     ax,es:[CTRLBRK_IRQ * 4]        ; get the vector IP
                mov     WORD PTR oldctrlbrk,ax
                mov     ax,es:[(CTRLBRK_IRQ * 4) + 2]      ; get the vector CS
                mov     WORD PTR oldctrlbrk+2,ax
;
; Now insert the new vector
;
                mov     ax,OFFSET newctrlbrk_intproc   ; store the new IP
                mov     WORD PTR es:[CTRLBRK_IRQ * 4],ax
                mov     WORD PTR es:[(CTRLBRK_IRQ * 4) + 2],cs ; store the new CS

;
; Take over CTRL C...first store the old vector
;
                mov     ax,es:[CTRLC_IRQ * 4]        ; get the vector IP
                mov     WORD PTR oldctrlc,ax
                mov     ax,es:[(CTRLC_IRQ * 4) + 2]      ; get the vector CS
                mov     WORD PTR oldctrlc+2,ax
;
; Now insert the new vector
;
                mov     ax,OFFSET newctrlc_intproc   ; store the new IP
                mov     WORD PTR es:[CTRLC_IRQ * 4],ax
                mov     WORD PTR es:[(CTRLC_IRQ * 4) + 2],cs ; store the new CS

                pop     es
                popa
                sti
                ret
setupctrlbrkirq endp

;=============================================================================
;   newctrlc_intproc       New Control C interrupt proc
;   ------------------
;
;   Parameters Passed:   none
;   Return Value:        none
;   Registers Modified:  none
;   Remarks:
;=============================================================================
newctrlc_intproc   proc    near
                pusha
                mov     ax,_DATA
                mov     ds,ax
                mov     dx,OFFSET userctrlcmsg
                call    putstring
                call    restoreirq0             ; restore IRQ0
                call    restorectrlbrkirq       ; restore control break irqs
                call    hostrestoreserialconfig ; restore serial config
                popa
                DOSINT  4ch                     ; return to DOS

newctrlc_intproc   endp

;=============================================================================
;   newctrlbrk_intproc       New Control Break interrupt proc
;   ------------------
;
;   Parameters Passed:   none
;   Return Value:        none
;   Registers Modified:  none
;   Remarks:
;=============================================================================
newctrlbrk_intproc   proc    near
                     iret
newctrlbrk_intproc   endp

;=============================================================================
;   restorectrlbrkirq   Restore Old (DOS) Control Break/Control Interrupts
;   -------------
;
;   Parameters Passed:   none
;   Return Value:        none
;   Registers Modified:  none
;   Remarks:
;=============================================================================
restorectrlbrkirq proc    near
                cli
                pusha
                push    es
;
; ...first restore the CTRL BREAK
;
                xor     ax,ax
                mov     es,ax                   ; ES = 0
                mov     ax, WORD PTR oldctrlbrk
                mov     es:[CTRLBRK_IRQ * 4],ax        ; store the vector IP
                mov     ax, WORD PTR oldctrlbrk + 2
                mov     es:[CTRLBRK_IRQ * 4 + 2],ax      ; store the vector CS
;
; then restore the CTRL C
;
                mov     ax, WORD PTR oldctrlc
                mov     es:[CTRLC_IRQ * 4],ax        ; store the vector IP
                mov     ax, WORD PTR oldctrlc + 2
                mov     es:[CTRLC_IRQ * 4 + 2],ax      ; store the vector CS
                pop     es
                popa
                sti
                ret

restorectrlbrkirq endp


;=============================================================================
;   setupirq0           Save the OLD IRQ0 and setup for new IRQ0
;   ---------
;
;   Parameters Passed:   none
;   Return Value:        none
;   Registers Modified:  none
;   Remarks:
;=============================================================================
setupirq0       proc    near
                pusha
                push    es
                cli
;
; Take over IRQ0...first store the old vector
;
                xor     ax,ax
                mov     es,ax                   ; ES = 0
                mov     ax,es:[IRQ0ADDR]        ; get the vector IP
                mov     WORD PTR cs:oldirq0,ax
                mov     ax,es:[IRQ0ADDR+2]      ; get the vector CS
                mov     WORD PTR cs:oldirq0+2,ax
;
; Now insert the new vector
;
                mov     ax,OFFSET newirq0_intproc   ; store the new IP
                mov     WORD PTR es:[IRQ0ADDR],ax
                mov     WORD PTR es:[IRQ0ADDR+2],cs ; store the new CS
;
; Setup the DOS rollover counter
;
                mov     WORD PTR dosirq0counter,0   ; clear the rollover
                                                    ; counter
;
; Setup the Default IRQ0 procedure...do nothing procedure
;
                mov     newirq0_proc,OFFSET nullproc
                mov     tick,FALSE
;
; All done..
;
                sti
                pop     es
                popa
                ret
setupirq0       endp

;=============================================================================
;   nullproc            NULL PROC....for debug only
;   --------
;
;   Parameters Passed:   none
;   Return Value:        none
;   Registers Modified:  none
;   Remarks:
;=============================================================================
;
nullproc    proc    near
            ret
nullproc    endp

;=============================================================================
;   restoreirq0        Restore the OLD IRQ0
;   -----------
;
;   Parameters Passed:   none
;   Return Value:        none
;   Registers Modified:  none
;   Remarks:
;=============================================================================
restoreirq0     proc    near
                pusha
                push    es
                cli
;
; ...first restore the old vector
;
                xor     ax,ax
                mov     es,ax                   ; ES = 0
                mov     ax, WORD PTR cs:oldirq0
                mov     es:[IRQ0ADDR],ax        ; store the vector IP
                mov     ax, WORD PTR cs:oldirq0 + 2
                mov     es:[IRQ0ADDR+2],ax      ; store the vector CS
;
; Now restore the old timer value
;
                call    restoreirq0timer        ; restore the timer for IRQ0

restoreirq0ret:
                sti
                pop     es
                popa
                ret
restoreirq0     endp

;=============================================================================
;   setupirq0timer      Setup the 8253 Timer for IRQ0 using newtimercount
;   --------------
;
;   Parameters Passed:   none
;   Return Value:        none
;   Registers Modified:  AX
;   Remarks:
;=============================================================================
setupirq0timer  proc    near
                cli
                mov     al,00110110b        ; counter 0, mode 3
                out     PCTIMERCTLREG,al    ; set the mode
                jmp     $+2
                mov     ax,newtimercount
                out     PCTIMER0,al
                jmp     $+2
                mov     al,ah
                out     PCTIMER0,al
                sti
                ret
setupirq0timer  endp

;=============================================================================
;   restoreirq0timer    Restore IRQ0 to its original PC configuration
;   ----------------
;
;   Parameters Passed:   none
;   Return Value:        none
;   Registers Modified:  none
;   Remarks:
;=============================================================================
restoreirq0timer  proc    near
                cli
                mov     al,00110110b        ; counter 0, mode 3
                out     PCTIMERCTLREG,al    ; set the mode
                jmp     $+2
                xor     ax,ax               ; timer to original value = 0
                out     PCTIMER0,al
                jmp     $+2
                mov     al,ah
                out     PCTIMER0,al
                sti
                ret
restoreirq0timer  endp


;=============================================================================
;   newirq0_intproc     Interrupt Procedure for IRQ0 when Program is running
;   ----------------
;
;   Parameters Passed:   none
;   Return Value:        none
;   Registers Modified:  none
;   Remarks:
;=============================================================================
newirq0_intproc     proc  near
                    sti
                    pusha
                    push  ds
;
; Since we could be in DOS, get OUR Data Segment
;
                    mov   ax,_DATA
                    mov   ds,ax
;
; Do the Interrupt work...
;
                    mov   tick,TRUE
;
; Do the call to the Routine inserted into the real time interrupt location
;
;                    mov   bx,OFFSET newirq0_proc
;                    call  ds:[bx]

;
; Determine if we should chain to DOS IRQ0
;
                    mov   ax,newtimercount  ; keep a running count in the..
                    add   dosirq0counter, ax ; ..dosirq0counter
                    jc    dodosirq0         ; if rollover, do the DOS IRQ0
                    jz    dodosirq0         ; also if 0...default condition
;
; Do the EOI command to the Interrupt Controller
;
endofirq0:
                    mov   ax,NSEOI
                    out   PCINTMSKREG,ax
                    pop   ds
                    popa
                    iret

;
; Chain to the DOS IRQ0 interrupt
;
dodosirq0:          test  outputmode,MULTIBIRDTIMEON
                    jz    dodosirq0now
                    inc   dostickcounter
                    jmp   endofirq0

dodosirq0now:
                    mov   ax,NSEOI        ; enable lower priority INTs..
                    out   PCINTMSKREG,ax  ; ..ie. serial INTs

                    pushf               ; emulate the pushf part of the INT
                    db    9ah           ; FAR CALL
oldirq0:            dd    0             ; Space for the CS and IP for
                                        ; ..DOS's IRQ0
                    pop   ds
                    popa
                    iret

newirq0_intproc     endp
;***************************************************************************
_TEXT               ENDS
                    END     fbbtest

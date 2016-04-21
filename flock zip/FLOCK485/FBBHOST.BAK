title   FBBHOST
subttl  Assembly FBB Host Command Routines for FBBTEST
page    50,132
;
;****************************************************************************
;****************************************************************************
;   FBBHOST.asm          FBB Host Commands
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
;   5/14/91        jf - created
;   9/17/91        jf - added posk for POSK36 and POSK72
;   10/12/91       eb - report rate deleted since stream mode not allowed
;                       on FBB
;   6/2/92         jf - added posfrmt reference                    
;   7/2/92         jf - added quaternion display
;   8/11/92        jf - added extended address mode capability
;                  jf - added data gathering capability
;   2/18/93        jf - modified the code to use 32 possibe addrs for
;                       both the extended and the normal address mode
;   3/22/93        jf - fixed bug in printing the button value
;
;          <<<< Copyright 1991 Ascension Technology Corporation >>>>
;*****************************************************************************
;*****************************************************************************
;...Misc. directives

                .286                        ; 80286 instructions
                INCLUDE asctech.inc         ; misc definitions for the Bird
                INCLUDE menudef.inc         ; menu definitions
                INCLUDE fbbser.inc          ; serial port definitions
                INCLUDE fbbtest.inc           ; test specific definitions

                PUBLIC   fbb_hostsenddata_cmd
                PUBLIC   fbb_hostsendstatus_cmd
                PUBLIC   fbb_hostsenderrcode_cmd
                PUBLIC   fbb_hostrs232_cmd
                PUBLIC   fbb_nextmaster_cmd

                PUBLIC   birdposmode
                PUBLIC   fbb_hostcmd_tbl
                PUBLIC   fbbgroupmodeflg


;
; External Menuing Routines
;
                EXTRN   sendmenu:NEAR
                EXTRN   sendmenuhdr:NEAR
                EXTRN   putstring:NEAR
                EXTRN   getstring:NEAR
                EXTRN   putchr:NEAR
                EXTRN   askyesno:NEAR
                EXTRN   displayunsigned:NEAR
                EXTRN   displaybinarybyte:NEAR
                EXTRN   hitkeycontinue:NEAR
                EXTRN   ckkeyrdy:NEAR
                EXTRN   clearkey:NEAR
                EXTRN   getchr:NEAR
                EXTRN   newline:NEAR
                EXTRN   getfloatnumber:NEAR
                EXTRN   getnumber:NEAR
                EXTRN   asciitohex:NEAR
                EXTRN   openfile:NEAR
                EXTRN   closefile:NEAR
                EXTRN   readfile:NEAR
                EXTRN   readfileline:NEAR
                EXTRN   clearscreen:NEAR
;
; External Serial Routines
;
                EXTRN   hostget_serial_record:NEAR
                EXTRN   hostget_serial_data:NEAR
                EXTRN   hostsend_serial_cmd:NEAR
                EXTRN   hostsend_serial_data:NEAR
                EXTRN   hostclear_rx:NEAR
                EXTRN   waitforchar:NEAR
;
; External Birdcmds Utilities
;
                EXTRN   printmatrix:NEAR
                EXTRN   printquaternions:NEAR
                EXTRN   converttounits:NEAR
                EXTRN   ckdoagain:NEAR

                EXTRN   get_output_mode:NEAR

;
; Bird Commands used
;
                EXTRN   bird_position:NEAR
                EXTRN   bird_angle:NEAR
                EXTRN   bird_matrix:NEAR
                EXTRN   bird_quaternions:NEAR
                EXTRN   bird_posquaternions:NEAR
                EXTRN   bird_positionangle:NEAR
                EXTRN   bird_positionmatrix:NEAR
                EXTRN   bird_anglealign:NEAR
                EXTRN   bird_hemisphere:NEAR
                EXTRN   bird_reference:NEAR
                EXTRN   bird_sleep:NEAR
                EXTRN   bird_mousebuttons:NEAR
                EXTRN   bird_changevalue:NEAR
                EXTRN   bird_examinevalue:NEAR
                EXTRN   bird_sync:NEAR

;
; External Birdcmd/Utilites
;
                EXTRN   format:WORD
                EXTRN   conv_const:WORD
                EXTRN   txdatabuf:BYTE
                EXTRN   rxdatabuf:BYTE
                EXTRN   posk:WORD
                EXTRN   posfrmt:WORD
;
; External Menuing Variables
;
                EXTRN   asciibuf:BYTE
;
; External Variables
;
                EXTRN   buttonmode:WORD
                EXTRN   buttonvalue:WORD
                EXTRN   outputmode:WORD
                EXTRN   fbb_address:BYTE
                EXTRN   fbb_startaddress:BYTE
                EXTRN   fbb_stopaddress:BYTE
                EXTRN   fbb_currentmaster:BYTE
                EXTRN   fbbaddrmask:BYTE
                EXTRN   numfbbaddresses:WORD

;
;*****************************************************************************

_DATA               SEGMENT WORD PUBLIC 'DATA'

;
; Parameter Numbers for Change/Examine Value Commands
;
RS232CMD            EQU 0   ; command 0 + DIP ADDRESS or Broadcast Address
CHANGEVALUECMD      EQU 'P' ; Change Value Cmd

FBBGROUPDATAGATHERPARANUM       EQU 35  ; Group Data Mode
FBBAUTOCONIG1XMTRNRCVRSPARAMNUM EQU 50  ; Auto Config - 1 XMTR / N RCVRs

;
; Bird Position Mode
;
birdposmode                   db   POSANGLEMODE           ; Position output mode


fbbgroupmodeflg               dw  FALSE                   ; flag for group mode
fbbnumactivedevices           dw  1                       ; number of active devices
fbb_masteraddress             db  1                       ; fbb master address

fbb_hostcmd_tbl               LABEL BYTE
fbb_hostrs232cmd              db  (0 * 32) ; cmd number 0 with 32 possible addrs
fbb_hostsenddatacmd           db  (1 * 32) ; cmd number 1 with 32 possible addrs
fbb_hostsendstatuscmd         db  (2 * 32) ; cmd number 2 with 32 possible addrs
fbb_hostsenderrcmd            db  (3 * 32) ; cmd number 3 with 32 possible addrs
fbb_hostnotused4cmd           db  0        ; not used
fbb_hostnotused5cmd           db  0
fbb_hostnotused6cmd           db  0
fbb_hostnotused7cmd           db  0

;
; Receive Buffer
;
hostrxbuf           db   (30 * 26) DUP (0) ; 30 devices with button info
                                           ; ..in group mode w/posmatrix data

;
; Messages
;
senddatamsg         db   CR,LF,'SEND DATA command sent..',CR,LF,'$'
sendstatusmsg       db   CR,LF,'SEND STATUS command sent..',CR,LF,'$'
senderrcodemsg      db   CR,LF,'SEND ERROR CODE command sent..',CR,LF,'$'
displaystatusmsg    db   CR,LF,'[MSTRBIRD INIT ERR RUN HOSTSYNC FBBSYNC EXTSYNC NOSYNC] => ','$'
displayerrcodemsg   db   CR,LF,'ERROR CODE => ','$'
autosetcompletemsg  db   CR,LF,'System configured for 1 XMTR/N RCVRs..',CR,LF,'$'
ask1xmtrnrcvrques   db   CR,LF,'Enter the number of Units (ERCs and 6DFOBs) in the Flock: ','$'
asknextmasterques   db   CR,LF,'Enter the Next Master Address: ','$'
nextmastercompletemsg db CR,LF,'Next Master Command Sent..',CR,LF,'$'
groupmodeques       db   CR,LF,'Do you want to enable Group Data Mode','$'
groupdatacompletemsg  db CR,LF,'Group Mode Information Sent..',CR,LF,'$'
masteraddrmsg       db   CR,LF,LF,'Current Master Address is ','$'
masteraddrques      db   CR,LF,'Enter the Master Address: ','$'

;
; Error Messages
;
senddataerrmsg      db   CR,LF,'** ERROR ** could not send the SEND DATA command',CR,LF,'$'
sendstatuserrmsg    db   CR,LF,'** ERROR ** could not send the SEND STATUS command',CR,LF,'$'
senderrcodeerrmsg   db   CR,LF,'** ERROR ** could not send the SEND ERROR CODE command',CR,LF,'$'
getstatuserrmsg     db   CR,LF,'** ERROR ** could not get the SEND STATUS response',CR,LF,'$'
geterrcodeerrmsg    db   CR,LF,'** ERROR ** could not get the SEND ERROR CODE response',CR,LF,'$'
nextmastererrmsg    db   CR,LF,'** ERROR ** could not get the NEXT MASTER command',CR,LF,'$'
illegalposmodeerrmsg db  CR,LF,'** RUN TIME ERROR ** illegal Position Mode value',CR,LF,'$'
illegalfbbmastererrmsg db CR,LF,'** ERROR ** illegal FBB Master Number',CR,LF,'$'
illegalentrymsg     db   CR,LF,'** ERROR ** illegal value, please try again','$'

;
; Flags
;
rs232exitflag        db  FALSE                   ; if TRUE, program exits

;
; Error Messages
;
autoseterrmsg        db   '** ERROR ** could not send AUTO CONFIG to the system',CR,LF,'$'
groupdataerrmsg      db   '** ERROR ** could not send Group Data Mode to the system',CR,LF,'$'
;
; Main Menu
;
mainmenuhdr     db  '****************************************************************************',CR,LF
                    db  '* ASCENSION TECHNOLOGY CORPORATION - FBBTEST \ FBBHOST \ RS232 COMMANDS    *',CR,LF
                    db  '****************************************************************************',CR,LF,'$'
mainmenu        dw  mainmenuprompt,mainmenu0,mainmenu1,mainmenu2,mainmenu3
                dw  mainmenu4,mainmenu5,mainmenu6,mainmenu7,mainmenu8
                dw  mainmenu9,mainmenu10,mainmenu11,mainmenu12,mainmenu13
                dw  mainmenu14,mainmenu15,mainmenu16,mainmenu17,mainmenu18
mainmenuprompt  db  'Menu Selections:','$'
mainmenu0       db  'FBB Host Main Menu','$'
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
mainmenu11      db  'Sleep/Wakeup','$'
mainmenu12      db  'Mouse Buttons','$'
mainmenu13      db  'Change Values','$'
mainmenu14      db  'Examine Values','$'
mainmenu15      db  'Synchronization','$'
mainmenu16      db  'Next Master Command','$'
mainmenu17      db  'Next Transmitter Command','$'
mainmenu18      db  'System Tests','$'
SIZERS232MENU   EQU 19

;
; Jump Table for the Main Menu Selections
;
mainmenusubs    dw  quitsel
                dw  bird_position
                dw  bird_angle
                dw  bird_matrix
                dw  bird_quaternions
                dw  bird_positionangle
                dw  bird_positionmatrix
                dw  bird_posquaternions
                dw  bird_anglealign
                dw  bird_hemisphere
                dw  bird_reference
                dw  bird_sleep
                dw  bird_mousebuttons
                dw  bird_changevalue
                dw  bird_examinevalue
                dw  bird_sync
                dw  fbb_nextmaster_cmd
                dw  nextxmtrcmd
                dw  systemtests

;
; Bird Commands
;
RS232CMDCHAR        EQU 0   ; command 0 + DIP ADDRESS or Broadcast Address
nextmastercmdchar   db   RS232CMDCHAR,' '   ; for nextmaster command
nextxmtrcmdchar     db   RS232CMDCHAR,'0 '  ; for nextxmtr command

;
; Next Transmitter Questions
;
nextxmtrques1   db  CR,LF,'Enter the Next Transmitter Address (1 - 14): ','$'
nextxmtrques2   db  CR,LF,'Enter the Next Transmitter Number (0 - 3): ','$'
nextxmtrmsg     db  CR,LF,'Next Transmitter Command Sent..','$'

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
hostreadmsg2    db  CR,LF,LF,'Bird Output: ','$'
hostreadblockmsg1 db CR,LF,'Hit any key to Read Block, <ESC> to End the Test',CR,LF,'$'

_DATA               ENDS

;*****************************************************************************

;*****************************************************************************

_TEXT           SEGMENT WORD PUBLIC 'CODE'
                ASSUME  cs:_TEXT,ds:_DATA


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
                cmp     dx,1
                jl      illegalnextxmtr1
                cmp     dx,14
                jg      illegalnextxmtr1
;
; DX contains the address 1 - 14
; ..store it in the Most Significant nibble of the command data
;
                mov     cl,4
                shl     dl,cl
                mov     nextxmtrcmdchar+2,dl ; store the char for output
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
                or      nextxmtrcmdchar+2,dl
;
; Send the commnand
;
                mov     cx,3                ; 3 character in cmd
                mov     bx,OFFSET nextxmtrcmdchar  ; get cmd
                mov     al,fbb_address
                mov     dl,fbbaddrmask      ; set the address mask
                and     BYTE PTR [bx],dl    ; clear the address
                or      [bx],al             ; set the address info
                call    hostsend_serial_cmd ; send the bird the cmd
                cmp     ax,3                ; did cmd go out OK?
                je      nextxmtrcmdtrueret  ; if ok, continue
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
                mov     dx, OFFSET illegalentrymsg
                call    putstring
                jmp     nextxmtrcmd
;
; Indicate the Illegal Number condition
;
illegalnextxmtr2:
                mov     dx, OFFSET illegalentrymsg
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
                call    hostclear_rx            ; clear input buffer
waitforbirdoutput:
                call    ckkeyrdy
                cmp     ax,TRUE
                je      birdoutputret       ; continue until keyhit

;
; Get the 4 chars from the BIRD and display them
;
                mov     cx,4
                mov     bx,OFFSET testbuf
                call    hostget_serial_data
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
birdoutputerr:  mov     ax,FALSE
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
                call    hostsend_serial_data    ; send the character
                cmp     ax,1
                jne     birdechoerr
;
; Now wait for the echoed character
;
                mov     cx,1
                mov     bx,OFFSET testbuf
                call    hostget_serial_data
                cmp     ax,TRUE             ; check that we got 4 chars
                jne     birdechoerr
;
; Display the character read back from the Bird
;
                mov     al,testbuf
                call    putchr
                jmp     waitforechoinput

;
; Inform user of an Error
;
birdechoerr:
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
                call    hostsend_serial_data    ; send the character
                cmp     ax,1
                jne     hostreaderr

;
; Now wait for the Output char
;
                mov     cx,1
                mov     bx,OFFSET testbuf
                call    hostget_serial_data
                cmp     ax,TRUE             ; check that we got 1 chars
                jne     hostreaderr
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
; Inform user of an Error if we could not read the block
;
hostreaderr:
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
                call    hostsend_serial_data    ; send the character
                cmp     ax,1
                jne     hostreadblockerr

;
; Now wait for the Output block
;
                mov     cx,256
                mov     bx,OFFSET testbuf
                call    hostget_serial_data
                cmp     ax,TRUE             ; check that we got 256 chars
                jne     hostreadblockerr
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
; Inform user of an Error
;
hostreadblockerr:
                mov     ax,FALSE            ; return with the FALSE condition
                ret

hostreadblockret:
                mov     ax,TRUE
                ret

hostreadblocktest  endp

;=============================================================================
;   fbb_nextmaster_cmd  FBB Next Master Command
;   ------------------
;
;   Parameters Passed:  none
;   Return Value:       in AX, TRUE if configured OK
;   Registers Modified: AX
;   Remarks:            Birds Must be at addresses 1 through 14
;                       .. the FBB Next Master command is a 1 byte command,
;                       where, the FBB address is in the most significant
;                       nibble, and the least significant nibble is a 0.
;                       (ie. command 40h, next master is the Bird at addr 4)
;
;=============================================================================
;
fbb_nextmaster_cmd  proc    near
                pusha
;
; Ask the User how many Birds in the Flock
;
                mov     dx,OFFSET asknextmasterques
                call    putstring
                call    getnumber
                cmp     ax,ESC_SEL
                jne     sendnextmaster1
                popa
                ret
;
; Send the Next Master Command
;
sendnextmaster1:
                mov     bx,OFFSET txdatabuf         ; get the data buf
                mov     fbb_currentmaster,dl        ; store for future use
                rol     dl,4                        ; get the address in
                                                    ; ..the MS nibble of DL
                mov     BYTE PTR[bx],dl
                mov     cx,1                ; setup for 1 bytes
                call    hostsend_serial_cmd ; off she goes
                cmp     ax,1                ; ck if command went out OK
                jne     nextmastererr
;
; Tell the User we've sent the command
;
                mov     dx,OFFSET nextmastercompletemsg
                call    putstring
                jmp     nextmasterret

nextmastererr:
                mov     dx,OFFSET nextmastererrmsg
                call    putstring
nextmasterret:
                call    hitkeycontinue
                popa
                mov     ax,TRUE
                ret

fbb_nextmaster_cmd endp

;=============================================================================
;    fbb_hostsenddata_cmd     FBB Send Position Data Command
;   ----------------
;
;   Parameters Passed:   none
;   Return Value:
;   Registers Modified:
;   Remarks:
;=============================================================================
;
fbb_hostsenddata_cmd        proc   NEAR
IFDEF FACTORYTEST
                test    outputmode,MULTIBIRDTIMEON
                jnz     dosenddatacmd
ENDIF
;
; Get the Output Mode
;
                call    get_output_mode
                cmp     ax,0
                jg      doclearscreen
                ret
doclearscreen:
                call    clearscreen
;
; Or in the DIP address
;
dosenddatacmd:
                mov     al,fbb_hostsenddatacmd
                and     al,fbbaddrmask
;
; Trap the Case of Group Mode because the command must go to the Master
;
                cmp     fbbgroupmodeflg,TRUE
                jne     setfbbaddress
                or      al,fbb_masteraddress
                jmp     setfbbdatacmd
setfbbaddress:
                or      al,fbb_address
setfbbdatacmd:
                mov     fbb_hostsenddatacmd,al
;
; Send the Command
;
                mov     bx,OFFSET fbb_hostsenddatacmd
                mov     cx,1
                call    hostsend_serial_cmd
                cmp     ax,1
                jne     fbbsenddataerr
;
; Check if we should skip the Response of Data
;
                test    outputmode,SKIPRECEIVE
                jnz     ckdofbbsenddata

;
; Check if we are in the group data gather mode
;
                mov     cx,1                  ; assume 1 device
                cmp     fbbgroupmodeflg,TRUE
                jne     togetposdata
;
; Display Address info for the Group Mode
;
setupgroupaddr:
                mov     cl,fbb_stopaddress     ; determine number of devices
                sub     cl,fbb_startaddress    ; ..to display
                inc     cl
                xor     ch,ch
;
; Get the Data..note that getpositiondata knows how many bytes to get
; ..using the variable birdposmode
;
togetposdata:
                mov     si,OFFSET hostrxbuf
togetposdata1:  push    cx
                call    getpositiondata
                cmp     ax,TRUE
                je      getnextrecord
                pop     cx
                ret                           ; return if we could not read data
;
; If in Group Mode then get data from all the birds before display
;
getnextrecord:  add     si,di
                pop     cx
                loop    togetposdata1

;
; Display the Data..displayposdata will return ASAP if outputmode
; does not have the DISPLAYON bit set
;
                mov     si,OFFSET hostrxbuf  ; reset the pointer
                mov     cx,1
                cmp     fbbgroupmodeflg,TRUE
                jne     todisplayposdata
                mov     cl,fbb_stopaddress     ; determine number of devices
                sub     cl,fbb_startaddress    ; ..to display
                inc     cl
                xor     ch,ch
                call    setupdatacursor        ; clear display
todisplayposdata:
                push    cx
                push    si
                call    displayposdata
                pop     si
                pop     cx
                add     si,di                ; point to the next record
                loop    todisplayposdata
;
; Do the Loop Again?
;
ckdofbbsenddata:
                call    ckdoagain
                cmp     ax,TRUE
                jne     fbbsenddataret
                jmp     dosenddatacmd

;
; Display an Error Message
;
fbbsenddataerr:
                mov     dx,OFFSET senddataerrmsg
                call    putstring
                call    hitkeycontinue
                mov     ax,FALSE
                ret
;
; All done...so Display a Message and return
;
fbbsenddataret:
                mov     dx,OFFSET senddatamsg
                call    putstring
                call    hitkeycontinue
                mov     ax,TRUE
                ret

fbb_hostsenddata_cmd        endp

;=============================================================================
;   fbb_hostsendstatus_cmd    Send FBB Status Command
;   ------------------
;
;   Parameters Passed:   (global) outputmode
;   Return Value:        in AX, TRUE if OK, FALSE otherwise
;   Registers Modified:
;   Remarks:
;=============================================================================
;
fbb_hostsendstatus_cmd      proc   NEAR
;
; Get the Output Mode
;
                call    get_output_mode
                cmp     ax,0
                jg      dosendstatuscmd
                ret
;
; Or in the DIP address
;
dosendstatuscmd:
                mov     al,fbb_hostsendstatuscmd
                and     al,fbbaddrmask
                or      al,fbb_address
                mov     fbb_hostsendstatuscmd,al

;
; Send the Command
;
                    mov       bx,OFFSET fbb_hostsendstatuscmd
                    mov       cx,1
                    call      hostsend_serial_cmd
                    cmp       ax,1
                    jne       fbbsendstatuserr
;
; Check if we should skip the Response of Data
;
                test    outputmode,SKIPRECEIVE
                jnz     ckdosendstatuscont
;
; Get the Data..
;
                    mov       cx,1                     ; setup for 1 char
                    mov       bx,OFFSET hostrxbuf      ; ..into hostrxbuf
                    call      hostget_serial_data      ; get the one byte response
                    cmp       ax,TRUE                       ; ck if OK
                    jne       fbbgetstatuserr
;
; If DISPLAYON then Display the DATA
;
                    test      outputmode,DISPLAYON
                    jz        ckdosendstatuscont
;
; Display the Status Byte..
;
                    mov       dx,OFFSET displaystatusmsg
                    call      putstring
                    mov       al,[bx]                       ; BX still points to hostrxbuf
                    call      displaybinarybyte
;
; Check if we should do it again
;
ckdosendstatuscont:
                call    ckdoagain
                cmp     ax,TRUE
                je      dosendstatuscmd
                jmp     fbbsendstatusret
;
; Error has occured...so display the SEND Error Message
;
fbbsendstatuserr:
                    mov       dx,OFFSET sendstatuserrmsg
                    call      putstring
                    call      hitkeycontinue
                    mov       ax,FALSE
                    ret

;
; Error has occured...so display the GET Error Message
;
fbbgetstatuserr:
                    mov       dx,OFFSET getstatuserrmsg
                    call      putstring
                    call      hitkeycontinue
                    mov       ax,FALSE
                    ret
;
; All done...so Display a Message and return
;
fbbsendstatusret:
                    mov       dx,OFFSET sendstatusmsg
                    call      putstring
                    call      hitkeycontinue
                    mov       ax,TRUE
                    ret
fbb_hostsendstatus_cmd      endp

;=============================================================================
;   fbb_hostsenderrcode_cmd Send the Error Code Command
;   ----------------
;
;   Parameters Passed:  (global) outputmode
;   Return Value:       in AX, TRUE if successful, FALSE otherwise
;   Registers Modified: AX
;   Remarks:
;=============================================================================
;
fbb_hostsenderrcode_cmd     proc   NEAR
;
; Get the Output Mode
;
                call    get_output_mode
                cmp     ax,0
                jg      dosenderrorcmd
                ret
;
; Or in the DIP address
;
dosenderrorcmd:
                mov     al,fbb_hostsenderrcmd
                and     al,fbbaddrmask
                or      al,fbb_address
                mov     fbb_hostsenderrcmd,al

;
; Send the Command
;
                    mov       bx,OFFSET fbb_hostsenderrcmd
                    mov       cx,1
                    call hostsend_serial_cmd
                    cmp       ax,1
                    jne       fbbsendstatuserr
;
; Check if we should skip the Response of Data
;
                test    outputmode,SKIPRECEIVE
                jnz     ckdosenderrcodecont
;
; Get the Data..
;
                    mov       cx,1                     ; setup for 1 char
                    mov       bx,OFFSET hostrxbuf      ; ..into hostrxbuf
                    call hostget_serial_data      ; get the one byte response
                    cmp       ax,TRUE                       ; ck if OK
                    jne       fbbgeterrcodeerr
;
; If DISPLAYON then Display the DATA
;
                    test outputmode,DISPLAYON
                    jz        ckdosenderrcodecont
;
; Display the Status Byte..
;
                    mov       dx,OFFSET displayerrcodemsg
                    call putstring
                mov      al,[bx]                       ; BX still points to hostrxbuf
                    call displaybinarybyte
;
; Check if we should do it again
;
ckdosenderrcodecont:
                call    ckdoagain
                cmp     ax,TRUE
                je      dosenderrorcmd
                jmp     fbbsenderrcoderet
;
; Error has occured...so display the SEND Error Message
;
fbbsenderrcodeerr:
                    mov       dx,OFFSET senderrcodeerrmsg
                    call putstring
                    call hitkeycontinue
                    mov       ax,FALSE
                    ret

;
; Error has occured...so display the GET Error Message
;
fbbgeterrcodeerr:
                    mov       dx,OFFSET geterrcodeerrmsg
                    call putstring
                    call hitkeycontinue
                    mov       ax,FALSE
                    ret
;
; All done...so Display a Message and return
;
fbbsenderrcoderet:
                    mov       dx,OFFSET senderrcodemsg
                    call putstring
                    call hitkeycontinue
                    mov       ax,TRUE
                    ret

fbb_hostsenderrcode_cmd     endp

;=============================================================================
;   fbb_hostrs232_cmd
;   -----------------
;
;   Parameters Passed:      none
;   Return Value:           none
;   Registers Modified:     AX,BX,CX,DX
;   Remarks:                the procedure calls the main menu for the
;                           RS232 Bird Commands
;=============================================================================
;
fbb_hostrs232_cmd           proc   NEAR
;
; Put up the Main Menu
;
                mov     rs232exitflag,FALSE      ; reset the exit flag
asmbirdmenu:
                call    hostclear_rx
;
; Send the Main Menu
;
                mov     dx, OFFSET mainmenuhdr  ; get screen header
                call    sendmenuhdr             ; send header to screen
                mov     cx, SIZERS232MENU       ; number of main menu entries
                mov     dx, OFFSET mainmenu     ; get main menu
                call    sendmenu                ; put up main menu
                cmp     ax,ESC_SEL              ; see if the use hit ESC
                jg      domenucmd               ; if not continue
                jmp     asmbirdexit
domenucmd:      shl     ax,1                    ; multilply by 2 for words
                mov     bx, OFFSET mainmenusubs ; get code address
                add     bx,ax                   ; add ax to bx
                call    [bx]                    ; call the roution
;
; See if we are ready to quit
;
ckexitflag:     cmp     rs232exitflag,TRUE      ; ck exitflag
                je      asmbirdexit             ; yep..it is set so quit
                jmp     asmbirdmenu             ; nope...continue
asmbirdexit:
                ret

fbb_hostrs232_cmd           endp
;
; If the User hit quit, ask confirmation question
;
quitsel         proc    near
                mov     rs232exitflag,TRUE
quitselexit:    ret
quitsel         endp


;=============================================================================
;    getpositiondata
;   ----------------
;
;   Parameters Passed:   (global) birdposmode
;                       si, location to store the data
;   Return Value:       in AX, TRUE if data is in the Buffer
;                       si, number of bytes received
;   Registers Modified:
;   Remarks:
;=============================================================================
;
; Define a table of the number of characters to receive as a function of
; birdposmode
;
posmodechrs_tbl         db 6        ; position
                        db 6        ; angles
                        db 12       ; pos and angles
                        db 18       ; matrix
                        db 24       ; pos and matrix
                        db 8        ; quaternion
                        db 14       ; pos and quaternion
;
getpositiondata proc    NEAR

                push    bx
                push    cx
;
; Check output mode to determine the number of bytes to receive
;
                mov     bl,birdposmode  ; get the mode
                xor     bh,bh           ; zero high byte
                mov     cl,cs:posmodechrs_tbl[bx]   ; get the # of chars
                xor     ch,ch           ; ... fill CX with the value
;
; Get the Serial Data
;
togetserialdata:
                mov     bx,si
                add     cx,buttonmode        ; add 1 if button byte appended
                cmp     fbbgroupmodeflg,TRUE
                jne     setcharbufptr
                inc     cx                   ; get an extra char if in
                                             ; group mode
                mov     di,cx
setcharbufptr:
                    call      hostget_serial_data  ; get the serial data
                    cmp       ax,TRUE
                    je        convertbirddata
                    jmp       getposdataret        ; return false
;
; go though the birddata and make into two's complemented
;   16 bit integers by:
;       - shifting the least sig byte 1 position
;       - shifting the complete word 1 position
;
convertbirddata:
                    shr     cx,1                ; divide by 2 for words
convertloop:        mov     ax,[bx]             ; get the complete word
                    shl     al,1                ; shift lsb 1
                    shl     ax,1                ; shift whole word 1
                    mov     [bx],ax             ; store the converted word
                    inc     bx                  ; point to next word
                    inc     bx
                    loop    convertloop         ; do for CX number of words
                    mov     ax,[bx]
                    mov     buttonvalue,ax      ; store the buttonvalue
                    mov     ax,TRUE             ; return TRUE
getposdataret:
                    pop     cx
                    pop     bx
                    ret                         ; return value in AX

getpositiondata        endp

;=============================================================================
;    displayposdata
;   ----------------
;
;   Parameters Passed:   (global) birdposmode
;                        si, address of data to display
;
;   Return Value:        none
;   Registers Modified:
;   Remarks:
;=============================================================================
;
;
; Define a Table of how to dsiplay as a function of birdposmode
;
displaymode_tbl dw      displayposmode              ; mode 0
                dw      displayanglemode            ; mode 1
                dw      displayposanglemode         ; mode 2
                dw      displaymatrixmode           ; mode 3
                dw      displayposmatrixmode        ; mode 4
                dw      displayquaternionmode       ; mode 5
                dw      displayposquaternionmode    ; mode 6

displayposdata  proc    NEAR
                push    di
                test    outputmode,DISPLAYON
                jz      nexttestaddress

                cmp     fbbgroupmodeflg,TRUE
                je      startdisplay

;
; set the cursur position to row 1, column 1 using the INT 10  function 2
;
                mov     al,fbb_address
                cmp     al,fbb_startaddress
                jne     displayaddress
                call    setupdatacursor

displayaddress:
                xor     ah,ah
                mov     al,fbb_address
                push    si
                call    displayunsigned    ; display the address
                mov     al,TAB
                call    putchr
                pop     si
;
; Debug Code to Increment the address startaddress through stopaddress
;
nexttestaddress:
                inc     fbb_address
                mov     al,fbb_stopaddress
                cmp     fbb_address,al
                jle     setaddress
                mov     al,fbb_startaddress
                mov     fbb_address,al
setaddress:
                test    outputmode,DISPLAYON
                jnz     startdisplay
                jmp     displayposret

;
; Setup to get data out of the buffer
;
startdisplay:
                mov     bx,si
;
; Check birdposmode mode to how to Display the Data
;
                mov     al,birdposmode
                xor     ah,ah           ; get the display into AX
                mov     si,OFFSET displaymode_tbl ; get the lookup table
                shl     ax,1                      ; adjust for word table
                add     si,ax                     ; find out which to display
                jmp     cs:[si]                   ; do the display work
;
; Position Mode
;
displayposmode:
                mov     cx,3                ; due 3 words
                mov     ax,posfrmt
                mov     format,ax           ; set up decimal point for position
                mov     ax,posk
                mov     conv_const,ax       ; set up conversion constant
                call    converttounits      ; convert and display
                jmp     displayposret
;
; Angle Mode
;
displayanglemode:
                mov     cx,3                ; due 3 words
                mov     format,ANGFORMAT    ; set up decimal point for angle
                mov     conv_const,ANGK     ; set up conversion constant
                call    converttounits      ; convert and display
                jmp     displayposret

;
; Position and Angle Mode
;
displayposanglemode:
;
; Print the Position
;
                mov     cx,3                ; due 3 words
                mov     ax,posfrmt
                mov     format,ax           ; set up decimal point for position
                mov     ax,posk
                mov     conv_const,ax       ; set up conversion constant
                call    converttounits      ; convert and display
;
; then print the angle
;
                mov     cx,3                ; due 3 words
                mov     format,ANGFORMAT    ; set up decimal point for angle
                mov     conv_const,ANGK     ; set up conversion constant
                call    converttounits      ; convert and display
                jmp     displayposret
;
; Matrix Mode
;
displaymatrixmode:
;
; Convert the Matrix data to Units and print
;
                mov     si,3                ; setup 3 rows of 3 times
nextrow1:       mov     cx,3                ; 3 numbers for convertounits
                cmp     si,3
                je      firstrow
                mov     al,TAB
                call    putchr
firstrow:
                mov     format,MATRIXFORMAT ; set up decimal point for matrix
                mov     conv_const,MATK     ; set up conversion constant
                call    converttounits      ; convert and display, BX and CX
                                            ; still set, BX increments for
                                            ; every piece of data converted
                dec     si
                cmp     si,0                ; see if on the last row
                je      displayposret       ; if not, do the next row
                call    newline             ; else, send a newline
                jmp     nextrow1

;
; Pos and Matrix Mode
;
displayposmatrixmode:
;
; Print the Position
;
                mov     cx,3                ; due 3 words
                mov     ax,posfrmt
                mov     format,ax           ; set up decimal point for position
                mov     ax,posk
                mov     conv_const,ax       ; set up conversion constant
                call    converttounits      ; convert and display
                call    newline
;
; Convert the Matrix data to Units and print
;
                mov     si,3                ; setup 3 rows of 3 times
nextrow2:       mov     cx,3                ; 3 numbers for convertounits
                mov     al,TAB
                call    putchr
                mov     format,MATRIXFORMAT ; set up decimal point for matrix
                mov     conv_const,MATK     ; set up conversion constant
                call    converttounits      ; convert and display, BX and CX
                                            ; still set, BX increments for
                                            ; every piece of data converted
                dec     si
                cmp     si,0                ; see if on the last row
                je      displayposret       ; if not, do the next row
                call    newline             ; else, send a newline
                jmp     nextrow2            ; continue to the next row

;
; Display Quaternion Mode
;
displayquaternionmode:
                call    printquaternions    ; print the quaternions
                jmp     displayposret
;
; Display Position and Quaternion Mode
;
displayposquaternionmode:
;
; Print the Position
;
                mov     cx,3                ; due 3 words
                mov     ax,posfrmt
                mov     format,ax           ; set up decimal point for position
                mov     ax,posk
                mov     conv_const,ax       ; set up conversion constant
                call    converttounits      ; convert and display
;
; print the Quaternions
;
                call    printquaternions    ; print the quaternions
                jmp     displayposret

;
; Return from the Display routine
;
displayposret:
                test    outputmode,DISPLAYON
                jz      displayposret2
;
; Display button value if in button mode
;
ckbuttonmode1:  cmp     buttonmode,0        ; ck if in Button Mode
                je      ckgroupmode         ; if not..move on

                mov     al,TAB              ; else, send at TAB
                call    putchr              ; .. to the console
                mov     al,SPACE            ; clear out last button value
                call    putchr              ; .. to the console
                mov     al,SPACE            ; 
                call    putchr              ;
                mov     al,SPACE            ;
                call    putchr              ;
                mov     al,BS               ; Backspace to overwrite
                call    putchr              ; .. to the console
                mov     al,BS               ;
                call    putchr              ;
                mov     al,BS               ;
                call    putchr              ;
                mov     ax,buttonvalue      ; get the buttonvalue
                call    displayunsigned     ; display the button value

ckgroupmode:
                cmp     fbbgroupmodeflg,TRUE
                jne     displayposret1
;
; Display Addresss information in Group Mode
;
                mov     al,TAB              ; display a TAB
                call    putchr
                mov     al,[bx]             ; get the address information
                call    displayunsigned     ; display the address

displayposret1:
                call    newline
displayposret2:
                pop     di
                ret
displayposdata  endp


;
; SETUP the Cursor to the Top Left of the CRT using the BIOS
;
setupdatacursor proc near
                pusha
                mov     ah,2
                mov     bh, 0
                mov     dh,1 
                mov     dl,0
                int     10h         ; set the cursor to top left of CRT
                popa
                ret
setupdatacursor endp

_TEXT               ENDS
;*****************************************************************************
                    END
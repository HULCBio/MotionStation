title   BIRD COMMANDS FOR FOBSOFT\ASM\ABIRD
subttl  Assembly Bird Commands for ABIRD
page    50,132

;****************************************************************************
;****************************************************************************
;   BIRDCMDS        Bird Commands 
;
;                   Ascension Technology Corporation
;                   PO Box 527
;                   Burlington, Vermont  05402
;                   802-655-7879
;
;   written by:     Jeff Finkelstein
;
;   Modification History:
;         10/18/90   jf - released
;         10/24/90   jf - misc mods..fixed birdalign bug, refer frame bug
;                         added 'hitkeycontinue' to ends of test
;         11/11/90   jf - add new commands, bird_xonxoff, bird_changevalue
;                         bird_examinevalue
;         11/12/90   jf - added bird_crtsync
;         11/29/90   jf - added 'Hit 'B' Key... to checkdone
;         11/30/90   jf - fixed sinangle lookup for Q2,Q3 accesses
;                         fixed rate display in bird_crtsync to be crystal
;                         dependent...does the math with crystalfreq
;         2/4/91     jf - added code to display button values
;                         modified filter names for AC Wide/Narrow filters
;                         sinslopetbl[62] modified to prevent overflow
;         2/20/91    jf - added initialization of factory test mode to
;                         birdloadconfig
;         3/16/91    jf - added new command CRT sync for Fast Vertical Retrace
;         4/3/91     jf - fixed bug in birdexaminevalue command to display
;                         filter on/off status properly
;         5/10/91    eb - printmatrix modified to provide blank lines between 
;                         printouts
;         5/20/91    jf - fixed row/col order in printmatrix
;         6/17/91    jf - fixed chg measurement rate bug
;         9/17/91    jf - added posk global for POSK36 and POSK72
;         10/7/91    jf - removed revision specific addresses
;         10/10/91   jf - put utility routines in CMDUTIL.asm
;                         examine data ready character would not give correct
;                         results if command preceeded by examine measurement rate
;                         or examine alpha_min.
;                         Prompt for change data ready character was not displayed
;         11/1/91    jf - added exm/chg alpha max and glitchchecking
;         11/7/91    jf - added exm model
;         11/10/91   jf - changed 'glitch checking' to 'sudden output change'
;         11/18/91   jf - changed max CRT sync to 72 Hz
;         3/23/92    jf - updated alpha min/max to be tables
;         4/7/92     jf - modified exm/chg ERROR MASK user input and output
;                    jf - added posformat variable for ER Controller
;         4/22/92    mo - added functions quaternions and posquaternions
;         6/1/92     jf - updated examine value to reflect new status
;                         definitions 
;         6/9/92     jf - removed save config from examine and change value
;                    jf - added extended error code to examine value
;         3/6/93     jf - Sync frequency is now divided by 2
;         3/9/93     jf - 286 instructions are enabled
;         3/9/93     jf - Updated for rev 3.41 and 4.22 ROMs
;         5/18/94    sw - added XYZ REFENENCE FRAME, Change value command 
;                         and Examine Value command
;         9/28/94    sw - decoded all of the 16 bits in BIRD SYSTEM STATUS
;
;          <<<< Copyright 1990 Ascension Technology Corporation >>>>
;*****************************************************************************
;*****************************************************************************
		INCLUDE menudef.inc             ; get menu definitions
		INCLUDE asctech.inc             ; Ascension Technology definitions
		INCLUDE serial.inc              ; serial definitions
		.286                            ; 286 instructions allowed
;
; Public Symbols
;
		PUBLIC  bird_position
		PUBLIC  bird_angle
		PUBLIC  bird_matrix
		PUBLIC  bird_quaternions
		PUBLIC  bird_positionangle
		PUBLIC  bird_positionmatrix
		PUBLIC  bird_posquaternions
		PUBLIC  bird_anglealign
		PUBLIC  bird_hemisphere
		PUBLIC  bird_reference
		PUBLIC  bird_reportrate
		PUBLIC  bird_sleep
		PUBLIC  bird_mousebuttons
		PUBLIC  bird_xonxoff
		PUBLIC  bird_changevalue
		PUBLIC  bird_examinevalue
		PUBLIC  bird_crtsync
;
; Public Variables
;
		PUBLIC  rxdatabuf
		PUBLIC  txdatabuf
		PUBLIC  temptxbuf
		PUBLIC  birdstreamcmd
		PUBLIC  birdpointcmd
		PUBLIC  birdexmvaluecmd
;
; External Birdcmd Utility Routines
;
		EXTRN   read_bird_data:NEAR
		EXTRN   check_done:NEAR
		EXTRN   converttounits:NEAR
		EXTRN   convert:NEAR
		EXTRN   printmatrix:NEAR
		EXTRN   printquaternions:NEAR
		EXTRN   getcrystalfreq:NEAR
		EXTRN   getangle:NEAR
		EXTRN   getaddrmode:NEAR
;
; External Menuing Routines
;
		EXTRN   sendmenu:NEAR
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
;
; External Serial Routines
;
		EXTRN   get_serial_record:NEAR
		EXTRN   get_serial_data:NEAR
		EXTRN   send_serial_cmd:NEAR
		EXTRN   waitforchar:NEAR
		EXTRN   clear_rx:NEAR
;
; External Command Utility Variables
;
		EXTRN   format:WORD
		EXTRN   anglecmd:WORD
		EXTRN   conv_const:WORD
		EXTRN   crystalfreq:WORD
		EXTRN   posk:WORD
		EXTRN   posfrmt:WORD
;
; External Menuing Variables
;
		EXTRN   asciibuf:BYTE
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
;
;*****************************************************************************

_DATA               SEGMENT WORD PUBLIC 'DATA'

;
; Storage for Serial Data to and from the Bird
;
rxdatabuf           db 40 dup (?)           ; storage for the received datas
txdatabuf           db 40 dup (?)           ; storage for Bird cmd strings
temptxbuf           db 40 dup (?)           ; temporary tx data storage


;
; FBB Configuration Structure
;
fbbconfigmode       db  0                   ;
fbbdevices          dw  0                   ; bitwise active devices
fbbdependents       dw  0                   ; bitwise dependent devices
extfbbdevices       dw  0                   ; bitwise active extended devices

fbbsyncmode         db  0                   ;
expaddrmodeflg      db  FALSE               ;

fbbgroupmodeflg     dw  FALSE

;
; Commands to the Bird
;
birdstreamcmd       db  '@'                 ; Stream
birdcrtsynccmd      db  'A'                 ; CRT Sync
birdpointcmd        db  'B'                 ; Point
birdloadconfigcmd   db  'C'                 ; Load Configuration File
birdwakeupcmd       db  'F'                 ; Wakeup
birdsleepcmd        db  'G'                 ; Sleep
birdrefframecmd     db  'H'                 ; Reference Frame
birdanglealigncmd   db  'J'                 ; Angle Align
birdhemispherecmd   db  'L'                 ; Hemisphere
birdbuttonmodecmd   db  'M'                 ; Button Mode
birdbuttonreadcmd   db  'N'                 ; Button Read
birdexmvaluecmd     db  'O'                 ; Examine Value
birdchgvaluecmd     db  'P'                 ; Change Value
birdrate1           db  'Q'                 ; Max Rate
birdrate2           db  'R'                 ; Max Rate/2
birdrate8           db  'S'                 ; Max Rate/8
birdrate32          db  'T'                 ; Max Rate/32
birdposcmd          db  'V'                 ; Position
birdanglecmd        db  'W'                 ; Angles
birdmatrixcmd       db  'X'                 ; Matrix
birdposanglecmd     db  'Y'                 ; Position/Angle
birdposmatrixcmd    db  'Z'                 ; Position/Matrix
birdquaternionscmd     db  '\'                 ; Quaternions
birdposquaternionscmd  db  ']'                 ; Position/Quaternions

;
; Messages
;
azimuthmsg          db  'Input the Azimuth (###.##):','$'
elevationmsg        db  'Input the Elevation (##.##):','$'
rollmsg             db  'Input the Roll (###.##):','$'
birdanglealignmsg   db  'Angle Alignment data sent to the Bird',CR,LF,'$'
alignpromptmsg      db  CR,LF,'Enter the angles used for new angle alignment...',CR,LF,'$'
hemispheremsg       db  'Hemisphere data sent to bird',CR,LF,'$'
refmsg              db  'New Reference Frame sent to bird',CR,LF,'$'
refpromptmsg        db  CR,LF,'Enter the angles used for new reference frame...',CR,LF,'$'
reportmsg           db  'Bird report rate configured',CR,LF,'$'
sleepwakemsg        db  'Sent the Sleep/Wake Command to the Bird',CR,LF,'$'
buttonquesmsg1      db  'Do you want the Button Byte added to the End of Data Stream','$'
buttonquesmsg2      db  CR,LF,'Display Button Value Now','$'
buttonmsg           db  CR,LF,'Hit any key to stop printing the button value',CR,LF,'$'
buttondisplaymsg    db  CR,LF,'Button = ','$'
xonxoffmsg          db  CR,LF,'Sent the XON/XOFF Command to the Bird',CR,LF,'$'
chgvaluemsg         db  CR,LF,'New Values Sent to the Bird',CR,LF,'$'
acnarrowfilterques  db  CR,LF,'Do you want the AC Narrow Notch filter OFF','$'
acwidefilterques    db  CR,LF,'Do you want the AC Wide Notch filter OFF','$'
dcfilterques        db  CR,LF,'Do you want the DC filter OFF','$'
measureratemsg      db  CR,LF,'Enter the Measurement COUNTS (0 to 65535): ','$'

; Bird System Status states
bss_b15_1           db  CR,LF,'Bird is a Master','$'
bss_b15_0           db  CR,LF,'Bird is a Slave','$'
bss_b14_1           db  CR,LF,'Bird has been initialized','$'
bss_b14_0           db  CR,LF,'Bird has not been initialized','$'
bss_b13_1           db  CR,LF,'Error detected','$'
bss_b13_0           db  CR,LF,'No error detected','$'
bss_b12_1           db  CR,LF,'Bird is not running','$'
bss_b12_0           db  CR,LF,'Bird is running','$'
bss_b11_1           db  CR,LF,'Bird is in HOST SYNC mode','$'
bss_b11_0           db  CR,LF,'Bird is not in HOST SYNC mode','$'
bss_b10_1           db  CR,LF,'Bird in Expanded address mode','$'
bss_b10_0           db  CR,LF,'Bird in Normal address mode','$'
bss_b9_1            db  CR,LF,'Bird in CRTSYN mode','$'
bss_b9_0            db  CR,LF,'Bird not in CRTSYN mode','$'
bss_b8_1            db  CR,LF,'No sync modes enabled','$'
bss_b8_0            db  CR,LF,'A sync mode enabled','$'
bss_b7_1            db  CR,LF,'Factory test commands enabled','$'
bss_b7_0            db  CR,LF,'Factory test commands not enabled','$'
bss_b6_1            db  CR,LF,'XOFF','$'
bss_b6_0            db  CR,LF,'XON','$'
bss_b5_1            db  CR,LF,'Bird in SLEEP mode','$'
bss_b5_0            db  CR,LF,'Bird in RUN mode','$'
positionmodemsg     db  CR,LF,'Position output selected ','$'
anglemodemsg        db  CR,LF,'Angle output selected ','$'
matrixmodemsg       db  CR,LF,'Matrix output selected ','$'
posanglemodemsg     db  CR,LF,'Position/Angle output selected ','$'
posmatrixmodemsg    db  CR,LF,'Position/Matrix output selected ','$'
facttestmodemsg     db  CR,LF,'Factory Test output selected ','$'
posquatermodemsg    db  CR,LF,'Position/Quaternion output selected ','$'
quatermodemsg       db  CR,LF,'Quaternion output selected ','$'
invalidmodemsg      db  CR,LF,'Illegal Output mode detected',CR,LF,'$'
streammodemsg       db  'in STREAM mode',CR,LF,'$'
pointmodemsg        db  'in POINT mode',CR,LF,'$'
softwarerevmsg      db  'Software Revision ','$'
crystalfreqmsg      db  'CPU Crystal Frequency in MHz: ','$'
rangemsg            db  'Maximum Range is ','$'
range36msg          db  '36 inches','$'
range72msg          db  '72 inches','$'
acnarrowfiltermsg   db  'AC Narrow Notch filter is ','$'
acwidefiltermsg     db  'AC Wide Notch filter is ','$'
dcfiltermsg         db  'DC filter is ','$'
onmsg               db  'ON',CR,LF,'$'
offmsg              db  'OFF',CR,LF,'$'
filtermsg           db  'Filter Constant is','$'
measurementratemsg  db  'Measurement rate in COUNTS as returned from the Bird: ','$'
crtsyncmsg          db  'CRT Sync ON/OFF sent to the Bird',CR,LF,'$'
pointmodepromptmsg  db  CR,LF,'Hit the B key to read Bird data or any other key to Quit',CR,LF,'$'
hostdelayquesmsg    db  'Enter the Number of 10 uS Counts desired for the FBB Host Delay: ','$'
fbbhostdelaymsg     db  'FBB Host Delay in 10 uS counts: ','$'
senddataquesmsg     db  'Should the Bird Output the Ready Character','$'
fbbactivedevicesheadermsg db CR,LF,'Devices RUNNING on the FBB are...',CR,LF,LF,'$'
fbbactivedevicemsg1 db 'FBB Device ','$'
fbbdependentsheadermsg db CR,LF,LF,'DEPENDENT FBB Devices on the FBB are...',CR,LF,LF,'$'
fbbdependentmsg1    db 'FBB Device ','$'
fbbactivedevicemsg2 db ' RUNNING Bit is ','$'
fbbdependentmsg2    db ' DEPENDENT Bit is ','$'
askchgactivequesmsg db  CR,LF,'Enter the FBB address (1-14) whose RUNNING status you want to change',CR,LF,'(ESC to Quit): ','$'
askchgdependentquesmsg db  CR,LF,'Enter the FBB address (1-14) whose DEPENDENT status you want to change',CR,LF,'(ESC to Quit): ','$'
syncmodemsg         db  CR,LF,LF,'FBB Sync Mode: ','$'
runstatemsg         db  CR,LF,LF,'FBB RUNning State: ','$'
armstatemsg         db  CR,LF,LF,'FBB ARMed State: ','$'
configmodemsg       db  CR,LF,LF,'FBB Config Mode: ','$'
senddatastatemsg    db  CR,LF,LF,'Send Data Ready State: ','$'
senddatardycharquesmsg db 'Enter the new Data Ready Character (decimal): ','$'
chgarmedques        db  CR,LF,'Do you want to ARM the Bird','$'
chgsaveconfigques   db  CR,LF,'Do you want to SAVE the Birds configuration ','$'
autoconfig1xmtrnrcvrques db CR,LF,'Enter the number of units (6DFOBs and ERCs) in the Flock: ','$'
deviceconfigmsg     db  CR,LF,'FBB Config [ACC RUNNING RCVR ERC XMTR3 XMTR2 XMTR1 XMTR0]:','$'
datardycharmsg      db  CR,LF,'The Data Ready Character is (decimal) ','$'
errorcodemsg        db  CR,LF,'The Error Code is (decimal) ','$'
expandedcodemsg     db  CR,LF,LF,'** NOTE ** The Expanded Error Address/Command are only valid for Error 13','$'
exterrorcodeaddrmsg db  CR,LF,'The Expanded Error Code Address is (decimal) ','$'
exterrorcodecmdmsg  db  CR,LF,'The Expanded Error Code Command is (decimal) ','$'
errormskmsg0        db  CR,LF,'FATAL Errors are Blinked Forever and Operation is Halted','$'
errormskmsg1        db  CR,LF,'FATAL Errors are Blinked Once and Operation is Resumed','$'
errormskmsg2        db  CR,LF,'FATAL Errors are Not Blinked and Operation is Halted','$'
errormskmsg3        db  CR,LF,'FATAL Errors are Not Blinked and Operation Continues','$'
glitchcheckmsg      db  CR,LF,'Do you want to Block Sudden Output Changes','$'
xyzrefframemsg      db  CR,LF,'Do you want to define Reference Frame','$'
glitchcheckstateoffmsg db  CR,LF,'Sudden Output Changes are output ','$'
glitchcheckstateonmsg  db  CR,LF,'Sudden Output Changes are NOT output ','$'
xyzrefframestateonmsg  db  CR,LF,'XYZ Reference Frame NOT defined ','$'
xyzrefframestateoffmsg db  CR,LF,'XYZ Reference Frame defined ','$'
modelmsg            db  CR,LF,'Model is: ','$'
groupdataques       db  CR,LF,'Do you want to enable group data mode','$'
groupdatamodemsg    db  CR,LF,'Group data info sent','$'
groupdataonmsg      db  CR,LF,'FBB Group Data Gathering is Enabled','$'
groupdataoffmsg     db  CR,LF,'FBB Group Data Gathering is Disabled','$'

;
; Error Messages
;
birdposerrmsg       db  '** ERROR ** could not read Bird Position',CR,LF,'$'
birdangleerrmsg     db  '** ERROR ** could not read Bird Angle',CR,LF,'$'
birdmatrixerrmsg    db  '** ERROR ** could not read Bird Matrix',CR,LF,'$'
birdquaternionserrmsg db '** ERROR ** could not read Bird Quaternions',CR,LF,'$'
birdposangleerrmsg  db  '** ERROR ** could not read Bird Position/Angle',CR,LF,'$'
birdposmatrixerrmsg db  '** ERROR ** could not read Bird Position/Matrix',CR,LF,'$'
birdposquaternionserrmsg db '** ERROR ** could not read Bird Position/Quaternions',CR,LF,'$'
angleerrormsg       db  '** ERROR ** invalid Euler Angle',CR,LF,'$'
buttonerrormsg      db  '** ERROR ** could not read button byte',CR,LF,'$'
filterinputerrmsg   db  '** ERROR ** invalid Filter Value',CR,LF,'$'
chginvaliderrormsg  db  '** ERROR ** invalid value..try again',CR,LF,'$'
getdeviceconfigerrmsg db '** ERROR ** could not get the device config response',CR,LF,'$'
;
; Hemisphere Menu
;
hemimenuptr         dw  hemimenuprompt,hemimenu0,hemimenu1,hemimenu2
		    dw  hemimenu3,hemimenu4,hemimenu5
hemimenuprompt      db  'Hemisphere Options:','$'
hemimenu0           db  'Forward','$'
hemimenu1           db  'Aft','$'
hemimenu2           db  'Upper','$'
hemimenu3           db  'Lower','$'
hemimenu4           db  'Left','$'
hemimenu5           db  'Right','$'
;
; Data for Hemisphere command
;
hemidatatbl         dw  0000h               ; data for Forward
		    dw  0100h               ; Aft
		    dw  010ch               ; Upper
		    dw  000ch               ; Lower
		    dw  0106h               ; Left
		    dw  0006h               ; Right
;
; Report Rate Menu
;
reportmenuptr       dw  reportmenuprompt,reportmenu0,reportmenu1
		    dw  reportmenu2,reportmenu3
reportmenuprompt    db  'Select the Report Rate (for STREAM mode):','$'
reportmenu0         db  'MAX','$'
reportmenu1         db  'MAX/2','$'
reportmenu2         db  'MAX/8','$'
reportmenu3         db  'MAX/32','$'
;
; Sleep Menu
;
sleepmenuptr        dw  sleepmenuprompt,sleepmenu0,sleepmenu1
sleepmenuprompt     db  'Enter Selection:','$'
sleepmenu0          db  'Sleep','$'
sleepmenu1          db  'Wake','$'

;
; XON/XOFF Menu
;
xonxoffmenuptr      dw  xonxoffmenuprompt,xonxoffmenu0,xonxoffmenu1
xonxoffmenuprompt   db  'Select Flow Command:','$'
xonxoffmenu0        db  'XON','$'
xonxoffmenu1        db  'XOFF','$'

;
; Change Value Menu
;
chgvaluemenuptr     dw  chgvaluemenuprompt,chgvaluemenu0
		    dw  chgvaluemenu1,chgvaluemenu2,chgvaluemenu3
		    dw  chgvaluemenu4,chgvaluemenu5,chgvaluemenu6
		    dw  chgvaluemenu7,chgvaluemenu8,chgvaluemenu9
		    dw  chgvaluemenu10,chgvaluemenu11,chgvaluemenu12
		    dw  chgvaluemenu13,chgvaluemenu14,chgvaluemenu15
		    dw  chgvaluemenu16

chgvaluemenuprompt  db  'Select Parameter to Change:','$'
chgvaluemenu0       db  'Previous Menu','$'
chgvaluemenu1       db  'Maximum Range Scaling','$'
chgvaluemenu2       db  'Filter ON/OFF Status','$'
chgvaluemenu3       db  'Filter Const - Alpha_Min','$'
chgvaluemenu4       db  'Bird Measurement Rate','$'
chgvaluemenu5       db  'Disable/Enable Data Ready Output','$'
chgvaluemenu6       db  'Change Data Ready Character','$'
chgvaluemenu7       db  'Set ON ERROR Mask','$'
chgvaluemenu8       db  'Filter Const - Vm','$'
chgvaluemenu9       db  'Filter Const - Alpha_Max','$'
chgvaluemenu10      db  'Block/Allow Sudden Output Changes','$'
chgvaluemenu11      db  'Set XYZ Reference Frame','$'
chgvaluemenu12      db  'Set FBB Host Delay','$'
chgvaluemenu13      db  'Set FBB Configuration','$'
chgvaluemenu14      db  'Set FBB ARMed','$'
chgvaluemenu15      db  'FBB Group Data','$'
chgvaluemenu16      db  'FBB Auto Config - 1 Trans/N Rec','$'

;
; Table of the Parameter Number of the Choices listed Above
;
chgparamtbl         db   0,3,4,5,6,8,9,11,12,13,14,17,32,33,34,35,50

;
; DC Filter Constant Table Messages for Change Value - Small Transmitter
;
chgdcfiltermsgtbl   dw  chgdcfiltermsg1
		    dw  chgdcfiltermsg2
		    dw  chgdcfiltermsg3
		    dw  chgdcfiltermsg4
		    dw  chgdcfiltermsg5
		    dw  chgdcfiltermsg6
		    dw  chgdcfiltermsg7
chgdcfiltermsg1     db  CR,LF,'Enter the Vm (decimal) value for the Range 0 to 12 inches: ','$'
chgdcfiltermsg2     db  CR,LF,'Enter the Vm (decimal) value for the Range 12 to 15 inches: ','$'
chgdcfiltermsg3     db  CR,LF,'Enter the Vm (decimal) value for the Range 15 to 19 inches: ','$'
chgdcfiltermsg4     db  CR,LF,'Enter the Vm (decimal) value for the Range 19 to 24 inches: ','$'
chgdcfiltermsg5     db  CR,LF,'Enter the Vm (decimal) value for the Range 24 to 30 inches: ','$'
chgdcfiltermsg6     db  CR,LF,'Enter the Vm (decimal) value for the Range 30 to 38 inches: ','$'
chgdcfiltermsg7     db  CR,LF,'Enter the Vm (decimal) value for the Range 38+ inches: ','$'

;
; DC Filter Constant Table Messages for Change Value - Extended Range Transmitter
;
extchgdcfiltermsgtbl   dw  extchgdcfiltermsg1
		    dw  extchgdcfiltermsg2
		    dw  extchgdcfiltermsg3
		    dw  extchgdcfiltermsg4
		    dw  extchgdcfiltermsg5
		    dw  extchgdcfiltermsg6
		    dw  extchgdcfiltermsg7
extchgdcfiltermsg1     db  CR,LF,'Enter the Vm (decimal) value for the Range 0 to 35 inches: ','$'
extchgdcfiltermsg2     db  CR,LF,'Enter the Vm (decimal) value for the Range 35 to 49 inches: ','$'
extchgdcfiltermsg3     db  CR,LF,'Enter the Vm (decimal) value for the Range 49 to 63 inches: ','$'
extchgdcfiltermsg4     db  CR,LF,'Enter the Vm (decimal) value for the Range 63 to 79 inches: ','$'
extchgdcfiltermsg5     db  CR,LF,'Enter the Vm (decimal) value for the Range 79 to 96 inches: ','$'
extchgdcfiltermsg6     db  CR,LF,'Enter the Vm (decimal) value for the Range 96 to 116 inches: ','$'
extchgdcfiltermsg7     db  CR,LF,'Enter the Vm (decimal) value for the Range 116+ inches: ','$'

;
; Alpha Min/Max Filter Constant Table Messages for Change Value - Small Transmitter
;
chgfiltermsgtbl     dw  chgfiltermsg1
		    dw  chgfiltermsg2
		    dw  chgfiltermsg3
		    dw  chgfiltermsg4
		    dw  chgfiltermsg5
		    dw  chgfiltermsg6
		    dw  chgfiltermsg7
chgfiltermsg1     db  CR,LF,'Enter the value (0 to 0.99996) for the Range 0 to 12 inches: ','$'
chgfiltermsg2     db  CR,LF,'Enter the value (0 to 0.99996) for the Range 12 to 15 inches: ','$'
chgfiltermsg3     db  CR,LF,'Enter the value (0 to 0.99996) for the Range 15 to 19 inches: ','$'
chgfiltermsg4     db  CR,LF,'Enter the value (0 to 0.99996) for the Range 19 to 24 inches: ','$'
chgfiltermsg5     db  CR,LF,'Enter the value (0 to 0.99996) for the Range 24 to 30 inches: ','$'
chgfiltermsg6     db  CR,LF,'Enter the value (0 to 0.99996) for the Range 30 to 38 inches: ','$'
chgfiltermsg7     db  CR,LF,'Enter the value (0 to 0.99996) for the Range 38+ inches: ','$'

;
; Alpha Min/Max Filter Constant Table Messages for Change Value - Extended Range Transmitter
;
extchgfiltermsgtbl     dw  extchgfiltermsg1
		    dw  extchgfiltermsg2
		    dw  extchgfiltermsg3
		    dw  extchgfiltermsg4
		    dw  extchgfiltermsg5
		    dw  extchgfiltermsg6
		    dw  extchgfiltermsg7
extchgfiltermsg1     db  CR,LF,'Enter the value (0 to 0.99996) for the Range 0 to 35 inches: ','$'
extchgfiltermsg2     db  CR,LF,'Enter the value (0 to 0.99996) for the Range 35 to 49 inches: ','$'
extchgfiltermsg3     db  CR,LF,'Enter the value (0 to 0.99996) for the Range 49 to 63 inches: ','$'
extchgfiltermsg4     db  CR,LF,'Enter the value (0 to 0.99996) for the Range 63 to 79 inches: ','$'
extchgfiltermsg5     db  CR,LF,'Enter the value (0 to 0.99996) for the Range 79 to 96 inches: ','$'
extchgfiltermsg6     db  CR,LF,'Enter the value (0 to 0.99996) for the Range 96 to 116 inches: ','$'
extchgfiltermsg7     db  CR,LF,'Enter the value (0 to 0.99996) for the Range 116+ inches: ','$'

;
; Error Mask Menu
;
errormaskmenuptr    dw  errormaskmenuprompt,errormaskmenu0,errormaskmenu1
		    dw  errormaskmenu2
errormaskmenuprompt db  'Select Error Mask Mode:','$'
errormaskmenu0      db  'Fatal Errors Blink Forever and Operation is Halted','$'
errormaskmenu1      db  'Fatal Errors Blink Once and Operation is Resumed','$'
errormaskmenu2      db  'Fatal Errors Do NOT Blink and Operation is Resumed','$'

;
; FBB Config Menu
;
fbbconfigmodemenuptr dw fbbconfigmenuprompt,fbbconfigmenu0
		    dw  fbbconfigmenu1
fbbconfigmenuprompt db  'Select FBB Configuration Mode:','$'
fbbconfigmenu0      db  'Standalone mode','$'
fbbconfigmenu1      db  'One Trans/Multiple Receivers ','$'
;
; Values for fbbconfig corresponding to menu choices
;
fbb_config_tbl      db  0,1

;
; Examine Value Menu
;
exmvaluemenuptr     dw  exmvaluemenuprompt,exmvaluemenu0
		    dw  exmvaluemenu1,exmvaluemenu2,exmvaluemenu3
		    dw  exmvaluemenu4,exmvaluemenu5,exmvaluemenu6
		    dw  exmvaluemenu7,exmvaluemenu8,exmvaluemenu9
		    dw  exmvaluemenu10,exmvaluemenu11,exmvaluemenu12
		    dw  exmvaluemenu13,exmvaluemenu14,exmvaluemenu15
		    dw  exmvaluemenu16,exmvaluemenu17,exmvaluemenu18
		    dw  exmvaluemenu19,exmvaluemenu20,exmvaluemenu21
		    dw  exmvaluemenu22, exmvaluemenu23

exmvaluemenuprompt  db  'Select Parameter to Examine:','$'
exmvaluemenu0       db  'Previous Menu','$'
exmvaluemenu1       db  'Bird System Status','$'
exmvaluemenu2       db  'Software Revision','$'
exmvaluemenu3       db  'Bird CPU Crystal Frequency','$'
exmvaluemenu4       db  'Maximum Range Scaling','$'
exmvaluemenu5       db  'Filter ON/OFF Status','$'
exmvaluemenu6       db  'Filter Const - Alpha_Min','$'
exmvaluemenu7       db  'Bird Measurement Rate','$'
exmvaluemenu8       db  'Data Ready Output','$'
exmvaluemenu9       db  'Data Ready Character','$'
exmvaluemenu10      db  'Error Code','$'
exmvaluemenu11      db  'ON ERROR Mask','$'
exmvaluemenu12      db  'Filter Const - Vm','$'
exmvaluemenu13      db  'Filter Const - Alpha_Max','$'
exmvaluemenu14      db  'Sudden Output Changes','$'
exmvaluemenu15      db  'Model','$'
exmvaluemenu16      db  'Expanded Error Code','$'
exmvaluemenu17      db  'XYZ Reference Frame','$'
exmvaluemenu18      db  'FBB Host Delay','$'
exmvaluemenu19      db  'FBB Configuration','$'
exmvaluemenu20      db  'FBB ARMed','$'
exmvaluemenu21      db  'FBB Group Data','$'
exmvaluemenu22      db  'FBB System Status','$'
exmvaluemenu23      db  'FBB Auto Config - 1 Trans/N Rec','$'

;
; Setup a Table for the examine value parameter numbers
;
exmparamtbl         db  0,0,1,2,3,4,5,6,8,9,10,11,12,13,14,15,16,17,32,33,34,35,36,50

;
; Setup a Table for the examine value response size
;
exmdatasizetbl      db  0,2,2,2,2,2,14,2,1,1,1,1,14,14,1,10,2,1,2,5,14,1,14,5

;
; Range Menu
;
rangemenuptr        dw  rangemenuprompt,rangemenu0,rangemenu1
rangemenuprompt     db  'Select Scaling Range:','$'
rangemenu0          db  '36 inch range','$'
rangemenu1          db  '72 inch range','$'

;
; DC Filter Constant Table Messages for Examine Value - Small Transmitter
;
exmdcfiltermsgtbl   dw  exmdcfiltermsg1
		    dw  exmdcfiltermsg2
		    dw  exmdcfiltermsg3
		    dw  exmdcfiltermsg4
		    dw  exmdcfiltermsg5
		    dw  exmdcfiltermsg6
		    dw  exmdcfiltermsg7

exmdcfiltermsg1     db  CR,LF,'For the Range 0 to 12 inches, value is ','$'
exmdcfiltermsg2     db  CR,LF,'For the Range 12 to 15 inches, value is ','$'
exmdcfiltermsg3     db  CR,LF,'For the Range 15 to 19 inches, value is ','$'
exmdcfiltermsg4     db  CR,LF,'For the Range 19 to 24 inches, value is ','$'
exmdcfiltermsg5     db  CR,LF,'For the Range 24 to 30 inches, value is ','$'
exmdcfiltermsg6     db  CR,LF,'For the Range 30 to 38 inches, value is ','$'
exmdcfiltermsg7     db  CR,LF,'For the Range 38+ inches, value is ','$'

;
; DC Filter Constant Table Messages for Examine Value - Extend Range Transmitter
;
extexmdcfiltermsgtbl   dw  extexmdcfiltermsg1
		    dw  extexmdcfiltermsg2
		    dw  extexmdcfiltermsg3
		    dw  extexmdcfiltermsg4
		    dw  extexmdcfiltermsg5
		    dw  extexmdcfiltermsg6
		    dw  extexmdcfiltermsg7

extexmdcfiltermsg1     db  CR,LF,'For the Range 0 to 35 inches, value is ','$'
extexmdcfiltermsg2     db  CR,LF,'For the Range 35 to 49 inches, value is ','$'
extexmdcfiltermsg3     db  CR,LF,'For the Range 49 to 63 inches, value is ','$'
extexmdcfiltermsg4     db  CR,LF,'For the Range 63 to 79 inches, value is ','$'
extexmdcfiltermsg5     db  CR,LF,'For the Range 79 to 96 inches, value is ','$'
extexmdcfiltermsg6     db  CR,LF,'For the Range 96 to 116 inches, value is ','$'
extexmdcfiltermsg7     db  CR,LF,'For the Range 116+ inches, value is ','$'


;
; CRT Sync Menu
;
crtsyncmenuptr      dw  crtsyncmenuprompt,crtsyncmenu0
		    dw  crtsyncmenu1,crtsyncmenu2,crtsyncmenu3
crtsyncmenuprompt   db  'Select CRT Sync Mode:','$'
crtsyncmenu0        db  'CRT Sync OFF','$'
crtsyncmenu1        db  'CRT Sync - CRT Vertical Retrace Greater than 72 Hz','$'
crtsyncmenu2        db  'CRT Sync - CRT Vertical Retrace Less than 72 Hz','$'
crtsyncmenu3        db  'Display CRT Pickup Info','$'

_DATA               ENDS

;*****************************************************************************

;*****************************************************************************

_TEXT           SEGMENT WORD PUBLIC 'CODE'
		ASSUME  cs:_TEXT,ds:_DATA

;=============================================================================
;   bird_position       Get Bird Position
;   ----------------
;
;   Parameters Passed:  outputmode (global), POINT,CONTINUOUS or STREAM
;                       buttonmode (global), current button mode, 0 if button
;                             character is not appended to data,
;                             1 if button character is appended
;   Return Value:       In AX, TRUE if successful, FALSE otherwise
;   Registers Modified: AX
;   Remarks:            Displays current Bird Position in POINT, CONTINUOUS
;                       or STREAM mode
;=============================================================================
;
bird_position   proc    near
		push    bx                  ; save regs
		push    cx
;
; Send the output Position command
;
		mov     cx,1                ; 1 character in cmd
		mov     bx,OFFSET birdposcmd ; get cmd
		call    send_serial_cmd     ; send the bird the cmd
		cmp     ax,1                ; did cmd go out OK?
		je      birdpos1            ; if ok, continue
		jmp     birdposfalseret     ; return false
;
; check for stream mode
;
birdpos1:       cmp     outputmode,STREAM   ; In Stream Mode
		jne     birdpospointcmd     ; if not, go on to loop
birdpos2:
		mov     cx,1                ; 1 character in cmd
		mov     bx,OFFSET birdstreamcmd ; get cmd
		call    send_serial_cmd     ; send the bird the cmd
		cmp     ax,1                ; did cmd go out OK?
		je      birdpos3            ; if ok, continue
		jmp     birdposfalseret     ; return false

birdpospointcmd:
		cmp     outputmode,POINT    ; if in Point mode send
		jne     birdpos3            ; prompt message
		mov     dx,OFFSET pointmodepromptmsg ; send a prompt to the Console
		call    putstring           ;
;
; Now continue on in a loop until done...check_done == TRUE
;
birdpos3:       call    check_done          ; are we done?
		cmp     ax,TRUE             ; if done..
		je      birdpostrueret      ; return true
;
; Get the 6 characters, 3 words
;
		mov     cx,3                ; get 3 rx words
		mov     bx,OFFSET rxdatabuf ; get space for rx chars
		call    read_bird_data      ; read the data
		cmp     ax,TRUE             ; was the response OK?
		jne     sendbirdposerrmsg   ; send the error msg
;
; Convert the data to Unit
;
		mov     ax,posfrmt
		mov     format,ax           ; set up decimal point for pos
		mov     ax,posk
		mov     conv_const,ax       ; set up conversion constant
		call    converttounits      ; convert and display, BX and CX
;
; Display the Button Value if Button Mode <> 0
;
		cmp     buttonmode,0        ; ck if in Button Mode
		je      birdpos4            ; if not..move on
		mov     al,TAB              ; else, send at TAB
		call    putchr              ; .. to the console
		call    putchr              ; .. two times
		mov     ax,buttonvalue      ; get the buttonvalue
		call    displayunsigned     ; display the button value
birdpos4:
		call    newline             ; send a newline
		jmp     birdpos3            ; continue until done
;
; Send Error message
;
sendbirdposerrmsg:
		mov     dx,OFFSET birdposerrmsg ; get the errormsg
		call    putstring           ; send message to the console
		call    hitkeycontinue      ; wait for confirmation
birdposfalseret: mov    ax,FALSE            ; return FALSE
		jmp     birdposexit
;
; Clean Exit
;
birdpostrueret: mov     ax,TRUE                 ; return TRUE
birdposexit:    pop     cx                  ; restore regs
		pop     bx
		ret                         ; home
bird_position   endp

;=============================================================================
;   bird_angle          Get Bird Angle
;   ----------------
;
;   Parameters Passed:  outputmode (global), POINT,CONTINUOUS or STREAM
;                       buttonmode (global), current button mode, 0 if button
;                             character is not appended to data,
;                             1 if button character is appended
;   Return Value:       In AX, TRUE if successful, FALSE otherwise
;   Registers Modified: AX
;   Remarks:            Displays current Bird Angle in POINT, CONTINUOUS
;                       or STREAM mode
;=============================================================================
;
bird_angle      proc    near
		push    bx                  ; save regs
		push    cx
;
; Send the output angle command
;
		mov     cx,1                ; 1 character in cmd
		mov     bx,OFFSET birdanglecmd ; get cmd
		call    send_serial_cmd     ; send the bird the cmd
		cmp     ax,1                ; did cmd go out OK?
		je      birdangle1          ; if ok, continue
		jmp     birdanglefalseret   ; return false
;
; check for stream mode
;
birdangle1:     cmp     outputmode,STREAM   ; In Stream Mode
		jne     birdanglepointcmd   ; if not, go on to loop
birdangle2:
		mov     cx,1                ; 1 character in cmd
		mov     bx,OFFSET birdstreamcmd ; get cmd
		call    send_serial_cmd     ; send the bird the cmd
		cmp     ax,1                ; did cmd go out OK?
		je      birdangle3          ; if ok, continue
		jmp     birdanglefalseret   ; return false

birdanglepointcmd:
		cmp        outputmode,POINT    ; if in Point mode send
		jne        birdangle3            ; prompt message
		mov        dx,OFFSET pointmodepromptmsg ; send a prompt to the Console
		call    putstring            ;
;
; Now continue on in a loop until done...check_done == TRUE
;
birdangle3:     call    check_done          ; are we done?
		cmp     ax,TRUE             ; if done..
		je      birdangletrueret    ; return true
;
; Get the 6 characters, 3 words
;
		mov     cx,3                ; get 3 rx words
		mov     bx,OFFSET rxdatabuf ; get space for rx chars
		call    read_bird_data      ; read the data
		cmp     ax,TRUE             ; was the response OK?
		jne     sendbirdangleerrmsg ; send the error msg
;
; Convert the data to Unit
;
		mov     format,ANGFORMAT    ; set up decimal point for angle
		mov     conv_const,ANGK     ; set up conversion constant
		call    converttounits      ; convert and display, BX and CX
					    ; still set
;
; Display the Button Value if Button Mode <> 0
;
		cmp        buttonmode,0        ; ck if in Button Mode
		je      birdangle4            ; if not..move on
		mov        al,TAB                ; else, send at TAB
		call    putchr                ; .. to the console
		call    putchr                ; .. two times
		mov        ax,buttonvalue        ; get the buttonvalue
		call    displayunsigned        ; display the button value
birdangle4:
		call    newline             ; send a newline
		jmp     birdangle3          ; continue until done
;
; Send Error message
;
sendbirdangleerrmsg:
		mov     dx,OFFSET birdangleerrmsg   ; get the errormsg
		call    putstring           ; send message to the console
		call    hitkeycontinue      ; wait for confirmation
birdanglefalseret: mov  ax,FALSE            ; return FALSE
		jmp     birdangleexit
;
; Clean Exit
;
birdangletrueret: mov   ax,TRUE         ; return TRUE
birdangleexit:  pop     cx                  ; restore regs
		pop     bx
		ret                         ; home
bird_angle      endp

;=============================================================================
;   bird_matrix         Get Bird Matrix
;   ----------------
;
;   Parameters Passed:  outputmode (global), POINT,CONTINUOUS or STREAM
;                       buttonmode (global), current button mode, 0 if button
;                             character is not appended to data,
;                             1 if button character is appended
;   Return Value:       In AX, TRUE if successful, FALSE otherwise
;   Registers Modified: AX
;   Remarks:            Displays current Bird Matrix in POINT, CONTINUOUS
;                       or STREAM mode
;=============================================================================
;
bird_matrix     proc    near
		push    bx                  ; save regs
		push    cx
;
; Send the output matrix command
;
		mov     cx,1                ; 1 character in cmd
		mov     bx,OFFSET birdmatrixcmd ; get cmd
		call    send_serial_cmd     ; send the bird the cmd
		cmp     ax,1                ; did cmd go out OK?
		je      birdmatrix1         ; if ok, continue
		jmp     birdmatrixfalseret  ; return false
;
; check for stream mode
;
birdmatrix1:    cmp     outputmode,STREAM   ; In Stream Mode
		jne     birdmatrixpointcmd  ;  if not, go on to loop
birdmatrix2:
		mov     cx,1                ; 1 character in cmd
		mov     bx,OFFSET birdstreamcmd ; get cmd
		call    send_serial_cmd     ; send the bird the cmd
		cmp     ax,1                ; did cmd go out OK?
		je      birdmatrix3         ; if ok, continue
		jmp     birdmatrixfalseret  ; return false

birdmatrixpointcmd:
		cmp        outputmode,POINT    ; if in Point mode send
		jne        birdmatrix3            ; prompt message
		mov        dx,OFFSET pointmodepromptmsg ; send a prompt to the Console
		call    putstring            ;
;
; Now continue on in a loop until done...check_done == TRUE
;
birdmatrix3:    call    check_done          ; are we done?
		cmp     ax,TRUE             ; if done..
		je      birdmatrixtrueret   ; return true
;
; Get the 18 characters, 9 words
;
		mov     cx,9                ; get 9 rx words
		mov     bx,OFFSET rxdatabuf ; get space for rx chars
		call    read_bird_data      ; read the data
		cmp     ax,TRUE             ; was the response OK?
		jne     sendbirdmatrixerrmsg ; send the error msg
;
; Convert the data to Units and print
;
		call    printmatrix         ; print the matrix
		jmp     birdmatrix3         ; continue until done
;
; Send Error message
;
sendbirdmatrixerrmsg:
		mov     dx,OFFSET birdmatrixerrmsg  ; get the errormsg
		call    putstring           ; send message to the console
		call    hitkeycontinue      ; wait for confirmation
birdmatrixfalseret: mov ax,FALSE            ; return FALSE
		jmp     birdmatrixexit
;
; Clean Exit
;
birdmatrixtrueret: mov  ax,TRUE         ;    return TRUE
birdmatrixexit: pop     cx                  ; restore regs
		pop     bx
		ret                         ; home
bird_matrix     endp

;=============================================================================
;   bird_quaternions         Get Bird Quaternions
;   ----------------
;
;   Parameters Passed:  outputmode (global), POINT,CONTINUOUS or STREAM
;                       buttonmode (global), current button mode, 0 if button
;                             character is not appended to data,
;                             1 if button character is appended
;   Return Value:       In AX, TRUE if successful, FALSE otherwise
;   Registers Modified: AX
;   Remarks:            Displays current Bird Quaternions in
;                       POINT, CONTINUOUS or STREAM mode
;=============================================================================
;
bird_quaternions  proc    near
		  push    bx                  ; save regs
		  push    cx
;
; Send the output quaternions command
;
		mov     cx,1                ; 1 character in cmd
		mov     bx,OFFSET birdquaternionscmd ; get cmd
		call    send_serial_cmd     ; send the bird the cmd
		cmp     ax,1                ; did cmd go out OK?
		je      birdquaternions1    ; if ok, continue
		jmp     birdquaternionsfalseret  ; return false
;
; check for stream mode
;
birdquaternions1:
		cmp     outputmode,STREAM   ; In Stream Mode
		jne     birdquaternionspointcmd  ;  if not, go on to loop
birdquaternions2:
		mov     cx,1                ; 1 character in cmd
		mov     bx,OFFSET birdstreamcmd ; get cmd
		call    send_serial_cmd     ; send the bird the cmd
		cmp     ax,1                ; did cmd go out OK?
		je      birdquaternions3         ; if ok, continue
		jmp     birdquaternionsfalseret  ; return false

birdquaternionspointcmd:
		cmp        outputmode,POINT    ; if in Point mode send
		jne        birdquaternions3            ; prompt message
		mov        dx,OFFSET pointmodepromptmsg ; send a prompt to the Console
		call    putstring            ;
;
; Now continue on in a loop until done...check_done == TRUE
;
birdquaternions3:    call    check_done          ; are we done?
		cmp     ax,TRUE             ; if done..
		je      birdquaternionstrueret   ; return true
;
; Get the 8 characters, 4 words
;
		mov     cx,4                ; get 4 rx words
		mov     bx,OFFSET rxdatabuf ; get space for rx chars
		call    read_bird_data      ; read the data
		cmp     ax,TRUE             ; was the response OK?
		jne     sendbirdquaternionserrmsg ; send the error msg
;
; Convert the data to Units and print
;
		call    printquaternions         ; print the quaternions
		jmp     birdquaternions3         ; continue until done
;
; Send Error message
;
sendbirdquaternionserrmsg:
		mov     dx,OFFSET birdquaternionserrmsg  ; get the errormsg
		call    putstring           ; send message to the console
		call    hitkeycontinue      ; wait for confirmation
birdquaternionsfalseret: mov ax,FALSE            ; return FALSE
		jmp     birdquaternionsexit
;
; Clean Exit
;
birdquaternionstrueret: mov  ax,TRUE         ;    return TRUE
birdquaternionsexit:
		pop     cx                  ; restore regs
		pop     bx
		ret                         ; home
bird_quaternions     endp

;=============================================================================
;   bird_positonangle   Get Bird Position and Angle
;   ----------------
;
;   Parameters Passed:  outputmode (global), POINT,CONTINUOUS or STREAM
;                       buttonmode (global), current button mode, 0 if button
;                             character is not appended to data,
;                             1 if button character is appended
;   Return Value:       In AX, TRUE if successful, FALSE otherwise
;   Registers Modified: AX
;   Remarks:            Displays current Bird Position and Angle in POINT,
;                       CONTINUOUS or STREAM mode
;=============================================================================
;
bird_positionangle proc near
		push    bx                  ; save regs
		push    cx
;
; Send the output posangle command
;
		mov     cx,1                ; 1 character in cmd
		mov     bx,OFFSET birdposanglecmd ; get cmd
		call    send_serial_cmd     ; send the bird the cmd
		cmp     ax,1                ; did cmd go out OK?
		je      birdposangle1       ; if ok, continue
		jmp     birdposanglefalseret ; return false
;
; check for stream mode
;
birdposangle1:  cmp     outputmode,STREAM   ; In Stream Mode
		jne     birdposanglepointcmd ;  if not, go on to loop
birdposangle2:
		mov     cx,1                ; 1 character in cmd
		mov     bx,OFFSET birdstreamcmd ; get cmd
		call    send_serial_cmd     ; send the bird the cmd
		cmp     ax,1                ; did cmd go out OK?
		je      birdposangle3       ; if ok, continue
		jmp     birdposanglefalseret ; return false
birdposanglepointcmd:
		cmp        outputmode,POINT    ; if in Point mode send
		jne        birdposangle3        ; prompt message

		mov        dx,OFFSET pointmodepromptmsg ; send a prompt to the Console
		call    putstring            ;
;
; Now continue on in a loop until done...check_done == TRUE
;
birdposangle3:  call    check_done          ; are we done?
		cmp     ax,TRUE             ; if done..
		je      birdposangletrueret ; return true
;
; Get the 12 characters, 6 words
;
		mov     cx,6                ; get 6 rx words
		mov     bx,OFFSET rxdatabuf ; get space for rx chars
		call    read_bird_data      ; read the data
		cmp     ax,TRUE             ; was the response OK?
		jne     sendbirdposangleerrmsg  ; send the error msg
;
; Convert the data to Units and print
;
; first print position
		mov     cx,3                ; due 3 words
		mov     ax,posfrmt
		mov     format,ax           ; set up decimal point for position
		mov     ax,posk
		mov     conv_const,ax       ; set up conversion constant
		call    converttounits      ; convert and display
; then print the angle
		mov     al,TAB
		call    putchr              ; space between position and angle
		mov     cx,3                ; due 3 words
		mov     format,ANGFORMAT    ; set up decimal point for angle
		mov     conv_const,ANGK     ; set up conversion constant
		call    converttounits      ; convert and display

;
; Display the Button Value if Button Mode <> 0
;
		cmp        buttonmode,0        ; ck if in Button Mode
		je      birdposangle4        ; if not..move on
		mov        al,TAB                ; else, send at TAB
		call    putchr                ; .. to the console
		call    putchr                ; .. two times
		mov        ax,buttonvalue        ; get the buttonvalue
		call    displayunsigned        ; display the button value
birdposangle4:
		call    newline             ; send a newline
		jmp     birdposangle3       ; continue until done

;
; Send Error message
;
sendbirdposangleerrmsg:
		mov     dx,OFFSET birdposangleerrmsg    ; get the errormsg
		call    putstring           ; send message to the console
		call    hitkeycontinue      ; wait for confirmation
birdposanglefalseret: mov   ax,FALSE        ; return FALSE
		jmp     birdposangleexit
;
; Clean Exit
;
birdposangletrueret: mov    ax,TRUE         ; return TRUE
birdposangleexit:
		pop     cx                  ; restore regs
		pop     bx
		ret                         ; home
bird_positionangle  endp

;=============================================================================
;   bird_positionmatrix     Get Bird Position and Matrix
;   -------------------
;
;   Parameters Passed:  outputmode (global), POINT,CONTINUOUS or STREAM
;                       buttonmode (global), current button mode, 0 if button
;                             character is not appended to data,
;                             1 if button character is appended
;   Return Value:       In AX, TRUE if successful, FALSE otherwise
;   Registers Modified: AX
;   Remarks:            Displays current Bird Position and Matrix in POINT,
;                       CONTINUOUS or STREAM mode
;=============================================================================
;
bird_positionmatrix proc near
		push    bx                  ; save regs
		push    cx
		push    dx
;
; Send the output posmatrix command
;
		mov     cx,1                ; 1 character in cmd
		mov     bx,OFFSET birdposmatrixcmd ; get cmd
		call    send_serial_cmd     ; send the bird the cmd
		cmp     ax,1                ; did cmd go out OK?
		je      birdposmatrix1      ; if ok, continue
		jmp     birdposmatrixfalseret ; return false
;
; check for stream mode
;
birdposmatrix1: cmp     outputmode,STREAM   ; In Stream Mode
		jne     birdposmatrixpointcmd ;  if not, go on to loop
birdposmatrix2:
		mov     cx,1                ; 1 character in cmd
		mov     bx,OFFSET birdstreamcmd ; get cmd
		call    send_serial_cmd     ; send the bird the cmd
		cmp     ax,1                ; did cmd go out OK?
		je      birdposmatrix3      ; if ok, continue
		jmp     birdposmatrixfalseret ; return false

birdposmatrixpointcmd:
		cmp        outputmode,POINT    ; if in Point mode send
		jne        birdposmatrix3        ; prompt message
		mov        dx,OFFSET pointmodepromptmsg ; send a prompt to the Console
		call    putstring            ;
;
; Now continue on in a loop until done...check_done == TRUE
;
birdposmatrix3: call    check_done          ; are we done?
		cmp     ax,TRUE             ; if done..
		je      birdposmatrixtrueret    ; return true
;
; Get the 24 characters, 12 words
;
		mov     cx,12               ; get posmatrix data
		mov     bx,OFFSET rxdatabuf ; get space for rx chars
		call    read_bird_data      ; read the data
		cmp     ax,TRUE             ; was the response OK?
		jne     sendbirdposmatrixerrmsg ; send the error msg
;
; Convert the data to Units and print
;
; first print position
		mov     cx,3                ; due 3 words
		mov     ax,posfrmt
		mov     format,ax           ; set up decimal point for position
		mov     ax,posk
		mov     conv_const,ax       ; set up conversion constant
		call    converttounits      ; convert and display
		call    newline             ; send a newline
; then the matrix
		call    printmatrix         ; print the matrix data
		jmp     birdposmatrix3      ; continue until done
;
; Send Error message
;
sendbirdposmatrixerrmsg:
		mov     dx,OFFSET birdposmatrixerrmsg   ; get the errormsg
		call    putstring           ; send message to the console
		call    hitkeycontinue      ; wait for confirmation
birdposmatrixfalseret: mov  ax,FALSE        ; return FALSE
		jmp     birdposmatrixexit
;
; Clean Exit
;
birdposmatrixtrueret: mov   ax,TRUE         ; return TRUE
birdposmatrixexit:
		pop     dx                  ; restore regs
		pop     cx
		pop     bx
		ret                         ; home
bird_positionmatrix endp

;=============================================================================
;   bird_posquaternions     Get Bird Position and Quaternions
;   -------------------
;
;   Parameters Passed:  outputmode (global), POINT,CONTINUOUS or STREAM
;                       buttonmode (global), current button mode, 0 if button
;                             character is not appended to data,
;                             1 if button character is appended
;   Return Value:       In AX, TRUE if successful, FALSE otherwise
;   Registers Modified: AX
;   Remarks:            Displays current Bird Position and Quaternions
;                       in POINT, CONTINUOUS or STREAM mode
;
;=============================================================================
;
bird_posquaternions proc near
		push    bx                  ; save regs
		push    cx
		push    dx
;
; Send the output posquaternions command
;
		mov     cx,1                ; 1 character in cmd
		mov     bx,OFFSET birdposquaternionscmd ; get cmd
		call    send_serial_cmd     ; send the bird the cmd
		cmp     ax,1                ; did cmd go out OK?
		je      birdposquaternions1 ; if ok, continue
		jmp     birdposquaternionsfalseret ; return false
;
; check for stream mode
;
birdposquaternions1:
		cmp     outputmode,STREAM   ; In Stream Mode
		jne     birdposquaternionspointcmd ;  if not, go on to loop
birdposquaternions2:
		mov     cx,1                ; 1 character in cmd
		mov     bx,OFFSET birdstreamcmd ; get cmd
		call    send_serial_cmd     ; send the bird the cmd
		cmp     ax,1                ; did cmd go out OK?
		je      birdposquaternions3      ; if ok, continue
		jmp     birdposquaternionsfalseret ; return false

birdposquaternionspointcmd:
		cmp        outputmode,POINT    ; if in Point mode send
		jne        birdposquaternions3        ; prompt message
		mov        dx,OFFSET pointmodepromptmsg ; send a prompt to the Console
		call    putstring            ;
;
; Now continue on in a loop until done...check_done == TRUE
;
birdposquaternions3:
		call    check_done          ; are we done?
		cmp     ax,TRUE             ; if done..
		je      birdposquaternionstrueret    ; return true
;
; Get the 14 characters, 7 words
;
		mov     cx,7                ; get posmatrix data
		mov     bx,OFFSET rxdatabuf ; get space for rx chars
		call    read_bird_data      ; read the data
		cmp     ax,TRUE             ; was the response OK?
		jne     sendbirdposquaternionserrmsg ; send the error msg
;
; Convert the data to Units and print
;
; first print position
		mov     cx,3                ; due 3 words
		mov     ax,posfrmt
		mov     format,ax           ; set up decimal point for position
		mov     ax,posk
		mov     conv_const,ax       ; set up conversion constant
		call    converttounits      ; convert and display
		call    newline             ; send a newline
; then the quaternions
		call    printquaternions         ; print the matrix data
		jmp     birdposquaternions3      ; continue until done
;
; Send Error message
;
sendbirdposquaternionserrmsg:
		mov     dx,OFFSET birdposquaternionserrmsg   ; get the errormsg
		call    putstring           ; send message to the console
		call    hitkeycontinue      ; wait for confirmation
birdposquaternionsfalseret: mov  ax,FALSE        ; return FALSE
		jmp     birdposquaternionsexit
;
; Clean Exit
;
birdposquaternionstrueret: mov   ax,TRUE         ; return TRUE
birdposquaternionsexit:
		pop     dx                  ; restore regs
		pop     cx
		pop     bx
		ret                         ; home
bird_posquaternions endp


;=============================================================================
;   bird_anglealign     Align the Bird User Specified Direction
;   ----------------
;
;   Parameters Passed:  outputmode (global), POINT,CONTINUOUS or STREAM
;                       buttonmode (global), current button mode, 0 if button
;                             character is not appended to data,
;                             1 if button character is appended
;   Return Value:       In AX, TRUE if successful, FALSE otherwise
;   Registers Modified: AX
;   Remarks:            prompts the user for Azimuth, Elevation and Roll of
;                       the User Direction and sends these values to the Bird
;                       to reorient the Birds direction.  The user is
;                       prompted for the SIN and COS of the 3 angular
;                       directions...since the program does not contain
;                       trigonomic functions.
;=============================================================================
;
bird_anglealign proc    near
		push    bx                  ; save regs
		push    cx
		push    dx
;
; Put up a Prompt Message
;
		mov     dx,OFFSET alignpromptmsg ; get message
		call    putstring           ; put to console
;
; Get the 3 angles from the user
;
		call    getangle            ; ask the questions
		cmp     ax,TRUE             ; everything go OK?
		jne     birdalignfalseret   ; if not, bail out
;
; Now set up the angle alignment command in the temporary command byte
;
		mov     bx,OFFSET anglecmd  ; get the angle cmd
		mov     al,birdanglealigncmd ; get the cmd
		mov     [bx],al             ; set the cmd byte
		mov     cx,13               ; 13 characters in cmd
		call    send_serial_cmd     ; send the bird the cmd
		cmp     ax,13               ; did cmd go out OK?
		je      birdalign1          ; if ok, continue
		jmp     birdalignfalseret   ; return false
;
; everything went out OK so tell the user
;
birdalign1:     mov     dx,OFFSET birdanglealignmsg
		call    putstring           ; send the message
		call    hitkeycontinue      ; wait for confirmation
		mov     ax,TRUE             ; return TRUE
		jmp     birdalignret

birdalignfalseret:
		mov     ax,FALSE            ; return FALSE
birdalignret:   pop     dx                  ; restore regs
		pop     cx
		pop     bx
		ret
bird_anglealign endp

;=============================================================================
;    bird_hemisphere    Set the Birds Hemisphere
;   ----------------
;
;   Parameters Passed:  none
;   Return Value:       TRUE if successful
;                       FALSE if unsuccessful
;                       ESC_SEL if ESC selected
;   Registers Modified: AX
;   Remarks:            prompt the user for the Bird hemisphere and send
;                       down coresponding hemisphere command to the Bird
;=============================================================================
;
bird_hemisphere proc    near
		push    bx                  ; save regs
		push    cx
		push    dx
;
; Send the Menu to the User
;
		mov     cx,6                ; setup for 6 choices
		mov     dx,OFFSET hemimenuptr ; get the menu
		call    sendmenu            ; put the menu on the screen
		cmp     ax,ESC_SEL          ; see if the user hit ESC
		jne     dohemimenucmd       ; if not continue
		jmp     hemiret        ; else redisplay
;                                           ; Setup the Command string to the Bird as a function of the
; User menu selection.....
; .....2 data bytes must be set for HEMI_AXIS and HEMI_SIGN
;
dohemimenucmd:  mov     bx,OFFSET hemidatatbl
		shl     ax,1                ; multiply AX by 2.. for words
		add     bx,ax               ; add in the user response
		mov     ax,[bx]             ; get the two byte into AX
		mov     bx,OFFSET txdatabuf ; set up the bird command
		mov     cl,birdhemispherecmd ; get the command
		mov     [bx],cl             ; store the command
		inc     bx                  ; point to the data position
		mov     [bx],ax             ; store the hemisphere data
;
; Send the command and data out
;
		dec     bx                  ; point back to the start of buf
		mov     cx,3                ; 3 bytes in command
		call    send_serial_cmd     ; out she goes..
		cmp     ax,3
		je      hemitrueret         ; return TRUE
		jmp     hemifalseret        ; return FALSE
hemifalseret:   mov     ax,FALSE
		jmp     hemiret
hemitrueret:    mov     dx,offset hemispheremsg ; put configuration msg up
		call    putstring
		call    hitkeycontinue      ; wait on confirmation
		mov     ax,TRUE             ; return TRUE
hemiret:        pop     dx                  ; restore regs
		pop     cx
		pop     bx
		ret
bird_hemisphere endp

;=============================================================================
;   bird_referframe     Define a new Bird Reference Frame
;   ---------------
;
;   Parameters Passed:  none
;   Return Value:       TRUE if successful
;                       FALSE otherwise
;   Registers Modified: AX
;   Remarks:            Queries user for azimuth, elevation and roll
;                       of new Bird reference frame
;=============================================================================
;
bird_reference  proc    near
		push    bx                  ; save regs
		push    cx
		push    dx
;
; Put up a Prompt Message
;
		mov     dx,OFFSET refpromptmsg ; get message
		call    putstring           ; put to console
;
; Get Angles from the User
;
		call    getangle
		cmp     ax,TRUE             ; everything go OK?
		jne     reffalseret         ; if not, bail out
;
; Send the command and data out
;
		mov     bx, OFFSET anglecmd ; point to the start of buf
		mov     al, birdrefframecmd ; load up the command ..'H'
		mov     [bx],al             ; store at the start of the buf
		mov     cx,13               ; 13 bytes in command
		call    send_serial_cmd     ; out she goes..
		cmp     ax,13
		je      reftrueret          ; return TRUE
		jmp     reffalseret         ; return FALSE
reffalseret:    mov     ax,FALSE
		jmp     refret
reftrueret:     mov     dx,offset refmsg    ; put configuration msg up
		call    putstring
		call    hitkeycontinue      ; wait on confirmation
		mov     ax,TRUE             ; return TRUE
refret:         pop     dx                  ; restore regs
		pop     cx
		pop     bx
		ret
bird_reference  endp

;=============================================================================
;    bird_reportrate    Select the Report Rate for Stream Mode
;   ----------------
;
;   Parameters Passed:  none
;   Return Value:       TRUE if successful
;                       FALSE if unsuccessful
;                       ESC_SEL if user selected ESC
;   Registers Modified: AX
;   Remarks:            Sends the Report Rate command to the Bird...
;                       ...can be MAX, MAX/2, MAX/8, or MAX/32
;=============================================================================
;
bird_reportrate proc    near
		push    bx                  ; save regs
		push    cx
		push    dx
;
; Send the Menu to the User
;
		mov     cx,4                ; setup for 4 choices
		mov     dx,OFFSET reportmenuptr ; get the menu
		call    sendmenu            ; put the menu on the screen
		cmp     ax,ESC_SEL          ; see if the user hit ESC
		jne     doreportmenucmd     ; if not continue
		jmp     reportret           ; else .. return
;
; Get the command byte offset from the birdrate1 byte
;
doreportmenucmd:
		mov     bx,OFFSET birdrate1 ; get the address
		add     bx,ax               ; add the user's selection
		mov     cx,1                ; send one byte
		call    send_serial_cmd     ; send the command
		cmp     ax,1                ; did cmd go out OK?
		je      reporttrueret       ; if so return TRUE
reportfalseret: mov     ax,FALSE            ; else, return FALSE
		jmp     reportret
reporttrueret:  mov     dx,OFFSET reportmsg ; get message
		call    putstring           ; inform the user
		call    hitkeycontinue      ; wait for confirmation
		mov     ax,TRUE             ; return TRUE
reportret:      pop     dx                  ; restore regs
		pop     cx
		pop     bx
		ret
bird_reportrate endp

;=============================================================================
;   bird_sleep          Bird Sleep/Wake Command
;   ----------------
;
;   Parameters Passed:  none
;   Return Value:       In AX, TRUE if successful
;                       FALSE, if unsuccessful
;                       ESC_SEL, if user selected ESC
;   Registers Modified: AX
;   Remarks:            Implements the 'G' (sleep) and 'F' (wake) commands
;                       on the Bird...'when sleeping', the FLY/STANDBY
;                       indicator is off.
;=============================================================================
;
bird_sleep      proc    near
		push    bx                  ; save regs
		push    cx
		push    dx
;
; Send the Menu to the User
;
		mov     cx,2                ; setup for 2 choices
		mov     dx,OFFSET sleepmenuptr ; get the menu
		call    sendmenu            ; put the menu on the screen
		cmp     ax,ESC_SEL          ; see if ESC was selected
		je      sleepfalseret
		mov     bx,OFFSET birdsleepcmd ; get the 'G' command
		sub     bx,ax               ; if AX is 1 the BX points to 'F'
		mov     cx,1                ; send 1 characater
		call    send_serial_cmd     ; send the bird the command
		cmp     ax,1                ; did cmd go out OK?
		je      sleeptrueret        ; if so, return TRUE
sleepfalseret:  mov     ax,FALSE            ; else, return FALSE
		jmp     sleepret
sleeptrueret:   mov     dx,OFFSET sleepwakemsg
		call    putstring           ; send the message to the console
		call    hitkeycontinue      ; wait for confirmation
sleepret:       pop     dx                  ; restore regs
		pop     cx
		pop     bx
		ret
bird_sleep      endp


;=============================================================================
;   bird_mousebuttons   Implements the M and N mouse button commands
;   ----------------
;
;   Parameters Passed:  none
;   Return Value:       0, if buttonmode if off
;                       1, if buttonmode is on, 'M'
;                       ESC_SEL, if the user selected ESC_SEL
;   Registers Modified: AX
;   Remarks:            sends down the button mode to the Bird and allows
;                       the user to view the Button state.
;=============================================================================
;
bird_mousebuttons proc  near
		push  bx                  ; save regs
		push  cx
		push  dx
;
; Ask if they want the Button Commands to aways be sent
;
		mov     dx,OFFSET buttonquesmsg1 ; ask button question1
		call    askyesno                ; prompt for yes not
		cmp     ax,ESC_SEL              ; did the user hit ESC/
		je      buttonfalseret          ; if so, bail out
		mov     buttonmode,ax           ; assign the global the value
		mov     bx,OFFSET txdatabuf     ; else, build the cmd string
		mov     cl,birdbuttonmodecmd    ; first get the cmd byte
		mov     [bx],cl                 ; store cmd in buffer
		inc     bx                      ; increment buffer pointer
		mov     [bx],al                 ; fill data with user answer
		mov     cx,2                    ; two characters to send
		dec     bx                      ; point to buffer start
		call    send_serial_cmd         ; send the cmd
		cmp     ax,2                    ; did cmd go out OK?
		jne     buttonfalseret          ; if not, return FALSE
;
; Now see if the user wants to display the current button value
;
		mov     dx,OFFSET buttonquesmsg2 ; get the questino
		call    askyesno                ; prompt for Y/N
		cmp     ax,TRUE                 ; is the answer YES
		jne     buttontrueret           ; if not, return TRUE anyway
		mov     dx,OFFSET buttonmsg     ; get the 'Hit any...msg'
		call    putstring               ; put msg up
;
; Now stay in a loop displaying Button value until a key hit
;
getbuttonval:   call    ckkeyrdy                ; see if key available
		cmp     ax,TRUE                 ; is one ready?
		jne     readbuttonval           ; if not read button value
		call    clearkey                ; else, clear keyboard
		jmp     buttontrueret           ; return TRUE
;
; Send command to Get button value
;
readbuttonval:  mov     bx,OFFSET birdbuttonreadcmd ; get button read cmd
		mov     cx,1                    ; 1 byte cmd
		call    send_serial_cmd         ; send the cmd
		cmp     ax,1                    ; did cmd go out OK?
		jne     buttonfalseret          ; if not return FALSE
;
; Wait for a character from the bird
;
		call    waitforchar             ; wait for a character
		cmp     ax,0                    ; did errors occur?
		jge     displaybuttonval        ; if OK, display button char
		mov     dx,OFFSET buttonerrormsg ; else, get the error msg
		call    putstring               ; put up error msg
		call    hitkeycontinue          ; wait for confirmation
		jmp     buttonfalseret          ; return FALSE
;
; Display button value... display as a number
;
displaybuttonval:
		mov     bx,ax                   ; save AX...button value
		mov     dx,OFFSET buttondisplaymsg
		call    putstring               ; put up display msg
		mov     ax,bx                   ; restore the button value
		call    displayunsigned         ; display AX
		jmp     getbuttonval            ; continue until key hit

buttonfalseret: mov     ax,FALSE                ; return FALSE
		jmp     buttonret
buttontrueret:  mov     ax,TRUE
buttonret:      pop     dx                      ; restore regs
		pop     cx
		pop     bx
		ret
bird_mousebuttons endp

;=============================================================================
;   bird_xonxoff        Bird XON / XOFF commands
;   ------------
;
;   Parameters Passed:  none
;   Return Value:       none
;                       TRUE, if a XON or XOFF command was executed
;                       FALSE, if command could not be executed
;                       ESC_SEL, if the user selected ESC_SEL
;   Registers Modified: AX
;   Remarks:            Sends the XON or XOFF command to the Bird
;=============================================================================
;
bird_xonxoff    proc    near
		push    bx                  ; save regs
		push    cx
		push    dx
;
; Send the Menu to the User
;
		mov     cx,2                ; setup for 2 choices
		mov     dx,OFFSET xonxoffmenuptr ; get the menu
		call    sendmenu            ; put the menu on the screen
		cmp     ax,ESC_SEL          ; see if the user hit ESC
		jne     ckxonxoff           ; if not continue
		jmp     xonxoffret          ; else ...home
ckxonxoff:      cmp     ax,0                ; first select was XON
		jne     sendxoff
		mov     al,XON              ; user selected XON
		jmp     sendxonxoff
sendxoff:       mov     al,XOFF             ; user selected XOFF
sendxonxoff:    mov     bx, OFFSET txdatabuf ; fill the command buffer..
		mov     [bx], al            ; ..with the data
		mov     cx,1                ; get ready to send 1 character
		call    send_serial_cmd     ; off she goes
		cmp     ax,1                ; ck if command went out OK
		je      xonxofftrueret
xonxofffalseret:
		mov     ax,FALSE            ; else, return FALSE
		jmp     xonxoffret
xonxofftrueret: mov     dx,OFFSET xonxoffmsg
		call    putstring           ; send the message to the console
		call    hitkeycontinue      ; wait for confirmation
		mov     ax,TRUE             ;
xonxoffret:     pop     dx                  ; restore regs
		pop     cx
		pop     bx
		ret
bird_xonxoff    endp

;=============================================================================
;   bird_changevalue        Bird Change Value/Parameters Command
;   ----------------
;
;   Parameters Passed:  none
;   Return Value:       none
;                       TRUE, if a Change Value command was executed
;                       FALSE, if command could not be executed
;                       ESC_SEL, if the user selected ESC_SEL
;   Registers Modified: AX
;   Remarks:            Sends the Change Value command and associated data
;                       down to the Bird
;=============================================================================
;
;
; Set up a Jump Table for the Menu Selections
;
chgvaluejmptbl  dw  chgvalueret             ; para# null
		dw  chgrangescale           ; para# 3
		dw  chgfilteronoff          ; para# 4
		dw  chgfilterconst          ; para# 5
		dw  chgmeasurementrate      ; para# 6
		dw  chgenabledatardy        ; para# 8
		dw  chgdatardychar          ; para# 9
		dw  chgonerrormsk           ; para# 11
		dw  chgdcfiltertbl          ; para# 12
		dw  chgfilteralphamax       ; para# 13
		dw  chgglitchckonoff        ; para# 14
		dw  chgXYZreferenceonoff    ; para# 17
		dw  chgfbbhostdelay         ; para# 32
		dw  chgfbbconfig            ; para# 33
		dw  chgfbbarmed             ; para# 34
		dw  chgfbbgroupdata         ; para# 35
		dw  chgfbbautoconfig1xnr    ; para# 50

bird_changevalue proc   near
		push    bx                  ; save regs
		push    cx
		push    dx
		push    si
;
; Send the Menu to the User
;
		mov     cx,17               ; setup choices
		mov     dx,OFFSET chgvaluemenuptr ; get the menu
		call    sendmenu            ; put the menu on the screen
		cmp     ax,0
		jg      chgvalue            ; if not continue
		jmp     chgvalueret         ; else ...home

chgvalue:       mov     bx,OFFSET txdatabuf ; use the txdatabuf for the cmd
		mov     cl,birdchgvaluecmd  ; setup the command byte.. 'P'
		mov     [bx],cl             ; store the command in the buffer
		inc     bx                  ; point to the next cmd byte
		push    ax
		mov     si,ax               ; use SI as table offset
		mov     al,chgparamtbl[si]  ; get the chg param via lookup tbl
		mov     [bx],al             ; store in the command string
		pop     ax
		shl     ax,1                ; use the user input to access
		mov     bx,ax               ; get the table offset
		jmp     chgvaluejmptbl[bx]  ; off to the work
;
; Change the Range Scale
;
chgrangescale:
		mov     cx,2                ; setup for 2 choices
		mov     dx,OFFSET rangemenuptr ; get the menu
		call    sendmenu            ; put the menu on the screen
		cmp     ax,ESC_SEL          ; see if the user hit ESC
		jne     setrangevalue       ; if not continue
		jmp     chgvalueret         ; else ...home
setrangevalue:
		mov     WORD PTR txdatabuf+2,ax ; get the data buf + 2
		mov     cx,4
		cmp     ax,0
		jne     setrange72
setrange36:     mov     posk,POSK36
		jmp     sendchgvaluecmd
setrange72:     mov     posk,POSK72
		jmp     sendchgvaluecmd

;
; Change the DAC, AC, and DC Filter ON/OFF condition
;
chgfilteronoff: mov     si,0                ; use si to hold filter values
		mov     dx,OFFSET acnarrowfilterques ; get the question
		call    askyesno            ; ask the user
		cmp     ax,ESC_SEL          ; see if ESC was selected
		jne     ckacnarrowanswer
		jmp     chgvalueret         ; if so ...quit
ckacnarrowanswer:
		cmp     ax,TRUE             ; was the answer yes
		jne     ckacfilter          ; if not, next question
		or      si,4                ; else, set bit value
ckacfilter:
		mov     dx,OFFSET acwidefilterques  ; get the question
		call    askyesno            ; ask the user
		cmp     ax,ESC_SEL          ; see if ESC was selected
		jne     ckacwideanswer
		jmp     chgvalueret         ; if so ...quit
ckacwideanswer:
		cmp     ax,TRUE             ; was the answer yes
		jne     ckdcfilter          ; if not, next question
		or      si,2                ; else, set bit value
ckdcfilter:
		mov     dx,OFFSET dcfilterques  ; get the question
		call    askyesno            ; ask the user
		cmp     ax,ESC_SEL          ; see if ESC was selected
		jne     ckdcanswer
		jmp     chgvalueret         ; if so ...quit
ckdcanswer:     cmp     ax,TRUE             ; was the answer yes
		jne     setfilteronoff      ; if not set the command value
		or      si,1                ; else, set bit value
setfilteronoff: mov     WORD PTR txdatabuf+2,si ; get the data buf + 2
		mov     cx,4
		jmp     sendchgvaluecmd
;
; Change the Filter Constant Table - Alpha Min
;
chgfilterconst:
		mov     cx,7                          ; setup for 7 questions
		mov     di,OFFSET txdatabuf+2
		mov     bx,OFFSET chgfiltermsgtbl
		cmp     posk,POSK144                  ; ck for an ERT
		jne     askfilterques
		mov     bx,OFFSET extchgfiltermsgtbl  ; setup for an ERT
askfilterques:
		mov     dx,[bx]
		call    putstring
		mov     format,4            ; setup for 2 places past decimal
		mov     conv_const,UNITK    ; setup for -1.0 to 0.99996
		call    getfloatnumber      ; get a floating point number
;
; Validate Filter Value  .... 0 <= Filter Value <= 0.99996
;
		cmp     dx,0                ; Can't be greater, but ck if <
		jl      filterinputerr
		mov     [di],dx                       ; store the data
		inc     di
		inc     di                            ; point to the next location
		inc     bx
		inc     bx                            ; point to next question
		loop    askfilterques
		mov     cx,16                         ; 16 byte command
		jmp     sendchgvaluecmd               ; send the command

filterinputerr: mov     dx,OFFSET filterinputerrmsg ; send the error msg
		call    putstring           ; put message to screen
		call    hitkeycontinue      ; confirm error
		jmp     askfilterques       ; do again

;
; Change the Measurement Rate
;
; NOTE:  This section should be modified to query the user for a RATE
;        and then determine the COUNTS from the rate using fixed point
;        math... for now, just query the user for the COUNTS
;
chgmeasurementrate:
		mov     dx,OFFSET measureratemsg ; get msg
		call    putstring                ; display msg
		call    getnumber                ; get a number from the user
		mov     WORD PTR txdatabuf+2,dx  ; store the data
		mov     cx,4                ; store the command size
		cmp     ax,ESC_SEL          ; ck for user ESC
		jne     tosendchgvaluecmd1     ; if not.. send the cmd
		jmp     chgvalueret         ; else return
tosendchgvaluecmd1:
		jmp     sendchgvaluecmd
;
; Change the Send Data Ready Flag
;
chgenabledatardy:
		mov     dx,OFFSET senddataquesmsg
		call    askyesno
		cmp     ax,ESC_SEL
		jne     sendchgrdy
		jmp     chgvalueret
sendchgrdy:
		mov     BYTE PTR txdatabuf+2,al       ; store the data
		mov     cx,3                          ; 3 byte command
		jmp     sendchgvaluecmd               ; send the command

;
; Ask the User for the New data ready character
;
chgdatardychar:
		mov     dx,OFFSET senddatardycharquesmsg
		call    putstring
		call    getnumber
		cmp     ax,ESC_SEL
		jne     storenewdatardychr
		jmp     chgvalueret
storenewdatardychr:
		mov     BYTE PTR txdatabuf+2,dl       ; store the data
		mov     cx,3                          ; 3 byte command
		jmp     sendchgvaluecmd               ; send the command

;
; Ask the user if they want the error mask
;
chgonerrormsk:
			mov     cx,3                          ; setup for choices
			mov     dx,OFFSET errormaskmenuptr
			call    sendmenu                      ; put the menu on the screen
		    cmp     ax,0
			jge     chgerrormaskvalue             ; if not continue
			jmp     chgvalueret                   ; else ...home
chgerrormaskvalue:
		cmp     ax,0
		je      senderrormsk
		cmp     ax,1
		je      senderrormsk
		mov     ax,3
senderrormsk:
			mov     BYTE PTR txdatabuf+2,al       ; store the data
			mov     cx,3                          ; 3 byte command
			jmp     sendchgvaluecmd               ; send the command

;
; Ask the user the for the DC Filter Values
;
chgdcfiltertbl:
		mov     cx,7                          ; setup for 7 questions
		mov     di,OFFSET txdatabuf+2
		mov     bx,OFFSET chgdcfiltermsgtbl
		cmp     posk,POSK144                  ; ck for an ERT
		jne     askdcfilterques
		mov     bx,OFFSET extchgdcfiltermsgtbl  ; setup for an ERT
askdcfilterques:
		mov     dx,[bx]
		call    putstring                     ; put up the question
		call    getnumber
		cmp     ax,ESC_SEL
		jne     storedcfiltervalue
		jmp     chgvalueret
storedcfiltervalue:
		mov     [di],dx                       ; store the data
		inc     di
		inc     di                            ; point to the next location
		inc     bx
		inc     bx                            ; point to next question
		loop    askdcfilterques
		mov     cx,16                         ; 16 byte command
		jmp     sendchgvaluecmd               ; send the command

;
; Change the Filter Constant Table - Alpha MAX
;
chgfilteralphamax:
		mov     cx,7                          ; setup for 7 questions
		mov     di,OFFSET txdatabuf+2
		mov     bx,OFFSET chgfiltermsgtbl
		cmp     posk,POSK144                  ; ck for an ERT
		jne     askfilterques1
		mov     bx,OFFSET extchgfiltermsgtbl  ; setup for an ERT
askfilterques1:
		mov     dx,[bx]
		call    putstring
		mov     format,4            ; setup for 2 places past decimal
		mov     conv_const,UNITK    ; setup for -1.0 to 0.99996
		call    getfloatnumber      ; get a floating point number
;
; Validate Filter Value  .... 0 <= Filter Value <= 0.99996
;
		cmp     dx,0                ; Can't be greater, but ck if <
		jl      filterinputerr1
		mov     [di],dx                       ; store the data
		inc     di
		inc     di                            ; point to the next location
		inc     bx
		inc     bx                            ; point to next question
		loop    askfilterques1
		mov     cx,16                         ; 16 byte command
		jmp     sendchgvaluecmd               ; send the command

filterinputerr1:
		mov     dx,OFFSET filterinputerrmsg ; send the error msg
		call    putstring           ; put message to screen
		call    hitkeycontinue      ; confirm error
		jmp     askfilterques1      ; do again

;
; Turn Glitch Checking ON/OFF
;
chgglitchckonoff:
		mov     dx,OFFSET glitchcheckmsg
		call    askyesno
		cmp     ax,ESC_SEL
		jne     sendglitchcheck
		jmp     chgvalueret
sendglitchcheck:
		mov     BYTE PTR txdatabuf+2,al       ; store the data
		mov     cx,3                          ; 3 byte command
		jmp     sendchgvaluecmd               ; send the command
;
; Ask the user for the Host Delay
;
chgfbbhostdelay:
		mov     dx,OFFSET hostdelayquesmsg
		call    putstring
		call    getnumber
		cmp     ax,ESC_SEL
		jne     sendhostdelay
		jmp     chgvalueret
sendhostdelay:
		mov     WORD PTR txdatabuf+2,dx       ; store the data
		mov     cx,4                          ; 4 byte command
		jmp     sendchgvaluecmd               ; send the command
;
; Turn XYZ Reference Frame ON/OFF
;
chgXYZreferenceonoff:                
		mov     dx,OFFSET xyzrefframemsg
		call    askyesno
		cmp     ax,ESC_SEL
		jne     sendXYZreference
		jmp     chgvalueret
sendXYZreference:
		mov     BYTE PTR txdatabuf+2,al       ; store the data
		mov     cx,3                          ; 3 byte command
		jmp     sendchgvaluecmd               ; send the command

;
; FBB Config
;
; Ask the User for the Configuration Mode (byte)
; Active Devices (word), Dependents (word)
;
chgfbbconfig:
		mov     cx,2                ; setup for 2 choices
		mov     dx,OFFSET fbbconfigmodemenuptr
		call    sendmenu            ; put the menu on the screen
		cmp     ax,ESC_SEL          ; see if the user hit ESC
		jne     storeconfigmode
		jmp     chgvalueret         ; else ...home

storeconfigmode:
		mov     si,ax
		mov     al,fbb_config_tbl[si]
		mov     fbbconfigmode,al
;
; Using the fbbdevices, look at bit 1-14 and display whether or not it is
; active...then ask the user if they want to change the current state of
; any bit
;
ckactivedevices:
		call    displayactivedevices

;
; See if the user wants to change any of the active bits
;
getchgactivenumber:
		mov     dx,OFFSET askchgactivequesmsg
		call    putstring
		call    getnumber
		cmp     ax,ESC_SEL
		je      getdependentdevices
;
; Set the appropriate bit in the fbbdevices word
;
		cmp     dx,0
		jle     invaliddevicenum
		cmp     dx,14
		jle     updateactivedevices
invaliddevicenum:
		mov     dx,OFFSET chginvaliderrormsg
		call    putstring
		jmp     getchgactivenumber
updateactivedevices:
		mov     cx,dx            ; get the users response
		mov     ax,1             ; start at bit 0..
		shl     ax,cl            ; set the bit in AX
		xor     fbbdevices,ax    ; update the bit in fbbdevices
		jmp     ckactivedevices  ; redisplay the entire list of devices
;
; Ask the user for the Dependent List information
;
;
getdependentdevices:
		call    displaydependents
;
; See if the user wants to change any of the active bits
;
getchgdependentnumber:
		mov     dx,OFFSET askchgdependentquesmsg
		call    putstring
		call    getnumber
		cmp     ax,ESC_SEL
		jne     setdevicebit
;
; shew... done with the FBB configuration
;
; Now Since we're done setting the configuration...send the cmd to the host
; RS232CMD + Change Command + Parameter # + 6 data bytes = 9 bytes
;
; This could be coded much more efficiently (via string move to txbuf)
; but it is left this way for clarity
;
		mov     bx,OFFSET txdatabuf  ; get the data buf
		mov     al,fbbconfigmode
		mov     [bx]+2,al            ; store the data in the cmd
		mov     ax,fbbdevices
		mov     [bx]+3,ax            ; store the data in the cmd
		mov     ax,fbbdependents
		mov     [bx]+5,ax            ; store the data in the cmd
		mov     cx,7                 ; setup for 7 bytes
		jmp     sendchgvaluecmd
;
; Set the appropriate bit in the fbbdevices word
;
setdevicebit:
		cmp     dx,0
		jle     invaliddependentnum
		cmp     dx,14
		jle     verifyactive
invaliddependentnum:
		mov     dx,OFFSET chginvaliderrormsg
		call    putstring
		jmp     getdependentdevices
verifyactive:
		mov     cx,dx            ; get the users response
		mov     ax,1             ; start at bit 0..
		shl     ax,cl            ; set the bit in AX
		test    fbbdevices,ax
		jz      invaliddependentnum
		xor     fbbdependents,ax ; update the bit in fbbdependents
		jmp     getdependentdevices ; redisplay the entire list of dependents
;
; FBB Armed
;
chgfbbarmed:
		mov     dx,OFFSET chgarmedques
		call    askyesno
		cmp     ax,ESC_SEL
		jne     sendfbbarmed
		jmp     chgvalueret
sendfbbarmed:
		mov     BYTE PTR txdatabuf+2,al
		mov     cx,3
		jmp     sendchgvaluecmd

;
; FBB Group Data
;
chgfbbgroupdata:
		mov     dx,OFFSET groupdataques
		call    askyesno
		cmp     ax,ESC_SEL
		jne     sendgroupdata
		jmp     chgvalueret
sendgroupdata:
		mov     fbbgroupmodeflg, ax    ; store the user's answer
		mov     BYTE PTR txdatabuf+2,al
		mov     cx,3
		jmp     sendchgvaluecmd

;
; Auto Configuration - 1 Transmitter, Multiple Receivers
;
chgfbbautoconfig1xnr:
		mov     dx,OFFSET autoconfig1xmtrnrcvrques
		call    putstring
		call    getnumber
		cmp     ax,ESC_SEL
		jne     sendautoconfig1xmtrnrcvr
		jmp     chgvalueret
sendautoconfig1xmtrnrcvr:
		mov     BYTE PTR txdatabuf+2,dl
		mov     cx,3
		jmp     sendchgvaluecmd

;
; Send the Command and new Parameter Values to the Bird
;
sendchgvaluecmd:
		mov     bx,OFFSET txdatabuf ; get the data buf
		push    cx
		call    send_serial_cmd     ; off she goes
		pop     cx
		cmp     ax,cx                ; ck if command went out OK
		je      chgvaluetrueret
chgvaluefalseret:
		mov     ax,FALSE            ; else, return FALSE
		jmp     chgvalueret
chgvaluetrueret:
		mov     dx,OFFSET chgvaluemsg
		call    putstring           ; send the message to the console
		call    hitkeycontinue      ; wait for confirmation
		mov     ax,TRUE             ;
chgvalueret:    pop     si                  ; restore regs
		pop     dx
		pop     cx
		pop     bx
		ret
bird_changevalue endp
;
;============================================================================
;
; Display the Device configuration in the rxdatabuf
;
displaydeviceconfig     proc near
		mov     si,OFFSET rxdatabuf
		mov     cx,1
nextdeviceconfig:
		mov     dx,OFFSET deviceconfigmsg
		call    putstring
		mov     al,cl
		xor     ah,ah
		call    displayunsigned     ; display the device number
		mov     al,TAB
		call    putchr
		mov     al,[si]
		xor     ah,ah
		call    displaybinarybyte   ; display the device config
		cmp     cl,BYTE PTR exmdatasizetbl+22
		je      displaydeviceconfigret
	cmp     cl,20
	jne     tonextdeviceconfig
	call    hitkeycontinue
tonextdeviceconfig:
		inc     si
		inc     cx
		jmp     nextdeviceconfig

displaydeviceconfigret:
		ret

displaydeviceconfig endp


;============================================================================
;
; Display the Active FBB Devices
;
displayactivedevices proc near
		push    ax
		push    bx
		push    cx
		push    dx
		push    si
		mov     dx,OFFSET fbbactivedevicesheadermsg
		call    putstring
		mov     cx,0                ; use CX as a counter starting at 0
		mov     si,00000001b        ; start with bit 0
nextactivedevice:
	cmp     cx,15
	jne     nextactivedevice1   ; if CX gets to address 15 reset the
	mov     si,00000001b        ; ..bit mask to bit 0
nextactivedevice1:
		shl     si,1
		cmp     cl,exmdatasizetbl+22 ; check against the table entry
		jl      displayactivedevice
		pop     si
		pop     dx
		pop     cx
		pop     bx
		pop     ax
		ret

displayactivedevice:
	cmp     cx,20
	jne     displayactivedevice1
	call    hitkeycontinue

displayactivedevice1:
		inc     cx
		mov     dx,OFFSET fbbactivedevicemsg1
		call    putstring
		mov     ax,cx
		call    displayunsigned
		mov     dx,OFFSET fbbactivedevicemsg2
		call    putstring
	cmp     cx,15
	jge     useextdevices
		test    fbbdevices,si
	jmp     tosenddevicemsg
useextdevices:
		test    extfbbdevices,si
tosenddevicemsg:
		jz      senddeviceoffmsg
		mov     dx,OFFSET onmsg
		call    putstring
		jmp     nextactivedevice
senddeviceoffmsg:
		mov     dx,OFFSET offmsg
		call    putstring
		jmp     nextactivedevice

displayactivedevices endp

;
; Display the Dependent FBB Devices
;
displaydependents  proc    near
		push    si
		mov     dx,OFFSET fbbdependentsheadermsg
		call    putstring
		mov     cx,0                ; use CX as a counter starting at 0
		mov     si,00000001b        ; start with bit 0

ckdependent:
		shl     si,1
		inc     cx
		cmp     cx,15
		jne     displaydependentdevice
		pop     si
		ret

displaydependentdevice:
		mov     dx,OFFSET fbbdependentmsg1
		call    putstring
		mov     ax,cx
		call    displayunsigned
		mov     dx,OFFSET fbbdependentmsg2
		call    putstring
		test    fbbdependents,si
		jz      senddependentoffmsg
		mov     dx,OFFSET onmsg
		call    putstring
		jmp     ckdependent
senddependentoffmsg:
		mov     dx,OFFSET offmsg
		call    putstring
		jmp     ckdependent
displaydependents  endp

;
; Show the FBB Configuration
;
showfbbconfig   proc    near
;
; Display the Config Mode byte
;
		mov     dx,OFFSET configmodemsg
		call    putstring
		mov     al,rxdatabuf
		xor     ah,ah
		call    displaybinarybyte
		call    newline
		call    hitkeycontinue
;
; Display the Active Devices
;
		mov     si,fbbdevices   ; save
		mov     ax,WORD PTR [rxdatabuf+1]
		mov     fbbdevices,ax
		call    displayactivedevices
		mov     fbbdevices,si   ;restore
		call    hitkeycontinue

;
; Display the Dependent Devices
;
		mov     si,fbbdependents   ; save
		mov     ax,WORD PTR [rxdatabuf+3]
		mov     fbbdependents,ax
		call    displaydependents
		mov     fbbdependents,si   ;restore
		call    hitkeycontinue
		ret
showfbbconfig   endp

;=============================================================================
;   bird_examinevalue   Bird Examine Value/Parameters Command
;   -----------------
;
;   Parameters Passed:  none
;   Return Value:       none
;                       TRUE, if a Change Value command was executed
;                       FALSE, if command could not be executed
;                       ESC_SEL, if the user selected ESC_SEL
;   Registers Modified: AX
;   Remarks:            Sends the Examine Value command down to the Bird
;                       and displays the data associated data
;=============================================================================
;
;
; Set up a Jump Table for the Menu Selections
;
exmvaluejmptbl  dw  exmvalueret                 ; para# null
		dw  exmstatus                   ; para# 0
		dw  exmrevison                  ; para# 1
		dw  exmcrystal                  ; para# 2
		dw  exmrangescale               ; para# 3
		dw  exmfilteronoff              ; para# 4
		dw  exmfilterconst              ; para# 5
		dw  exmmeasurementrate          ; para# 6
		dw  exmdatardyout               ; para# 8
		dw  exmdatardychar              ; para# 9
		dw  exmerrorcode                ; para# 10
		dw  exmerrormsk                 ; para# 11
		dw  exmdcfiltertbl              ; para# 12
		dw  exmfilteralphamax           ; para# 13
		dw  exmglitchcheckonoff         ; para# 14
		dw  exmmodel                    ; para# 15
		dw  exmexterrorcode             ; para# 16
		dw  exmxyzrefframe              ; para# 17
		dw  exmhostdelay                ; para# 32
		dw  exmfbbconfig                ; para# 33
		dw  exmfbbarmed                 ; para# 34
		dw  exmfbbgroupdata             ; para# 35
		dw  exmsysconfig                ; para# 36
		dw  exmautoconfig1xmtrnrcvr     ; para# 50

bird_examinevalue proc  near
		push    bx                  ; save regs
		push    cx
		push    dx
;
; Setup the Number of Bytes to for certain commands as a function
; of normal or expanded addressing mode
;
; ..assume normal mode
;
		mov     expaddrmodeflg,FALSE
		mov     BYTE PTR exmdatasizetbl + 19, 5
		mov     BYTE PTR exmdatasizetbl + 20, 14
		mov     BYTE PTR exmdatasizetbl + 22, 14
		mov     BYTE PTR exmdatasizetbl + 23, 5
;
; Get the Address Mode from the flock
;
		call    getaddrmode
		cmp     ax,14
		je      sendexmmenu
;
; Setup for Expanded Mode
;
		mov     expaddrmodeflg,TRUE
		mov     BYTE PTR exmdatasizetbl + 19, 7
		mov     BYTE PTR exmdatasizetbl + 20, 30
		mov     BYTE PTR exmdatasizetbl + 22, 30
		mov     BYTE PTR exmdatasizetbl + 23, 7

;
; Send the Menu to the User
;
sendexmmenu:
		mov     cx,24               ; setup for 22 choices
		mov     dx,OFFSET exmvaluemenuptr ; get the menu
		call    sendmenu            ; put the menu on the screen
		cmp     ax,0
		jg      exmvalue            ; if not continue
		jmp     exmvalueret         ; else ...home
;
; Send the Examine Command down to the Bird and then decode the
; information returned as per the user's selection
;
exmvalue:       push    ax                  ; save the user's selection
		mov     cx,ax
		mov     bx,OFFSET txdatabuf ; use the txdatabuf for the cmd
		mov     ax,WORD PTR birdexmvaluecmd  ; get the command word RS232 + Cmd
		mov     [bx],al             ; store the cmd
		mov     si,cx               ; lookup the parameter number
		mov     al,exmparamtbl[si]  ; get the param number
		mov     [bx]+1,al           ; store the selection
		mov     cx,2                ; setup for a 2 byte cmd
		call    send_serial_cmd     ; send the cmd
		cmp     ax,2                ; ck cmd went out OK
		je      getexmdata          ; continue if OK
		pop     ax                  ; clean up stack
		jmp     exmvaluefalseret    ; else ...quit
;
; Get the N Byte response into the rxdatabuf
;
getexmdata:     pop     ax                  ; get the users selection
		push    ax                  ; restore the stack
		mov     si,OFFSET exmdatasizetbl
		add     si,ax               ; figure out the correct number of bytes
		mov     cl,[si]             ; setup to receive N bytes for tbl
		xor     ch,ch
		mov     bx,OFFSET rxdatabuf ; receive data into the rxdatabuf
		call    get_serial_data     ; get the data
		cmp     ax,TRUE             ; verify all went OK
		je      decodeexmdata       ; if so...decode the data
		pop     ax                  ; clean up stack
		jmp     exmvaluefalseret    ; else..quit

decodeexmdata:  call    newline             ; add a line inbetween the Menu
		mov     cx,WORD PTR [rxdatabuf] ; get the data from the buffer
		pop     ax                  ; restore the menu selection
		shl     ax,1                ; setup to use the jmptbl
		mov     bx,ax
		jmp     exmvaluejmptbl[bx]  ; off to the word
;
; Display Status
;
high_byte       db  0
low_byte        db  0

exmstatus:      mov     high_byte,ch        ; save for later
		mov     low_byte,cl         ; save for later
					    ; Bird System Status output
bit15:          mov     ch,high_byte
		and     ch,80h              ; check bit 15 ..
		jz      bit15_0               ; if zero jump to message
		mov     dx,OFFSET bss_b15_1 ; load in message addr for bit set
		call    putstring           ; put on the console
		jmp     bit14               ; go to next
bit15_0:        mov     dx,OFFSET bss_b15_0 ; load in message addr for bit zero
		call    putstring           ; put to the console
bit14:          mov     ch,high_byte
		and     ch,40h              ; check bit 14 ..
		jz      bit14_0               ; if zero jump to message
		mov     dx,OFFSET bss_b14_1 ; load in message addr for bit set
		call    putstring           ; put on the console
		jmp     bit13               ; go to next
bit14_0:        mov     dx,OFFSET bss_b14_0 ; load in message addr for bit zero
		call    putstring           ; put to the console
bit13:          mov     ch,high_byte
		and     ch,20h              ; check bit 13 ..
		jz      bit13_0               ; if zero jump to message
		mov     dx,OFFSET bss_b13_1 ; load in message addr for bit set
		call    putstring           ; put on the console
		jmp     bit12               ; go to next
bit13_0:        mov     dx,OFFSET bss_b13_0 ; load in message addr for bit zero
		call    putstring           ; put to the console
bit12:          mov     ch,high_byte
		and     ch,10h              ; check bit 12 ..
		jz      bit12_0               ; if zero jump to message
		mov     dx,OFFSET bss_b12_1 ; load in message addr for bit set
		call    putstring           ; put on the console
		jmp     bit11               ; go to next
bit12_0:        mov     dx,OFFSET bss_b12_0 ; load in message addr for bit zero
		call    putstring           ; put to the console
bit11:          mov     ch,high_byte
		and     ch,8h              ; check bit 11 ..
		jz      bit11_0               ; if zero jump to message
		mov     dx,OFFSET bss_b11_1 ; load in message addr for bit set
		call    putstring           ; put on the console
		jmp     bit10               ; go to next
bit11_0:        mov     dx,OFFSET bss_b11_0 ; load in message addr for bit zero
		call    putstring           ; put to the console
bit10:          mov     ch,high_byte
		and     ch,4h              ; check bit 10 ..
		jz      bit10_0               ; if zero jump to message
		mov     dx,OFFSET bss_b10_1 ; load in message addr for bit set
		call    putstring           ; put on the console
		jmp     bit9                ; go to next
bit10_0:        mov     dx,OFFSET bss_b10_0 ; load in message addr for bit zero
		call    putstring           ; put to the console
bit9:           mov     ch,high_byte
		and     ch,2h              ; check bit 9 ..
		jz      bit9_0               ; if zero jump to message
		mov     dx,OFFSET bss_b9_1 ; load in message addr for bit set
		call    putstring           ; put on the console
		jmp     bit8               ; go to next
bit9_0:         mov     dx,OFFSET bss_b9_0 ; load in message addr for bit zero
		call    putstring           ; put to the console
bit8:           mov     ch,high_byte
		and     ch,1h              ; check bit 8 ..
		jz      bit8_0               ; if zero jump to message
		mov     dx,OFFSET bss_b8_1 ; load in message addr for bit set
		call    putstring           ; put on the console
		jmp     bit7               ; go to next
bit8_0:         mov     dx,OFFSET bss_b8_0 ; load in message addr for bit zero
		call    putstring           ; put to the console
bit7:           mov     cl,low_byte 
		and     cl,80h              ; check bit 7 ..
		jz      bit7_0               ; if zero jump to message
		mov     dx,OFFSET bss_b7_1 ; load in message addr for bit set
		call    putstring           ; put on the console
		jmp     bit6               ; go to next
bit7_0:         mov     dx,OFFSET bss_b7_0 ; load in message addr for bit zero
		call    putstring           ; put to the console
bit6:           mov     cl,low_byte  
		and     cl,40h              ; check bit 6 ..
		jz      bit6_0               ; if zero jump to message
		mov     dx,OFFSET bss_b6_1 ; load in message addr for bit set
		call    putstring           ; put on the console
		jmp     bit5               ; go to next
bit6_0:         mov     dx,OFFSET bss_b6_0 ; load in message addr for bit zero
		call    putstring           ; put to the console
bit5:           mov     cl,low_byte  
		and     cl,20h              ; check bit 5 ..
		jz      bit5_0               ; if zero jump to message
		mov     dx,OFFSET bss_b5_1 ; load in message addr for bit set
		call    putstring           ; put on the console
		jmp     bit4               ; go to next
bit5_0:         mov     dx,OFFSET bss_b5_0 ; load in message addr for bit zero
		call    putstring           ; put to the console
bit4:           mov     cl,low_byte
		and     cl,01eh              ; ck bits 1 through 4
		cmp     cl,2h               ; see if in position mode
		jne     ckanglemode         ; if not ck angle mode
		mov     dx,OFFSET positionmodemsg  ; else, set position msg
		jmp     sendmodemsg
ckanglemode:    cmp     cl,4h               ; see if in angle mode
		jne     ckmatrixmode        ; if not ck matrix mode
		mov     dx,OFFSET anglemodemsg     ; else, set anglemsg
		jmp     sendmodemsg
ckmatrixmode:   cmp     cl,6h               ; see if in matrix mode
		jne     ckposanglemode      ; if not ck pos/angle mode
		mov     dx,OFFSET matrixmodemsg    ; else, set matrix msg
		jmp     sendmodemsg
ckposanglemode: cmp     cl,8h               ; see if in pos/angle mode
		jne     ckposmatrixmode     ; if not ck pos/matrix mode
		mov     dx,OFFSET posanglemodemsg  ; else, set pos/angle msg
		jmp     sendmodemsg
ckposmatrixmode: cmp    cl,0ah              ; see if in pos/matrix mode
		jne     ckfacttestmode      ; if not ck factory test output
		mov     dx,OFFSET posmatrixmodemsg ; else, set pos/matrix msg
		jmp     sendmodemsg
ckfacttestmode: cmp     cl,0ch              ; see if in factory test mode
		jne     ckquatermode        ; if not ck quater mode
		mov     dx,OFFSET facttestmodemsg ; else, set factory test msg
		jmp     sendmodemsg
ckquatermode:   cmp     cl,0eh              ; see if in pos/quater mode
		jne     ckposquatermode     ; if not ck pos/quater mode
		mov     dx,OFFSET quatermodemsg ; else, set pos/quater msg
		jmp     sendmodemsg
ckposquatermode:   cmp    cl,010h           ; see if in quater mode
		jne     invalidmode         ; if not set illegal mode
		mov     dx,OFFSET posquatermodemsg ; else, set quater msg
		jmp     sendmodemsg

invalidmode:    mov     dx,OFFSET invalidmodemsg
sendmodemsg:    call    putstring           ; send the msg to the console
		mov     cl,low_byte
		and     cl,1                ; see if bit 0 is on
		jz      sendpointmsg
		mov     dx,OFFSET streammodemsg ; else put up the stream msg
		jmp     sendoutmodemsg
sendpointmsg:   mov     dx,OFFSET pointmodemsg  ; set the point mode msg
sendoutmodemsg: call    putstring           ; send the msg to the console
		jmp     exmvaluetrueret
;
; Examine Software Revison Number
;
exmrevison:     mov     dx,OFFSET softwarerevmsg ; send the software rev msg
		call    putstring
		xor     ah,ah               ; clear AH
		mov     al,cl               ; get the Major Revision value
		call    displayunsigned     ; display the value
		mov     al,'.'              ; put up a .
		call    putchr
		mov     al,ch               ; get the Minor Revision value
		call    displayunsigned     ; display the value
		jmp     exmvaluetrueret
;
; Examine Crystal Frequency
;
exmcrystal:     mov     dx, OFFSET crystalfreqmsg   ; put up the msg
		call    putstring
		mov     ax,cx               ; get the crystal frequency
		call    displayunsigned     ; display the frequency
		jmp     exmvaluetrueret
;
; Examine Range Scale
;
exmrangescale:  mov     dx,OFFSET rangemsg  ; put up range msg
		call    putstring
		cmp     cl,0                ; if CL = 0 the max range = 36"
		je      sendrange36
		mov     dx,OFFSET range72msg ; else range is 72"
		jmp     sendrangemsg
sendrange36:    mov     dx,OFFSET range36msg ; set range msg to 36"
sendrangemsg:   call    putstring            ; send the msg
		jmp     exmvaluetrueret
;
; Examine filter status
;
exmfilteronoff: mov     ch,cl
		mov     dx,OFFSET acnarrowfiltermsg ; get the msg
		call    putstring
;
; ck the AC Narrow filter bit
;
		test    cl,4                ; see if on
		jz      setacnarrowon       ; if 0 send the ON msg
		mov     dx,OFFSET offmsg    ; else send the OFF msg
		jmp     sendacnarrowmsg
setacnarrowon:  mov     dx,OFFSET onmsg
sendacnarrowmsg:
		call    putstring           ; display it..
;
; ck the AC filter bit
;
		mov     dx,OFFSET acwidefiltermsg ; get the msg
		call    putstring
		test    cl,2                ; see if on
		jz      setacwideon         ; if 0 send the ON msg
		mov     dx,OFFSET offmsg    ; else send the OFF msg
		jmp     sendacwidemsg
setacwideon:    mov     dx,OFFSET onmsg
sendacwidemsg:  call    putstring           ; display it..
;
; ck the DC filter bit
;
		mov     dx,OFFSET dcfiltermsg ; get the msg
		call    putstring
		test    cl,1                ; see if on
		jz      setdcon             ; if 0 send the ON msg
		mov     dx,OFFSET offmsg    ; else send the OFF msg
		jmp     senddcmsg
setdcon:        mov     dx,OFFSET onmsg
senddcmsg:      call    putstring           ; display it..
		jmp     exmvaluetrueret
;
; Examine the filter constant table - Alpha Min
;
exmfilterconst:
		mov     cx,7
		mov     bx,OFFSET exmdcfiltermsgtbl
		mov     si,OFFSET rxdatabuf

		cmp     posk,POSK144        ; ck for extended range
		jne     displayfiltermsg1
		mov     bx,OFFSET extexmdcfiltermsgtbl ; setup for extended range

displayfiltermsg1:
		mov     dx,[bx]
		call    putstring           ; display the message

		push    bx
		push    cx
		mov     format,4            ; setup for 4 decimal places..
		mov     conv_const,UNITK    ; ...0.00 to 0.99996
		mov     cx,1                ; convert 1 word...
		mov     bx,si               ;...in the rxdatabuf
		call    converttounits      ; display number as a float
		pop     cx
		pop     bx

		inc     bx                  ; point to next message
		inc     bx
		inc     si                  ; point to the next data value
		inc     si
		loop    displayfiltermsg1

		jmp     exmvaluetrueret

;
; Examine the Measurement Rate
;
; ** NOTE ** this section of code will be modified to convert the raw
;            number returned from the bird to a rate..for now the raw
;            number is displayed
;
exmmeasurementrate:
		mov     dx,OFFSET measurementratemsg
		call    putstring           ; display the msg
		mov     ax,cx               ; get the counts
		call    displayunsigned     ; display the counts
		jmp     exmvaluetrueret

;
; Examine Data Ready Output Enable State
;
exmdatardyout:
		mov     dx,OFFSET senddatastatemsg
		call    putstring
		cmp     cl,0
		je      senddatastateoff
		mov     dx,OFFSET onmsg
		call    putstring
		jmp     exmvaluetrueret
senddatastateoff:
		mov     dx,OFFSET offmsg
		call    putstring
		jmp     exmvaluetrueret

;
; Examine Data Ready Character
;
exmdatardychar:
		mov     dx,OFFSET datardycharmsg
		call    putstring
		mov     ax,cx
		xor     ah,ah
		call    displayunsigned
		jmp     exmvaluetrueret

;
; Examine Error Code
;
exmerrorcode:
		mov     dx,OFFSET errorcodemsg
		call    putstring
		mov     ax,cx
		xor     ah,ah
		call    displayunsigned
		jmp     exmvaluetrueret
;
; Examine Error Mask
;
exmerrormsk:
		cmp     cl,0
		jne     ckerrmsk1
			mov     dx,OFFSET errormskmsg0
		jmp     senderrmskstring
ckerrmsk1:
		cmp     cl,1
		jne     ckerrmsk2
			mov     dx,OFFSET errormskmsg1
		jmp     senderrmskstring
ckerrmsk2:
		cmp     cl,2
		jne     errmsk3
			mov     dx,OFFSET errormskmsg2
		jmp     senderrmskstring
errmsk3:
			mov     dx,OFFSET errormskmsg3
senderrmskstring:
			call    putstring
		jmp     exmvaluetrueret

;
; Examine DC Filter Constant Table Data
;
exmdcfiltertbl:
			mov     cx,7
			mov     bx,OFFSET exmdcfiltermsgtbl
			mov     si,OFFSET rxdatabuf

		cmp     posk,POSK144        ; ck for extended range
		jne     displayfiltermsg
		mov     bx,OFFSET extexmdcfiltermsgtbl ; setup for extended range

displayfiltermsg:
			mov     dx,[bx]
			call    putstring           ; display the message
			mov     ax,[si]             ; get the Vm data value
			call    displayunsigned     ; display the data value
			inc     bx                  ; point to next message
			inc     bx
			inc     si                  ; point to the Vm data value
			inc     si
		    loop    displayfiltermsg

			jmp     exmvaluetrueret

;
; Examine Filter Constant - Alpha Max
;
exmfilteralphamax:
		mov     cx,7
		mov     bx,OFFSET exmdcfiltermsgtbl
		mov     si,OFFSET rxdatabuf

		cmp     posk,POSK144        ; ck for extended range
		jne     displayfiltermsg2
		mov     bx,OFFSET extexmdcfiltermsgtbl ; setup for extended range

displayfiltermsg2:
		mov     dx,[bx]
		call    putstring           ; display the message

		push    bx
		push    cx
		mov     format,4            ; setup for 4 decimal places..
		mov     conv_const,UNITK    ; ...0.00 to 0.99996
		mov     cx,1                ; convert 1 word...
		mov     bx,si               ;...in the rxdatabuf
		call    converttounits      ; display number as a float
		pop     cx
		pop     bx

		inc     bx                  ; point to next message
		inc     bx
		inc     si                  ; point to the next data value
		inc     si
		loop    displayfiltermsg2

		jmp     exmvaluetrueret

;
; Examine Glitch Checking ON/OFF
;
exmglitchcheckonoff:
			 cmp     cl,TRUE
			 je      glitchcheckon
			 mov     dx,OFFSET glitchcheckstateoffmsg
			 call    putstring
			 jmp     exmvaluetrueret
glitchcheckon:
			 mov     dx,OFFSET glitchcheckstateonmsg
			 call    putstring
			 jmp     exmvaluetrueret

;
; Examine Model
;
exmmodel:       mov     dx,OFFSET modelmsg          ; display the user msg
		call    putstring
		mov     rxdatabuf+10,'$'            ; set the line term. char
		mov     dx,OFFSET rxdatabuf         ; get the address of the string
		call    putstring                   ; display the string
		jmp     exmvaluetrueret

;
; Examine Expanded Error Code
;
exmexterrorcode:
		mov     dx,OFFSET errorcodemsg
		call    putstring
		mov     ax,cx
		xor     ah,ah
		call    displayunsigned
	mov     dx,OFFSET expandedcodemsg
	call    putstring
		mov     dx,OFFSET exterrorcodeaddrmsg
		call    putstring
	push    cx
		mov     al,ch
	and     al,00011111b            ; assume expanded address mode
	cmp     expaddrmodeflg,TRUE
	je      displayexterraddr
	and     al,00001111b
displayexterraddr:
		xor     ah,ah
		call    displayunsigned
		mov     dx,OFFSET exterrorcodecmdmsg
		call    putstring
	pop     cx
		mov     al,ch
	shr     al,4                    ; assume expanded normal mode
	cmp     expaddrmodeflg,FALSE
	je      displayexterrcmd
	shr     al,1
displayexterrcmd:
	and     al,00000111b
		xor     ah,ah
		call    displayunsigned

		jmp     exmvaluetrueret

;
; Examine XYZ Reference Frame ON/OFF
;
exmxyzrefframe:
			 cmp     cl,TRUE
			 je      xyzrefframeon
			 mov     dx,OFFSET xyzrefframestateonmsg
			 call    putstring
			 jmp     exmvaluetrueret
xyzrefframeon:
			 mov     dx,OFFSET xyzrefframestateoffmsg
			 call    putstring
			 jmp     exmvaluetrueret


;
; Examine FBB/Host Delay
;
exmhostdelay:
		mov     dx,OFFSET fbbhostdelaymsg
		call    putstring           ; display the msg
		mov     ax,cx               ; get the counts
		call    displayunsigned     ; display the counts
		jmp     exmvaluetrueret
;
; Examine Saved Config State
;
exmfbbgroupdata:
			cmp     cl,TRUE                     ; if set then it has
			jne     sendgroupdataoffmsg         ; .. been saved
sendgroupdataonmsg:
			mov     dx,OFFSET groupdataonmsg
			call    putstring
			jmp     exmvaluetrueret
sendgroupdataoffmsg:
		    mov     dx,OFFSET groupdataoffmsg
			call    putstring
			jmp     exmvaluetrueret

;
; Examine System Configuration
;
exmsysconfig:
		call    displaydeviceconfig
		jmp     exmvaluetrueret

;
; Examine FBB Configuration
;
exmfbbconfig:
		call    showfbbconfig
		jmp     exmvaluetrueret
;
; Examine FBB ARMed State
;
exmfbbarmed:
		call    displaydeviceconfig
		jmp     exmvaluetrueret
;
; Examine Auto Configuration - 1 Transmitter, N Receivers
;
exmautoconfig1xmtrnrcvr:
		call    showfbbconfig
		jmp     exmvaluetrueret
;
; Return from Examine Value
;
exmvaluefalseret:
		mov     ax,FALSE            ; return FALSE
		jmp     exmvalueret
exmvaluetrueret:
		call    hitkeycontinue      ; wait for confirmation
		mov     ax,TRUE             ; return TRUE
exmvalueret:    pop     dx                  ; restore regs
		pop     cx
		pop     bx
		ret
bird_examinevalue endp

;=============================================================================
;   bird_crtsync        Bird CRT Synchronization Commands
;   ------------
;
;   Parameters Passed:  none
;   Return Value:       none
;                       TRUE, if a Change Value command was executed
;                       FALSE, if command could not be executed
;                       ESC_SEL, if the user selected ESC_SEL
;   Registers Modified: AX
;   Remarks:            Sends the CRT sync command down to the Bird.
;                       Displays the data from the 'pickup' if in Display
;                       Pickup Mode
;=============================================================================
;
bird_crtsync    proc    near
		push    cx                  ; save regs
		push    dx
;
; Send the User the Menu
;
		mov     dx,OFFSET crtsyncmenuptr ; get the menu
		mov     cx,4                ; 4 menu choices
		call    sendmenu
		cmp     ax,ESC_SEL          ; ck for user ESC
		jne     readcpucrystalfreq
		jmp     crtsyncret
;
; First, Get the Crystal Frequency
;
readcpucrystalfreq:
		push    ax                  ; save the user's entry
		call    getcrystalfreq      ; init crystalfreq
		cmp     ax,TRUE             ; everything go OK?
		pop     ax                  ; restore the user's entry
		je      sendcrtsync         ; if so ..continue
		jmp     crtsyncfalseret     ; else,.. home
;
; Initialize the txdatabuf with the command
;
sendcrtsync:    xor     ch,ch               ; set for cmd data = 0
		mov     bx,OFFSET txdatabuf ; use the txdatabuf for the cmd
		mov     cl,birdcrtsynccmd   ; load the command byte
		mov     [bx],cx             ; initialized for 'A',0
					    ; ...CRT SYNC OFF
;
; Check the user's response 3 - Display CRT Value
;
		cmp     ax,3                ; see if the '255' mode selected
		je      getsyncinfo
		jmp     cksyncoff           ; if not..ck other modes
;
; Send the command and display the voltage and the rate
;
getsyncinfo:    mov     BYTE PTR[bx]+1,0ffh ; set cmd data to 255
getsyncdata:    mov     bx,OFFSET txdatabuf ; needed in the following loop
		mov     cx,2                ; setup for a 2 byte cmd
		call    send_serial_cmd     ; send the cmd
		cmp     ax,2                ; ck cmd went out OK
		je      readpickupinfo
		jmp     crtsyncfalseret
readpickupinfo: mov     cx,4                ; setup to receive 4 bytes
		mov     bx,OFFSET rxdatabuf ; receive data into the rxdatabuf
		call    get_serial_data     ; get the data
		cmp     ax,TRUE             ; verify all went OK
		je      decodesyncdata      ; if so...decode the data
		jmp     crtsyncfalseret
;
; First display Volts
;
decodesyncdata: mov     bx,OFFSET rxdatabuf
		mov     format,4
		mov     conv_const,VOLTK    ; set for Voltage conversion
		mov     cx,1                ; convert 1 word pointed to..
		call    converttounits      ; .. by BX, currently rxdatabuf
					    ; ...display the data
;
; Next display the Rate.. to determine the rate the crystal frequency is
; multiplied by the CRYSTALRATEK (12500).  The crystal frequency is
; multiplied by 1000 to increase the resolution when the operation:
; (CRYSTALRATEK * crystal frequency * 1000)/number of counts, is performed
;
		mov     al,TAB              ; add some space inbetween data
		call    putchr
		mov     bx,OFFSET rxdatabuf+2   ; get the number of counts
		mov        si,WORD PTR [bx]    ; save data for display in a bit
		mov        ax,1000                ; multiply the crystalfreq by 1000
		mul        crystalfreq            ; ..to increase resolution of the
					    ; ..rate display to 2 dec. places
		mov     conv_const,CRYSTALRATEK ; get the multiplier
		mul        conv_const            ; build DX:AX as the dividend
		cmp        WORD PTR [bx],0        ; trap divide by 0 ...
		je        skipdivide          ; ..else get INT 0
		div        WORD PTR [bx]        ; divide by the number of counts
		shr        ax,1             ; divide by 2
		mov        [bx],ax                ; assign the result to where
					    ; ..the number of counts was
skipdivide:        mov        conv_const,INTK     ; set the conv const for display
		mov     cx,1                ; setup to display 1 word
		mov     format,2            ; 2 decimal places
		call    converttounits      ; convert and display the data
		call    newline             ; send a CR LF to the console
;
; Stay in a loop display values until a key is hit
;
		call    ckkeyrdy            ; is key ready
		cmp     ax,TRUE             ; if so return TRUE
		je      killcrtdisplay
		jmp     getsyncdata         ; else get another set of points
killcrtdisplay:
		call    clearkey            ; clear the key board
		mov     bx,OFFSET txdatabuf    ; reset the transmit pointer
		xor        al,al                ; set AL = 0 to shut of sync
		mov        BYTE PTR [bx]+1,al  ; set the sync mode off
		jmp        sendsynccmd

cksyncoff:      cmp     ax,0                ; command is CRT sync OFF?
		jne     cksyncon            ; if not CRT sync ON
		jmp     sendsynccmd         ; send the cmd
cksyncon:
		mov     BYTE PTR[bx]+1,al   ; store in the cmd string

sendsynccmd:    mov     cx,2                ; setup for a 2 byte cmd
		call    send_serial_cmd     ; send the cmd
		cmp     ax,2                ; ck cmd went out OK
		je      crtsynctrueret
		jmp     crtsyncfalseret

crtsynctrueret: mov     ax,TRUE
		mov     dx,OFFSET crtsyncmsg
		call    putstring
crtsyncret1:    call    hitkeycontinue
		jmp     crtsyncret
crtsyncfalseret:
		mov     ax,FALSE
crtsyncret:     pop     dx                  ; restore regs
		pop     cx
		ret
bird_crtsync    endp

;*****************************************************************************
_TEXT           ENDS
																       

   
		end

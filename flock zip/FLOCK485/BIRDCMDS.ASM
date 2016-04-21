title   BIRD COMMANDS
subttl  Assembly Bird Commands for FBBTEST
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
;                          fixed rate display in bird_crtsync to be crystal
;                            dependent...does the math with crystalfreq
;         2/4/91     jf - added code to display button values
;                         modified filter names for AC Wide/Narrow filters
;                          sinslopetbl[62] modified to prevent overflow
;         2/20/91    jf - added initialization of factory test mode to
;                         birdloadconfig
;         3/16/91    jf - added new command CRT sync for Fast Vertical Retrace
;         4/3/91     jf - fixed bug in birdexaminevalue command to display
;                         filter on/off status properly
;         5/10/91    eb - printmatrix modified to provide blank lines between 
;                         printouts
;         5/15/91    jf - now usind FBBSER.inc for the FBBTEST code
;         6/10/91    jf - continued mods for FBBTEST code
;         6/11/91    jf - removed the point command ('B') from the
;                         position,angle,matrix,posmatrix,posangle cmds
;         9/17/91    jf - added posk for POSK36 and POSK72
;         10/10/91   jf - put utility functions in CMDUTIL.asm
;                    jf - modified birdposmode definitions
;         10/11/91   jf - fixed bug in synchronization that did not allow
;                         the sync mode to shut off.
;                         Angle align, ref frame, hemisphere,report rate commands
;                         did not work because count of bytes in commands was
;                         1 too small when send out as an FBBRS232CMD.
;                         Examine data ready character would give wrong value is
;                         preceeded by examine measurement rate or alpha min
;                         Change data ready character prompt message was not displayed
;                         Report rate command deleted since stream mode not allowed
;                         when host is using the FBB
;         11/1/91    jf - added exm/chg alpha max and glitchchecking
;         11/7/91    jf - added exm model
;         11/10/91   jf - changed glitch checking to sudden output change
;         12/27/91   jf - fixed bug in button read routine
;         7/2/92     jf - added quaternions
;         8/11/92    jf - added extended address mode capability
;         2/18/93    jf - update bird examine value status messages
;         3/6/93     jf - Sync frequency is now divided by 2
;         9/29/94    sw - Bird System Status 16 bits decoded
;
;          <<<< Copyright 1991 Ascension Technology Corporation >>>>
;*****************************************************************************
;*****************************************************************************
		INCLUDE menudef.inc             ; get menu definitions
		INCLUDE asctech.inc             ; Ascension Technology definitions
		INCLUDE fbbtest.inc             ; fbbtest definitions
		INCLUDE fbbser.inc              ; serial definitions
		.286                            ; 286 instructions allowed
;
; Public Symbols
;
		PUBLIC  bird_position
		PUBLIC  bird_angle
		PUBLIC  bird_matrix
		PUBLIC  bird_quaternions
		PUBLIC  bird_posquaternions
		PUBLIC  bird_positionangle
		PUBLIC  bird_positionmatrix
		PUBLIC  bird_anglealign
		PUBLIC  bird_hemisphere
		PUBLIC  bird_reference
		PUBLIC  bird_sleep
		PUBLIC  bird_mousebuttons
		PUBLIC  bird_changevalue
		PUBLIC  bird_examinevalue
		PUBLIC  bird_sync
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
		EXTRN   converttounits:NEAR
		EXTRN   convert:NEAR
		EXTRN   printmatrix:NEAR
		EXTRN   getcrystalfreq:NEAR
	EXTRN   getaddrmode:NEAR
		EXTRN   getangle:NEAR
		EXTRN   ckdoagain:NEAR
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
		EXTRN   hostget_serial_record:NEAR
		EXTRN   hostget_serial_data:NEAR
		EXTRN   hostsend_serial_cmd:NEAR
		EXTRN   hostclear_rx:NEAR
		EXTRN   waitforchar:NEAR

;
; External Command Utility Variables
;
		EXTRN   format:WORD
		EXTRN   anglecmd:WORD
		EXTRN   conv_const:WORD
		EXTRN   crystalfreq:WORD
		EXTRN   posk:WORD
;
; External Menuing V*ariables
;
		EXTRN   asciibuf:BYTE
;
; External Birdmain Variables
;
		EXTRN   buttonmode:WORD
		EXTRN   buttonvalue:WORD
		EXTRN   outputmode:WORD
		EXTRN   birdposmode:BYTE
;
; External Serial Variables
;
		EXTRN   phaseerror_count:WORD
;
; External FBB Variables
;
	EXTRN   fbb_address:BYTE
	EXTRN   fbb_stopaddress:BYTE
		EXTRN   fbbaddrmask:BYTE
		EXTRN   fbbgroupmodeflg:WORD
;
;*****************************************************************************

_DATA               SEGMENT WORD PUBLIC 'DATA'

;
; Storage for Serial Data to and from the Bird
;
rxdatabuf           db 40 dup (?)           ; storage for the received datas
txdatabuf           db 40 dup (?)           ; storage for Bird cmd strings
temptxbuf           db 40 dup (?)           ; temporary tx data storage

fbbsyncmode         db  0                   ;
expaddrmodeflg      db  FALSE               ;

;
; FBB Configuration Structure
;
fbbconfigmode       db  0                   ;
fbbdevices          dw  0                   ; bitwise active devices
fbbdependents       dw  0                   ; bitwise dependent devices
extfbbdevices       dw  0                   ; bitwise active extended devices


;
; Commands to the Bird
;
RS232CMDCHAR        EQU 0   ; command 0 + DIP ADDRESS or Broadcast Address

birdstreamcmd       db  RS232CMDCHAR,'@'                 ; Stream
birddumpaddresscmd  db  RS232CMDCHAR,'a'                 ; Dump Data from Address
birdfactorytestcmd  db  RS232CMDCHAR,'z'                 ; Factory test cmd
birdsynccmd         db  RS232CMDCHAR,'A'                 ; Sync
birdpointcmd        db  RS232CMDCHAR,'B'                 ; Point
birdwakeupcmd       db  RS232CMDCHAR,'F'                 ; Wakeup/RUN
birdsleepcmd        db  RS232CMDCHAR,'G'                 ; Sleep
birdrefframecmd     db  RS232CMDCHAR,'H'                 ; Reference Frame
birdanglealigncmd   db  RS232CMDCHAR,'J'                 ; Angle Align
birdhemispherecmd   db  RS232CMDCHAR,'L'                 ; Hemisphere
birdbuttonmodecmd   db  RS232CMDCHAR,'M'                 ; Button Mode
birdbuttonreadcmd   db  RS232CMDCHAR,'N'                 ; Button Read
birdexmvaluecmd     db  RS232CMDCHAR,'O'                 ; Examine Value
birdchgvaluecmd     db  RS232CMDCHAR,'P'                 ; Change Value
birdrate1           db  RS232CMDCHAR,'Q'                 ; Max Rate
birdrate2           db  RS232CMDCHAR,'R'                 ; Max Rate/2
birdrate8           db  RS232CMDCHAR,'S'                 ; Max Rate/8
birdrate32          db  RS232CMDCHAR,'T'                 ; Max Rate/32
birdposcmd          db  RS232CMDCHAR,'V'                 ; Position
birdanglecmd        db  RS232CMDCHAR,'W'                 ; Angles
birdmatrixcmd       db  RS232CMDCHAR,'X'                 ; Matrix
birdposanglecmd     db  RS232CMDCHAR,'Y'                 ; Position/Angle
birdposmatrixcmd    db  RS232CMDCHAR,'Z'                 ; Position/Matrix
birdquaternionscmd  db  RS232CMDCHAR,'\'                 ; Quaternions
birdposquaternionscmd  db  RS232CMDCHAR,']'              ; Pos/Quaternions

;
; Messages
;
azimuthmsg          db  'Input the Azimuth (###.##):','$'
elevationmsg        db  'Input the Elevation (##.##):','$'
rollmsg             db  'Input the Roll (###.##):','$'
configfilepromptmsg db  'Enter the CONFIGURATION file name to send to the Bird: ','$'
birdanglealignmsg   db  'Angle Alignment data sent to the Bird',CR,LF,'$'
alignpromptmsg      db  CR,LF,'Enter the angles used for new angle alignment...',CR,LF,'$'
readconfigdatamsg   db  '...reading configuration Data from the Bird',CR,LF,'$'
compareconfigdatamsg db '...comparing data sent with data returned..',CR,LF,'$'
configokmsg         db  'configuration loaded successfully',CR,LF,'$'
configbadmsg        db  'configuration NOT loaded successfully',CR,LF,'$'
hemispheremsg       db  'Hemisphere data sent to bird',CR,LF,'$'
refmsg              db  'New Reference Frame sent to bird',CR,LF,'$'
refpromptmsg        db  CR,LF,'Enter the angles used for new reference frame...',CR,LF,'$'
sleepwakemsg        db  'Sent the Sleep/Wake Command to the Bird',CR,LF,'$'
buttonquesmsg1      db  'Do you want the Button Byte added to the End of Data Stream','$'
buttonquesmsg2      db  CR,LF,'Display Button Value Now','$'
buttonmsg           db  CR,LF,'Hit any key to stop printing the button value',CR,LF,'$'
buttondisplaymsg    db  CR,LF,'Button = ','$'
chgvaluemsg         db  CR,LF,'New Values Sent to the Bird',CR,LF,'$'
acnarrowfilterques  db  CR,LF,'Do you want the AC Narrow Notch filter OFF','$'
acwidefilterques    db  CR,LF,'Do you want the AC Wide Notch filter OFF','$'
dcfilterques        db  CR,LF,'Do you want the DC filter OFF','$'
filterconstmsg      db  CR,LF,'Enter the new Filter Constant (0 to 0.99996): ','$'
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
bss_b5_1            db  CR,LF,'Bird in SLEEP mode',CR,LF,'$'
bss_b5_0            db  CR,LF,'Bird in RUN mode',CR,LF,'$'

posmodemsg          db  'Position output selected ','$'
factorymodemsg      db  'Factory use output selected ','$'
anglemodemsg        db  'Angle output selected ','$'
matrixmodemsg       db  'Matrix output selected ','$'
posanglemodemsg     db  'Position/Angle output selected ','$'
posmatrixmodemsg    db  'Position/Matrix output selected ','$'
quaternmodemsg      db  'Quaternion output selected ','$'
posquaternmodemsg   db  'Position/Quaternion output selected ','$'
invalidmodemsg      db  'Illegal Output mode detected',CR,LF,'$'
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
syncmsg             db  'Synchronization sent to the Bird',CR,LF,'$'
pointmodepromptmsg  db  CR,LF,'Hit the B key to read Bird data or any other key to Quit',CR,LF,'$'
hostdelayquesmsg    db  'Enter the Number of 10 uS Counts desired for the FBB Host Delay: ','$'
fbbhostdelaymsg     db  'FBB Host Delay in 10 uS counts: ','$'
fbbarmquesmsg       db  'Do you want to ARM/Initialize the FBB system now','$'
fbbrunquesmsg       db  'Should the FBB system be RUNNING','$'
senddataquesmsg     db  'Should the Bird Output the Ready Character','$'
fbbactivedevicesheadermsg db CR,LF,'Devices RUNNING on the FBB are...',CR,LF,LF,'$'
fbbactivedevicemsg1 db 'FBB Device ','$'
fbbactivedevicemsg2 db ' RUNNING Bit is ','$'
fbbdependentsheadermsg db CR,LF,LF,'DEPENDENT FBB Devices on the FBB are...',CR,LF,LF,'$'
fbbdependentmsg1    db 'FBB Device ','$'
fbbdependentmsg2    db ' Dependent Bit is ','$'
askchgactivequesmsg    db  CR,LF,'Enter the FBB device address (1-14) whose RUNNING status',CR,LF,'you want to toggle ON/OFF or ESC to end: ','$'
askchgdependentquesmsg db  CR,LF,'Enter the FBB device address (1-14) whose DEPENDENT status',CR,LF,'you want to toggle ON/OFF or ESC to end: ','$'
syncmodemsg         db  CR,LF,LF,'FBB Sync Mode: ','$'
runstatemsg         db  CR,LF,LF,'FBB RUNning State: ','$'
armstatemsg         db  CR,LF,LF,'FBB ARMed State: ','$'
configmodemsg       db  CR,LF,LF,'FBB Config Mode: ','$'
senddatastatemsg    db  CR,LF,LF,'Send Data Ready State: ','$'
senddatardycharquesmsg db 'Enter the new Data Ready Character (decimal): ','$'
deviceconfigmsg     db  CR,LF,'FBB Config [ACC RUNNING RCVR ERC XMTR3 XMTR2 XMTR1 XMTR0]:','$'
chgarmedques        db  CR,LF,'Do you want to ARM the Bird','$'
autoconfig1xmtrnrcvrques db CR,LF,'Enter the number of units (6DFOBs and ERCs) in the Flock: ','$'
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
glitchcheckstateoffmsg db  CR,LF,'Sudden Output Changes are output ','$'
glitchcheckstateonmsg  db  CR,LF,'Sudden Output Changes are NOT output ','$'
modelmsg            db  CR,LF,'Model is: ','$'
groupdataques       db  CR,LF,'Do you want to enable group data mode','$'
groupdatamodemsg    db  CR,LF,'Group data info sent','$'
groupdataonmsg      db  CR,LF,'FBB Group Data Gathering is Enabled','$'
groupdataoffmsg     db  CR,LF,'FBB Group Data Gathering is Disabled','$'

;
; Error Messages
;
phaseerrormsg       db  '*NOTE* Phase Errors have occured: ','$'
invalidfilemsg      db  '** ERROR ** invalid file name',CR,LF,'$'
badfileformatmsg    db  '** ERROR ** bad file format',CR,LF,'$'
badbirddatamsg      db  '** ERROR ** did not get back Dump Array from the Bird',CR,LF,'$'
compareerrormsg1    db  '** ERROR ** sent ','$'
compareerrormsg2    db  ' received ','$'
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
; Sleep Menu
;
sleepmenuptr        dw  sleepmenuprompt,sleepmenu0,sleepmenu1
sleepmenuprompt     db  'Enter Selection:','$'
sleepmenu0          db  'Sleep','$'
sleepmenu1          db  'Wake','$'

;
; Change Value Menu
;
chgvaluemenuptr     dw  chgvaluemenuprompt,chgvaluemenu0
		    dw  chgvaluemenu1,chgvaluemenu2,chgvaluemenu3
		    dw  chgvaluemenu4,chgvaluemenu5,chgvaluemenu6
		    dw  chgvaluemenu7,chgvaluemenu8,chgvaluemenu9
		    dw  chgvaluemenu10,chgvaluemenu11,chgvaluemenu12
		    dw  chgvaluemenu13,chgvaluemenu14,chgvaluemenu15
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
chgvaluemenu11      db  'Set FBB Host Delay','$'
chgvaluemenu12      db  'Set FBB Configuration','$'
chgvaluemenu13      db  'Set FBB ARMed','$'
chgvaluemenu14      db  'FBB Group Data','$'
chgvaluemenu15      db  'FBB Auto Config - 1 Trans/N Rec','$'

;
; Table of the Parameter Number of the Choices listed Above
;
chgparamtbl         db   0,3,4,5,6,8,9,11,12,13,14,32,33,34,35,50

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
	    dw  exmvaluemenu22
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
exmvaluemenu17      db  'FBB Host Delay','$'
exmvaluemenu18      db  'FBB Configuration','$'
exmvaluemenu19      db  'FBB ARMed','$'
exmvaluemenu20      db  'FBB Group Data','$'
exmvaluemenu21      db  'FBB System Status','$'
exmvaluemenu22      db  'FBB Auto Config - 1 Trans/N Rec','$'

;
; Setup a Table for the examine value parameter numbers
;
exmparamtbl         db  0,0,1,2,3,4,5,6,8,9,10,11,12,13,14,15,16,32,33,34,35,36,50

;
; Setup a Table for the examine value response size in bytes
;
exmdatasizetbl      db  0,2,2,2,2,2,14,2,1,1,1,1,14,14,1,10,2,2,5,14,1,14,5

;
; Range Menu
;
rangemenuptr        dw  rangemenuprompt,rangemenu0,rangemenu1
rangemenuprompt     db  'Select Scaling Range:','$'
rangemenu0          db  '36 inch range','$'
rangemenu1          db  '72 inch range','$'

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
extexmdcfiltermsg2     db  CR,LF,'For the Range 35 to 46 inches, value is ','$'
extexmdcfiltermsg3     db  CR,LF,'For the Range 46 to 63 inches, value is ','$'
extexmdcfiltermsg4     db  CR,LF,'For the Range 63 to 79 inches, value is ','$'
extexmdcfiltermsg5     db  CR,LF,'For the Range 79 to 96 inches, value is ','$'
extexmdcfiltermsg6     db  CR,LF,'For the Range 96 to 116 inches, value is ','$'
extexmdcfiltermsg7     db  CR,LF,'For the Range 116+ inches, value is ','$'


;
; FBB Sync Menu
;
fbbsyncmodemenuptr  dw  fbbsyncmenuprompt,fbbsyncmenu0
		    dw  fbbsyncmenu1,fbbsyncmenu2,fbbsyncmenu3
fbbsyncmenuprompt   db  'Select FBB Synchronization Mode:','$'
fbbsyncmenu0        db  'No Sync (bit 0 = 1)','$'
fbbsyncmenu1        db  'External Hardware Sync (bit 1 = 1)','$'
fbbsyncmenu2        db  'FBB Sync (bit 2 = 1)','$'
fbbsyncmenu3        db  'Host Sync (bit 3 = 1)','$'
;
; Values for fbbsync corresponding to menu choices
;
fbb_sync_tbl        db  1,2,4,8

;
; Sync Menu
;
syncmenuptr      dw  syncmenuprompt,syncmenu0
		    dw  syncmenu1,syncmenu2,syncmenu3,syncmenu4
syncmenuprompt   db  'Select CRT Sync Mode:','$'
syncmenu0        db  'Sync OFF','$'
syncmenu1        db  'CRT Sync - CRT Vertical Retrace Greater than 72 Hz','$'
syncmenu2        db  'CRT Sync - CRT Vertical Retrace Less than 72 Hz','$'
syncmenu3        db  'CRT Sync - Display Pickup Info','$'
syncmenu4        db  'Host Sync ON','$'

;
; Error Mask Menu
;
errormaskmenuptr     dw  errormaskmenuprompt,errormaskmenu0
		     dw  errormaskmenu1,errormaskmenu2
errormaskmenuprompt  db  'Select Error Mask Mode:','$'
errormaskmenu0       db  'Fatal Errors are Blinked Forever','$'
errormaskmenu1       db  'Fatal Errors are Blinked Once','$'
errormaskmenu2       db  'Fatal Errors are NOT Blinked','$'

;
; Software Revision Specific Addresses of data inside the Bird
;
s_addr              dw  0b9h
xc_addr             dw  019eh
sc_addr             dw  01b0h
xmtraxis_addr       dw  0205h
senaxis_addr        dw  0207h
ampcode_addr        dw  020bh
xmtrgain_addr       dw  020dh
xdac_addr           dw  029ch
ydac_addr           dw  029eh
zdac_addr           dw  02a0h

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
sendposmode:
		push    cx
		xor     cx,cx
		loop    $
		pop     cx

		mov     bl,birdposcmd       ; get the cmd
		and     bl,fbbaddrmask      ; mask off the address bits
		or      bl,fbb_address      ; add in the address bits
		mov     birdposcmd,bl       ; replace the cmd with new addr
		mov     bx, OFFSET birdposcmd
		mov     cx,2                ; 2 characters in cmd
		call    hostsend_serial_cmd ; send the bird the cmd
		cmp     ax,2                ; did cmd go out OK?
		je      birdpostrueret
		jmp     birdposfalseret     ; return false

birdposfalseret: mov    ax,FALSE            ; return FALSE
		jmp     birdposexit
;
; Clean Exit
;
birdpostrueret:
	inc     fbb_address
	mov     al,fbb_stopaddress
		cmp     fbb_address,al
		jle     sendposmode

		mov     ax,TRUE                 ; return TRUE
		mov     birdposmode,POSMODE
		call    hitkeycontinue

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
sendanglemode:
		push    cx
		xor     cx,cx
		loop    $
		pop     cx

		mov     bl,birdanglecmd     ; get the cmd
		and     bl,fbbaddrmask      ; mask off the address bits
		or      bl,fbb_address      ; add in the address bits
		mov     birdanglecmd,bl     ; replace the cmd with new addr
		mov     cx,2                ; 2 characters in cmd
		mov     bx,OFFSET birdanglecmd
		call    hostsend_serial_cmd     ; send the bird the cmd
		cmp     ax,2                ; did cmd go out OK?
		je      birdangletrueret    ; if ok, continue
		jmp     birdanglefalseret   ; return false

birdanglefalseret: 
		mov     ax,FALSE            ; return FALSE
		jmp     birdangleexit
;
; Clean Exit
;
birdangletrueret: 
		inc     fbb_address
		mov     al,fbb_stopaddress
		cmp     fbb_address,al
		jle     sendanglemode

		mov     ax,TRUE         ; return TRUE
		mov     birdposmode,ANGLEMODE
		call    hitkeycontinue

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
sendmatrixmode:
		push    cx
		xor     cx,cx
		loop    $
		pop     cx
		mov     bl,birdmatrixcmd    ; get the cmd
		and     bl,fbbaddrmask      ; mask off the address bits
		or      bl,fbb_address      ; add in the address bits
		mov     birdmatrixcmd,bl    ; replace the cmd with new addr
		mov     cx,2                ; 2 character in cmd
		mov     bx,OFFSET birdmatrixcmd
		call    hostsend_serial_cmd ; send the bird the cmd
		cmp     ax,2                ; did cmd go out OK?
		je      birdmatrixtrueret   ; if ok, continue
		jmp     birdmatrixfalseret  ; return false

birdmatrixfalseret: mov ax,FALSE            ; return FALSE
		jmp     birdmatrixexit
;
; Clean Exit
;
birdmatrixtrueret: 
	inc     fbb_address
	mov     al,fbb_stopaddress
		cmp     fbb_address,al
		jle     sendmatrixmode

	mov     ax,TRUE         ;    return TRUE
		mov     birdposmode,MATRIXMODE
		call    hitkeycontinue

birdmatrixexit: pop     cx                  ; restore regs
		pop     bx
		ret                         ; home
bird_matrix     endp

;=============================================================================
;   bird_quaternions    Get Bird Quaternions
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
bird_quaternions proc    near
		push    bx                  ; save regs
		push    cx
;
; Send the output matrix command
;
sendquatermode:
		push    cx
		xor     cx,cx
		loop    $
		pop     cx
		mov     bl,birdquaternionscmd ; get the cmd
		and     bl,fbbaddrmask      ; mask off the address bits
		or      bl,fbb_address      ; add in the address bits
		mov     birdquaternionscmd,bl ; replace the cmd with new addr
		mov     bx,OFFSET birdquaternionscmd
		mov     cx,2                ; 2 character in cmd
		call    hostsend_serial_cmd ; send the bird the cmd
		cmp     ax,2                ; did cmd go out OK?
		je      birdquatertrueret   ; if ok, continue
		jmp     birdquaterfalseret  ; return false

birdquaterfalseret: 
		mov     ax,FALSE            ; return FALSE
		jmp     birdquaterexit
;
; Clean Exit
;
birdquatertrueret: 
				inc             fbb_address
				mov             al,fbb_stopaddress
				cmp             fbb_address,al
				jle             sendquatermode

				mov     ax,TRUE         ;    return TRUE
		mov     birdposmode,QUATERNIONMODE
		call    hitkeycontinue

birdquaterexit: pop     cx                  ; restore regs
		pop     bx
		ret                         ; home
bird_quaternions     endp

;=============================================================================
;   bird_posquaternions    Get Bird posquaternions
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
bird_posquaternions proc    near
		push    bx                  ; save regs
		push    cx
;
; Send the output matrix command
;
sendposquatermode:
		push    cx
		xor     cx,cx
		loop    $
		pop     cx

		mov     bl,birdposquaternionscmd ; get the cmd
		and     bl,fbbaddrmask      ; mask off the address bits
		or      bl,fbb_address      ; add in the address bits
		mov     birdposquaternionscmd,bl ; replace the cmd with new addr
		mov     bx,OFFSET birdposquaternionscmd
		mov     cx,2                ; 2 character in cmd
		call    hostsend_serial_cmd ; send the bird the cmd
		cmp     ax,2                ; did cmd go out OK?
		je      birdposquatertrueret   ; if ok, continue
		jmp     birdposquaterfalseret  ; return false

birdposquaterfalseret: 
		mov     ax,FALSE            ; return FALSE
		jmp     birdposquaterexit
;
; Clean Exit
;
birdposquatertrueret: 
				inc             fbb_address
				mov             al,fbb_stopaddress
				cmp             fbb_address,al
				jle             sendposquatermode

				mov     ax,TRUE         ;    return TRUE
		mov     birdposmode,POSQUATERNIONMODE
		call    hitkeycontinue

birdposquaterexit: 
		pop     cx                  ; restore regs
		pop     bx
		ret                         ; home
bird_posquaternions     endp

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
sendposanglemode:
		push    cx
		xor     cx,cx
		loop    $
		pop     cx

		mov     bl,birdposanglecmd  ; get the cmd
		and     bl,fbbaddrmask      ; mask off the address bits
		or      bl,fbb_address      ; add in the address bits
		mov     birdposanglecmd,bl  ; replace the cmd with new addr
		mov     bx,OFFSET birdposanglecmd
		mov     cx,2                ; 1 character in cmd
		mov     bx,OFFSET birdposanglecmd ; get cmd
		call    hostsend_serial_cmd ; send the bird the cmd
		cmp     ax,2                ; did cmd go out OK?
		je      birdposangletrueret ; if ok, continue
		jmp     birdposanglefalseret ; return false

birdposanglefalseret: 
		mov     ax,FALSE        ; return FALSE
		jmp     birdposangleexit
;
; Clean Exit
;
birdposangletrueret: 
				inc             fbb_address
				mov             al,fbb_stopaddress
				cmp             fbb_address,al
				jle             sendposanglemode

				mov     ax,TRUE         ; return TRUE
		mov     birdposmode,POSANGLEMODE
		call    hitkeycontinue

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
sendposmatrixmode:
		push    cx
		xor     cx,cx
		loop    $
		pop     cx

		mov     bl,birdposmatrixcmd   ; get the cmd
		and     bl,fbbaddrmask        ; mask off the address bits
		or      bl,fbb_address        ; add in the address bits
		mov     birdposmatrixcmd,bl   ; replace the cmd with new addr
		mov     cx,2                  ; 1 character in cmd
		mov     bx,OFFSET birdposmatrixcmd ; get cmd
		call    hostsend_serial_cmd   ; send the bird the cmd
		cmp     ax,2                  ; did cmd go out OK?
		je      birdposmatrixtrueret  ; if ok, continue
		jmp     birdposmatrixfalseret ; return false
birdposmatrixfalseret: 
		mov     ax,FALSE        ; return FALSE
		jmp     birdposmatrixexit
;
; Clean Exit
;
birdposmatrixtrueret: 
				inc             fbb_address
				mov             al,fbb_stopaddress
				cmp             fbb_address,al
				jle             sendposmatrixmode

				mov     ax,TRUE         ; return TRUE
		mov     birdposmode,POSMATRIXMODE
		call    hitkeycontinue

birdposmatrixexit:
		pop     dx                  ; restore regs
		pop     cx
		pop     bx
		ret                         ; home
bird_positionmatrix endp


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
		mov     ax,WORD PTR birdanglealigncmd ; get the cmd
		mov     [bx],ax             ; set the cmd byte

		mov     bl,BYTE PTR anglecmd ; get the cmd
		and     bl,fbbaddrmask      ; mask off the address bits
		or      bl,fbb_address      ; add in the address bits
		mov     BYTE PTR anglecmd,bl ; replace the cmd with new addr
		mov     bx,OFFSET anglecmd  ; get the angle cmd
		mov     cx,14               ; 14 characters in cmd

		call    hostsend_serial_cmd ; send the bird the cmd
		cmp     ax,14               ; did cmd go out OK?
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
		mov     cx,word ptr birdhemispherecmd ; get the command
		mov     [bx],cx             ; store the command
		mov     [bx]+2,ax           ; store the hemisphere data
;
; Send the command and data out
;
		mov     bl,txdatabuf        ; get the cmd
		and     bl,fbbaddrmask      ; mask off the address bits
		or      bl,fbb_address      ; add in the address bits
		mov     txdatabuf,bl        ; replace the cmd with new addr

		mov     bx,OFFSET txdatabuf
		mov     cx,4                ; 4 bytes in command
		call    hostsend_serial_cmd     ; out she goes..
		cmp     ax,4
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
		mov     ax, WORD PTR birdrefframecmd ; load up the command ..'H'
		mov     [bx],ax             ; store at the start of the buf

		mov     bl,BYTE PTR anglecmd ; get the cmd
		and     bl,fbbaddrmask      ; mask off the address bits
		or      bl,fbb_address      ; add in the address bits
		mov     BYTE PTR anglecmd,bl ; replace the cmd with new addr

		mov     bx,OFFSET anglecmd  ; get the angle cmd
		mov     cx,14               ; 14 bytes in command
		call    hostsend_serial_cmd     ; out she goes..
		cmp     ax,14
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
;   bird_sleep          Bird Sleep/Wake Command
;   ----------------
;
;   Parameters Passed:  none
;   Return Value:       In AX, TRUE if successful
;                       FALSE, if unsuccessful
;                       ESC_SEL, if user selected ESC
;   Registers Modified: AX
;   Remarks:            Implements the 'G' (sleep) and 'F' (wake/run) commands
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

		mov     bl,birdsleepcmd     ; get the cmd
		and     bl,fbbaddrmask      ; mask off the address bits
		or      bl,fbb_address      ; add in the address bits
		mov     birdsleepcmd,bl     ; replace the cmd with new addr
		mov     bx,OFFSET birdsleepcmd ; get the 'G' command
		cmp     ax,0                ; if 0 then SLEEP
		je      sendsleepwakecmd
sendwakecmd:
		mov     bl,birdwakeupcmd    ; get the cmd
		and     bl,fbbaddrmask      ; mask off the address bits
		or      bl,fbb_address      ; add in the address bits
		mov     birdwakeupcmd,bl    ; replace the cmd with new addr
		mov     bx,OFFSET birdwakeupcmd ; get the 'F' command
sendsleepwakecmd:
		mov     cx,2                ; send 2 characater
		call    hostsend_serial_cmd ; send the bird the command
		cmp     ax,2                ; did cmd go out OK?
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
		call    askyesno                ; prompt for yes/no
		cmp     ax,ESC_SEL              ; did the user hit ESC/
		jne     buildbutcmd
		jmp     buttonfalseret          ; if so, bail out
buildbutcmd:
		mov     buttonmode,ax           ; assign the global the value
		mov     bx,OFFSET txdatabuf     ; else, build the cmd string
		mov     cx,WORD PTR birdbuttonmodecmd ; first get the cmd byte
		mov     [bx],cx                 ; store cmd in buffer
		mov     [bx]+2,al               ; fill data with user answer
		mov     cx,3                    ; three characters to send
		mov     bl,txdatabuf            ; get the cmd
		and     bl,fbbaddrmask          ; mask off the address bits
		or      bl,fbb_address          ; add in the address bits
		mov     txdatabuf,bl            ; replace the cmd with new addr
		mov     bx,OFFSET txdatabuf     ; else, build the cmd string
		call    hostsend_serial_cmd     ; send the cmd
		cmp     ax,3                    ; did cmd go out OK?
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
getbuttonval:   call    ckdoagain               ; see if key available
		cmp     ax,FALSE                ; is one ready?
		jne     readbuttonval           ; if not read button value
		call    clearkey                ; else, clear keyboard
		jmp     buttontrueret           ; return TRUE
;
; Send command to Get button value
;
readbuttonval:
		mov     bl,birdbuttonreadcmd    ; get the cmd
		and     bl,fbbaddrmask          ; mask off the address bits
		or      bl,fbb_address          ; add in the address bits
		mov     birdbuttonreadcmd,bl    ; replace the cmd with new addr
		mov     bx,OFFSET birdbuttonreadcmd ; get button read cmd
		mov     cx,2                    ; 2 byte cmd
		call    hostsend_serial_cmd     ; send the cmd
		cmp     ax,2                    ; did cmd go out OK?
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
chgvaluejmptbl dw  chgvalueret             ; para# null
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
		mov     cx,16                ; setup choices
		mov     dx,OFFSET chgvaluemenuptr ; get the menu
		call    sendmenu            ; put the menu on the screen
		cmp     ax,0
		jg      chgvalue            ; if not continue
		jmp     chgvalueret         ; else ...home

chgvalue:       mov     bx,OFFSET txdatabuf ; use the txdatabuf for the cmd
		mov     cx,WORD PTR birdchgvaluecmd  ; setup the command byte.. RS232CMD & 'P'
		mov     [bx],cx             ; store the command in the buffer
		inc     bx                  ; point to the next cmd byte
		inc     bx
		push    ax
		mov     si,ax               ; use SI as table offset
		mov     al,chgparamtbl[si]  ; get the chg param via lookup tbl
		mov     [bx],al             ; ...in the command string
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
		mov     WORD PTR txdatabuf+3,ax ; get the data buf + 3
		mov     cx,5
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
setfilteronoff: mov     WORD PTR txdatabuf+3,si ; get the data buf + 3
		mov     cx,5
		jmp     sendchgvaluecmd

;
; Change the Filter Constant Table - Alpha Min
;
chgfilterconst:
		mov     cx,7                          ; setup for 7 questions
		mov     di,OFFSET txdatabuf+3
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
		mov     cx,17                         ; 17 byte command
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
		mov     WORD PTR txdatabuf+3,dx  ; store the data
		mov     cx,5                     ; store the command size
		cmp     ax,ESC_SEL               ; ck for user ESC
		jne     tosendchgvaluecmd1       ; if not.. send the cmd
		jmp     chgvalueret              ; else return
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
		mov     BYTE PTR txdatabuf+3,al       ; store the data
		mov     cx,4                          ; 4 byte command
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
		mov     BYTE PTR txdatabuf+3,dl       ; store the data
		mov     cx,4                          ; 4 byte command
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
		mov     BYTE PTR txdatabuf+3,al       ; store the data
		mov     cx,4                          ; 4 byte command
		jmp     sendchgvaluecmd               ; send the command

;
; Ask the user the for the DC Filter Values
;
chgdcfiltertbl:
		mov     cx,7                          ; setup for 7 questions
		mov     di,OFFSET txdatabuf+3
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
		mov     cx,17                         ; 16 byte command
		jmp     sendchgvaluecmd               ; send the command

;
; Change the Filter Constant Table - Alpha MAX
;
chgfilteralphamax:
		mov     cx,7                          ; setup for 7 questions
		mov     di,OFFSET txdatabuf+3
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
		mov     cx,17                         ; 16 byte command
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
		mov     BYTE PTR txdatabuf+3,al       ; store the data
		mov     cx,4                          ; 4 byte command
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
		mov     WORD PTR txdatabuf+3,dx       ; store the data
		mov     cx,5                          ; 5 byte command
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
		mov     [bx]+3,al            ; store the data in the cmd
		mov     ax,fbbdevices
		mov     [bx]+5,ax            ; store the data in the cmd
		mov     ax,fbbdependents
		mov     [bx]+7,ax            ; store the data in the cmd
		mov     cx,8                 ; setup for 8 bytes
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
		mov     BYTE PTR txdatabuf+3,al
		mov     cx,4
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
		mov     BYTE PTR txdatabuf+3,al
		mov     cx,4
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
		mov     BYTE PTR txdatabuf+3,dl
		mov     cx,4
		jmp     sendchgvaluecmd
;
; Send the Command and new Parameter Values to the Bird
;
sendchgvaluecmd:
		mov     bl,txdatabuf        ; get the cmd
		and     bl,fbbaddrmask      ; mask off the address bits
		or      bl,fbb_address      ; add in the address bits
		mov     txdatabuf,bl        ; replace the cmd with new addr
		mov     bx,OFFSET txdatabuf ; get the data buf
		push    cx
		call    hostsend_serial_cmd ; off she goes
		pop     cx
		cmp     ax,cx               ; ck if command went out OK
		je      chgvaluetrueret
		jmp     chgvaluefalseret
;
; Return from the Change Value Command
;
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
		cmp     cl,BYTE PTR exmdatasizetbl+21
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


;
; Display the Active FBB Devices
;
displayactivedevices proc near
		pusha
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
		cmp     cl,exmdatasizetbl+21 ; check against the table entry
		jl      displayactivedevice
		popa
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
		pusha
		mov     dx,OFFSET fbbdependentsheadermsg
		call    putstring
		mov     cx,0                ; use CX as a counter starting at 0
		mov     si,00000001b        ; start with bit 0

ckdependent:
		shl     si,1
		inc     cx
		cmp     cl,15
		jne     displaydependentdevice
		popa
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
	mov     BYTE PTR exmdatasizetbl + 18, 5
	mov     BYTE PTR exmdatasizetbl + 19, 14
	mov     BYTE PTR exmdatasizetbl + 21, 14
	mov     BYTE PTR exmdatasizetbl + 22, 5
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
	mov     BYTE PTR exmdatasizetbl + 18, 7
	mov     BYTE PTR exmdatasizetbl + 19, 30
	mov     BYTE PTR exmdatasizetbl + 21, 30
	mov     BYTE PTR exmdatasizetbl + 22, 7

;
; Send the Menu to the User
;
sendexmmenu:
		mov     cx,23               ; setup # of choices
		mov     dx,OFFSET exmvaluemenuptr ; get the menu
		call    sendmenu            ; put the menu on the screen
		cmp     ax,0
		jg      exmvalue            ; if not continue
		jmp     exmvalueret         ; else ...home
;
; Send the Examine Command down to the Bird and then decode the
; information returned as per the user's selection
;
exmvalue:
	push    ax                  ; save the user's selection
		mov     cx,ax
		mov     ax,WORD PTR birdexmvaluecmd  ; get the command word RS232 + Cmd
		mov     WORD PTR txdatabuf,ax ; store both the cmd and data
		mov     bl,txdatabuf        ; get the cmd
		and     bl,fbbaddrmask      ; mask off the address bits
		or      bl,fbb_address      ; add in the address bits
		mov     txdatabuf,bl        ; replace the cmd with new addr
		mov     si,cx               ; lookup the parameter number
		mov     al,exmparamtbl[si] ; get the param number
		mov     bx,OFFSET txdatabuf ; use the txdatabuf for the cmd
		mov     [bx]+2,al           ; store the selection
		mov     cx,3                ; setup for a 3 byte cmd
		call    hostsend_serial_cmd ; send the cmd
		cmp     ax,3                ; ck cmd went out OK
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
		call    hostget_serial_data ; get the data
		cmp     ax,TRUE             ; verify all went OK
		je      decodeexmdata       ; if so...decode the data
		pop     ax                  ; clean up the stack
		jmp     exmvaluefalseret    ; else..quit

decodeexmdata:
	call    newline             ; add a line inbetween the Menu
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
; *******************************************
		and     cl,0eh               ; set up for compares
ckfactorymode:  cmp     cl,ah               ; see if in factory mode
		jne     ckposmode        ; if not ck matrix mode
		mov     dx,OFFSET factorymodemsg     ; else, set anglemsg
		jmp     sendmodemsg
ckposmode:      cmp     cl,2h               ; see if in pos mode
		jne     ckanglemode        ; if not ck matrix mode
		mov     dx,OFFSET posmodemsg     ; else, set anglemsg
		jmp     sendmodemsg
ckanglemode:    cmp     cl,4h               ; see if in angle mode
		jne     ckmatrixmode        ; if not ck matrix mode
		mov     dx,OFFSET anglemodemsg     ; else, set anglemsg
		jmp     sendmodemsg
ckmatrixmode:
		cmp     cl,6h               ; see if in matrix mode
		jne     ckposanglemode      ; if not ck pos/angle mode
		mov     dx,OFFSET matrixmodemsg    ; else, set matrix msg
		jmp     sendmodemsg
ckposanglemode:
		cmp     cl,8h               ; see if in pos/angle mode
		jne     ckposmatrixmode     ; if not ck pos/matrix mode
		mov     dx,OFFSET posanglemodemsg  ; else, set pos/angle msg
		jmp     sendmodemsg
ckposmatrixmode:
		cmp     cl,0ah              ; see if in pos/matrix mode
		jne     ckquaternmode
		mov     dx,OFFSET posmatrixmodemsg ; else, set pos/matrix msg
		jmp     sendmodemsg
ckquaternmode:
		cmp     cl,0dh              ; see if in quaternion mode
		jne     ckposquaternmode
		mov     dx,OFFSET quaternmodemsg ; else, set quaternion msg
		jmp     sendmodemsg
ckposquaternmode:
		cmp     cl,10h              ; see if in pos/quaternion mode
		jne     invalidmode
		mov     dx,OFFSET posquaternmodemsg ; else, set pos/quaternion msg
		jmp     sendmodemsg
invalidmode:
		mov     dx,OFFSET invalidmodemsg
sendmodemsg:    call    putstring           ; send the msg to the console
		mov     cl,low_byte
		and     cl,1                ; see if bit 0 is on
		jz      sendpointmsg
		mov     dx,OFFSET streammodemsg ; else put up the stream msg
		jmp     sendoutmodemsg
sendpointmsg:
	mov     dx,OFFSET pointmodemsg  ; set the point mode msg
sendoutmodemsg:
	call    putstring           ; send the msg to the console
		jmp     exmvaluetrueret
;
; Examine Software Revison Number
;
exmrevison:
	mov     dx,OFFSET softwarerevmsg ; send the software rev msg
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
setacwideon:
	mov     dx,OFFSET onmsg
sendacwidemsg:
	call    putstring           ; display it..
;
; ck the DC filter bit
;
		mov     dx,OFFSET dcfiltermsg ; get the msg
		call    putstring
		test    cl,1                ; see if on
		jz      setdcon             ; if 0 send the ON msg
		mov     dx,OFFSET offmsg    ; else send the OFF msg
		jmp     senddcmsg
setdcon:
	mov     dx,OFFSET onmsg
senddcmsg:
	call    putstring           ; display it..
		jmp     exmvaluetrueret
;
; Examine the filter constant
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
exmmodel:
	mov     dx,OFFSET modelmsg          ; display the user msg
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
; Examine FBB/Host Delay
;
exmhostdelay:
		mov     dx,OFFSET fbbhostdelaymsg
		call    putstring           ; display the msg
		mov     ax,cx               ; get the counts
		call    displayunsigned     ; display the counts
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
; Examine Auto Configuration - 1 Transmitter, N Receivers
;
exmautoconfig1xmtrnrcvr:
		call    showfbbconfig
		jmp     exmvaluetrueret
;
; Examine Value Return
;
exmvaluefalseret:
		call    hitkeycontinue  
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
;   bird_sync        Bird CRT Synchronization Commands
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
bird_sync    proc    near
		push    cx                  ; save regs
		push    dx
;
; Send the User the Menu
;
		mov     dx,OFFSET syncmenuptr ; get the menu
		mov     cx,5                ; 5 menu choices
		call    sendmenu
		cmp     ax,ESC_SEL          ; ck for user ESC
		jne     readcpucrystalfreq
		jmp     syncret
;
; First, Get the Crystal Frequency
;
readcpucrystalfreq:
		push    ax                  ; save the user's entry
		call    getcrystalfreq      ; init crystalfreq
		cmp     ax,TRUE             ; everything go OK?
		pop     ax                  ; restore the user's entry
		je      sendsync            ; if so ..continue
		jmp     syncfalseret        ; else,.. home
;
; Initialize the txdatabuf with the command
;
sendsync:       mov     bx,OFFSET txdatabuf ; use the txdatabuf for the cmd
		mov     cx,WORD PTR birdsynccmd ; load the command byte
		mov     [bx],cx             ; initialized for 'A',0
		mov     BYTE PTR[bx]+2,0    ; store in the cmd string
					    ; ... SYNC OFF
;
; Check for Host Sync
;
		cmp     ax,4                
		jne     ckdisplaycrtval
		mov     al,8                ; Host Sync Value
		mov     BYTE PTR[bx]+2,al   ; store in the cmd string
		jmp     sendsynccmd
;
; Check the user's response 3 - Display CRT Value
;
ckdisplaycrtval:
		cmp     ax,3                ; see if the '255' mode selected
		je      getsyncinfo
		jmp     cksyncoff           ; if not..ck other modes
;
; Send the command and display the voltage and the rate
;
getsyncinfo:    mov     BYTE PTR[bx]+2,0ffh ; set cmd data to 255
getsyncdata:
		mov     bl,txdatabuf        ; get the cmd
		and     bl,fbbaddrmask      ; mask off the address bits
		or      bl,fbb_address      ; add in the address bits
		mov     txdatabuf,bl        ; replace the cmd with new addr
		mov     bx,OFFSET txdatabuf ; needed in the following loop
		mov     cx,3                ; setup for a 3 byte cmd
		call    hostsend_serial_cmd     ; send the cmd
		cmp     ax,3                ; ck cmd went out OK
		je      readpickupinfo
		jmp     syncfalseret
readpickupinfo: mov     cx,4                ; setup to receive 4 bytes
		mov     bx,OFFSET rxdatabuf ; receive data into the rxdatabuf
		call    hostget_serial_data     ; get the data
		cmp     ax,TRUE             ; verify all went OK
		je      decodesyncdata      ; if so...decode the data
		jmp     syncfalseret
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
		mov     si,WORD PTR [bx]    ; save data for display in a bit
		mov     ax,1000                ; multiply the crystalfreq by 1000
		mul     crystalfreq            ; ..to increase resolution of the
					    ; ..rate display to 2 dec. places
		mov     conv_const,CRYSTALRATEK ; get the multiplier
		mul     conv_const            ; build DX:AX as the dividend
		cmp     WORD PTR [bx],0        ; trap divide by 0 ...
		je      skipdivide          ; ..else get INT 0
		div     WORD PTR [bx]        ; divide by the number of counts
	shr     ax,1                   ; divide by 2
		mov     [bx],ax                ; assign the result to where
					    ; ..the number of counts was
skipdivide:     mov     conv_const,INTK     ; set the conv const for display
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
		mov     bx,OFFSET txdatabuf ; reset the transmit pointer
		xor     al,al               ; set AL = 0 to shut of sync
		mov     BYTE PTR [bx]+2,al  ; set the sync mode off
		jmp     sendsynccmd

cksyncoff:      cmp     ax,0                ; command is CRT sync OFF?
		jne     cksyncon            ; if not CRT sync ON
		jmp     sendsynccmd         ; send the cmd
cksyncon:
		mov     BYTE PTR[bx]+2,al   ; store in the cmd string

sendsynccmd:
		mov     bl,txdatabuf        ; get the cmd
		and     bl,fbbaddrmask      ; mask off the address bits
		or      bl,fbb_address      ; add in the address bits
		mov     txdatabuf,bl        ; replace the cmd with new addr
		mov     bx,OFFSET txdatabuf
		mov     cx,3                ; setup for a 3 byte cmd
		call    hostsend_serial_cmd ; send the cmd
		cmp     ax,3                ; ck cmd went out OK
		je      synctrueret
		jmp     syncfalseret

synctrueret:    mov     ax,TRUE
		mov     dx,OFFSET syncmsg
		call    putstring
syncret1:       call    hitkeycontinue
		jmp     syncret
syncfalseret:
		mov     ax,FALSE
syncret:        pop     dx                  ; restore regs
		pop     cx
		ret
bird_sync    endp

;*****************************************************************************
_TEXT           ENDS
																       

   
		end

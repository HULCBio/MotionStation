'****************************************************************************
'****************************************************************************
'   bbird.bas      - Bird QuickBasic Main
'
'   The Bird(tm) position and orientation measurement system is controlled
'   via a serial RS232 communication link.  This program allows the user
'   to 'experiment' with the Bird by selecting control commands from a
'   rudimentary menuing system.  After becoming familiar with the commands
'   the user can CUT and PASTE code from the source files listed below for
'   use in their own application.
'
'   written for:    Ascension Technology Corporation
'                   PO Box 527
'                   Burlington, Vermont  05402
'
'                   802-860-6440
'
'   written by:     Jeff Finkelstein
'
'   Modification History:
'
'   11/1/90         jf - released
'   11/5/90         jf - removed the 'Q' command and the 'M' command
'                        from the initialization of the Bird
'   11/10/90        jf - added new commands:
'                           XON/XOFF,EXAMINE,CHANGE,CRTSYNCE
'                   jf - added getserialdata function to simplify receiving
'                        raw data from the bird
'   11/11/90        jf - added getunsigned...which enables ESC key detection
'   11/29/90        jf - fixed bug in printmatrix
'                        fixed negative angle bug in birdanglealign and
'                        birdreferframe
'                        added 'Hit 'b' Key...' in checkdone
'   2/4/91          jf - added code to display buttonvalue%
'   2/20/91         jf - moved initialization of factory test mode to
'                        birdloadconfig
'   3/16/91         jf - added new choice (1) to CRT Sync for syncing 1 frame
'                        per Sync input for Fast Vertical Retrace CRTs
'   4/3/91          jf - fixed bug in birdchangevalue for turning filters
'                        on and off
'   5/10/91         eb - fixed rev # print format problem in birdexaminevalue
'   5/20/91         jf - fixed rol/col bug in printmatrix
'                        added revision number to Menu Header ..rev 3.00
'   9/17/91         jf - added posk! for POSK36 and POSK72
'   10/7/91         jf - removed revision specific addresses ..rev 3.01
'   10/18/91        jf - updated max measurement rate to 144 ..rev 3.02
'   10/28/91        jf - added disable of RTS to not reset the Bird ..rev 3.03
'   11/1/91         jf - added chg/exm alpha max and glitch checking
'                        ..rev 3.04
'   11/7/91         jf - added exm model
'                        fixed bug in getserialdata..rev 3.05
'   11/10/91        jf - changed 'glitch checking' to 'sudden output change'
'   11/18/91        jf - changed max CRT sync rate to 72 Hz
'   3/23/92         jf - modified alpha min/max to tables
'   3/31/92         jf - added new commands for next transmitter,
'                        next master, RS232 to FBB commands
'   4/7/92          jf - modified operation of chg/exm Error Mask..rev 3.06
'                   jf - added xmtrtype scaling
'   4/9/92          jf - modified measurement rate const to 0.3 for ROMs
'                        3.28 and 4.11
'   4/20/92         mo - added functions quaternions and posquaternions
'   5/5/92          jf - added system test menu selections ..rev 3.07
'   6/1/92          jf - updated examine value to reflect new status
'                        definitions ..rev 3.08
'   10/12/92        jf - modified printmatrix to display 3 sig. digits
'                        ..rev 3.09
'   2/18/93         jf - updated examine value for new status definitions
'                        ..rev 3.10
'   3/4/93          jf - updated birdcrtsync to display the rate divided
'                        by 2 since rev 3.41 and 4.22 ROMs require this
'                        change
'   3/8/93          jf - updated for extended range transmitter values in
'                        filter constants and Vm table
'                   jf - fixed bugs in the examine fbb config and fbb arm
'                   jf - added examine fbb system status
'                   jf - ..rev 3.11
'   3/22/93         jf - getoutputmode now locks out the STREAM menu
'                        selection if the RS232 to FBB address is active
'                        ..rev 3.12
'   11/9/93         eb - include file eliminated an incorporated into main
'                        line code
'                        all qbbird files renamed to bbird
'   4/26/94         sw - include reference frame in change/examine value
'   9/28/94         sw - decode all 16 bits of Bird System Status
'
'          <<<< Copyright 1993 Ascension Technology Corporation >>>>
'****************************************************************************
'****************************************************************************
'
DECLARE FUNCTION askyesno% (promptstring$)
DECLARE FUNCTION checkdone% (outputmode%)
DECLARE FUNCTION getangles% (anglearray!())
DECLARE FUNCTION getbirdstatus% ()
DECLARE FUNCTION getcrystalfreq% ()
DECLARE FUNCTION getoutputmode% ()
DECLARE FUNCTION getserialdata% (dataarray%(), charstoread%)
DECLARE FUNCTION getserialrecord% (recordsize%, outputmode%)
DECLARE FUNCTION getunsigned% (min%, max%)
DECLARE FUNCTION readbirddata% (birddata%(), numwords%, outputmode%, buttonmode%)
DECLARE FUNCTION sendmenu% (menustrings$(), numberofselections%)
DECLARE FUNCTION sendserialcmd% (cmdstring AS STRING, cmdsize%)
DECLARE FUNCTION serialinit% ()
DECLARE FUNCTION showfbbconfig% (dataarray%())
DECLARE SUB birdanglealign ()
DECLARE SUB birdhemisphere ()
DECLARE SUB birdreferframe ()
DECLARE SUB birdreportrate ()
DECLARE SUB birdsleepwake ()
DECLARE SUB birdmousebuttons ()
DECLARE SUB birdposition (outputmode%, buttonmode%)
DECLARE SUB birdangles (outputmode%, buttonmode%)
DECLARE SUB birdmatrix (outputmode%, buttonmode%)
DECLARE SUB birdquaternions (outputmode%, buttonmode%)
DECLARE SUB birdpositionandangles (outputmode%, buttonmode%)
DECLARE SUB birdpositionandmatrix (outputmode%, buttonmode%)
DECLARE SUB birdposquaternions (outputmode%, buttonmode%)
DECLARE SUB birdchangevalue ()
DECLARE SUB birdexaminevalue ()
DECLARE SUB birdcrtsync ()
DECLARE SUB birdxonxoff ()
DECLARE SUB birdechotest ()
DECLARE SUB birdoutputtest ()
DECLARE SUB clearrxbuf ()
DECLARE SUB hitkeycontinue ()
DECLARE SUB hostreadtest ()
DECLARE SUB hostreadblocktest ()
DECLARE SUB nextmastercmd ()
DECLARE SUB nextxmtrcmd ()
DECLARE SUB printmatrix (birddata%())
DECLARE SUB printquaternions (birddata%())
DECLARE SUB rs232tofbbcmd ()
DECLARE SUB setxmtrtype ()
DECLARE SUB systemtests ()

'
' Include general definitions for the Bird program
'
' Modification History
'
'   11/1/90     jf - released
'   9/17/91     jf - added POSK36 and POSK72
'   10/7/91     jf - added YES and NO
'   4/7/92      jf - added POSK144 for ER Controller
'
' Misc. Definitions
'
CONST TRUE = 1
CONST FALSE = 0
CONST YES = 1
CONST NO = 0

'
' Menuing Definitions
'
CONST MAXNUMMENUSELECTIONS = 20

'
' Character Definitions
'
CONST BELCHR = &H7
CONST BSCHR = &H8
CONST TABCHR = &H9
CONST CRCHR = &HD
CONST LFCHR = &HA
CONST XON = &H11
CONST XOFF = &H13
CONST ESCCHR = &H1B
CONST SPCHR = &H20

CONST ESCSEL = -1

'
' Output Mode
'
CONST POINTM = 0
CONST CONTINUOUS = 1
CONST STREAM = 2

'
' Number Conversion Constants
'
CONST POSK36 = 36! / 32768!   'CONVERT INTEGER TO INCHES
CONST POSK72 = 72! / 32768!   'CONVERT INTEGER TO INCHES
CONST POSK144 = 144! / 32768! 'CONVERT INTEGER TO INCHES for ER Controller
CONST ANGK = 180! / 32768!    'CONVERT INTEGER TO DEGREES
CONST DTR = 3.141593 / 180!   'CONVERT DEGREES TO RADIANS
CONST WTF = 1! / 32768!       'CONVERT WORDS TO FLOATS
CONST FTW = 32768!            'CONVERT FLOATS TO WORDS


'
' Error Conditions
'
CONST RXERROR = -1
CONST RXPHASEERROR = -2



'
' Output Mode
'
DIM outputmode%                     ' output mode..POINTM, CONTINUOUS, or STREAM

'
' Button Mode
'
DIM buttonmode%                     ' button mode .. 0 or 1
buttonmode% = 0                     ' initialized to OFF

'
' Button Value
'
DIM buttonvalue%                    ' button value
buttonvalue% = 0                    ' initialized to OFF

'
' FBB Variables
'
DIM fbbdevices%                     ' Devices on the FBB bus
fbbdevices% = 0                     ' initialized to none
DIM fbbdependents%                  ' Dependents on the FBB Bus
fbbdependents% = 0                  ' initialized to none

DIM rs232tofbbaddr%                 ' RS232 to FBB Command Address
rs232tofbbaddr% = 0                 ' initialized to 0


'
' Serial Port Defaults
'
DIM baud$                           ' baud rate string
baud$ = "9600"
DIM comport$                        ' COMn string
comport$ = "COM1"

'
' Position Range Scaling
'
DIM posk!                           ' position constant for 36" or 72"
posk! = POSK36

'
' FBB Address Mask for decoding the Expanded Error Code Address
'
DIM fbbaddrmask%
fbbaddrmask% = &HF                  ' &H1F for Expanded Address Mode

'
' FBB Command Divisor for decoding the Expanded Error Code Command
'
DIM fbbcmdbitdiv%
fbbcmdbitdiv% = 16                  ' 32 for Expanded Address Mode

'
' Expanded Address Mode Flag
'
DIM expandedaddrmode%
expandedaddrmode% = FALSE

'
' Number of FBB Devices
'
DIM numfbbdevices%
numfbbdevices% = 14

'
' Bird Crystal Frequency
'
DIM crystalfreq!                    ' initialized by the routines that use it

'
' Dimension a Receive Buffer
'
DIM rxbuf AS STRING * 100           ' setup a receive buffer

'
' Error Handler Definitions/Initializations
'
DIM filenameerr%                    ' file name error flag
filenameerr% = FALSE
DIM filedataerr%                    ' file data error flag
filedataerr% = FALSE
DIM phaseerrorcount%                ' phase error counter
phaseerrorcount% = 0

'
' Setup a Timer for Trap serial port 'hung' condition
'
ON TIMER(4) GOSUB serialtimeouterror    'if more than 4 sec when reading COMn

'
' Turn on the Cursor
'
LOCATE 1, 1, 1

'
' Initialize the Serial Port...quit if it counldn't be initialized
'
IF serialinit% = FALSE THEN
     STOP
END IF

'
' Create the main menu
'
DIM mainmenu$(24)
mainmenu$(0) = "Menu Selections:"
mainmenu$(1) = "Quit"
mainmenu$(2) = "Position"
mainmenu$(3) = "Angles"
mainmenu$(4) = "Matrix"
mainmenu$(5) = "Quaternions"
mainmenu$(6) = "Position/Angles"
mainmenu$(7) = "Position/Matrix"
mainmenu$(8) = "Position/Quaternions"
mainmenu$(9) = "Angle Align"
mainmenu$(10) = "Hemisphere"
mainmenu$(11) = "Reference Frame"
mainmenu$(12) = "Report Rate"
mainmenu$(13) = "Sleep/Wakeup"
mainmenu$(14) = "Mouse Buttons"
mainmenu$(15) = "XON/XOFF"
mainmenu$(16) = "Change Values"
mainmenu$(17) = "Examine Values"
mainmenu$(18) = "CRT Synchronization"
mainmenu$(19) = "FBB Next Master"
mainmenu$(20) = "FBB Next Transmitter"
mainmenu$(21) = "RS232 to FBB Command"
mainmenu$(22) = "Set Transmitter Type"
mainmenu$(23) = "System Tests"
mainmenu$(24) = "Serial Port Configuration"'

'
' Do the main menu until the user selects Quit
'
DO
     '
     ' Shut off all previous errors
     '
     phaseerrorcount% = 0
     TIMER OFF
     ON ERROR GOTO 0

     '
     ' Put up the Window Header
     '
     CLS
     PRINT "***************************************************************************"
     PRINT "* ASCENSION TECHNOLOGY CORPORATION - Bird Main Menu         Revision 3.13 *"
     PRINT "***************************************************************************"
     PRINT

     '
     ' Send menu to the Consol and operate on the User's selection
     '
     SELECT CASE (sendmenu%(mainmenu$(), 24))

          CASE 0              ' Quit
               IF askyesno%("Are you sure you want to quit") = TRUE THEN
                    END
               END IF

          CASE 1              ' Position
               outputmode% = getoutputmode%
               IF outputmode% <> ESCSEL THEN
                    CALL birdposition(outputmode%, buttonmode%)
               END IF

          CASE 2              ' Angles
               outputmode% = getoutputmode%
               IF outputmode% <> ESCSEL THEN
                    CALL birdangles(outputmode%, buttonmode%)
               END IF

          CASE 3              ' Matrix
               outputmode% = getoutputmode%
               IF outputmode% <> ESCSEL THEN
                    CALL birdmatrix(outputmode%, buttonmode%)
                END IF

          CASE 4              ' Quaternions
               outputmode% = getoutputmode%
               IF outputmode% <> ESCSEL THEN
                    CALL birdquaternions(outputmode%, buttonmode%)
                END IF

          CASE 5              ' Position and Angles
               outputmode% = getoutputmode%
               IF outputmode% <> ESCSEL THEN
                    CALL birdpositionandangles(outputmode%, buttonmode%)
               END IF

          CASE 6              ' Position and Matrix
               outputmode% = getoutputmode%
               IF outputmode% <> ESCSEL THEN
                    CALL birdpositionandmatrix(outputmode%, buttonmode%)
               END IF

          CASE 7              ' Position and Quaternions
               outputmode% = getoutputmode%
               IF outputmode% <> ESCSEL THEN
                    CALL birdposquaternions(outputmode%, buttonmode%)
               END IF

          CASE 8
               CALL birdanglealign

          CASE 9
               CALL birdhemisphere

          CASE 10
               CALL birdreferframe

          CASE 11
               CALL birdreportrate

          CASE 12
               CALL birdsleepwake

          CASE 13
               CALL birdmousebuttons

          CASE 14
               CALL birdxonxoff

          CASE 15
               CALL birdchangevalue

          CASE 16
               CALL birdexaminevalue

          CASE 17
               CALL birdcrtsync

          CASE 18
               CALL nextmastercmd

          CASE 19
               CALL nextxmtrcmd

          CASE 20
               CALL rs232tofbbcmd

          CASE 21
               CALL setxmtrtype

          CASE 22
               CALL systemtests

          CASE 23
               IF serialinit% = FALSE THEN
                    END
               END IF
          CASE ESCSEL

     END SELECT

LOOP WHILE (TRUE)

'
' close the serial port and quit
'
CLOSE #1

END


'
' Event Handlers
'

serialtimeouterror:
PRINT "** ERROR ** serial port time out error"
serialerr% = TRUE
RETURN

'
' Error Handlers
'
serialopenerror:
PRINT "** ERROR ** could not open serial port"
serialerr% = TRUE
RESUME NEXT

serialrxerror:
PRINT "* * ERROR ** serial port receive fault"
serialerr% = TRUE
RESUME NEXT

filenameerror:
PRINT "** ERROR ** invalid filename"
filenameerr% = TRUE
RESUME NEXT

filedataerror:
PRINT "** ERROR ** could not read data from file"
filedataerr% = TRUE
RESUME NEXT

FUNCTION askyesno% (promptstring$)

PRINT promptstring$ + " (Y/N)? ";

DO
     valid% = TRUE

     DO
          answchar$ = INKEY$
     LOOP WHILE answchar$ = ""

     SELECT CASE answchar$

          CASE "y"
               askyesno% = TRUE
          CASE "Y"
               askyesno% = TRUE
          CASE "n"
               askyesno% = FALSE
          CASE "N"
               askyesno% = FALSE
          CASE CHR$(ESCCHR)
               askyesno% = ESCSEL
               EXIT FUNCTION
          CASE ELSE
               valid% = FALSE
               PRINT CHR$(BELCHR);
     END SELECT

LOOP WHILE valid% = FALSE

PRINT answchar$

END FUNCTION

SUB birdanglealign
'
' Set up for a 13 character command string
'
DIM birdanglealigncmd AS STRING * 13
'
' Set up an array for the 3angles
'
DIM anglearray!(3)

'
' Fill the first character in the command string with the aligment command
'
birdanglealigncmd = "J"

'
' Get the 3 angles Azimuth, Elevation and Roll and store in anglearray!()
'
PRINT "Enter the Angles for the new Alignment..."
IF getangles%(anglearray!()) <> TRUE THEN
     EXIT SUB
END IF

'
' Convert the angles to Sine and Cosine and store in
' the birdanglealigncmd string
'
cpos% = 2
FOR i% = 0 TO 2
     '
     ' Get the Sine of the Angle
     '
     tempfloat! = SIN(anglearray!(i%) * DTR)
     '
     ' Trap for Sin = 1.00 since the bird can only accept -1.00 to 0.99996
     '
     IF tempfloat! < .99998 THEN
          word% = INT(tempfloat! * FTW)
     ELSE
          word% = 32767
     END IF
     'PRINT "Sword = "; word%; "  "; HEX$(word%); " LS = "; CHR$(word% AND &HFF); " MS = "; CHR$(INT((word% AND &HFF00)/ 256) AND &HFF);
     MID$(birdanglealigncmd, cpos%, 1) = CHR$(word% AND &HFF)
     MID$(birdanglealigncmd, cpos% + 1, 1) = CHR$(INT((word% AND &HFF00) / 256) AND &HFF)
       
     '
     ' Get the Cosine of the Angle
     '
     tempfloat! = COS(anglearray!(i%) * DTR)
     '
     ' Trap for Cos = 1.00 since the bird can only accept -1.00 to 0.99996
     '
     IF tempfloat! < .99998 THEN
          word% = INT(tempfloat! * FTW)
     ELSE
          word% = 32767
     END IF
     'PRINT "Cword = "; word%; "  "; HEX$(word%); " LS = "; CHR$(word% AND &HFF); " MS = "; CHR$(INT((word% AND &HFF00)/ 256) AND &HFF)
     MID$(birdanglealigncmd, cpos% + 2, 1) = CHR$(word% AND &HFF)
     MID$(birdanglealigncmd, cpos% + 3, 1) = CHR$(INT((word% AND &HFF00) / 256) AND &HFF)
     cpos% = cpos% + 4
NEXT i%

'
' Send the Command to the Bird
'
cmdok% = sendserialcmd%(birdanglealigncmd, 13)

PRINT "Angle Alignment Data Sent to the Bird"

CALL hitkeycontinue

END SUB

SUB birdangles (outputmode%, buttonmode%)

SHARED buttonvalue%

'
' set up storage for the received record data
'
DIM birddata%(3)

'
' Send the Angle Command
'
cmdok% = sendserialcmd%("W", 1)

'
' if in STREAM mode then send the Stream command
'
IF outputmode% = STREAM THEN
     cmdok% = sendserialcmd%("@", 1)
END IF

'
' if in POINT mode then prompt the User
'
IF outputmode% = POINTM THEN
     PRINT
     PRINT "Hit the 'B' key to read Bird Data, or any other key to Quit"
END IF

'
' Stay in a loop displaying Angle data from the Bird
'
WHILE checkdone%(outputmode%) = FALSE  ' continue until TRUE
     '
     ' read 3 words of data from the Bird
     '
     IF (readbirddata%(birddata%(), 3, outputmode%, buttonmode%) = FALSE) THEN
          EXIT SUB
     END IF

     '
     ' convert the birddata%() to angles and display
     '
     FOR i% = 0 TO 2
          PRINT USING "     ####.##"; birddata%(i%) * ANGK;
     NEXT i%
        
     '
     ' Print the button value
     '
     IF buttonmode% <> 0 THEN
          PRINT USING "      ###"; buttonvalue%;
     END IF
     PRINT ""

WEND
END SUB

SUB birdchangevalue

SHARED crystalfreq!
SHARED fbbdevices%
SHARED fbbdependents%
SHARED posk!

'
' setup the command
'
DIM birdchangevaluecmd AS STRING * 16 ' 2 command chars + 14 data
birdchangevaluecmd = "P" + CHR$(0) + CHR$(0) + CHR$(0)

'
' Setup the Change Value menu
'
DIM changevaluemenu$(18)
changevaluemenu$(0) = "Select Parameter to Change:"
changevaluemenu$(1) = "Previous Menu"
changevaluemenu$(2) = "Maximum Range Scaling"
changevaluemenu$(3) = "Filter ON/OFF Status"
changevaluemenu$(4) = "Filter Const - Alpha_Min"
changevaluemenu$(5) = "Bird Measurement Rate"
changevaluemenu$(6) = "Disable/Enable Data Ready Output"
changevaluemenu$(7) = "Change Data Ready Character"
changevaluemenu$(8) = "Set ON ERROR Mask"
changevaluemenu$(9) = "Filter Const - Vm "
changevaluemenu$(10) = "Filter Const - Alpha_Max"
changevaluemenu$(11) = "Block/Allow Sudden Output Changes"
changevaluemenu$(12) = "XYZ Reference Frame"
changevaluemenu$(13) = "Set FBB Host Delay"
changevaluemenu$(14) = "Set FBB Configuration"
changevaluemenu$(15) = "Set FBB ARMed"
changevaluemenu$(16) = "Enable/Disable Group Mode"
changevaluemenu$(17) = "FBB Auto Config - 1 Trans/N Rec"

'
' Set up a table of strings to allow the user to input the VM values
'
DIM rangemsg$(7)
rangemsg$(0) = "For the range 0 to 12 inches, "
rangemsg$(1) = "For the range 12 to 15 inches, "
rangemsg$(2) = "For the range 15 to 19 inches, "
rangemsg$(3) = "For the range 19 to 24 inches, "
rangemsg$(4) = "For the range 24 to 30 inches, "
rangemsg$(5) = "For the range 30 to 38 inches, "
rangemsg$(6) = "For the range 38+ inches, "

DIM extrangemsg$(7)
extrangemsg$(0) = "For the range 0 to 35 inches, "
extrangemsg$(1) = "For the range 35 to 49 inches, "
extrangemsg$(2) = "For the range 49 to 63 inches, "
extrangemsg$(3) = "For the range 63 to 79 inches, "
extrangemsg$(4) = "For the range 79 to 96 inches, "
extrangemsg$(5) = "For the range 96 to 116 inches, "
extrangemsg$(6) = "For the range 116+ inches, "

'
' Setup the Range Menu
'
DIM rangemenu$(3)

rangemenu$(0) = "Select Scaling Range:"
rangemenu$(1) = "36 inch range"
rangemenu$(2) = "72 inch range"

'
' Setup the Error Mask Menu
'
DIM errormaskmenu$(4)
errormaskmenu$(0) = "Select Error Mask Mode:"
errormaskmenu$(1) = "Fatal Errors Blink Forever and Operation is Halted"
errormaskmenu$(2) = "Fatal Errors Blink Once and Operation is Resumed"
errormaskmenu$(3) = "Fatal Errors Do NOT Blink and Operation is Resumed"

'
' Setup the FBB Configuration Menu
'
DIM configmodemenu$(3)
configmodemenu$(0) = "FBB Configuration Mode:"
configmodemenu$(1) = "Standalone"
configmodemenu$(2) = "1 Transmitter, N Receivers"

'
' Get the Status from the Bird
'
IF getbirdstatus% <> TRUE THEN
     EXIT SUB
END IF


'
' Send the Menu to the Screen and take appropriate actioN
'
answer% = sendmenu%(changevaluemenu$(), 17)
SELECT CASE (answer%)
     CASE 0
          EXIT SUB

     CASE 1     ' Range Scale
          '
          ' Set the Parameter number
          '
          MID$(birdchangevaluecmd, 2) = CHR$(3)
          cmdsize% = 4

          '
          ' Now fill the command with the Scale, 0 for 36" or 1 for 72"
          '
          SELECT CASE (sendmenu%(rangemenu$(), 2))
                CASE 0  ' 36"
                    MID$(birdchangevaluecmd, 3) = CHR$(0)
                    posk! = POSK36
                  
                CASE 1  ' 72"
                    MID$(birdchangevaluecmd, 3) = CHR$(1)
                    posk! = POSK72
          
                CASE ESCSEL
                    EXIT SUB
          END SELECT
        

     CASE 2    ' Filter ON/OFF Status
          '
          ' Set the Parameter number
          '
          MID$(birdchangevaluecmd, 2) = CHR$(4)
     cmdsize% = 4

          '
          ' Ask the user to 'fill in the bits'...filter ON/OFF selection
          '
          yesnoanswer% = askyesno%("Do you want the AC Narrow Notch filter OFF")
          IF (yesnoanswer% = TRUE) THEN
               filtercmd% = 4
          ELSE
               IF (yesnoanswer% = ESCSEL) THEN
                    EXIT SUB
               END IF
          END IF
        
          yesnoanswer% = askyesno%("Do you want the AC Wide Notch filter OFF")
          IF (yesnoanswer% = TRUE) THEN
               filtercmd% = filtercmd% + 2
          ELSE
               IF (yesnoanswer% = ESCSEL) THEN
                    EXIT SUB
               END IF
          END IF
        
          yesnoanswer% = askyesno%("Do you want the DC filter OFF")
          IF (yesnoanswer% = TRUE) THEN
               filtercmd% = filtercmd% + 1
          ELSE
               IF (yesnoanswer% = ESCSEL) THEN
                    EXIT SUB
               END IF
          END IF

          '
          ' Set up the command byte in the command string
          '
          MID$(birdchangevaluecmd, 3) = CHR$(filtercmd%)
     
     CASE 3    ' Filter Constant Table - Alpha Min
          '
          ' Set the Parameter number
          '
          MID$(birdchangevaluecmd, 2) = CHR$(5)
          cmdsize% = 16

          FOR i% = 0 TO 6

                '
                ' Get the Filter Value from the User..with validation
                '         0 to 0.99996
        
                DO
                     valid% = TRUE
                     IF posk! = POSK36 THEN
                          PRINT rangemsg$(i%)
                     ELSE
                          PRINT extrangemsg$(i%)
                     END IF
                     PRINT "Input the New Filter Value (0 to 0.99996): ";
                     INPUT filtervalue!

                     IF (filtervalue! < 0!) OR (filtervalue! >= 1!) THEN
                          PRINT "** Error ** invalid filter value...try again"
                          valid% = FALSE
                     END IF
                LOOP UNTIL (valid% = TRUE)

                '
                ' Convert float to word 0 to 32767 and store in the command
                '
                filterword% = filtervalue! * FTW
                MID$(birdchangevaluecmd, 3 + (i% * 2)) = CHR$(filterword% AND &HFF)
                MID$(birdchangevaluecmd, 4 + (i% * 2)) = CHR$(INT(filterword% / 256) AND &HFF)

          NEXT i%

  
     CASE 4    ' Measurement Rate
          '
          ' Set the Parameter number
          '
          MID$(birdchangevaluecmd, 2) = CHR$(6)
          cmdsize% = 4

          '
          ' Get the CPU crstal freq
          '
          IF (getcrystalfreq% = FALSE) THEN
               EXIT SUB
          END IF
               
          PRINT CHR$(LFCHR) + "**NOTE** do not reduce measurement frequency if"
          PRINT "         the Bird is synchronized to the CRT" + CHR$(LFCHR)
          

          '
          ' Get the Measurement frequency from the User
          '
          DO
               valid% = TRUE
               PRINT "Input the desired measurement frequency (14 to 144 Hz): ";
               INPUT measurementrate!

               IF (measurementrate! < 14!) OR (measurementrate! > 144!) THEN
                    PRINT "** Error ** invalid measurement rate...try again"
                    valid% = FALSE
               END IF
          LOOP UNTIL (valid% = TRUE)

          '
          ' Convert to transmitter time counts
          '
          ' Note: Since the xmtrtimecnt can be from 0 to 65536 it must be
          '       a float
          '
          xmtrtimecnt! = (((crystalfreq! / 8!) * 1000!) * (((1000! / measurementrate!) - .3) / 4!))

          '
          ' convert the float xmtrtimecnt! to an integer -32768 to 32767
          '
          IF xmtrtimecnt! > 32767! THEN
               xmtrtimecntword% = xmtrtimecnt! - 65536!
          ELSE
               xmtrtimecntword% = xmtrtimecnt!
          END IF

          '
          ' Store the Word in the Command String
          '
          MID$(birdchangevaluecmd, 3) = CHR$(xmtrtimecntword% AND &HFF)
          MID$(birdchangevaluecmd, 4) = CHR$(INT(xmtrtimecntword% / 256) AND &HFF)

     CASE 5   ' Disable/Enable Data Ready Output

          '
          ' Set the Parameter number and the command size
          '
          MID$(birdchangevaluecmd, 2) = CHR$(8)
          cmdsize% = 3

          '
          ' Ask the User if they want to Enable the Data Output
          ' Character
          '
          answer% = askyesno%("Do you want Data Ready Output enabled")
          IF answer% = ESCSEL THEN
               EXIT SUB
          END IF
          IF (answer% = YES) THEN
               MID$(birdchangevaluecmd, 3) = CHR$(TRUE)
          ELSE
               MID$(birdchangevaluecmd, 3) = CHR$(FALSE)
          END IF

     CASE 6   ' Change Data Ready Character
          '
          ' Set the Parameter number and the command size
          '
          MID$(birdchangevaluecmd, 2) = CHR$(9)
          cmdsize% = 3

          '
          ' Ask the User for the Data Ready Character to Send
          '
          PRINT "Enter the desired data ready character in decimal (0-255): ";
          answer% = getunsigned(0, 255)
          MID$(birdchangevaluecmd, 3) = CHR$(answer%)

     CASE 7   ' Set ON ERROR Mask
          '
          ' Set the Parameter number and the command size
          '
          MID$(birdchangevaluecmd, 2) = CHR$(11)
          cmdsize% = 3

          '
          ' Ask the user if they want to inhibit FATAL Errors
          ' and if the want to inhibit WARNING1 errors
          '
          SELECT CASE (sendmenu%(errormaskmenu$(), 3))
                CASE 0  ' Fatal Error Blinks Forever and Operation is Halted
                    MID$(birdchangevaluecmd, 3) = CHR$(0)
                  
                CASE 1  ' Fatal Error Blinks Once and Operation is Resumed
                    MID$(birdchangevaluecmd, 3) = CHR$(1)

                CASE 2  ' Fatal Error Does Not Blinks and Operation is Resumed
                    MID$(birdchangevaluecmd, 3) = CHR$(3)

                CASE ESCSEL
                    EXIT SUB
          END SELECT
          PRINT

     CASE 8   ' Set DC Filter Constant Table
          '
          ' Set the Parameter number
          '
          MID$(birdchangevaluecmd, 2) = CHR$(12)
          cmdsize% = 16

          '
          ' Ask the user for the Table Values
          '
          FOR i% = 0 TO 6
                IF posk! = POSK36 THEN
                    PRINT rangemsg$(i%) + "enter the VM value: ";
                ELSE
                    PRINT extrangemsg$(i%) + "enter the VM value: ";
                END IF

                vmvalue% = getunsigned%(0, 32767)
                IF vmvalue% = ESCSEL THEN
                     EXIT SUB
                END IF

                '
                ' Store the Word in the Command String
                '
                MID$(birdchangevaluecmd, 3 + (i% * 2)) = CHR$(vmvalue% AND &HFF)
                MID$(birdchangevaluecmd, 4 + (i% * 2)) = CHR$(INT(vmvalue% / 256) AND &HFF)
           NEXT i%

     CASE 9   ' Filter Constant Alpha_Max
          '
          ' Set the Parameter number
          '
          MID$(birdchangevaluecmd, 2) = CHR$(13)
          cmdsize% = 16

          FOR i% = 0 TO 6

                '
                ' Get the Filter Value from the User..with validation
                '         0 to 0.99996
        
                DO
                     valid% = TRUE
                     IF posk! = POSK36 THEN
                         PRINT rangemsg$(i%)
                     ELSE
                         PRINT extrangemsg$(i%)
                     END IF

                     PRINT "Input the New Filter Value (0 to 0.99996): ";
                     INPUT filtervalue!

                     IF (filtervalue! < 0!) OR (filtervalue! >= 1!) THEN
                          PRINT "** Error ** invalid filter value...try again"
                          valid% = FALSE
                     END IF
                LOOP UNTIL (valid% = TRUE)

                '
                ' Convert float to word 0 to 32767 and store in the command
                '
                filterword% = filtervalue! * FTW
                MID$(birdchangevaluecmd, 3 + (i% * 2)) = CHR$(filterword% AND &HFF)
                MID$(birdchangevaluecmd, 4 + (i% * 2)) = CHR$(INT(filterword% / 256) AND &HFF)

          NEXT i%

     CASE 10  ' Glitching ON/OFF
          '
          ' Set the Parameter number and the command size
          '
          MID$(birdchangevaluecmd, 2) = CHR$(14)
          cmdsize% = 3

          '
          ' Ask the User if they want to Enable Glitch Checking
          '
          answer% = askyesno%("Do you want to Block Sudden Output Changes")
          IF answer% = ESCSEL THEN
               EXIT SUB
          END IF
          IF (answer% = YES) THEN
               MID$(birdchangevaluecmd, 3) = CHR$(TRUE)
          ELSE
               MID$(birdchangevaluecmd, 3) = CHR$(FALSE)
          END IF

     CASE 11  ' Set XYZ Reference Frame Status
          
          ' Set the Parameter number and the command size
          '
          MID$(birdchangevaluecmd, 2) = CHR$(17)
          cmdsize% = 3

          '
          ' Ask the User if they want to Enable XYZ Reference Frame Mode
          '
          answer% = askyesno%("Do you want to Enable XYZ Reference Frame")
          IF answer% = ESCSEL THEN
               EXIT SUB
          END IF
          IF (answer% = YES) THEN
               MID$(birdchangevaluecmd, 3) = CHR$(1)
          ELSE
               MID$(birdchangevaluecmd, 3) = CHR$(0)
          END IF


     CASE 12  ' Set FBB Host Delay

          '
          ' Set the Parameter number and the command size
          '
          MID$(birdchangevaluecmd, 2) = CHR$(32)
          cmdsize% = 4

          '
          ' Ask the user to enter the FBB Response Delay
          '
          PRINT
          PRINT "Enter the desired delay in units of microseconds: ";
          answer% = getunsigned%(0, 32767)
          IF (answer% = ESCSEL) THEN
               EXIT SUB
          END IF
          floatanswer = answer% / 10
          tempanswer% = INT(floatanswer)
          IF tempanswer% < floatanswer THEN
               tempanswer% = tempanswer% + 1
          END IF
          MID$(birdchangevaluecmd, 3) = CHR$(tempanswer% AND &HFF)
          MID$(birdchangevaluecmd, 4) = CHR$(INT(tempanswer% / 256) AND &HFF)

     CASE 13  ' Set FBB Configuration

          '
          ' Set the Parameter number and the command size
          '
          MID$(birdchangevaluecmd, 2) = CHR$(33)
          cmdsize% = 7

          '
          ' Ask the user for the Configuration Mode
          '
          SELECT CASE (sendmenu%(configmodemenu$(), 2))
               CASE 0  ' standalone
                    MID$(birdchangevaluecmd, 3) = CHR$(&H0)

               CASE 1  ' one trans/ n rec
                    MID$(birdchangevaluecmd, 3) = CHR$(&H1)

               CASE ESCSEL
                    EXIT SUB
      
          END SELECT

          '
          ' Ask the user for the FBB Device Numbers
          '
          DO
               PRINT "FBB Devices.."

               FOR i% = 1 TO 14
                    PRINT "Device at FBB address ";
                    PRINT USING "##"; i%;
                    PRINT " is ";
                    IF ((2 ^ i% AND fbbdevices%) = 2 ^ i%) THEN
                         PRINT "RUNNING"
                    ELSE
                         PRINT "NOT RUNNING"
                    END IF
               NEXT i%

               PRINT
               PRINT
               PRINT "Enter the FBB address whose RUNNING status you want to change (0 to Quit): ";
               answer% = getunsigned%(0, 14)

               IF (answer% = ESCSEL) THEN
                    EXIT SUB
               END IF
               IF (answer% <> 0) THEN
                    fbbdevices% = fbbdevices% XOR (2 ^ answer%)' flip the bit state
               END IF

          LOOP WHILE (answer% <> 0)
        
          MID$(birdchangevaluecmd, 4) = CHR$(fbbdevices% AND &HFF)
          MID$(birdchangevaluecmd, 5) = CHR$(INT(fbbdevices% / 256) AND &HFF)
          
          '
          '  Ask the user for the FBB Dependents
          '
          DO
               PRINT
               PRINT "FBB Dependents..";

                FOR i% = 1 TO 14
                     '
                     ' Only Active devices can be dependents
                     '
                     IF (((2 ^ i%) AND fbbdevices%) = 2 ^ i%) THEN
                          PRINT "Device at FBB address ";
                          PRINT USING "##"; i%;
                          PRINT " is ";
                          IF (((2 ^ i%) AND fbbdependents%) = 2 ^ i%) THEN
                               PRINT "DEPENDENT"
                          ELSE
                               PRINT "NOT DEPENDENT"
                          END IF
                     END IF
                NEXT i%

                PRINT
                PRINT
                PRINT "Enter the FBB address whose DEPENDENT status you want to change (0 to Quit): ";
                answer% = getunsigned%(0, 14)
                IF answer% = ESCSEL THEN
                     EXIT SUB
                END IF
                IF answer% <> 0 THEN
                      IF ((2 ^ answer% AND fbbdevices%) = 2 ^ answer%) THEN
                            fbbdependents% = fbbdependents% XOR (2 ^ answer%)' flip the bit state
                      ELSE  ' device is not active
                            PRINT "Device at FBB address ";
                            PRINT USING "##"; answer%;
                            PRINT " is NOT ACTIVE"
                      END IF
                END IF
           LOOP WHILE answer% <> 0

           MID$(birdchangevaluecmd, 6) = CHR$(fbbdependents% AND &HFF)
           MID$(birdchangevaluecmd, 7) = CHR$(INT(fbbdependents% / 256) AND &HFF)


     CASE 14  ' Set FBB ARMed

          '
          ' Set the Parameter number and the command size
          '
          MID$(birdchangevaluecmd, 2) = CHR$(34)
          cmdsize% = 3

          '
          ' Ask the user if they want to ARM the Bird
          '
          answer% = askyesno%("Do you want to ARM the Bird")
          IF answer% = ESCSEL THEN
               EXIT SUB
          END IF
          IF answer% = YES THEN
               MID$(birdchangevaluecmd, 3) = CHR$(TRUE)
          ELSE
               MID$(birdchangevaluecmd, 3) = CHR$(FALSE)
          END IF

     CASE 15  ' Enable Group Mode
          '
          ' Set the Parameter number and the command size
          '
          MID$(birdchangevaluecmd, 2) = CHR$(35)
          cmdsize% = 3

          '
          ' Ask the user if they want to Enable Group Mode
          '
          answer% = askyesno%("Do you want to Enable Group Mode")
          IF answer% = ESCSEL THEN
               EXIT SUB
          END IF
          IF answer% = YES THEN
               MID$(birdchangevaluecmd, 3) = CHR$(TRUE)
          ELSE
               MID$(birdchangevaluecmd, 3) = CHR$(FALSE)
          END IF

     CASE 16  ' FBB Auto Configuration - 1 Trans/N Rec

          '
          ' Set the Parameter number and the command size
          '
          MID$(birdchangevaluecmd, 2) = CHR$(50)
          cmdsize% = 3

          '
          ' Ask the user to enter the number of receivers
          '
          PRINT "NOTE:  This Auto Configuration mode assumes that Bird 1 will be a"
          PRINT "       Master and Birds 2 through N will be Slaves"
          PRINT

          PRINT
          PRINT "Enter the number of Bird Units in the Flock: ";
          answer% = getunsigned%(1, 14)
          IF answer% = ESCSEL THEN
               EXIT SUB
          END IF
          MID$(birdchangevaluecmd, 3) = CHR$(answer%)
   
     CASE ESCSEL
        EXIT SUB

END SELECT

'
' Send the Command to the Bird
'
cmdok% = sendserialcmd%(birdchangevaluecmd, cmdsize%)

PRINT "New Values sent to the Bird"

CALL hitkeycontinue

END SUB

SUB birdcrtsync

SHARED crystalfreq!

'
' Setup the Command
'
DIM birdcrtsynccmd AS STRING * 2
birdcrtsynccmd = "A" + CHR$(0)

'
' Setup Space for the Response data
'
DIM crtsyncdata%(4)

'
' Setup the CRT sync menu
'
DIM crtsyncmenu$(4)
crtsyncmenu$(0) = "Select CRT sync Mode:"
crtsyncmenu$(1) = "CRT Sync Off"
crtsyncmenu$(2) = "CRT Sync - Vertical Retrace Greater Than 72 Hz"
crtsyncmenu$(3) = "CRT Sync - Vertical Retrace Less Than 72 Hz"
crtsyncmenu$(4) = "Display CRT Pickup info"

'
' Get the user response to the menu
'
SELECT CASE (sendmenu%(crtsyncmenu$(), 4))
     CASE 0  ' CRT sync OFF
          '
          ' Setup the command type and send it
          '
          MID$(birdcrtsynccmd, 2) = CHR$(0)
          cmdok% = sendserialcmd%(birdcrtsynccmd, 2)
        


     CASE 1  ' CRT sync - Greater than 72 Hz
          '
          ' Setup the command type and send it
          '
          MID$(birdcrtsynccmd, 2) = CHR$(1)
          cmdok% = sendserialcmd%(birdcrtsynccmd, 2)
        
        
     CASE 2  ' CRT sync - Less than 72 Hz
          '
          ' Setup the command type and send it
          '
          MID$(birdcrtsynccmd, 2) = CHR$(2)
          cmdok% = sendserialcmd%(birdcrtsynccmd, 2)


     CASE 3  ' Disply CRT pickup info
          '
          ' Get the Birds Crystal Frequency
          '
          IF (getcrystalfreq% = FALSE) THEN
               EXIT SUB
          END IF
        
          '
          ' Setup the command type
          '
          MID$(birdcrtsynccmd, 2) = CHR$(255)
          '
          ' Display the Pickup Voltage and Retrace Rate
          '
          DO
               '
               ' Send the command
               '
               cmdok% = sendserialcmd%(birdcrtsynccmd, 2)
             
               '
               ' Get the data back from the Bird
               '
               IF (getserialdata%(crtsyncdata%(), 4) = FALSE) THEN
                    EXIT SUB
               END IF

               '
               ' Determine the retrace voltage
               '
               crtvolts! = ((crtsyncdata%(1) AND &H7F) * 256 + crtsyncdata%(0)) * WTF * 5!
               PRINT USING "#.##### "; crtvolts!;

               '
               ' Determine the retrace count
               '
               ' Note: since the rate can be greater than 32767 use a float
               '       to hold the count
               '
               crtretracecount! = (crtsyncdata%(3) * 256!) + crtsyncdata%(2)
             
               '
               ' Don't compute Retrace Rate if the crtretracecount% = 0
               '
               IF (crtretracecount! <> 0!) THEN
                    crtretracerate! = (125000! * crystalfreq! / crtretracecount!) / 2
               ELSE 'compute
                    crtretracerate! = 0!
               END IF
               '
               ' Display the Retrace Rate
               '
               PRINT USING "  ####.##"; crtretracerate!

          LOOP WHILE INKEY$ = ""
             
          '
          ' Setup the command to SYNC OFF and send it
          '
          MID$(birdcrtsynccmd, 2) = CHR$(0)
          cmdok% = sendserialcmd%(birdcrtsynccmd, 2)

     CASE ESCSEL
          EXIT SUB

END SELECT

CALL hitkeycontinue

END SUB

SUB birdechotest
DIM testbuf%(1)
DIM echochar AS STRING * 1

'
' Tell the user to hit any key to echo..
'
PRINT "Hit any key to Echo..<ESC> to end the test"

'
' Stay in a loop sending characters to the Bird until
' the user hits a ESC key.. clear the RX buf first
'
CALL clearrxbuf

WHILE (TRUE)

     '
     ' Wait for a key
     '
     DO
          echokey$ = INKEY$
     LOOP UNTIL echokey$ <> ""

     '
     ' Check if key is ESC
     '
     IF echokey$ = CHR$(ESCCHR) THEN
          EXIT SUB
     END IF

     '
     ' Display the key selected
     '
     PRINT echokey$;

     '
     ' Send the character to the Bird
     '
     MID$(echochar, 1) = echokey$
     cmdok% = sendserialcmd%(echochar, 1)

     '
     ' Get the 1 byte from the Bird
     '
     IF (getserialdata%(testbuf%(), 1) = FALSE) THEN
          EXIT SUB
     END IF
 
     '
     ' Display the char on the console
     '
     PRINT CHR$(testbuf%(0));

WEND


END SUB

SUB birdexaminevalue

SHARED fbbaddrmask%
SHARED fbbcmdbitdiv%
SHARED crystalfreq!
SHARED posk!
SHARED numfbbdevices%
SHARED expandedaddrmode%

'rev 5/10/91 print out fields changed for filter const, rev#, measurement rate
' 4/26/94 print out XYZ Reference Frame value

' Setup the command

DIM birdexaminevaluecmd AS STRING * 2
birdexaminevaluecmd = "O" + CHR$(0)

'
' Setup room for the MAXIMUM, 30 byte response
'
DIM parameter%(30)

'
' Setup the examine value menu
'
DIM examinevaluemenu$(25)
examinevaluemenu$(0) = "Select Parameter to Examine:"
examinevaluemenu$(1) = "Previous Menu"
examinevaluemenu$(2) = "Bird System Status"
examinevaluemenu$(3) = "Software Revision"
examinevaluemenu$(4) = "Bird CPU Crystal Frequency"
examinevaluemenu$(5) = "Maximum Range Scaling"
examinevaluemenu$(6) = "Filter ON/OFF Status"
examinevaluemenu$(7) = "Filter Const - Alpha_Min"
examinevaluemenu$(8) = "Bird Measurement Rate"
examinevaluemenu$(9) = "Data Ready Output"
examinevaluemenu$(10) = "Data Ready Character"
examinevaluemenu$(11) = "Error Code"
examinevaluemenu$(12) = "ON ERROR Mask"
examinevaluemenu$(13) = "Filter Const - Vm"
examinevaluemenu$(14) = "Filter Const - Alpha_Max"
examinevaluemenu$(15) = "Sudden Output Change Detection"
examinevaluemenu$(16) = "Model"
examinevaluemenu$(17) = "Expanded Error Code"
examinevaluemenu$(18) = "XYZ Reference Frame"
examinevaluemenu$(19) = "FBB Host Delay"
examinevaluemenu$(20) = "FBB Configuration"
examinevaluemenu$(21) = "FBB ARMed"
examinevaluemenu$(22) = "FBB Group Mode"
examinevaluemenu$(23) = "FBB System Status"
examinevaluemenu$(24) = "FBB Auto Config - 1 Trans/N Rec"

'
' Setup a Table for the parameter number of the user selections
'
DIM examineparanumber%(24)
examineparanumber%(0) = 0
examineparanumber%(1) = 0
examineparanumber%(2) = 1
examineparanumber%(3) = 2
examineparanumber%(4) = 3
examineparanumber%(5) = 4
examineparanumber%(6) = 5
examineparanumber%(7) = 6
examineparanumber%(8) = 8
examineparanumber%(9) = 9
examineparanumber%(10) = 10
examineparanumber%(11) = 11
examineparanumber%(12) = 12
examineparanumber%(13) = 13
examineparanumber%(14) = 14
examineparanumber%(15) = 15
examineparanumber%(16) = 16
examineparanumber%(17) = 17
examineparanumber%(18) = 32
examineparanumber%(19) = 33
examineparanumber%(20) = 34
examineparanumber%(21) = 35
examineparanumber%(22) = 36
examineparanumber%(23) = 50

'
' Setup a Table for the number of characters returned by each examine command
'
DIM examinedatasize%(24)
examinedatasize%(0) = 0
examinedatasize%(1) = 2
examinedatasize%(2) = 2
examinedatasize%(3) = 2
examinedatasize%(4) = 2
examinedatasize%(5) = 2
examinedatasize%(6) = 14
examinedatasize%(7) = 2
examinedatasize%(8) = 1
examinedatasize%(9) = 1
examinedatasize%(10) = 1
examinedatasize%(11) = 1
examinedatasize%(12) = 14
examinedatasize%(13) = 14
examinedatasize%(14) = 1
examinedatasize%(15) = 10
examinedatasize%(16) = 2
examinedatasize%(17) = 1
examinedatasize%(18) = 2
examinedatasize%(19) = 5
examinedatasize%(20) = 14
examinedatasize%(21) = 1
examinedatasize%(22) = 14
examinedatasize%(23) = 5

'
' Set up some messages for the DC Filter Table
'
DIM rangemsg$(7)
rangemsg$(0) = "For the range 0 to 12 inches, the value is "
rangemsg$(1) = "For the range 12 to 15 inches, the value is "
rangemsg$(2) = "For the range 15 to 19 inches, the value is "
rangemsg$(3) = "For the range 19 to 24 inches, the value is "
rangemsg$(4) = "For the range 24 to 30 inches, the value is "
rangemsg$(5) = "For the range 30 to 38 inches, the value is "
rangemsg$(6) = "For the range 38+ inches, the value is "

DIM extrangemsg$(7)
extrangemsg$(0) = "For the range 0 to 35 inches, the value is "
extrangemsg$(1) = "For the range 35 to 49 inches, the value is "
extrangemsg$(2) = "For the range 49 to 63 inches, the value is "
extrangemsg$(3) = "For the range 63 to 79 inches, the value is "
extrangemsg$(4) = "For the range 79 to 96 inches, the value is "
extrangemsg$(5) = "For the range 96 to 116 inches, the value is "
extrangemsg$(6) = "For the range 116+ inches, the value is "

'
' Get the Status from the Bird
'
IF getbirdstatus% <> TRUE THEN
     EXIT SUB
END IF
'
' Re setup the examine value data size for a few entries if in the
' expanded address mode
'
examinedatasize%(19) = 5
examinedatasize%(20) = 14
examinedatasize%(22) = 14
examinedatasize%(23) = 5
IF expandedaddrmode% = TRUE THEN
     examinedatasize%(19) = 7
     examinedatasize%(20) = 30
     examinedatasize%(22) = 30
     examinedatasize%(23) = 7
END IF

'
' Find out which Value the User wants to look at and take
' appropriate action
'
answer% = sendmenu%(examinevaluemenu$(), 24)
IF (answer% > 0) THEN
     '
     ' Store the command
     '
     MID$(birdexaminevaluecmd, 2) = CHR$(examineparanumber%(answer%))

     '
     ' Send the command to the Bird
     '
     cmdok% = sendserialcmd%(birdexaminevaluecmd, 2)
    
     '
     ' Get the N byte response response
     '
     IF (getserialdata%(parameter%(), examinedatasize%(answer%)) = FALSE) THEN
          EXIT SUB
     END IF

     '
     ' Decode the information retrieved
     '
     SELECT CASE answer%
          CASE 1     ' System Status
               '
               '  Check bit 15 .. master/slave
               '
               IF (parameter%(1) AND &H80) THEN
                PRINT "Bird is a Master"
               ELSE
                    PRINT "Bird is a Slave"
               END IF

               '
               '  Check bit 14 .. initialization
               '
               IF (parameter%(1) AND &H40) THEN
                    PRINT "Bird has been initialized"
               ELSE
                    PRINT "Bird has not been initialized"
               END IF
               
               '
               '  Check bit 13 .. error status
               '
               IF (parameter%(1) AND &H20) THEN
                    PRINT "Error detected"
               ELSE
                    PRINT "No error detected"
               END IF

               '
               '  Check bit 12 .. running
               '
               IF (parameter%(1) AND &H10) THEN
                    PRINT "Bird is not running"
               ELSE
                    PRINT "Bird is running"
               END IF

               '
               '  Check bit 11 .. HOST SYNC
               '
               IF (parameter%(1) AND &H8) THEN
                    PRINT "Bird is in HOST SYNC mode"
               ELSE
                    PRINT "Bird is not in HOST SYNC mode"
               END IF

               '
               '  Check bit 10 .. address mode
               '
               IF (parameter%(1) AND &H4) THEN
                    PRINT "Bird in Expanded address mode"
               ELSE
                    PRINT "Bird in Normal address mode"
               END IF

               '
               '  Check bit 9 .. CRTSYNC
               '
               IF (parameter%(1) AND &H2) THEN
                    PRINT "Bird in CRTSYN mode"
               ELSE
                    PRINT "Bird not in CRTSYN mode"
               END IF

               '
               '  Check bit 8 .. sync modes
               '
               IF (parameter%(1) AND &H1) THEN
                    PRINT "No sync modes enabled"
               ELSE
                    PRINT "A sync mode enabled"
               END IF

               '
               '  Check bit 7 .. factory test commands
               '
               IF (parameter%(0) AND &H80) THEN
                    PRINT "Factory test commands enabled"
               ELSE
                    PRINT "Factory test commands not enabled"
               END IF

               '
               '  Check bit 6 .. XON/XOFF
               '
               IF (parameter%(0) AND &H40) THEN
                    PRINT "XOFF"
               ELSE
                    PRINT "XON"
               END IF

               '
               '  Check bit 5
               '
               IF (parameter%(0) AND &H20) THEN
                    PRINT "Bird in SLEEP mode"
               ELSE
                    PRINT "Bird in RUN mode"
               END IF
           

               '
               ' check output selection
               '
               SELECT CASE ((parameter%(0) AND &H1E) / 2)
                    CASE 1
                         PRINT "Position output selected ";
                    CASE 2
                         PRINT "Angle output selected ";
                    CASE 3
                         PRINT "Matrix output selected ";
                    CASE 4
                         PRINT "Position/Angle output selected ";
                    CASE 5
                         PRINT "Position/Matrix output selected ";
                    CASE 6
                         PRINT "Factory Test output selected ";
                    CASE 7
                         PRINT "Quaternion output selected ";
                    CASE 8
                         PRINT "Position/Quaternion output selected ";
                    CASE ELSE
                         PRINT "Illegal Output mode detected"
                         CALL hitkeycontinue
                         EXIT SUB
               END SELECT

               '
               ' check outputmode
               '
               IF (parameter%(0) AND 1) THEN
                    PRINT "in STREAM mode"
               ELSE
                    PRINT "in POINT mode"
               END IF
                    

          CASE 2     ' Software Rev
               PRINT "Software REV ";
               PRINT USING "#"; parameter%(0);
               PRINT ".";
               PRINT USING "##"; parameter%(1)

          CASE 3     ' CPU Crystal
               '
               ' Store the Value in the Global
               '
               crystalfreq! = parameter%(0)
               PRINT "CPU Crystal is ";
               PRINT USING "##.#"; crystalfreq!;
               PRINT " MHz"

          CASE 4    ' Maximum Range
               PRINT "Mamimimu Range is ";
               IF parameter%(0) = 1 THEN
                    PRINT "72 inches"
               ELSE
                    PRINT "36 inches"
               END IF

          CASE 5    ' Filter Status
               PRINT "AC Narrow Notch filter is: ";
               IF (parameter%(0) AND 4) THEN
                    PRINT "OFF"
               ELSE
                    PRINT "ON"
               END IF

               PRINT "AC Wide Notch filter is: ";
               IF (parameter%(0) AND 2) THEN
                    PRINT "OFF"
               ELSE
                    PRINT "ON"
               END IF

               PRINT "DC filter is: ";
               IF (parameter%(0) AND 1) THEN
                    PRINT "OFF"
               ELSE
                    PRINT "ON"
               END IF

          CASE 6    ' Filter Constant
               '
               ' Display the DC Filter Table
               '
               FOR i% = 0 TO 13 STEP 2
                    filterdata% = parameter%(i%) + (parameter%(i% + 1) * 256)
                    IF posk! = POSK36 THEN
                         PRINT rangemsg$(i% / 2);
                    ELSE
                         PRINT extrangemsg$(i% / 2);
                    END IF
                    PRINT USING " #.####"; filterdata% * WTF
               NEXT i%
                    

          CASE 7    ' Measurement Rate
               IF (getcrystalfreq% = FALSE) THEN
                    EXIT SUB
               END IF
             
               '
               ' Convert the 2 byte parameter to the measurement rate
               '
               ' Note: Since the xmtrtimecnt can be from 0 to 65536 xmtrtimecnt
               '       is a float
               '
               xmtrtimecnt! = parameter%(1) * 256! + parameter%(0)
               measurementrate! = 1000! / ((4! * (xmtrtimecnt! * (8! / crystalfreq!) / 1000!)) + .3)
                  
               PRINT "Measurement Rate: ";
               PRINT USING "###."; measurementrate!;
               PRINT " Hz"
                  
               '
               ' Display the CRT XMTR TIME count
               '
               PRINT "Transmitter Time Counts: ";
               PRINT USING "#####"; xmtrtimecnt!

          CASE 8    ' Disable/Enable Data Ready Output

               PRINT
               PRINT "Data Ready Output is ";
               IF parameter%(0) = TRUE THEN
                    PRINT "ENABLED"
               ELSE
                    PRINT "DISABLED"
               END IF

          CASE 9    ' Change Data Ready Character
               PRINT
               PRINT "Data Ready Output Character is ";
               PRINT USING "###"; parameter%(0);
               PRINT " (decimal)"

          CASE 10   ' Error Code
               PRINT
               PRINT "Error Code is ";
               PRINT parameter%(0)

          CASE 11   ' ON ERROR Mask
               PRINT
               SELECT CASE (parameter%(0) AND &H3)
                    CASE 0
                         PRINT "Fatal Errors Blink Forever and Operation is Halted"
                    CASE 1
                         PRINT "Fatal Errors Blink Once and Operation is Resumed"
                    CASE 2
                         PRINT "Fatal Errors Do NOT Blink and Operation is Halted"
                    CASE 3
                         PRINT "Fatal Errors Do NOT Blink and Operation is Resumed"
               END SELECT
               PRINT
               PRINT

          CASE 12    ' DC Filter Constant Table

               '
               ' Display the DC Filter Table
               '
               FOR i% = 0 TO 13 STEP 2
                    vmdata% = parameter%(i%) + (parameter%(i% + 1) * 256)
                    IF posk! = POSK36 THEN
                         PRINT rangemsg$(i% / 2) + STR$(vmdata%)
                    ELSE
                         PRINT extrangemsg$(i% / 2) + STR$(vmdata%)
                    END IF
               NEXT i%

          CASE 13    ' Filter Constant Alpha Max
               '
               ' Display the DC Filter Table
               '
               FOR i% = 0 TO 13 STEP 2
                    filterdata% = parameter%(i%) + (parameter%(i% + 1) * 256)
                    IF posk! = POSK36 THEN
                         PRINT rangemsg$(i% / 2);
                    ELSE
                         PRINT extrangemsg$(i% / 2);
                    END IF
                    PRINT USING " #.####"; filterdata% * WTF
               NEXT i%
        
          CASE 14    ' Glitch Checking
               PRINT
               IF parameter%(0) = TRUE THEN
                    PRINT "Sudden Output Changes are Not Output"
               ELSE
                    PRINT "Sudden Output Changes are Output"
               END IF

          CASE 15    ' Model
               PRINT
               PRINT "Model is: ";
               FOR i% = 0 TO 9
                  PRINT CHR$(parameter%(i%));
               NEXT i%
               PRINT

          CASE 16   ' Expanded Error Code
               PRINT
               PRINT "Error Code is ";
               PRINT parameter%(0)
               PRINT
               PRINT "** NOTE ** The Expanded Address/Command is only valid for Error 13"
               PRINT "Expanded Error Code Address is ";
               PRINT parameter%(1) AND fbbaddrmask%
               PRINT "Expanded Error Code Command is ";
               PRINT (parameter%(1) AND (NOT fbbaddrmask%)) / fbbcmdbitdiv%

          CASE 17    ' XYZ Reference Frame
               PRINT "XYZ Reference Frame is ";
               IF parameter%(0) = TRUE THEN
                 PRINT " Enabled"
               ELSE
                 PRINT " Not Enabled"
               END IF


          CASE 18    ' FBB Host Delay

               PRINT "FBB Host Response Delay is ";
               PRINT (parameter%(0) + (parameter%(1) * 256)) * 10; " microseconds"
                 
          CASE 19    ' FBB Configuration
toshowfbbconfig:
               IF showfbbconfig%(parameter%()) <> TRUE THEN
                    EXIT SUB
               END IF

          CASE 20    ' Show System Configuration
           
toshowfbbstatus:
               PRINT "Flock Configuration..."
                    
               FOR i% = 0 TO numfbbdevices% - 1

                    IF i% = 20 THEN
                         CALL hitkeycontinue
                    END IF

                    PRINT "FBB ADDR ";
                    PRINT USING "##"; i% + 1;
                    PRINT ": ";
                      
                    IF ((parameter%(i%) AND &H80) = &H0) THEN
                         PRINT "NOT ACCESSIBLE";
                    ELSE

                    IF ((parameter%(i%) AND &H90) = &H80) THEN
                         PRINT "6DFOB, ACCESSIBLE, ";

                    ELSE
                         PRINT "ERC, ACCESSIBLE, ";
                    END IF
                    
                    IF ((parameter%(i%) AND &H40) = &H40) THEN
                         PRINT "RUNNING, ";
                    ELSE
                         PRINT "Not RUNNING, ";
                    END IF

                    IF ((parameter%(i%) AND &H10) = &H0) THEN
                         IF ((parameter%(i%) AND &H20) = &H20) THEN
                              PRINT "RCVR";
                         ELSE
                              PRINT "No RCVR";
                         END IF

                         IF ((parameter%(i%) AND &H1) = &H1) THEN
                              PRINT ", XMTR";
                         ELSE
                              PRINT ", No XMTR ";
                         END IF
                    END IF
                      
                     
                    IF ((parameter%(i%) AND &H11) = &H11) THEN
                         PRINT " ERT0 ";
                    END IF
                     
                    IF ((parameter%(i%) AND &H12) = &H12) THEN
                         PRINT " ERT1 ";
                    END IF

                    IF ((parameter%(i%) AND &H14) = &H14) THEN
                         PRINT " ERT2 ";
                    END IF

                    IF ((parameter%(i%) AND &H18) = &H18) THEN
                         PRINT " ERT3 ";
                    END IF
                      
                    IF ((parameter%(i%) AND &H1F) = &H10) THEN
                         PRINT " No ERTs ";
                    END IF
                    END IF
                    PRINT
               NEXT i%
            
          CASE 21   ' FBB Group Mode
               IF parameter%(0) = TRUE THEN
                    PRINT "FBB Group Mode is Enabled"
               ELSE
                    PRINT "FBB Group Mode is Disabled"
               END IF

          CASE 22   ' FBB System Status
               GOTO toshowfbbstatus
          CASE 23   ' FBB Auto Configuration
               GOTO toshowfbbconfig

     END SELECT
   
     CALL hitkeycontinue

END IF

END SUB

SUB birdhemisphere

DIM hemimenu$(6)

'
' Values to Send the Bird For a Given Hemisphere
'
'              hemixyz%     hemisin%
'FORWARD          0             0
'AFT              0             1
'UPPER            12            1
'LOWER            12            0
'LEFT             6             1
'RIGHT            6             0

hemimenu$(0) = "Hemisphere Options:"
hemimenu$(1) = "Forward"
hemimenu$(2) = "Aft"
hemimenu$(3) = "Upper"
hemimenu$(4) = "Lower"
hemimenu$(5) = "Left"
hemimenu$(6) = "Right"

SELECT CASE sendmenu%(hemimenu$(), 6)
     CASE 0          'Forward
          hemixyz% = 0
          hemisin% = 0
     CASE 1          'Aft
          hemixyz% = 0
          hemisin% = 1
     CASE 2          'Upper
          hemixyz% = 12
          hemisin% = 1
     CASE 3          'Lower
          hemixyz% = 12
          hemisin% = 0
     CASE 4          'Left
          hemixyz% = 6
          hemisin% = 1
     CASE 5          'Right
          hemixyz% = 6
          hemisin% = 0
     CASE ESCSEL
          EXIT SUB
END SELECT

'
' Send the Hemisphere Command
'
birdcmd$ = "L" + CHR$(hemixyz%) + CHR$(hemisin%)
cmdok% = sendserialcmd%(birdcmd$, 3)

PRINT "Hemisphere Data Sent to the Bird"
CALL hitkeycontinue
END SUB

SUB birdmatrix (outputmode%, buttonmode%)

'
' set up storage for the received record data
'
DIM birddata%(9)

'
' Send the Matrix Command
'
cmdok% = sendserialcmd%("X", 1)

'
' if in STREAM mode then send the Stream command
'
IF outputmode% = STREAM THEN
     cmdok% = sendserialcmd%("@", 1)
END IF

'
' if in POINT mode then prompt the User
'
IF outputmode% = POINTM THEN
     PRINT
     PRINT "Hit the 'B' key to read Bird Data, or any other key to Quit"
END IF

'
' Stay in a loop displaying Angle data from the Bird
'
WHILE checkdone%(outputmode%) = FALSE  ' continue until TRUE
     '
     ' read 9 words of data from the Bird
     '
     IF (readbirddata%(birddata%(), 9, outputmode%, buttonmode%) = FALSE) THEN
          EXIT SUB
     END IF

     '
     ' convert the birddata%() to angles and display
     '
     CALL printmatrix(birddata%())


WEND

END SUB

SUB birdmousebuttons

SHARED buttonmode%
'
' Setup the Command
'
DIM birdbuttonmodecmd AS STRING * 2
birdbuttonmodecmd = "M"         ' initialize the command byte

'
' Setup room for the Response
'
DIM buttonvalue%(1)

'
' Ask the user if they want the Button Commands to aways be sent
'
IF askyesno%("Do you want the Button Byte added to the End of the Data Stream") = TRUE THEN
     buttonmode% = 1
END IF

'
' Set the command mode byte
'
MID$(birdbuttonmodecmd, 2, 1) = CHR$(buttonmode%)

'
' Send the command to the Bird
'
cmdok% = sendserialcmd%(birdbuttonmodecmd, 2)

'
' Ask if they want to display the button value now
'
PRINT
IF askyesno%("Do you want to display the Button Value now") = TRUE THEN
   
     PRINT "Hit any key to stop printing the button value"

     '
     ' Display the Button value until a key hit
     '
     WHILE (INKEY$ = "")
          '
          ' Send the command to return the Button Value
          '
          cmdok% = sendserialcmd%("N", 1)

          '
          ' Get the Button Byte from the Com Port
          '
          IF (getserialdata%(buttonvalue%(), 1) = FALSE) THEN
               EXIT SUB
          END IF

          '
          ' Display the Button Value as a Decimal Number
          '
          PRINT "Button = "; ASC(CHR$(buttonvalue%(0)))
     WEND
   
END IF

END SUB

SUB birdoutputtest

DIM testbuf%(4)

'
' Stay in a loop displaying the info from the Bird until
' the user hits a key.. clear the RX buf first
'
CALL clearrxbuf
WHILE (INKEY$ = "")

     '
     ' Get the 4 bytes from the Bird
     '
     IF (getserialdata%(testbuf%(), 4) = FALSE) THEN
          EXIT SUB
     END IF
  
     '
     ' Display the 4 chars
     '
     FOR i% = 0 TO 3
          PRINT CHR$(testbuf%(i%));
     NEXT i%

WEND

END SUB

SUB birdposition (outputmode%, buttonmode%)

SHARED buttonvalue%
SHARED posk!

'
' set up storage for the received record data
'
DIM birddata%(3)

'
' Send the Position Command
'
cmdok% = sendserialcmd%("V", 1)

'
' if in STREAM mode then send the Stream command
'
IF outputmode% = STREAM THEN
     cmdok% = sendserialcmd%("@", 1)
END IF

'
' if in POINT mode then prompt the User
'
IF outputmode% = POINTM THEN
     PRINT
     PRINT "Hit the 'B' key to read Bird Data, or any other key to Quit"
END IF
'
' Stay in a loop displaying Position data from the Bird
'
WHILE checkdone%(outputmode%) = FALSE  ' continue until TRUE
     '
     ' read 3 words of data from the Bird
     '
     IF (readbirddata%(birddata%(), 3, outputmode%, buttonmode%) = FALSE) THEN
          EXIT SUB
     END IF

     '
     ' convert the birddata%() to inches and display
     '
     FOR i% = 0 TO 2
          PRINT USING "      ###.##"; birddata%(i%) * posk!;
     NEXT i%

     '
     ' Print the button value
     '
     IF buttonmode% <> 0 THEN
          PRINT USING "      ###"; buttonvalue%;
     END IF
     PRINT ""

WEND

END SUB

SUB birdpositionandangles (outputmode%, buttonmode%)

SHARED buttonvalue%
SHARED posk!

'
' set up storage for the received record data
'
DIM birddata%(6)

'
' Send the Position Command
'
cmdok% = sendserialcmd%("Y", 1)

'
' if in STREAM mode then send the Stream command
'
IF outputmode% = STREAM THEN
     cmdok% = sendserialcmd%("@", 1)
END IF

'
' if in POINT mode then prompt the User
'
IF outputmode% = POINTM THEN
     PRINT
     PRINT "Hit the 'B' key to read Bird Data, or any other key to Quit"
END IF
'
' Stay in a loop displaying Position data from the Bird
'
WHILE checkdone%(outputmode%) = FALSE  ' continue until TRUE
     '
     ' read 6 words of data from the Bird
     '
     IF (readbirddata%(birddata%(), 6, outputmode%, buttonmode%) = FALSE) THEN
          EXIT SUB
     END IF

     '
     ' convert the birddata%() to inches and display
     '
     FOR i% = 0 TO 2
          PRINT USING "  ###.##"; birddata%(i%) * posk!;
     NEXT i%

     '
     ' convert the birddata%() to angles and display
     '
     FOR i% = 3 TO 5
          PRINT USING "  ####.##"; birddata%(i%) * ANGK;
     NEXT i%
        
     '
     ' Print the button value
     '
     IF buttonmode% <> 0 THEN
          PRINT USING "      ###"; buttonvalue%;
     END IF
     PRINT ""
   

WEND

END SUB

SUB birdpositionandmatrix (outputmode%, buttonmode%)

SHARED posk!

'
' set up storage for the received record data
'
DIM birddata%(12)

'
' Send the Matrix Command
'
cmdok% = sendserialcmd%("Z", 1)

'
' if in STREAM mode then send the Stream command
'
IF outputmode% = STREAM THEN
     cmdok% = sendserialcmd%("@", 1)
END IF

'
' if in POINT mode then prompt the User
'
IF outputmode% = POINTM THEN
     PRINT
     PRINT "Hit the 'B' key to read Bird Data, or any other key to Quit"
END IF
'
' Stay in a loop displaying Position and Matrix data from the Bird
'
WHILE checkdone%(outputmode%) = FALSE  ' continue until TRUE
     '
     ' read 12 words of data from the Bird
     '
     IF (readbirddata%(birddata%(), 12, outputmode%, buttonmode%) = FALSE) THEN
          EXIT SUB
     END IF

     '
     ' convert the birddata%() to inches and display
     '
     FOR i% = 0 TO 2
          PRINT USING "      ###.##"; birddata%(i%) * posk!;
     NEXT i%
     PRINT ""

     '
     ' Since printmatrix needs the birddata array offset by 3
     ' ...adjust the matrix data to start at birddata(0)
     '
     FOR i% = 0 TO 8
          birddata%(i%) = birddata%(i% + 3)
     NEXT i%
     CALL printmatrix(birddata%())
WEND

END SUB

SUB birdposquaternions (outputmode%, buttonmode%)

SHARED posk!

'
' set up storage for the received record data
'
DIM birddata%(7)

'
' Send the Position/Quaternions Command
'
cmdok% = sendserialcmd%("]", 1)

'
' if in STREAM mode then send the Stream command
'
IF outputmode% = STREAM THEN
     cmdok% = sendserialcmd%("@", 1)
END IF

'
' if in POINT mode then prompt the User
'
IF outputmode% = POINTM THEN
     PRINT
     PRINT "Hit the 'B' key to read Bird Data, or any other key to Quit"
END IF
'
' Stay in a loop displaying Position and Quaternions data from the Bird
'
WHILE checkdone%(outputmode%) = FALSE  ' continue until TRUE
     '
     ' read 7 words of data from the Bird
     '
     IF (readbirddata%(birddata%(), 7, outputmode%, buttonmode%) = FALSE) THEN
          EXIT SUB
     END IF

     '
     ' convert the birddata%() to inches and display
     '
     FOR i% = 0 TO 2
          PRINT USING "      ###.##"; birddata%(i%) * posk!;
     NEXT i%
     PRINT ""

     '
     ' Since printquaternions needs the birddata array offset by 3
     ' ...adjust the quaternions data to start at birddata(0)
     '
     FOR i% = 0 TO 3
          birddata%(i%) = birddata%(i% + 3)
     NEXT i%
     CALL printquaternions(birddata%())
WEND

END SUB

SUB birdquaternions (outputmode%, buttonmode%)

'
' set up storage for the received record data
'
DIM birddata%(4)

'
' Send the Quaternions Command
'
cmdok% = sendserialcmd%("\", 1)

'
' if in STREAM mode then send the Stream command
'
IF outputmode% = STREAM THEN
     cmdok% = sendserialcmd%("@", 1)
END IF

'
' if in POINT mode then prompt the User
'
IF outputmode% = POINTM THEN
     PRINT
     PRINT "Hit the 'B' key to read Bird Data, or any other key to Quit"
END IF

'
' Stay in a loop displaying Angle data from the Bird
'
WHILE checkdone%(outputmode%) = FALSE  ' continue until TRUE
     '
     ' read 4 words of data from the Bird
     '
     IF (readbirddata%(birddata%(), 4, outputmode%, buttonmode%) = FALSE) THEN
          EXIT SUB
     END IF

     '
     ' convert the birddata%() to quaternions and display
     '
     CALL printquaternions(birddata%())


WEND

END SUB

SUB birdreferframe
DIM birdrefframecmd AS STRING * 13
DIM anglearray!(3)

birdrefframecmd$ = "H"              'Start the command
'
' Get the three angles from the user
'
PRINT "Enter the Angles for the new reference frame..."
IF getangles%(anglearray!()) = FALSE THEN
     EXIT SUB
END IF

'
' convert the angles to SIN and COS and store in the command string
'
'
cpos% = 2
FOR i% = 0 TO 2
     '
     ' Get the Sine of the Angle
     '
     tempfloat! = SIN(anglearray!(i%) * DTR)
     '
     ' Trap for Sin = 1.00 since the bird can only accept -1.00 to 0.99996
     '
     IF tempfloat! < .99998 THEN
          word% = (tempfloat! * FTW)
     ELSE
          word% = 32767
     END IF
     MID$(birdrefframecmd, cpos%, 1) = CHR$(word% AND &HFF)
     MID$(birdrefframecmd, cpos% + 1, 1) = CHR$(((word% AND &HFF00) / 256) AND &HFF)
       
     '
     ' Get the Cosine of the Angle
     '
     tempfloat! = COS(anglearray!(i%) * DTR)
     '
     ' Trap for Cos = 1.00 since the bird can only accept -1.00 to 0.99996
     '
     IF tempfloat! < .99998 THEN
          word% = (tempfloat! * FTW)
     ELSE
          word% = 32767
     END IF
     MID$(birdrefframecmd, cpos% + 2, 1) = CHR$(word% AND &HFF)
     MID$(birdrefframecmd, cpos% + 3, 1) = CHR$(((word% AND &HFF00) / 256) AND &HFF)
     cpos% = cpos% + 4
NEXT i%

'
' Send the reference frame command to the Bird
'
cmdok% = sendserialcmd%(birdrefframecmd, 13)

PRINT "Reference Frame Sent to the Bird"

CALL hitkeycontinue

END SUB

SUB birdreportrate


DIM birdratecmd AS STRING * 1
DIM repratemenu$(5)
'
' Setup the Menu
'
repratemenu$(0) = "Select the Report Rate (for Stream Mode):"
repratemenu$(1) = "MAX"
repratemenu$(2) = "MAX/2"
repratemenu$(3) = "MAX/8"
repratemenu$(4) = "MAX/32"

'
' Send the Menu to the Console
'
SELECT CASE sendmenu%(repratemenu$(), 4)
     CASE 0
          birdratecmd = "Q"
     CASE 1
          birdratecmd = "R"
     CASE 2
          birdratecmd = "S"
     CASE 3
          birdratecmd = "T"
     CASE ESCSEL
          EXIT SUB
END SELECT

'
' Send the rate command to the Bird
'
cmdok% = sendserialcmd%(birdratecmd, 1)

PRINT "Report Rate send to the Bird"

CALL hitkeycontinue

END SUB

SUB birdsleepwake

DIM birdsleepwakecmd AS STRING * 1
DIM sleepwakemenu$(3)
'
' Setup the menu selections
'
sleepwakemenu$(0) = "Enter Selection:"
sleepwakemenu$(1) = "Sleep"
sleepwakemenu$(2) = "Wake"

SELECT CASE sendmenu%(sleepwakemenu$(), 2)
     CASE 0
          birdsleepwakecmd = "G"

     CASE 1
          birdsleepwakecmd = "F"
     CASE ESCSEL
          EXIT SUB
END SELECT

'
' Send the sleep or wake command to the Bird
'
cmdok% = sendserialcmd%(birdsleepwakecmd, 1)

PRINT "Sent the Sleep/Wake command to the Bird"

CALL hitkeycontinue

END SUB

SUB birdxonxoff

DIM birdflowcmd AS STRING * 1

DIM xonxoffmenu$(3)

xonxoffmenu$(0) = "Select Flow Command:"
xonxoffmenu$(1) = "XON"
xonxoffmenu$(2) = "XOFF"

'
' Ask the User which flow command they want...and take action
'
SELECT CASE (sendmenu%(xonxoffmenu$(), 2))

     CASE 0
          birdflowcommand = XON

     CASE 1
          birdflowcommand = XOFF

     CASE ESCSEL
          EXIT SUB

END SELECT

'
' Send the Command to the Bird
'
cmdok% = sendserialcmd%(birdflowcmd, 1)

PRINT "Sent Flow command to the Bird"

CALL hitkeycontinue

END SUB

FUNCTION checkdone% (outputmode%)

SHARED phaseerrorcount%

'
' Assume not done
'
checkdone% = FALSE

SELECT CASE outputmode%
   
     CASE STREAM
          '
          ' ckeck for any key
          '
          IF INKEY$ <> "" THEN
               cmdok% = sendserialcmd%("B", 1) ' send the point command to stop stream

               '
               ' check for phase errors
               '
               IF phaseerrorcount% <> 0 THEN
                    PRINT "*NOTE* "; phaseerrorcount%; "Phase Errors have occured"
               END IF

               '
               ' indicate we're done
               '
               checkdone% = TRUE
               CALL hitkeycontinue
          END IF

     CASE CONTINUOUS
          '
          ' Check for any key
          '
          IF INKEY$ <> "" THEN
               '
               ' indicate we're done
               '
               checkdone% = TRUE
               CALL hitkeycontinue
          ELSE
               '
               ' send the point command for next record
               '
               cmdok% = sendserialcmd%("B", 1)
        
          END IF

     CASE POINTM
      
          '
          ' Wait for a key
          '
          DO
               key$ = INKEY$
          LOOP WHILE key$ = ""

          '
          ' Check to see if it was a B or b
          '
          IF UCASE$(key$) = "B" THEN
               cmdok% = sendserialcmd%("B", 1)
          ELSE
               checkdone% = TRUE           ' else... say we're done
          END IF

END SELECT

END FUNCTION

SUB clearrxbuf

'
' Clear the Receive buffer
'
WHILE (LOC(1) > 0)
     rxchar$ = INPUT$(1, #1)
WEND

END SUB

FUNCTION getangles% (anglearray!())
'
' Define String Prompts
'
DIM angleprompt$(3)
angleprompt$(0) = "Azimuth"
angleprompt$(1) = "Elevation"
angleprompt$(2) = "Roll"

'
' Define Validation
'
DIM anglemin!(3)
anglemin!(0) = -180!
anglemin!(1) = -90!
anglemin!(2) = -180!

DIM anglemax!(3)
anglemax!(0) = 180!
anglemax!(1) = 90!
anglemax!(2) = 180!

'
' Get the 3 angles from the user with validation
'
FOR angle% = 0 TO 2
     DO
          valid% = TRUE
          PRINT "Input " + angleprompt$(angle%);
          INPUT floatangle!

          IF (floatangle! < anglemin!(angle%)) OR (floatangle! >= anglemax!(angle%)) THEN
               PRINT "** Error ** invalid angle...try again"
               valid% = FALSE
          END IF
     LOOP UNTIL (valid% = TRUE)

     '
     ' Store the Validated Angle
     '
     anglearray!(angle%) = floatangle!

NEXT angle%

getangles% = TRUE

END FUNCTION

FUNCTION getbirdstatus%

SHARED rs232tofbbaddr%
SHARED expandedaddrmode%
SHARED fbbaddrmask%
SHARED fbbcmdbitdiv%
SHARED numfbbdevices%

'
' Setup the Command
'
DIM getbirdstatuscmd AS STRING * 2
getbirdstatuscmd = "O" + CHR$(0)

'
' Dimension space for the received data
'
DIM parameter%(2)

'
' Save the RS232 to FBB address...this command will always be sent to
' address 0
'
temprs232tofbbaddr% = rs232tofbbaddr%
'
' Put up a message indicating Bird Status
'
PRINT "Checking Bird Status..."

'
' Send the Command to the Bird
'
cmdok% = sendserialcmd%(getbirdstatuscmd, 2)

'
' Get the 2 characater response from the Bird
'
IF (getserialdata%(parameter%(), 2) = FALSE) THEN
     PRINT "** ERROR ** could not read status from the Bird"
     getbirdstatus% = FALSE
     rs232tofbbaddr% = temprs232tofbbaddr%
     EXIT FUNCTION
END IF

'
' Set up the expanded address mode variable using the bit information
' returned in the status word
'
IF (parameter%(1) AND &H4) THEN
     PRINT "System configured in expanded address mode"
     PRINT
     expandedaddrmode% = TRUE
     fbbaddrmask% = &H1F
     numfbbdevices% = 30
     fbbcmdbitdiv% = 32
ELSE
     PRINT "System configured in normal address mode"
     PRINT
     fbbaddrmask% = &HF
     fbbcmdbitdiv% = 16
     numfbbdevices% = 14
     expandedaddrmode% = FALSE
END IF

'
' Restore the rs232tofbbaddr%
'
rs232tofbbaddr% = temprs232tofbbaddr%

getbirdstatus% = TRUE

END FUNCTION

FUNCTION getcrystalfreq%

SHARED crystalfreq!

'
' Setup the Command
'
DIM getcrystalfreqcmd AS STRING * 2
getcrystalfreqcmd = "O" + CHR$(2)

'
' Dimension space for the received data
'
DIM parameter%(2)

'
' Send the Command to the Bird
'
cmdok% = sendserialcmd%(getcrystalfreqcmd, 2)

'
' Get the 2 characater response from the Bird
'
IF (getserialdata%(parameter%(), 2) = FALSE) THEN
     getcrystalfreq% = FALSE
     EXIT FUNCTION
END IF

'
' Set up the Crystal frequency
'
crystalfreq! = parameter%(0)

getcrystalfreq% = TRUE

END FUNCTION

'  getoutputmode        Get the output mode from the User
'
'  Parameters Passed:   none
'
'  Return Value:        user selection, POINT, CONTINUOUS, or STREAM
'
'  Function:            Routine presents the user with the output modes and
'                       waits for a user response
'
FUNCTION getoutputmode%
SHARED rs232tofbbaddr%

DIM outputmodemenu$(3)

outputmodemenu$(0) = "Output Mode Selections:"
outputmodemenu$(1) = "Point"
outputmodemenu$(2) = "Continuous"
outputmodemenu$(3) = "Stream"

'
' Skip the display of the STREAM if the RS232 to FBB address is active
'
IF rs232tofbbaddr% = 0 THEN
     menusize% = 3
ELSE
     menusize% = 2
END IF


getoutputmode% = sendmenu%(outputmodemenu$(), menusize%)

END FUNCTION

FUNCTION getserialdata% (dataarray%(), charstoread%)

SHARED serialerr%

'
' Setup Error Trapping
'
TIMER ON                        ' enable time out trap
ON ERROR GOTO serialrxerror     ' enable serial receive data trap

'
' Get the n byte characater response from the Bird and store as integers
'
FOR i% = 0 TO charstoread% - 1
     DO
     LOOP UNTIL (LOC(1) <> 0) OR (serialerr% = TRUE)

     IF serialerr% = FALSE THEN
          dataarray%(i%) = ASC(INPUT$(1, #1))
     ELSE
          serialerr% = FALSE
          PRINT "** ERROR ** could not read back data from the bird"
          CALL hitkeycontinue
          getserialdata% = FALSE
          ON ERROR GOTO 0     ' disable serial receive data trap
          EXIT FUNCTION
     END IF

NEXT i%

TIMER OFF
ON ERROR GOTO 0     ' disable serial receive data trap

getserialdata% = TRUE

END FUNCTION

FUNCTION getserialrecord% (recordsize%, outputmode%)

SHARED serialerr%
SHARED phaseerrorcount%
SHARED rxbuf AS STRING * 100

DIM temprxbuf AS STRING * 100
DIM rxchar AS STRING * 1

'
' Set up the error Traps
'
ON ERROR GOTO serialrxerror
TIMER ON

'
' Set up the receive character counter
'
charcount% = 1
 
DO
     '
     ' Get character only if one is available...since QuickBASIC will
     ' hang at the INPUT$ until one is available not allowing the ON TIMER
     ' function to work
     '
     DO
     LOOP UNTIL (LOC(1) <> 0) OR (serialerr% = TRUE)

     IF serialerr% = FALSE THEN
          rxchar = INPUT$(1, #1)                 ' get the char
     END IF
     '
     ' Process the characters... as long as serial errors have not occurred
     '
     IF serialerr% = FALSE THEN
          IF charcount% = 1 THEN
               IF ((ASC(rxchar) AND &H80) = &H80) THEN
                    MID$(rxbuf, charcount%) = rxchar
               ELSE
                    IF outputmode% <> STREAM THEN
                         errorflag% = RXPHASEERROR
                    ELSE
                         phaseerrorcount% = phaseerrorcount% + 1
                         DO
                              rxchar = INPUT$(1, #1)
                         LOOP UNTIL ((ASC(rxchar) AND &H80) = &H80) OR (serialerr% = TRUE)
                         IF serialerr% = FALSE THEN
                              MID$(rxbuf, charcount%) = rxchar
                         ELSE
                              errorflag% = RXERROR
                         END IF
                    END IF
               END IF
          ELSE
               IF ((ASC(rxchar) AND &H80) = &H0) THEN     ' check for phase = 0
                    MID$(rxbuf, charcount%) = rxchar
               ELSE
                    IF outputmode% <> STREAM THEN
                         errorflag% = RXPHASEERROR
                    ELSE
                         charcount = 1           ' clear the counter
                         rxbuf = ""              ' clear the buffer
                    END IF
               END IF
          END IF
          charcount% = charcount% + 1         ' increment the char counter
     END IF
LOOP UNTIL (serialerr% = TRUE) OR (errorflag% <> 0) OR (charcount% > recordsize%)

'
' read records from the buffer if 1 or more records is currently
' present in the buffer, to prevent the buffer from eventually overflowing
' ....throw the data away
'
WHILE (LOC(1) >= recordsize%) AND (serialerr% = FALSE)
     temprxbuf = INPUT$(recordsize%, #1)
WEND

'
'   Shut off the timer
'
TIMER OFF

'
' Get ready to return the number of chars received
'
getserialrecord% = charcount%

'
' Check to see if a RX error occurred
'
IF (errorflag% <> 0) THEN
     getserialrecord% = errorflag%
END IF

'
' Return the result of reading the record...
' If an error occurred, return RXERROR
' else, return the number of characters read
'
IF (serialerr% = TRUE) THEN
     serialerr% = FALSE
     getserialrecord% = RXERROR
END IF

END FUNCTION

FUNCTION getunsigned% (min%, max%)
'
' Initialize the user response to 0
'
DIM answerstring AS STRING * 80

'
' Keep a counter for the number of valid keys entered
'
chrcount% = 1

DO
     '
     ' Wait for a key from the user
     '
     '
     DO
          key$ = INKEY$
     LOOP UNTIL key$ <> ""
   
     asciikey% = ASC(key$)

     '
     ' Take action on the key
     '
     SELECT CASE asciikey%
          CASE ESCCHR
               getunsigned% = ESCSEL
               EXIT FUNCTION
        
          CASE &H30 TO &H39
               PRINT CHR$(asciikey%);
               MID$(answerstring, chrcount%) = CHR$(asciikey%)
               chrcount% = chrcount% + 1

          CASE CRCHR
               IF (chrcount% = 1) THEN
                    PRINT CHR$(BELCHR);
               ELSE
                    PRINT CHR$(CRCHR)
                    getunsigned% = VAL(LEFT$(answerstring, chrcount% - 1))
                    EXIT FUNCTION
               END IF
        
          CASE BSCHR
               IF chrcount% > 1 THEN
                    LOCATE CSRLIN, POS(0) - 1
                    PRINT CHR$(SPCHR);
                    LOCATE CSRLIN, POS(0) - 1
                    chrcount% = chrcount% - 1
               ELSE
                    PRINT CHR$(BELCHR);
               END IF

          CASE ELSE
               PRINT CHR$(BELCHR);

     END SELECT

LOOP WHILE TRUE

END FUNCTION

SUB hitkeycontinue

'
' Prompt the user
'
PRINT
PRINT "...hit any key to continue"

'
' Wait for a key stroke
'
DO
LOOP WHILE INKEY$ = ""

END SUB

SUB hostreadblocktest

DIM testbuf%(256)
DIM tempchar AS STRING * 1

'
' Use a SPACE to send to the Bird
'
MID$(tempchar, 1) = " "

'
' Tell the user to hit any key to read the block..
'
PRINT "Hit any key to read the block..<ESC> to end the test"

'
' Stay in a loop displaying the block of data from the Bird until
' the user hits a ESC key.. clear the RX buf first
'
CALL clearrxbuf

WHILE (TRUE)

     '
     ' Wait for a key
     '
     DO
          key$ = INKEY$
     LOOP UNTIL key$ <> ""

     '
     ' Check if key is ESC
     '
     IF key$ = CHR$(ESCCHR) THEN
          EXIT SUB
     END IF

     '
     ' Send the SPACE to the Bird
     '
     cmdok% = sendserialcmd%(tempchar, 1)

     '
     ' Get the 256 bytes from the Bird
     '
     IF (getserialdata%(testbuf%(), 256) = FALSE) THEN
          EXIT SUB
     END IF

     '
     ' Display the 256 chars as decimal numbers on the console
     '
     PRINT
     PRINT
     PRINT "Bird Output: "; testbuf%(0);
     FOR i% = 1 TO 255
          PRINT ",";
          PRINT testbuf%(i%);
     NEXT i%

WEND

END SUB

SUB hostreadtest

DIM testbuf%(1)
DIM tempchar AS STRING * 1

'
' Use a SPACE to send to the Bird
'
MID$(tempchar, 1) = " "

'
' Tell the user to hit any key to read the char..
'
PRINT "Hit any key to read the character..<ESC> to end the test"

'
' Stay in a loop displaying the character from the Bird until
' the user hits a ESC key.. clear the RX buf first
'
CALL clearrxbuf

WHILE (TRUE)

     '
     ' Wait for a key
     '
     DO
          key$ = INKEY$
     LOOP UNTIL key$ <> ""

     '
     ' Check if key is ESC
     '
     IF key$ = CHR$(ESCCHR) THEN
          EXIT SUB
     END IF

     '
     ' Send the SPACE to the Bird
     '
     cmdok% = sendserialcmd%(tempchar, 1)

     '
     ' Get the 1 character from the Bird
     '
     IF (getserialdata%(testbuf%(), 1) = FALSE) THEN
          EXIT SUB
     END IF

     '
     ' Display the 1 char as decimal number on the console
     '
     PRINT "Bird Output: "; testbuf%(0)
WEND
END SUB

SUB nextmastercmd

DIM nextmastercmdstr AS STRING * 1

'
' Get the Next Master from the User
'

PRINT "Enter the NEXT Master address (1 - 14): ";
nextmaster% = getunsigned%(1, 14)
IF nextmaster% = ESCSEL THEN
     EXIT SUB
END IF

'
' Send the command to the Bird '0' (30h) + the FBB Address
'
nextmastercmdstr = CHR$(nextmaster% + &H30)

cmdok% = sendserialcmd%(nextmastercmdstr, 2)

PRINT "Next Master Command Sent"
CALL hitkeycontinue

END SUB

SUB nextxmtrcmd

DIM nextxmtrcmdstr AS STRING * 2

'
' Get the Next Transmitter Address from the User
'
PRINT "Enter the NEXT Transmitter Address (1 - 14): ";
answer% = getunsigned%(1, 14)
IF answer% = ESCSEL THEN
     EXIT SUB
END IF

'
' Store the Info in the MS Nibble of the Next Transmitter Char
'
nextxmtr% = answer% * 16

'
' Get the Next Transmitter Number from the User
'
PRINT "Enter the NEXT Transmitter Number (0 - 3): ";
answer% = getunsigned%(0, 3)
IF answer% = ESCSEL THEN
     EXIT SUB
END IF

'
' Store the Info in the LS Nibble of the Next Transmitter Char
' .. without effect the address info
'
nextxmtr% = nextxmtr% + answer%

'
' Send the command to the Bird '0' + followed by the Next Transmitter Char
'
MID$(nextxmtrcmdstr, 1, 1) = CHR$(&H30)
MID$(nextxmtrcmdstr, 2, 1) = CHR$(nextxmtr%)
cmdok% = sendserialcmd%(nextxmtrcmdstr, 2)

PRINT "Next Transmittter Command Sent"
CALL hitkeycontinue
END SUB

SUB printmatrix (birddata%())

SHARED buttonvalue%
SHARED buttonmode%

'
' Print the 3 x 3 matrix
'
     ' birddata% 0  3  6
     '           1  4  7
     '           2  5  8
     '
     FOR row% = 0 TO 2
          PRINT USING "  ###.###"; birddata%(row%) * WTF;
          PRINT USING "  ###.###"; birddata%(row% + 3) * WTF;
          PRINT USING "  ###.###"; birddata%(row% + 6) * WTF;
          '
          ' Print the button value
          '
          IF (row% = 2) AND (buttonmode% <> 0) THEN
               PRINT USING "    ###"; buttonvalue%;
          END IF

          PRINT ""
     NEXT row%

     PRINT ""

END SUB

SUB printquaternions (birddata%())

SHARED buttonvalue%
SHARED buttonmode%

'
' Print the 3 x 1 quaternions
'
     ' birddata% q0 q1 q2 q3
     '
PRINT USING "  ###.#####"; birddata%(0) * WTF; birddata%(1) * WTF; birddata%(2) * WTF; birddata%(3) * WTF;

          IF (buttonmode% <> 0) THEN
               PRINT USING "    ###"; buttonvalue%;
          END IF

     PRINT ""

END SUB

FUNCTION readbirddata% (birddatabuff%(), numwords%, outputmode%, buttonmode%)
'
' Gain access to the Global buttonvalue%
'
SHARED buttonvalue%

SHARED rxbuf AS STRING * 100               ' get the handle to the receive buffer

'
' Determine how many bytes to read
'
recordsize% = (numwords% * 2) + buttonmode%

'
' Read in the characters...checking for proper record format
'
IF (getserialrecord%(recordsize%, outputmode%) < 0) THEN
     PRINT "** ERROR ** could not read record from the Bird"
     CALL hitkeycontinue
     readbirddata% = FALSE
     EXIT FUNCTION
END IF

'
' convert the string of bytes to integers in birdata%()
'
'   lsbyte gets shifted left 1
'   msbyte and lsbyte (word) get shiftes left 1
'
FOR word% = 0 TO numwords% - 1

     lsbyte% = ASC(MID$(rxbuf, (word% * 2) + 1, 1))          ' get lsbyte
     lsbyte% = (lsbyte% * 2) AND &HFF                        ' shift lsbyte left 1
     msbyte% = ASC(MID$(rxbuf, (word% * 2) + 2, 1))          ' get msbyte

     '
     ' Work with the data divided as an integer since Basic doesn't allow
     ' integers greater than 32767... make negative
     '
     tempdata% = ((msbyte% * 256) + lsbyte%)
     IF tempdata% >= 16384 THEN
          tempdata% = tempdata% - 32768
     END IF

     '
     ' Now effect the last shift left of the word
     '
     birddatabuff%(word%) = tempdata% * 2

NEXT word%

'
' Read the buttonvalue if required
'
IF buttonmode% <> 0 THEN
     buttonvalue% = ASC(MID$(rxbuf, recordsize%, 1)) ' get the button value
END IF

readbirddata% = TRUE

END FUNCTION

SUB rs232tofbbcmd

SHARED rs232tofbbaddr%

answer% = askyesno%("Do you want to use the RS232 to FBB Command")

IF answer% = ESCSEL THEN
          EXIT SUB
ELSE
     IF answer% = FALSE THEN
          rs232tofbbaddr% = 0
          EXIT SUB
     END IF
END IF

PRINT "Enter the Destination FBB Address: ";
answer% = getunsigned%(1, 14)

IF answer% > 0 THEN
     rs232tofbbaddr% = answer%
END IF

END SUB

'  sendmenu     - Send Menu Prompts to the Console and return selection
'
'  Parameters Passed:   numberofselections%, number of selections in the
'                       menu
'                       menustrings$(), array of strings used for the menu
'                       selections.  menustring$(0) is the menu prompt
'  Return Value:        user selection which is a number,
'                       0 - numberofselections%, or ESC_SEL, if the user
'                       selected ESCAPE
'  Function:            Routine presents the user with the menustrings and
'                       waits for a user response
'
FUNCTION sendmenu% (menustrings$(), numberofselections%)

DIM menustring$(MAXNUMMENUSELECTIONS)
PRINT menustrings$(0)
'
' Put up the selections
'
IF (numberofselections% < 18) THEN
     FOR i% = 1 TO numberofselections%
          PRINT CHR$(TABCHR) + CHR$(TABCHR);
          PRINT USING "##.   "; i% - 1;
          PRINT menustrings$(i%)
     NEXT i%
ELSE
     
     
     menusidelength% = ((numberofselections%) / 2) + (numberofselections% AND 1) + 1
     xloc% = POS(0)
     yloc% = CSRLIN

     '
     ' Put up the Left side of the menu
     '
     yscroll = 0
     FOR i% = 1 TO menusidelength% - 1
          IF CSRLIN = 24 THEN
               yscroll = yscroll + 1
          END IF
          PRINT USING "   ##. "; i% - 1;
          PRINT menustrings$(i%)
     NEXT i%
     yendloc% = CSRLIN

     '
     ' Put up the Right side of the menu
     '
     FOR i% = menusidelength% TO numberofselections%
          LOCATE yloc% + i% - menusidelength% - yscroll, xloc% + 35
          PRINT USING "   ##.  "; i% - 1;
          PRINT menustrings$(i%)
     NEXT i%
   
     LOCATE yendloc% + 1, 1

END IF


'
' Get the selection
'
DO
     valid% = TRUE

     '
     ' Put up the selection Prompt and get answer
     '
     PRINT "Enter Selection ( 0 to"; numberofselections% - 1; "): ";
            
     answer% = getunsigned%(0, numberofselections% - 1)
   
     IF answer% = ESCSEL THEN
          sendmenu% = ESCSEL
          PRINT
          EXIT FUNCTION
     ELSE
          IF ((answer% < 0) OR (answer% > numberofselections% - 1)) THEN
               PRINT "** ERROR ** invalid selection" + CHR$(LFCHR)
               valid% = FALSE
          END IF
     END IF

LOOP UNTIL (valid% = TRUE)

'
' Else Return Result
'
sendmenu% = answer%
PRINT

END FUNCTION

FUNCTION sendserialcmd% (cmdstring AS STRING, cmdsize%)

SHARED rs232tofbbaddr%

DIM rs232tofbbbirdcmd AS STRING * 256

'
' Check to see if the RS232 to FBB command is in effect (non Zero)
'
IF rs232tofbbaddr% <> 0 THEN
   
     '
     ' Construct the RS232 to FBB Prefix Character as 0F0h + FBB address
     '
     MID$(rs232tofbbbirdcmd, 1, 1) = CHR$(rs232tofbbaddr% + &HF0)

     '
     ' Store the birdcmd in the rs232tofbbbirdcmd
     '
     MID$(rs232tofbbbirdcmd, 2, cmdsize%) = cmdstring
   
     '
     ' Send the RS232 to FBB Command to the User
     '
     PRINT #1, LEFT$(rs232tofbbbirdcmd, cmdsize% + 1);


ELSE ' skip using the FBB

     '
     ' Send the Command to the User
     '
     PRINT #1, LEFT$(cmdstring, cmdsize%);

END IF

'
' Return to OK to the Caller
'
sendserialcmd% = TRUE

END FUNCTION

FUNCTION serialinit%

SHARED baud$
SHARED comport$
SHARED serialerr%

DIM serialmenu$(10)

serialmenu$(0) = "Select Port Options:"
serialmenu$(1) = "No Change"
serialmenu$(2) = "115200"
serialmenu$(3) = "57600"
serialmenu$(4) = "38400"
serialmenu$(5) = "19200"
serialmenu$(6) = "9600"
serialmenu$(7) = "4800"
serialmenu$(8) = "2400"
serialmenu$(9) = "COM1"
serialmenu$(10) = "COM2"

maxbaudrate& = 115200  ' max baud rate on a PC compatible

'
' Put up a Serial Header
'
CLS
PRINT "***************************************************************************"
PRINT "* ASCENSION TECHNOLOGY CORPORATION - Serial Port Configuration            *"
PRINT "***************************************************************************"
PRINT

done% = FALSE

DO
   
     PRINT CHR$(LFCHR) + "Current Serial Port Configuration: " + comport$ + " at " + baud$
     PRINT
   
     '
     ' Send the Menu to the Console
     '
     menusel% = sendmenu%(serialmenu$(), 10)

     SELECT CASE menusel%
        
          CASE 1 TO 7
               baud$ = serialmenu$(menusel% + 1)
             
          CASE 8
               comport$ = "COM1"

          CASE 9
               comport$ = "COM2"

          CASE ESCSEL
               PRINT ""
               done% = TRUE
             
          CASE ELSE
               done% = TRUE
        
     END SELECT

LOOP WHILE done% = FALSE

'
' Close the existing Port....
'
CLOSE #1

'
' Open the new comport with the new variables
'   comport$    - COM1,or COM2
'   initbaud$   - 19200...2400
'   N,8,1       - no parity, 8 bit, 1 stop bit
'   CD0         - a time out error if Carrier Detect goes in active
'   DS0         - a time out error if Data Set Ready goes in active
'   CS0         - a time out error if Clear to Send goes in active
'   RS          - RTS is NOT asserted, therefore the Bird is NOT RESET
'   OP100       - retry opening COMn for 100 milliseconds
'   BIN         - binary data
'
'   The default receive buffer and transmit buffer is 512 bytes
'
'
' Trap the baud rate initialization if the baud rate is greater than 19200
' ... since the BASIC OPEN will not allow higher rates
'
IF VAL(baud$) > 19200 THEN
     initbaud$ = "19200"
ELSE
     initbaud$ = baud$
END IF

'
' Setup the OPEN string
'
com$ = comport$ + ":" + initbaud$ + ",N,8,1,CD0,DS0,CS0,OP100,RS,BIN"

'
' Open the COM port
'
ON ERROR GOTO serialopenerror

OPEN com$ FOR RANDOM AS #1           ' com port is opened for random access

'
' If an error occurred durint the open, then the serialerr flag was set..
'
IF (serialerr% = TRUE) THEN
     serialerr% = FALSE
     serialinit% = FALSE
     CALL hitkeycontinue
     EXIT FUNCTION
END IF

'
' Fill in the divisor register for the higher baudrates
'
IF VAL(baud$) > 19200 THEN
     IF comport$ = "COM1" THEN
          serialportaddr% = &H3F8         ' com 1 base address
     ELSE
          serialportaddr% = &H2F8         ' com 2 base address
     END IF
        
     '
     ' Determine the divisor register value
     '
     divisorreglow% = INT(maxbaudrate& / VAL(baud$))
     divisorreghigh% = 0     ' 0 for all baud rates

     '
     ' Set the divisor register in the 8250 Type UART
     '
     OUT serialportaddr% + 3, &H83               ' DLAB bit set, 8 bit, no parity
     OUT serialportaddr% + 0, divisorreglow%     ' set the divisor reg
     OUT serialportaddr% + 1, divisorreghigh%    ' set the divisor reg
     OUT serialportaddr% + 3, &H3                ' DLAB bit reset 8 bit, no parity
END IF


serialinit% = TRUE

END FUNCTION

SUB setxmtrtype

SHARED posk!

DIM xmtrtypemenu$(3)
xmtrtypemenu$(0) = "Select Transmitter Type:"
xmtrtypemenu$(1) = "Short Range Transmitter"
xmtrtypemenu$(2) = "Extended Range Transmitter"

SELECT CASE (sendmenu%(xmtrtypemenu$(), 2))
        
     CASE 0  ' Short Range
          posk! = POSK36

     CASE 1  ' Extended Range
          posk! = POSK144

     CASE ESCSEL
           
END SELECT

END SUB

FUNCTION showfbbconfig% (dataarray%())

SHARED expandedaddrmode%

'
' data byte 0 - mode
'
SELECT CASE (dataarray%(0))
     CASE 0
          PRINT "Bird is in STANDALONE mode"
   
     CASE 1
          PRINT "Bird is in 1 Transmitter, Multiple Receiver mode"
   
     CASE ELSE
          PRINT "** Error ** unknown FBB configuration mode"
          showfbbconfig% = FALSE
          EXIT FUNCTION

END SELECT

CALL hitkeycontinue

'
' FBB Devices - stored in dataarray%(1) and dataarray%(2)
'
FOR i% = 1 TO 7
     PRINT "Device at address ";
     PRINT i%;
     IF (dataarray%(1) AND 2 ^ i%) = (2 ^ i%) THEN
          PRINT "is RUNNING"
     ELSE
          PRINT "is NOT RUNNING"
     END IF
NEXT i%

FOR i% = 8 TO 14
     PRINT "Device at address ";
     PRINT i%;
     IF (dataarray%(2) AND 2 ^ (i% - 8)) = (2 ^ (i% - 8)) THEN
          PRINT "is RUNNING"
     ELSE
          PRINT "is NOT RUNNING"
     END IF
NEXT i%

IF expandedaddrmode% = TRUE THEN

FOR i% = 15 TO 22
     IF i% = 20 THEN
          CALL hitkeycontinue
     END IF

     PRINT "Device at address ";
     PRINT i%;
     IF (dataarray%(5) AND 2 ^ (i% - 15)) = 2 ^ (i% - 15) THEN
          PRINT "is RUNNING"
     ELSE
          PRINT "is NOT RUNNING"
     END IF
NEXT i%

FOR i% = 22 TO 30
     IF i% = 20 THEN
          CALL hitkeycontinue
     END IF

     PRINT "Device at address ";
     PRINT i%;
     IF (dataarray%(6) AND 2 ^ (i% - 22)) = 2 ^ (i% - 22) THEN
          PRINT "is RUNNING"
     ELSE
          PRINT "is NOT RUNNING"
     END IF
NEXT i%

END IF

CALL hitkeycontinue

'
' FBB Dependents - stored in dataarray%(3) and dataarray%(4)
'
dataarray%(4) = dataarray%(4) AND &H7F
fbbdependents% = dataarray%(3) + dataarray%(4) * 256
FOR i% = 1 TO 14
     PRINT "Device at address ";
     PRINT i%;
     IF (fbbdependents% AND 2 ^ i%) = 2 ^ i% THEN
          PRINT "is DEPENDENT"
     ELSE
          PRINT "is NOT DEPENDENT"
     END IF
NEXT i%

showfbbconfig% = TRUE

END FUNCTION

SUB systemtests

DIM systestmenu$(6)
systestmenu$(0) = "Select System Test"
systestmenu$(1) = "Return to Main Menu"
systestmenu$(2) = "Bird Output Test"
systestmenu$(3) = "Bird Echo Test"
systestmenu$(4) = "Host Read Test"
systestmenu$(5) = "Host Read Block Test"

DIM testnumber%(5)
testnumber%(0) = 0
testnumber%(1) = 3
testnumber%(2) = 5
testnumber%(3) = 7
testnumber%(4) = 9


'
' Put the Test selection
'
testsel% = sendmenu%(systestmenu$(), 5)

'
' Do the User selected Test
'
IF testsel% > 0 THEN

     '
     ' Tell the User to check the DIP switch
     '
     PRINT "** NOTE ** The DIP switch should be set to Test Number: "; testnumber%(testsel%)
     CALL hitkeycontinue



     SELECT CASE testsel%

          CASE 1  ' Bird Output Test
               CALL birdoutputtest

          CASE 2  ' Bird Echo Test
               CALL birdechotest

          CASE 3  ' Host Read Test
               CALL hostreadtest

          CASE 4  ' Host Read Block
               CALL hostreadblocktest
   
     END SELECT

END IF


END SUB


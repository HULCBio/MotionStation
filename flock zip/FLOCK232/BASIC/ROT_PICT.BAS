'file=ROT_PICT.BAS

'demo that rotates and translates an xyz axes system as the Bird rotates
'and translates



DECLARE SUB HEADER ()
DECLARE SUB followbird ()
DECLARE SUB BYTES.TO.WORD (MSbyte AS INTEGER, LSbyte AS INTEGER, word AS INTEGER, AD AS SINGLE)
DECLARE SUB DRAWcross (att() AS SINGLE)
DECLARE SUB GET.POSITION.MATRIX ()
DECLARE SUB GRAPHICSinit ()
DECLARE SUB pause ()
DECLARE SUB readBIRDdata ()
DECLARE SUB INITcom ()

OPTION BASE 1

DIM command AS INTEGER, OUT.MODE AS INTEGER
DIM birddata(48) AS SINGLE
DIM Numwords AS INTEGER
DIM X AS SINGLE, y AS SINGLE, z AS SINGLE, M(3, 3) AS SINGLE
DIM Xeold(3) AS INTEGER, Yeold(3) AS INTEGER, X0old(3) AS INTEGER, Y0old(3) AS INTEGER
DIM att(3, 3) AS SINGLE, ATTt(3, 3) AS SINGLE
DIM Image1(1 TO 500)  AS INTEGER, Image2(1 TO 500) AS INTEGER, Image3(1 TO 500) AS INTEGER
DIM Image4(1 TO 500)  AS INTEGER, Image5(1 TO 500) AS INTEGER, Image6(1 TO 500) AS INTEGER
DIM Image7(1 TO 500) AS INTEGER
DIM ATTUDE(3, 3) AS SINGLE, ItoF AS SINGLE

KEY 15, CHR$(0) + CHR$(1)           'trap on escape key with no caps lock
KEY 16, CHR$(64) + CHR$(1)          'trap on escape key with caps lock
ON KEY(15) GOSUB escape.key.trap         'WAY OUT IF ESCAPE KEY HIT
ON KEY(16) GOSUB escape.key.trap
KEY(15) ON       'TURN ON THE TRAP
KEY(16) ON

ON TIMER(2) GOSUB escape.key.trap       'if more than 2 sec in readBIRDdata


ItoF = 1! / 32768!     'INTEGER TO FRACTION

CALL HEADER         'print some instruction

CALL INITcom     'init the RS-232 port for reading the bird data


TYPEmenu:
SCREEN 0           'non-graphics screen
PRINT "Graphics picture follows bird motion     ( 1 )"
PRINT "EXIT program                             ( 2 )"
INPUT command


IF command = 1 THEN CALL followbird
IF command = 2 THEN END
GOTO TYPEmenu



'***************************************************************************

'SUBROUTINE TO PROVIDE WAY OUT WHEN ESCAPE KEY HIT

escape.key.trap:

CLS        'clear the screen
PRINT
PRINT
PRINT "***You hit the ESCAPE key***"
PRINT "            or"
PRINT "***The RS-232c port is hung***"
PRINT
PRINT
PRINT "The program will restart on hitting carriage return"
PRINT
CALL pause
RUN             'startup again

RETURN

SUB BYTES.TO.WORD (MSbyte AS INTEGER, LSbyte AS INTEGER, word AS INTEGER, AD AS SINGLE)


'CONVERT BYTES TO A 16 BIT WORD
'
'GIVEN THE BYTES MSbyte AND LSbyte
'RETURNS AN INTEGER 'WORD' IN BIPOLAR FORMAT BETWEEN -32768 AND 32767
'AND RETURNS THE REAL 'AD' BETWEEN 0 AND 65535

'WRITTEN MAY 3, 1990


DIM AN AS SINGLE


AD = MSbyte * 256! + LSbyte
AN = AD

'CONVERT TO 2'S COMPLEMENT BETWEEN +32767 / -32768
IF AD > 32767! THEN AN = AD - 65536!
word = AN


END SUB

SUB DRAWcross (att() AS SINGLE)

'draws a graphic cross as a function of the position and orientation
'of the bird



DIM J AS INTEGER
DIM lcolor AS INTEGER, X0 AS INTEGER, Y0 AS INTEGER, Xe AS INTEGER, Ye AS INTEGER



SHARED Xeold() AS INTEGER, Yeold() AS INTEGER, Xpos AS SINGLE, Ypos AS SINGLE
SHARED Zpos AS SINGLE, X0old() AS INTEGER, Y0old() AS INTEGER

'the columns of the MATRIX each define a vector that points in the
'x,y,z direction of the receiver

'extract each of these vectors and draw them

FOR J = 1 TO 3

'pull out the correct elements so azim gives rotation about screen y axis

IF J = 1 THEN
X = att(1, 2)
y = att(1, 3)
z = att(1, 1)
END IF
IF J = 2 THEN
X = att(2, 2)
y = att(2, 3)
z = att(2, 1)
END IF

IF J = 3 THEN
X = att(3, 2)
y = att(3, 3)
z = att(3, 1)
END IF

'scale the coordinate axes so their length is only .125 instead of 1
X = .125 * X
y = .125 * y
z = .125 * z


'add on the coordinates of the moving receiver
'to give coordinates of end of each axis

X = X + Ypos
y = y + Zpos
z = z + Xpos

'project 3D space onto 2D window with perspective

Div = ABS(Xpos)

Xorigin = Ypos / Div   'origin of axes system is receiver location
Yorigin = Zpos / Div

Xend = X / Div
Yend = y / Div

'convert to graph resolution

X0 = 320 * Xorigin + 320  'range is now 0 to 640 with Ypos=0 corresponding to Xc=320
Y0 = 240 * Yorigin + 240

Xe = 320 * Xend + 320
Ye = 240 * Yend + 240
IF X0 > 640 THEN X0 = 640
IF Y0 > 480 THEN Y0 = 480
IF Xe > 640 THEN Xe = 640
IF Ye > 640 THEN Ye = 480


'erase the previous line
LINE (X0old(J), Y0old(J))-(Xeold(J), Yeold(J)), 0
IF J = 1 THEN lcolor = 2    'green
IF J = 2 THEN lcolor = 3  'cyan
IF J = 3 THEN lcolor = 4 'red

'draw a colored line
LINE (X0, Y0)-(Xe, Ye), lcolor
Xeold(J) = Xe
Yeold(J) = Ye
X0old(J) = X0
Y0old(J) = Y0

NEXT J

END SUB

SUB followbird

'an xyz axes system follows the position and orientation of the bird


'written 11/12/93 by ebb


SHARED ATTUDE() AS SINGLE, Numwords AS INTEGER, Xpos AS SINGLE
SHARED Ypos AS SINGLE, Zpos AS SINGLE
DIM att(3, 3) AS SINGLE, ATTr(3, 3) AS SINGLE, ATTt(3, 3) AS SINGLE


startpict:
CALL GRAPHICSinit
CLS

'set up for position/matrix output from bird

PRINT #1, "Z";              'set pos/matrix command to bird
Numwords = 12                '12 words to return from bird


again2:



CALL GET.POSITION.MATRIX  'get pos/orientation data from the bird

CALL DRAWcross(ATTUDE())  'graphics output for results

checkkey:
a$ = INKEY$                'if a keyboard hit, get out
IF a$ = "" THEN GOTO again2


END SUB

SUB GET.232.INPUT.WORD (word AS INTEGER, AD AS SINGLE)

'READS TWO BYTES FROM THE RS232 PORT AND RETURNS AN INTEGER 'WORD'
'BETWEEN -32768 AND 32767 ALSO RETURNS A SINGLE 'AD' BETWEEN 0-65535

DIM MSbyte AS INTEGER, LSbyte AS INTEGER

'READ LSbyte FROM BIRD'D RS232 PORT
'WAIT TO SEE IF BIRD GOT COMMAND
CHECKINPUT:
FOR i = 1 TO 500        'AT 9600 BAUD DOESN'T SEEMS YOU CAN USE 10 TO 10000
IF EOF(1) = 0 THEN GOTO READBYTE          'DATA IN BUFFER READ IT
NEXT i
 PRINT "INPUT TIME OUT - HIT A KEY TO RETURN"
a$ = INKEY$
IF a$ <> "" THEN EXIT SUB        'PROVIDE A WAY OUT IF LOCKUP BY HITTING A KEY
GOTO CHECKINPUT           'TRY AGAIN

READBYTE:

'READ THE LSbyte FROM BIRD
b$ = INPUT$(1, #1)
'
'READ MSbyte FROM BIRD
c$ = INPUT$(1, #1)
'CONVERT STRING TO BYTES TO WORD
LSbyte = ASC(b$)
MSbyte = ASC(c$)

'GET AD FROM 0 TO 65535 AND WORD FROM -32768 TO 32767
CALL BYTES.TO.WORD(MSbyte, LSbyte, word, AD)


END SUB

SUB GET.POSITION.MATRIX

'gets and prints the position/matrix output from the bird


SHARED birddata() AS SINGLE, ItoF AS SINGLE, Numwords AS INTEGER
SHARED OUT.MODE  AS INTEGER
SHARED ATTUDE() AS SINGLE, Xpos AS SINGLE, Ypos AS SINGLE, Zpos AS SINGLE


DIM i  AS INTEGER, J AS INTEGER, K AS INTEGER, N AS INTEGER


'PRINT #1, "Z";              'set pos/matrix command to bird
'Numwords = 12                '12 words to return from bird
CALL readBIRDdata           'get x,y,z and orientation words


'convert position to fractional
Xpos = birddata(1) * ItoF
Ypos = birddata(2) * ItoF
Zpos = birddata(3) * ItoF

'arrange the BIRDDATA values in matrix format

i = 4
FOR J = 1 TO 3
  FOR K = 1 TO 3
        ATTUDE(K, J) = birddata(i) * ItoF
        i = i + 1
  NEXT K
NEXT J


END SUB

SUB GRAPHICSinit

'initialize screen for doing a graphics cross
SHARED Image1() AS INTEGER, Image2() AS INTEGER, Image3() AS INTEGER
SHARED Image4() AS INTEGER, Image5() AS INTEGER, Image6() AS INTEGER
SHARED Image7() AS INTEGER

SCREEN 12          '480x640 vga graphics

'make a big cross
'LINE (10, 0)-(10, 20)                'vertical line
'LINE (0, 10)-(20, 10)                'horizontal line

'store the image of the cross into the array image()
'GET (0, 0)-(20, 20), Image

'make a small cross green
LINE (2, 0)-(2, 4), 2
LINE (0, 2)-(4, 2), 2
GET (0, 0)-(4, 4), Image1

'make a small cross cyan
LINE (2, 0)-(2, 4), 3
LINE (0, 2)-(4, 2), 3
GET (0, 0)-(4, 4), Image2

'make a small cross red
LINE (2, 0)-(2, 4), 4
LINE (0, 2)-(4, 2), 4
GET (0, 0)-(4, 4), Image3


'make a small cross purple
LINE (2, 0)-(2, 4), 5
LINE (0, 2)-(4, 2), 5
GET (0, 0)-(4, 4), Image4

'make a small cross brown
LINE (2, 0)-(2, 4), 6
LINE (0, 2)-(4, 2), 6
GET (0, 0)-(4, 4), Image5

'make a small cross white
LINE (2, 0)-(2, 4), 7
LINE (0, 2)-(4, 2), 7
GET (0, 0)-(4, 4), Image6


'make a small cross blue
LINE (2, 0)-(2, 4), 9
LINE (0, 2)-(4, 2), 9
GET (0, 0)-(4, 4), Image7



'the actuall drawing in real time will be done with a PUT
CLS       'erase the cross


END SUB

SUB HEADER

CLS
PRINT
PRINT
PRINT

PRINT "This is demo program that rotates and translates an xyz axes system"
PRINT "as the Bird rotates and translates"
PRINT
PRINT "requires an RS-232 port hooked directly into the Bird whose receiver"
PRINT "is being rotated"
PRINT
PRINT "it assumes forward hemisphere operation "
PRINT
PRINT "it assumes that you have a VGA graphics card on your computer"
PRINT
PRINT
PRINT
PRINT
CALL pause
CLS

END SUB

SUB INITcom

'initializes this host computer's communications port
'works with 19200 although microsoft basic says 9600 is max

'WRITTEN MAY 4, 1990
'revised 10/20/90   150 baud deleted from menu since not supported by Bird
'revised 2/16/91    op100,bin added to initialization
'revised 2/17/91    higher baud rates added for FOBs
'revised 5/6/93     com2 added


DIM BAUDN AS INTEGER
SHARED com$


maxbaudrate& = 115200  ' max baud rate on a PC compatible

'INITIALIZE THIS HOST COMPUTER'S COMMUNICATION PORT
CLOSE #1
PRINT
PRINT
PRINT
PRINT "Select baud rate for RS-232C communications to The Bird"
PRINT
PRINT "115,200   ( 0 )"
PRINT " 57,600   ( 1 )"
PRINT " 38,400   ( 2 )"
PRINT " 19,200   ( 3 )"
PRINT "  9,600   ( 4 )"
PRINT "  4,800   ( 5 )"
PRINT "  2,400   ( 6 )"
PRINT
PRINT "BAUD RATES 300 - 1,200 are not valid for FOBs"
PRINT
PRINT "  1,200   ( 7 )"
PRINT "    600   ( 8 )"
PRINT "    300   ( 9 )"
PRINT
INPUT "Input a baud number of 0-9  ", BAUDN
IF BAUDN = 0 THEN baud$ = "115200"
IF BAUDN = 1 THEN baud$ = "57600"
IF BAUDN = 2 THEN baud$ = "38400"
IF BAUDN = 3 THEN baud$ = "19200"
IF BAUDN = 4 THEN baud$ = "9600"
IF BAUDN = 5 THEN baud$ = "4800"
IF BAUDN = 6 THEN baud$ = "2400"
IF BAUDN = 7 THEN baud$ = "1200"
IF BAUDN = 8 THEN baud$ = "600"
IF BAUDN = 9 THEN baud$ = "300"



' Trap the baud rate initialization if the baud rate is greater than 19200
' ... since the BASIC OPEN will not allow higher rates
'
IF VAL(baud$) > 19200 THEN
         initbaud$ = "19200"
ELSE
         initbaud$ = baud$
END IF

PRINT
PRINT "specify the COM port number being used by the RS232"
PRINT "COM1    ( 1 )"
PRINT "COM2    ( 2 )"
INPUT cnum
IF cnum = 1 THEN comport$ = "COM1:"
IF cnum = 2 THEN comport$ = "COM2:"


'since the flock of birds uses the rs232 line RTS request to send
'to put the system into reset you must control the line when you open
'the port. If RS not specified basic then RTS is held electrically high
'a space (3-25v) causing the birds reset line to be held in reset.
'If RS is specified then the RST line is held low,a mark, (-3 to -25v)
'taking the bird out of reset to allow it to run


com$ = comport$ + initbaud$ + ",N,8,1,CD0,DS0,CS0,RS,OP100,BIN"

OPEN com$ FOR RANDOM AS #1


' Fill in the divisor register for the higher baudrates
'
IF VAL(baud$) > 19200 THEN
         IF comport$ = "COM1:" THEN
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

CLS




END SUB

SUB pause

PRINT "HIT ANY KEY TO CONTINUE"
WAITFORKEY:
a$ = INKEY$
IF a$ = "" GOTO WAITFORKEY

END SUB

SUB readBIRDdata

SHARED Numwords AS INTEGER, birddata() AS SINGLE, com$
SHARED noise.stat AS INTEGER, OUT.MODE AS INTEGER


DIM CPOS AS INTEGER, II AS INTEGER, LSbyte AS INTEGER, MSbyte AS INTEGER
DIM word AS LONG, test AS INTEGER



'PROCEDURE readBIRDdata
'
'READS BIRD DATA IN INTEGER FORMAT INTO ARRAY BIRDDATA()
'USING THE POINT MODE. USER MUST SETUP THE OUTPUT MODE, IE MATRIX, ANGLES
'ECT , BEFORE CALLING THIS ROUTINE AND USER MUST
'SET 'Numwords' TO THE NUMBER OF WORDS TO BE GOTTEN FOR A GIVEN
'MODE, IE Numwords=9 IF MATRIX OUTPUT SELECTED


REQUESTdata:
 '
PRINT #1, "B"; 'SEND REQUEST TO BIRD IF NOT STREAM MODE



'GET Numwords*2 BYTES FROM BIRD

TIMER ON                        'WILL TRAP IF RS232 HANGS

PORThung:
IF LOC(1) = 0 GOTO PORThung     'WAIT TILL SOMETHING IS IN BUFFER
TIMER OFF                       'SHUT OFF TIMER TRAP
b$ = INPUT$(Numwords * 2, #1)   'READ THE REQUESTED NUMBER OF BYTES FROM RS232

'EXTRACT Numwords WORDS FROM THE STRING CONVERTING TO BIPOLAR

FOR II = 1 TO Numwords
  CPOS = 2 * II - 1
  'GET LS BYTE
  LSbyte = ASC(MID$(b$, CPOS, 1))
  '
  'CHECK FOR DATA PHASING ERROR.
  'FIRST BYTE OF FIRST WORD SHOULD BE=1
  'FIRST BYTE OF ALL OTHER WORDS SHOULD BE=0
  'JUST CHECKING FIRST WORD DOESN'T SEEM TO BE ENOUGH SINCE IF BYTES ARE
  'OUT OF ORDER THE FIRST BIT MAY BE A DATA BIT =1 AND GIVE A FALSE INDICATION
  '
  IF II = 1 THEN    'CHECK LSBYTE OF WORD 1 FOR A 1
  test = LSbyte AND &H80
  IF test = 128 THEN GOTO FORMmsb   'IF MSB=1 THEN OK EXIT
  PRINT "PHASING ERROR"
  CLOSE #1         'FLUSH THE BUFFER
  OPEN com$ FOR RANDOM AS #1
  a$ = INKEY$
  IF a$ <> "" THEN GOTO ENDITALL   'GET OUT OF A LOCK UP IF KEY HIT

  GOTO REQUESTdata
  END IF

'
 IF II = 2 THEN
        test = LSbyte AND &H80
        IF test = 0 THEN GOTO FORMmsb   'IF MSB=0 THEN OK EXIT
        PRINT "PHASING ERROR"
        CLOSE #1         'FLUSH THE BUFFER
        OPEN com$ FOR RANDOM AS #1
        GOTO REQUESTdata
 END IF
'
FORMmsb:
  LSbyte = (LSbyte AND &H7F) * 2 'for formatted BIRD data

  'GET MS BYTE
  MSbyte = ASC(MID$(b$, CPOS + 1, 1))
  word = (MSbyte * 256! + LSbyte) * 2 'for formatted BIRD data

  'CONVERT TO 16 BIT BIPOLAR BETWEEN -32768 AND 32767
  IF word > 32767! THEN word = word - 65536!
   birddata(II) = word     'TEMPORARILY SAVE DATA
NEXT II

ENDITALL:
END SUB


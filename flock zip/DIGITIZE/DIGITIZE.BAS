'DIGITIZE.bas

'Bird used for digitizing with a stylus tip

'Written June 10, 1991

'programming language is Microsoft quickbasic




DECLARE SUB CALIBRATEstylus ()
DECLARE SUB KEYBOARDhit (B$)
DECLARE SUB GAUSSjordon (N AS INTEGER, C() AS SINGLE)
DECLARE SUB NORMALequations (N AS INTEGER, M AS INTEGER, X() AS SINGLE, C() AS SINGLE)
DECLARE SUB CHECKforOFFSETS ()
DECLARE SUB TWOpointDISTANCE ()
DECLARE SUB DEFINEmeasurementFRAME ()
DECLARE SUB mmcol (a() AS SINGLE, B() AS SINGLE, R() AS SINGLE)
DECLARE SUB DEFAULTtoUSERframe (D() AS SINGLE, U() AS SINGLE)
DECLARE SUB COLLECTdataTOfile ()
DECLARE SUB ENTERsytlusOFFSETS ()
DECLARE SUB MEASUREandAVERAGE (NtoAVER AS INTEGER, X AS SINGLE, Y AS SINGLE, z AS SINGLE)
DECLARE SUB CROSS (a() AS SINGLE, B() AS SINGLE, C() AS SINGLE)
DECLARE SUB NORMALIZEvector (a() AS SINGLE, an() AS SINGLE)
DECLARE SUB MIDN (M() AS SINGLE)
DECLARE SUB TIPxyz (Xs AS SINGLE, Ys AS SINGLE, Zs AS SINGLE)
DECLARE SUB readbird ()
DECLARE SUB Digitize ()
DECLARE SUB POSITIONMATRIXdata ()
DECLARE SUB GETBIRDparameter (parameter AS INTEGER)
DECLARE SUB STATUSdecode (STAT AS INTEGER)
DECLARE SUB GET232INPUTWORD (WORD AS INTEGER, AD AS SINGLE)
DECLARE SUB INPUTvalue (a$, VALUE!)
DECLARE SUB LOADconfiguration ()
DECLARE SUB INTtoBYTES (WORD AS INTEGER, MSbyte AS INTEGER, LSbyte AS INTEGER)
DECLARE SUB pause ()
DECLARE SUB INITcom1 ()
DECLARE SUB BYTEStoWORD (MSbyte AS INTEGER, LSbyte AS INTEGER, WORD AS INTEGER, AD AS SINGLE)
DECLARE SUB MANUinstruct ()
DECLARE SUB AUTOinstruct ()





OPTION BASE 1         'ARRAYS START AT 1

DIM COMMAND AS INTEGER, done  AS INTEGER
DIM BIRDDATA(48) AS SINGLE
DIM Numwords AS INTEGER, POSK AS SINGLE, ANGK AS SINGLE, DTR AS SINGLE
DIM Bmax(12) AS SINGLE, Bmin(12) AS SINGLE, MEAN(12) AS SINGLE
DIM DEVIATION(12) AS SINGLE, PKtoPK(12) AS SINGLE, SX(12) AS DOUBLE
DIM SX2(12) AS DOUBLE, Naver AS INTEGER
DIM CLOCK AS SINGLE, ItoF AS SINGLE
DIM revno AS SINGLE, CRYSTAL AS INTEGER
DIM ADscale AS SINGLE, CONFIGrb(36) AS INTEGER
DIM GRAPHICSflag AS INTEGER
DIM image(1 TO 500)  AS INTEGER
DIM firstentry AS INTEGER
DIM X AS SINGLE, Y AS SINGLE, z AS SINGLE, M(3, 3) AS SINGLE
DIM CONFIGloaded AS INTEGER, Xo AS SINGLE, Yo AS SINGLE, Zo AS SINGLE
DIM AZIM AS SINGLE, ELEV AS SINGLE, roll AS SINGLE
DIM origin(3) AS SINGLE, REFframeROTATION(3, 3) AS SINGLE
DIM Xs AS SINGLE, Ys AS SINGLE, Zs AS SINGLE, NUMtoAVERAGE AS INTEGER
DIM U(3) AS SINGLE, D(3) AS SINGLE


CLS     'clear the screen
PRINT
PRINT
PRINT "***************************************************************"
PRINT " Copyright 1991,92,93, Ascension Technology Corp. All rights reserved."
PRINT "***************************************************************"
PRINT




KEY 15, CHR$(0) + CHR$(1)           'trap on escape key with no caps lock
KEY 16, CHR$(64) + CHR$(1)          'trap on escape key with caps lock
ON KEY(15) GOSUB ESCAPEkeyTRAP         'WAY OUT IF ESCAPE KEY HIT
ON KEY(16) GOSUB ESCAPEkeyTRAP
KEY(15) ON       'TURN ON THE TRAP
KEY(16) ON

ON TIMER(2) GOSUB ESCAPEkeyTRAP       'if more than 2 sec in READbird


POSK = 36! / 32768!     'CONVERT INTEGER TO INCHES
ANGK = 180! / 32768!   'CONVERT INTEGER TO DEGREES
DTR = 3.141593 / 180!  'CONVERT DEGREES TO RADIANS
ItoF = 1! / 32768!     'INTEGER TO FRACTION

CALL INITcom1           'initialize the rs232 port
CALL GETBIRDparameter(1) 'determine software rev number for determining
                         'if configuration file data should be loaded


TYPEmenu:
PRINT
COMMAND = 0

OPmenu:
PRINT "Enter a command code:"
PRINT
PRINT
IF revno < 3! THEN PRINT "LOAD CONFIGURATION   ( 1 )"
PRINT "Digitize             ( 2 )"
PRINT "EXIT program         ( 3 )"
INPUT COMMAND
PRINT

IF COMMAND = 1 THEN CALL LOADconfiguration
IF COMMAND = 2 THEN CALL Digitize
IF COMMAND = 3 THEN END

PRINT
CALL pause
PRINT
PRINT
GOTO TYPEmenu


STOP


'SUBROUTINE TO PROVIDE WAY OUT WHEN ESCAPE KEY HIT

ESCAPEkeyTRAP:

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

SUB AUTOinstruct

'instruction for auto calibration of the stylus

CLS
PRINT
PRINT "              STYLUS TIP CALIBRATION SETUP"
PRINT ""
PRINT ""
PRINT "Calibration of the offset distances from the stylus tip to the"
PRINT "center of the receiver can usually be done utilizing a very"
PRINT "simple jig."
PRINT ""
PRINT "For calibration I would recommend the following:"
PRINT ""
PRINT "1.  A hard, flat surface at least 16 inches long and 4 inches"
PRINT "     wide made of plastic, glass, wood, or any other non-metallic"
PRINT "     material."
PRINT ""
CALL pause
PRINT "2.  A support for the above surface that will keep the surface "
PRINT "     positioned at desk height above the floor to avoid magnetic"
PRINT "     distortions due to the steel rebar used in concrete"
PRINT "     floors.  The support should also be non-metallic.  A wood"
PRINT "     desk, stacking plastic milk cases, or a sturdy cardboard box"
PRINT "     will do."
PRINT ""
PRINT "3.   The transmitter will rest at one end of this surface and the"
PRINT "     stylus tip will rotate on the surface one foot in front of  "
PRINT "     the transmitter.  If there is a possibility that the"
PRINT "     transmitter will move during calibration then it should be"
PRINT "     taped or screwed to the surface - use plastic or 300 series"
PRINT "     stainless steel screws.  The stylus tip should be as short"
PRINT "     as possible since any errors in the Bird's angular measure"
PRINT "     will be magnified by the tip length.  For each degree of"
CALL pause
PRINT "     error and each inch of tip length, you will experience"
PRINT "     0.0157 inches of error in computed tip position (tip length"
PRINT "     times the tangent of the error angle.  Error angle is 0.5"
PRINT "     degrees root mean square for the Bird) .  If the stylus is"
PRINT "     long then the transmitter should be raised above the surface"
PRINT "     so that its center line is approximately on the center line"
PRINT "     of the receiver when the stylus is perpendicular to the"
PRINT "     surface."
PRINT ""
PRINT "4.   Calibration can be accomplished by rotating the stylus about"
PRINT "     its tip through several different angles and collecting the"
PRINT "     Bird's POSITION/MATRIX data at each orientation.  A least"
PRINT "     squares solution is then carried out to solve for the tip"
PRINT "     x,y,z offsets.  Once set up, the data collection takes less"
PRINT "     than one minute."
CALL pause
PRINT ""
PRINT "     A typical data collection sequence would be to hold the "
PRINT "     stylus vertical with the tip at a fixed location on the"
PRINT "     table, then rotate approximately 45 degrees forward, then"
PRINT "     backwards, then left, then right and possibly some other"
PRINT "     angles if experience shows its required.  No fixture is"
PRINT "     required to do the rotations unless you have a very unsteady"
PRINT "     hand and even this can be overcome by multiple samples at"
PRINT "     each rotation angle. It is only required to maintain the tip"
PRINT "     of the stylus at the same point on the surface during all"
PRINT "     rotations.  The sharper the tip the better since a blunt tip"
PRINT "     will introduce errors as the stylus is rotated.  If you have"
PRINT "     a blunt tip, then a slight depression in the surface with a"
PRINT "     radius of curvature equal to or slightly larger than the"
PRINT "     tips radius will help maintain the tip at the same x,y,z"
PRINT "     location on the surface."
CALL pause

END SUB

SUB BYTEStoWORD (MSbyte AS INTEGER, LSbyte AS INTEGER, WORD AS INTEGER, AD AS SINGLE)

'SUBROUTINE BYTEStoWORD( MSbyte, LSbyte, WORD, AD )

'CONVERT BYTES TO A 16 BIT WORD
'
'GIVEN THE BYTES MSbyte AND LSbyte
'RETURNS AN INTEGER 'WORD' IN BIPOLAR FORMAT BETWEEN -32768 AND 32767
'AND RETURNS THE REAL 'AD' BETWEEN 0 AND 65535

'WRITTEN MAY 3, 1990


DIM an AS SINGLE


AD = MSbyte * 256! + LSbyte
an = AD

'CONVERT TO 2'S COMPLEMENT BETWEEN +32767 / -32768
IF AD > 32767! THEN an = AD - 65536!
WORD = an


END SUB

SUB CALIBRATEstylus

'determine the stylus offset distances

'written 3/14/93 by ebb

SHARED X AS SINGLE, Y AS SINGLE, z AS SINGLE, M() AS SINGLE
SHARED Xo AS SINGLE, Yo AS SINGLE, Zo AS SINGLE

DIM NUMBERofPOINTS AS INTEGER, X(20, 21) AS SINGLE
DIM C(20, 21) AS SINGLE, XYZb(20), Mx(20), My(20), Mz(20)
DIM i AS INTEGER, J AS INTEGER, k AS INTEGER
DIM NUMBERofUNKNOWNS AS INTEGER, n1 AS INTEGER

'solving for the tip offsets is based on the general equation


'        Xs = Xb + Xo * M(1, 1) + Yo * M(2, 1) + Zo * M(3, 1)
'        Ys = Yb + Xo * M(1, 2) + Yo * M(2, 2) + Zo * M(3, 2)
'        Zs = Zb + Xo * M(1, 3) + Yo * M(2, 3) + Zo * M(3, 3)

'where Xs,Ys,Zs are the xyz coordinates of the stylus tip
'      Xb,Yb,Zb are the coordinates of the center of the bird's receiver
'      Xo,Yo,Zo are the offset distances from the stylus tip to the
'               center of the bird receiver
'      and M(i,j) are the elements of the bird's orientation matrix

'if you add all of the equations together and subtract the coordinates
'measured at the first calibration point then Xs,Ys,Zs drop out yielding

'(Xb+Yb+Zb)1-(Xb+Yb+Zb)n = Xo(Mxn-Mx1)+Yo(Myn-My1)+Zo(Mzn-Mz1)
' where 1,n  are subscripts representing the first and n'th measured points
'   and Mx=M(1,1)+M(1,2)+M(1,3)
'       My=M(2,1)+M(2,2)+M(2,3)
'       Mz=M(3,1)+M(3,2)+M(3,3)
'thus everything is known except Xo,Yo,Zo. Thus collecting stylus data at
'at least 4 different orientations allows one to solve for the unknowns
'in this case we will collect at more orientations and use the method
'of least squares to solve the over determined sets of equations

CLS
PRINT
INPUT "instructions for auto cal of stylus ? No (0)   Yes (1)", yesno
IF yesno = 1 THEN CALL AUTOinstruct
PRINT
INPUT "exit this procedure ? No (0)   YES (1)  ", yesno
IF yesno = 1 THEN EXIT SUB
PRINT

PRINT " NUMBER OF CAL POINTS TO COLLECT (5 MIN, 20 MAX) "
PRINT " more points give better results"
PRINT
INPUT NUMBERofPOINTS

NUMBERofUNKNOWNS = 3

FOR i = 1 TO NUMBERofPOINTS
PRINT "CAL POINT # ", i
PRINT

IF i = 1 THEN PRINT "move stylus tip to x=12,y=0, z=0, hold the stylus vertical"
IF i = 2 THEN PRINT "rotate 45 deg forward"
IF i = 3 THEN PRINT "rotate 45 deg aft"
IF i = 4 THEN PRINT "rotate 45 deg left"
IF i = 5 THEN PRINT "rotate 45 deg right"
IF i > 5 THEN PRINT " rotate to some other angle"
PRINT "do not move the stylus tip"
PRINT
PRINT "hit any key when stylus positioned "

CALL KEYBOARDhit(B$)            'waits till any key hit
CALL POSITIONMATRIXdata
PRINT CHR$(7)                 'RING THE BELL WHEN CHARACTER COLLECTED

'save Mx(i)=M(1,1)+M(1,2)+M(1,3)
'save My(i)=M(2,1)+M(2,2)+M(2,3)
'save Mz(i)=M(3,1)+M(3,2)+M(3,3)
Mx(i) = M(1, 1) + M(1, 2) + M(1, 3)
My(i) = M(2, 1) + M(2, 2) + M(2, 3)
Mz(i) = M(3, 1) + M(3, 2) + M(3, 3)

'save bird measured values. coordinates of receiver center
XYZb(i) = X + Y + z

NEXT i


'build elements for forming normal equations
FOR i = 2 TO NUMBERofPOINTS
i1 = i - 1
X(i1, 1) = Mx(i) - Mx(1)
X(i1, 2) = My(i) - My(1)
X(i1, 3) = Mz(i) - Mz(1)
X(i1, 4) = XYZb(1) - XYZb(i)
NEXT i

'form the normal equations
CALL NORMALequations(NUMBERofUNKNOWNS, NUMBERofPOINTS - 1, X(), C())

'solve the simultaneous equations for the tip offsets
CALL GAUSSjordon(NUMBERofUNKNOWNS, C())

'offsets
n1 = NUMBERofUNKNOWNS + 1

Xo = C(1, n1)
Yo = C(2, n1)
Zo = C(3, n1)

PRINT "offsets"
PRINT "Xo= "; Xo
PRINT "Yo= "; Yo
PRINT "Zo= "; Zo
PRINT
CALL pause


END SUB

SUB CHECKforOFFSETS

'checks if offsets are entered
'some procedures should not be done without offsets


SHARED Xo AS SINGLE, Yo AS SINGLE, Zo  AS SINGLE

IF Xo + Yo + Zo = 0 THEN
PRINT CHR$(7)        'RING BELL WHEN POINT COLLECTED
PRINT ""
PRINT " ** The tip offsets are zero. Determine the correct values if you want good results ***"
PRINT
END IF

END SUB

SUB COLLECTdataTOfile

'measure coordinates in the USER ref frame and put into a file




SHARED NUMtoAVERAGE AS INTEGER, U() AS SINGLE, D() AS SINGLE



CALL CHECKforOFFSETS        'make sure the user has determined his tip offsets

PRINT
INPUT "Input the file name with path for output ", a$
OPEN a$ FOR OUTPUT AS #2

INPUT "Enter title for file contents description ", a$
PRINT #2, a$      'put title in files
PRINT
PRINT
INPUT "How many measurements to average together >=1  ", NUMtoAVERAGE
IF NUMtoAVERAGE <= 0 THEN NUMtoAVERAGE = 1
PRINT



MENU2:
PRINT
PRINT "hit a B to collect a data point"
PRINT "hit a T to add text to the file"
PRINT "hit a D when done entering data to this file"
PRINT

GETKEYHIT:
a$ = INKEY$        'key key hit
IF a$ = "" THEN GOTO GETKEYHIT
a$ = UCASE$(a$)     'if user hit a lower case key, convert to upper case


IF a$ = "T" THEN
        INPUT "enter text string to add to file ", a$
        PRINT #2, a$
        GOTO MENU2
END IF


IF a$ = "D" THEN
        CLOSE (2)
        EXIT SUB
END IF


IF a$ = "B" THEN

'collect and average tip coordinates measured in the default ref frame

CALL MEASUREandAVERAGE(NUMtoAVERAGE, D(1), D(2), D(3))



'convert the coord from the default ref frame to x,y,z in the user ref frame

CALL DEFAULTtoUSERframe(D(), U())

        PRINT USING "###.##   "; U(1); U(2); U(3)


        'SEND the tip coordinates to the file

         PRINT #2, USING "###.##   "; U(1); U(2); U(3)
         PRINT #2, ""


        GOTO MENU2
END IF

GOTO MENU2


END SUB

SUB CROSS (a() AS SINGLE, B() AS SINGLE, C() AS SINGLE)


'form the cross product between two vectors
'axb=c

C(1) = a(2) * B(3) - a(3) * B(2)
C(2) = a(3) * B(1) - a(1) * B(3)
C(3) = a(1) * B(2) - a(2) * B(1)


END SUB

SUB DEFAULTtoUSERframe (D() AS SINGLE, U() AS SINGLE)

'converts x,y,z tip measurements in the default measurement frame (D(1),D(2),D(3))
'to x,y,z coordinates in the user defined measurement frame (U(1),U(2),U(3))

SHARED origin() AS SINGLE, REFframeROTATION() AS SINGLE
DIM i  AS INTEGER, a(3) AS SINGLE



'subtract out the new frame origin

FOR i = 1 TO 3
a(i) = D(i) - origin(i)
NEXT i

'rotate the point from the default frame to the user frame

CALL mmcol(REFframeROTATION(), a(), U())





END SUB

SUB DEFINEmeasurementFRAME


'the default measurement frame in which the x,y,z coordinates are measured is
'defined by an origin centered at the center of the transmitter coils, an
'X axis going out the face of the xmtr aligned with the X transmitter coil
'a Y axis going out the right side of the xmtr aligned to the Y transmitter coil
'and a Z axis going vertically down, all when viewed from behind the transmitter
'Behind being defined when you are standing behind the transmitter with the
'transmitter cable pointing toward you.  These coil axes are not necesarily
'aligned with the case of the transmitter.

'If you want to define a measurement plane and origin that differ from the
'default, then one must define the x,y,z coordinates of a new origin, the x,y,z
'coordinates of a point along the new x axis and the x,y,z coordinates of a
'point along the new y axis.

SHARED origin() AS SINGLE, REFframeROTATION() AS SINGLE
SHARED U() AS SINGLE, D() AS SINGLE

DIM doit AS INTEGER, NUMtoAVERAGE AS INTEGER
DIM X(3) AS SINGLE, Xn(3) AS SINGLE, Y(3) AS SINGLE, Yn(3) AS SINGLE
DIM Zn(3) AS SINGLE, org(3) AS SINGLE, i AS INTEGER




PRINT
PRINT "The stylus offsets must be determined before you use this routine"
PRINT ""
INPUT "EXIT NOW ( 0 ) or continue to define the new measurement frame ( 1 ) ", doit
IF doit = 0 THEN EXIT SUB


PRINT " to define a new measurement frame you must measure three point with you stylus"
PRINT " the new origin"
PRINT " a point along the new X axis"
PRINT " a point along the new Y axis"
PRINT
PRINT


'set the x,y,z coordinates of the new ref frame to zero

origin(1) = 0!
origin(2) = 0!
origin(3) = 0!

'set to the identity matrix the directional cosine rotation matrix that
'defines the orientation of the new reference frame

CALL MIDN(REFframeROTATION())



PRINT " HOLD THE STYLUS TIP ON THE NEW ORIGIN"
PRINT " hit any key when ready to take measurements"
PRINT "do not move the sytlus until the computer beeps"

NUMtoAVERAGE = 10       'average 10 readings

CALL pause
CALL MEASUREandAVERAGE(NUMtoAVERAGE, org(1), org(2), org(3))'collect and average x,y,z
PRINT CHR$(7)        'RING BELL WHEN POINT COLLECTED
PRINT USING "###.##   "; org(1); org(2); org(3)     'print the tip values

PRINT
PRINT
PRINT " HOLD THE STYLUS TIP ON A POINT ALONG THE NEW X AXIS"
PRINT " hit any key when ready to take measurements"
PRINT "do not move the sytlus until the computer beeps"

CALL pause
CALL MEASUREandAVERAGE(NUMtoAVERAGE, X(1), X(2), X(3))'collect and average x,y,z
PRINT CHR$(7)        'RING BELL WHEN POINT COLLECTED
PRINT USING "###.##   "; X(1); X(2); X(3)'print the tip values

PRINT
PRINT
PRINT " HOLD THE STYLUS TIP ON A POINT ALONG THE NEW Y AXIS"
PRINT " hit any key when ready to take measurements"
PRINT "do not move the sytlus until the computer beeps"

CALL pause
CALL MEASUREandAVERAGE(NUMtoAVERAGE, Y(1), Y(2), Y(3))'collect and average x,y,z
PRINT CHR$(7)        'RING BELL WHEN POINT COLLECTED
PRINT USING "###.##   "; Y(1); Y(2); Y(3)'print the tip values


'reference the axis points to the origin

FOR i = 1 TO 3
X(i) = X(i) - org(i)
Y(i) = Y(i) - org(i)
NEXT i


'normalize the x component

CALL NORMALIZEvector(X(), Xn())


'normalize the y component

CALL NORMALIZEvector(Y(), Yn())


'generate a Z axis via the right hand screw rule

CALL CROSS(Xn(), Yn(), Zn())


'define the direction cosine matrix for transforming xyz point from the
'default frame to the new measurement frame

REFframeROTATION(1, 1) = Xn(1)
REFframeROTATION(1, 2) = Xn(2)
REFframeROTATION(1, 3) = Xn(3)
REFframeROTATION(2, 1) = Yn(1)
REFframeROTATION(2, 2) = Yn(2)
REFframeROTATION(2, 3) = Yn(3)
REFframeROTATION(3, 1) = Zn(1)
REFframeROTATION(3, 2) = Zn(2)
REFframeROTATION(3, 3) = Zn(3)


'now do the origin

origin(1) = org(1)
origin(2) = org(2)
origin(3) = org(3)




PRINT "check values in new frame by computing tip continously till key hit?  YES ( 0 ), NO ( 1 )  "
INPUT yesno
PRINT
IF yesno = 0 THEN

readuseragain:

'collect and average tip coordinates measured in the default ref frame

CALL MEASUREandAVERAGE(NUMtoAVERAGE, D(1), D(2), D(3))



'convert the coord from the default ref frame to x,y,z in the user ref frame

CALL DEFAULTtoUSERframe(D(), U())

        PRINT USING "###.##   "; U(1); U(2); U(3)


a$ = INKEY$       'read keyboard
IF a$ = "" THEN GOTO readuseragain
END IF


END SUB

SUB Digitize

'WRITTEN 5/19/91 BY EBB

SHARED X AS SINGLE, Y AS SINGLE, z AS SINGLE, M() AS SINGLE
SHARED Numwords  AS INTEGER, revno AS SINGLE
SHARED CONFIGloaded AS INTEGER
SHARED Xo AS SINGLE, Yo AS SINGLE, Zo AS SINGLE
SHARED AZIM AS SINGLE, ELEV AS SINGLE, roll AS SINGLE


DIM i AS INTEGER, J AS INTEGER, k AS INTEGER
DIM mode AS INTEGER


'CHECK IF CONFIGURATION DATA LOADED
IF revno >= 3! THEN GOTO configNOTneeded       'newer Birds/flocks don't use configuration files

IF CONFIGloaded = 0 THEN
PRINT
PRINT " *** CONFIGURATION DATA NOT LOADED "
PRINT ""
PRINT " *** RECOMMEND RETURN TO MAIN MENU TO LOAD CONFIGURATION DATA"
PRINT
PRINT " *** OTHERWISE DIGITIZING ACCURACY WILL BE DEGRADED"
PRINT
PRINT
PRINT CHR$(7)        'ring the bell
pause
END IF

configNOTneeded:

PRINT #1, "Z";           'init bird to pos/matrix output
Numwords = 12            '12 words to get in pos/matrix

MENU1:
CLS
PRINT
PRINT "Manually enter stylus offsets        ( 1 )"
PRINT "Auto calibrate stylus offsets        ( 2 ) "
PRINT "Define a measurement frame           ( 3 )"
PRINT "Collect data to a file               ( 4 )"    'in the user defined ref frame
PRINT "Determine distance between 2 points  ( 5 )"
PRINT "RETURN TO MAIN MENU                  ( 6 )"
INPUT mode


IF mode = 1 THEN CALL ENTERsytlusOFFSETS
IF mode = 2 THEN CALL CALIBRATEstylus
IF mode = 3 THEN CALL DEFINEmeasurementFRAME
IF mode = 4 THEN CALL COLLECTdataTOfile
IF mode = 5 THEN CALL TWOpointDISTANCE
IF mode = 6 THEN EXIT SUB

GOTO MENU1




END SUB

SUB ENTERsytlusOFFSETS


SHARED Xo AS SINGLE, Yo AS SINGLE, Zo AS SINGLE, Xs AS SINGLE, Ys AS SINGLE, Zs AS SINGLE

DIM casetorun AS INTEGER



changeoffsets:
PRINT : PRINT : PRINT
PRINT "Change tip offsets                     ( 0 )"
PRINT "List tip offset calibration procedure  ( 1 )"
PRINT "Exit to main menu                      ( 2 )"
INPUT casetorun
PRINT : PRINT

IF casetorun = 2 THEN EXIT SUB


IF casetorun = 0 THEN
PRINT
a$ = "X offset in inches "
CALL INPUTvalue(a$, Xo)
a$ = "Y offset in inches "
CALL INPUTvalue(a$, Yo)
a$ = "Z offset in inches "
CALL INPUTvalue(a$, Zo)
PRINT

PRINT "check values by computing tip continously till key hit?  YES( 0 ), NO( 1 )  "
INPUT yesno
PRINT
IF yesno = 1 THEN GOTO changeoffsets
tipagain:
CALL TIPxyz(Xs, Ys, Zs)         'get the tip coordinates using current offsets
PRINT USING "###.##   "; Xs; Ys; Zs   'print the tip values

a$ = INKEY$       'read keyboard
IF a$ = "" THEN GOTO tipagain
GOTO changeoffsets
END IF

IF casetorun = 1 THEN
CALL MANUinstruct         'list the instructions
END IF


END SUB

SUB GAUSSjordon (N AS INTEGER, C() AS SINGLE)
'
'GAUSS/JORDON METHOD OF SOLVING N SIMULTANEOUS EQUATIONS
'WORKS FOR HOMOGENEOUS (B=0) AND NON-HOMOGENEOUS LINEAR EQUATIONS (B <>0 )
'WRITTEN MARCH 7, 1987 BY E.B.BLOOD


'EQUATION TO BE SOLVED IS OF THE FORM  CX=B
'WHERE C IS A MATRIX OF KNOWN COEFFICIENTS C(I,J)
'AND X IS A MATRIX X(J) OF UNKNOWNS
'AND B IS A MATRIX B(I) OF KNOW CONSTANTS
'EQUATIONS THUS TAKE FORM OF:
'C(1,1)*X(1)+C(1,2)*X(2)+... C(1,J)*X(J)=B(1)
'C(2,1)*X(1)+C(2,2)*X(2)+... C(2,J)*X(J)=B(2)
'......
'C(I,1)*X(1)+C(I,2)*X(2)+... C(I,J)*X(J)=B(I)
'
'ON ENTRY  THE COEFFICIENTS C(I,J) ARE IN C(1,1), C(1,2) ...C(N,N)
'ON ENTRY B(I) IS IN C(I,N+1)
'ON EXIT THE SOLUTION X(I) IS IN C(I,N+1)


DIM i AS INTEGER, J AS INTEGER, k AS INTEGER, n1 AS INTEGER
DIM K1 AS INTEGER, D AS SINGLE



'GAUSS / JORDON METHOD OF SOLVING N SIMULTANEOUS EQUATIONS

n1 = N + 1
FOR k = 1 TO N
K1 = k + 1
FOR J = K1 TO n1
'
'NEED FOLLOWING TEST FOR SOLVING HOMOGENOUS EQUATIONS (B=0)
IF C(k, k) = 0 THEN
        C(k, J) = 1!
ELSE
        C(k, J) = C(k, J) / C(k, k)
END IF

NEXT J

C(k, k) = 1!
FOR i = 1 TO N
IF i = k GOTO endloop
IF C(i, k) = 0 GOTO endloop

FOR J = K1 TO n1
C(i, J) = C(i, J) - C(i, k) * C(k, J)
NEXT J
C(i, k) = 0!
endloop:
NEXT i
NEXT k
'
' ALL DONE PRINT SOLUTION MATRIX A
'PRINT "SOLUTION"
'FOR i = 1 TO N
'PRINT C(i, n1);
'NEXT i
'PRINT

END SUB

SUB GET232INPUTWORD (WORD AS INTEGER, AD AS SINGLE)

'READS TWO BYTES FROM THE RS232 PORT AND RETURNS AN INTEGER 'WORD'
'BETWEEN -32768 AND 32767 ALSO RETURNS A SINGLE 'AD' BETWEEN 0-65535

DIM MSbyte AS INTEGER, LSbyte AS INTEGER

'READ LSbyte FROM BIRD'D RS232 PORT
'WAIT TO SEE IF BIRD GOT COMMAND
CHECKINPUT:
FOR i = 1 TO 50        'AT 9600 BAUD DOESN'T SEEMS YOU CAN USE 10 TO 10000
IF EOF(1) = 0 THEN GOTO READBYTE          'DATA IN BUFFER READ IT
NEXT i
 PRINT "INPUT TIME OUT - HIT A KEY TO RETURN"
a$ = INKEY$
IF a$ <> "" THEN EXIT SUB        'PROVIDE A WAY OUT IF LOCKUP BY HITTING A KEY
GOTO CHECKINPUT           'TRY AGAIN

READBYTE:

'READ THE LSbyte FROM BIRD
B$ = INPUT$(1, #1)
'
'READ MSbyte FROM BIRD
C$ = INPUT$(1, #1)
'CONVERT STRING TO BYTES TO WORD
LSbyte = ASC(B$)
MSbyte = ASC(C$)

'GET AD FROM 0 TO 65535 AND WORD FROM -32768 TO 32767
CALL BYTEStoWORD(MSbyte, LSbyte, WORD, AD)


END SUB

SUB GETBIRDparameter (parameter AS INTEGER)

SHARED CONFIGrb() AS INTEGER



'given a parameter number uses the Birds EXAMINE VALUE command to get
'and decode the parameter

'parameter numbers that can be passed
'
'    0          System status
'    1          Software revision number
'    2          Bird computer crystal speed
'    3          Maximum range scaling
'    4          Filter ON/OFF status
'    5          Filter constant ALPHA_MIN
'    6          System measurement rate
'    7          CONFIGURATION data


'written  10/19/90 by ebblood
'revised 10/30/90 rev # calculation was in error, fractional is MSbyte
'revised 11/5/90 added to FILToff 2 cycle ac filter
'revised 2/2/91 dac filter deleted and 2 cycle ac filter takes its place
'revised 5/15/91 now gets CONFIGURATION data
'revised 2/16/94 by SteveWork. Reduce function support to param 1 and 7.


SHARED CLOCK AS SINGLE, revno AS SINGLE, POSK AS SINGLE, CRYSTAL AS INTEGER

DIM WORD AS INTEGER, AD AS SINGLE, i AS INTEGER
DIM MSbyte AS INTEGER, LSbyte AS INTEGER

PRINT
PRINT

'send EXAMINE VALUE command to Bird
PRINT #1, "O"; CHR$(parameter);

IF parameter = 7 GOTO readconfig

'get the word output from the Bird in response to the EXAMINE VALUE command
CALL GET232INPUTWORD(WORD, AD)


'decode the word sent by The Bird

IF parameter = 1 THEN

'form the rev no as 2.0,2.1,2.21 ect
'fractional part of rev # is MSbyte, integer part is LSbyte

        CALL INTtoBYTES(WORD, MSbyte, LSbyte)    'convert to bytes

        IF MSbyte < 10 THEN
                revno = LSbyte + MSbyte / 10!
        ELSE
                revno = LSbyte + MSbyte / 100!
        END IF
        PRINT "Software revision number = "; revno

END IF


readconfig:
IF parameter = 7 THEN

        'read 36 bytes of configuration data from the bird
        FOR i = 1 TO 36
                C$ = INPUT$(1, #1)
                'CONVERT STRING TO BYTES TO WORD
                CONFIGrb(i) = ASC(C$)
        NEXT i

END IF

PRINT

'
END SUB

SUB INITcom1

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


PRINT
'INPUT "AUTO-BAUD DETECT AT BIRD ? NO ( 0 )   YES ( 1 ) ", BAUDN
'IF BAUDN = 1 THEN PRINT #1, " ";    'SEND SPACE FOR AUTO-BAUD DETECTION






END SUB

SUB INPUTvalue (a$, VALUE)

'USER CAN SEND A STRING FOR AN INPUT PROMPT MESSAGE
'IF A CARRIAGE RETURN IS INPUT FOR THE DATA REQUEST THEN THE VALUE IS
'LEFT UNCHANGE. OTHERWISE THE CHANGED VALUE IS RETURNED TO THE USER

'WRITTEN MAY 3, 1990

PRINT a$; " "; VALUE;
INPUT B$                           'GET THE INPUT FROM THE USER'S KEYBOARD HIT
IF LEN(B$) > 0 THEN VALUE = VAL(B$)


END SUB

SUB INTtoBYTES (WORD AS INTEGER, MSbyte AS INTEGER, LSbyte AS INTEGER)

DIM WORD1 AS SINGLE

 'PROCEDURE INT_TO_BYTES( WORD, MSbyte, LSbyte )
 '
 ' REVISED 7/12/89 WORD NO LONGER CHANGED SINCE IT CHANGES PASSED PARAMETERS
 '
 'CONVERTS A SIGNED OR UNSIGNED INTEGER 16 BIT WORD TO 2 INTEGER BYTES
 '
WORD1 = WORD
IF WORD1 < 0 THEN WORD1 = WORD1 + 65536
MSbyte = INT(WORD1 / 256)
LSbyte = INT(WORD1 - MSbyte * 256!)


END SUB

SUB KEYBOARDhit (B$)


'wait till user hits keyboad and returns character in a$
waitforkeyboard:
a$ = INKEY$
IF a$ = "" THEN GOTO waitforkeyboard

END SUB

SUB LOADconfiguration

'Gets a CONFIGURATION data file from the disk and sends it to the BIRD
'WRITTEN MAY 2, 1990

'RETURNS VIA SHARED CONFIGloaded=1 IF SUCCESSFUL CONFIGURATION LOAD

SHARED XC.ADDR AS INTEGER, SC.ADDR AS INTEGER, CONFIGrb() AS INTEGER
SHARED CONFIGloaded AS INTEGER


DIM NUMC(36) AS INTEGER, NUMR(36) AS INTEGER, i AS INTEGER, J AS INTEGER
DIM MSbyte AS INTEGER, LSbyte AS INTEGER, k AS INTEGER
DIM ARRAY(3, 3) AS INTEGER, NERROR AS INTEGER


INPUT "CONFIGURATION data file name to send to The Bird ", Cfile$
OPEN Cfile$ FOR INPUT AS #2           'open the file
PRINT

'The first line in the file is not configuration data but is used
'for text purpose such as identification
'get the first line and print it

LINE INPUT #2, ALINE$
PRINT "The first line read from the file is: "
PRINT
PRINT ALINE$
PRINT

'initialize the configuration string to the CONFIGURATION command "C"
CONFIG$ = "C"

'read all the configuration bytes from the file
FOR i = 1 TO 36
  LINE INPUT #2, ALINE$
  NUMC(i) = VAL(ALINE$)               'GET THE NUMERIC VALUES OF CONFIG BYTE
  CONFIG$ = CONFIG$ + CHR$(NUMC(i))   'build the configuration word
NEXT i
CLOSE (2)           'close the disk file

'send the configuration data to The Bird
PRINT #1, CONFIG$;


'READ BACK THE CONFIGURATION DATA FROM THE BIRD

FOR i = 1 TO 1000      'GIVE THE BIRD TIME TO PUT THE DATA INTO ARRAYS
NEXT i

PRINT
PRINT " CONFIGURATION DATA READ BACK FROM THE BIRD"
PRINT

CALL GETBIRDparameter(7)            'read the configuration data back from the bird


'COMPARE THE CONFIGURATION DATA FROM THE FILE NUMC() WITH THE
'CONFIGURATION DATA READ BACK FROM THE BIRD , CONFIGrb()

NERROR = 0            'INIT TO NO ERRORS
CONFIGloaded = 0      'INIT TO CONFIGURATION NOT LOADED
FOR i = 1 TO 36
  IF NUMC(i) <> CONFIGrb(i) THEN
    PRINT "CONFIGURATION DATA ERROR AT BYTE #"; i; " MISMATCHED BYTES="; NUMC(i); CONFIGrb(i)
    NERROR = NERROR + 1
  END IF
NEXT i
PRINT
PRINT

IF NERROR = 0 THEN
PRINT "*** SUCCESSFUL CONFIGURATION LOAD ****"
CONFIGloaded = 1        'SET FLAG FOR GOOD LOAD
END IF


END SUB

SUB MANUinstruct

'print the instructions for manual calibration of the stylus tip
'
CLS
PRINT
PRINT
PRINT " 1. remove any metal from the area including your chair"
PRINT " 2. mark a point about 12 inches in front of the xmtr that is at"
PRINT "    (x = 12, y = 0, z = 0)"
PRINT " 3. enter approximate values for the offsets"
PRINT
PRINT "    X offset is positive for a tip in front of the center of the receiver"
PRINT "    Y offset is positive for a tip to the right of the center of the receiver"
PRINT "    Z offset is positive for a tip below the center of the receiver"
PRINT
PRINT "    all directions are viewing the receiver from the top (the mounting"
PRINT "    holes are on the bottom) with the cable facing toward your stomach"
PRINT
PRINT " 4. level the transmitter fore and aft by shimming with paper"
PRINT "     determine level by measuring Z with the receiver near the xmtr along y=0"
PRINT "     and farther away from the xmtr along Y=0. shim the xmtr fore "
PRINT "     and aft till the Z values are pretty close along the Y=0 line"
CALL pause
PRINT " 5. for the X and Y offset with the stylus tip always touching the point:"
PRINT "    point the receiver toward the xmtr (azim=180)  record the X,Y print outs"
PRINT "    point the receiver away from the xmtr (azim=0) record the X,Y print outs"
PRINT "    subtract the X values (azim 180 - azim 0 ) and divide by 2. this is the"
PRINT "    X offset, subtract the Y values and divide by 2. this is the Y offset"
PRINT "    when rotating the receiver, the case must be level in the two positions"
PRINT
PRINT " 6. for the Z offset, use a reference point a few inches above the table as"
PRINT "    X=12, Y=0 if the point has zero thickness touch the tip to the point first"
PRINT "    with the receiver horizontal (roll=0), record the Z, then roll the"
PRINT "    receiver (roll=180) and record the Z. Subtract the two and divide by"
PRINT "    zero. this is the Z offset."
PRINT
PRINT "    if the reference point you are touching has finite thickness (T) and you"
PRINT "    touch the top surface then the bottom surface, then the Z offset is"
PRINT "    top Z minus bottom Z minus T all divided by 2"
CALL pause
PRINT "  7. With this first cut of offset entered, repeat 5,6,7"
PRINT
PRINT "  8. Digitizing accuracy is higher when the object is at least 12 inches"
PRINT "     from the transmitter."
CALL pause


END SUB

SUB MEASUREandAVERAGE (NtoAVER AS INTEGER, X AS SINGLE, Y AS SINGLE, z AS SINGLE)


'measures the x,y,z coordinates of the stylus tip. returning an average value
'for NtoAVER samples

DIM i AS INTEGER, Xt AS SINGLE, Yt AS SINGLE, Zt AS SINGLE

'zero out average
X = 0
Y = 0
z = 0

FOR i = 1 TO NtoAVER

        CALL TIPxyz(Xt, Yt, Zt)     'tip coordinates in default ref frame

X = X + Xt
Y = Y + Yt
z = z + Zt

NEXT i

'form average

X = X / NtoAVER
Y = Y / NtoAVER
z = z / NtoAVER




END SUB

SUB MIDN (M() AS SINGLE)



 'PROCEDURE MIDN( M )
 '
 'MATRIX IDENTITY
 '
 'SETS THE INPUT 3X3 MATRIX M TO THE IDENTITY
 '
 'WRITTEN MARCH 11, 1987 BY E.B.BLOOD



 M(1, 1) = 1!
 M(2, 1) = 0!
 M(3, 1) = 0!
 '
 M(1, 2) = 0!
 M(2, 2) = 1!
 M(3, 2) = 0!
 '
 M(1, 3) = 0!
 M(2, 3) = 0!
 M(3, 3) = 1!

END SUB

SUB mmcol (a() AS SINGLE, B() AS SINGLE, R() AS SINGLE)



 '   PROCEDURE MMCOL( A,B,R )
 '
 '   MATRIX MULTIPLY BY A COLUMN
 '
 '   MULTIPLIES A 3X3 MATRIX (A) BY A 3X1 COLUMN (B)
 '   MAT R=A*B
 ' MATRIX R AND A CANNOT BE SAME MATRICES ON INPUT
 '
 '   APRIL 16,1986 BY E.B.BLOOD
 '
 '
 R(1) = a(1, 1) * B(1) + a(1, 2) * B(2) + a(1, 3) * B(3)
 R(2) = a(2, 1) * B(1) + a(2, 2) * B(2) + a(2, 3) * B(3)
 R(3) = a(3, 1) * B(1) + a(3, 2) * B(2) + a(3, 3) * B(3)

END SUB

SUB NORMALequations (N AS INTEGER, M AS INTEGER, X() AS SINGLE, C() AS SINGLE)


'forms the normal equations, C(N,N), for a least square solution
'of N unknows given M measurements, where M>N

'equations to be solved are of the form
'Y(1)=A1*X(1,1)+A2*X(1,2)+... AN*X(1,N)
'Y(2)=A1*X(2,1)+A2*X(2,2)+... AN*X(2,N)
' .
' .
'Y(M)=A1*X(M,1)+A2*X(M,2)+... AN*X(M,N)
'in terms of the passed array, X(M,N) are in X(M,N)
'Y(M) is passed in X(M,N+1)

'the normal equations are returned in C(N,N) where
'C(j,k)=sum from i=1 to M of X(i,j)*X(i,k)

'in terms of a set up for a Gauss-Jordon solution, the simulatneous equations
'to be solved with "normalized" terms are

'C(1,N+1)=A1*C(1,1)+A2*C(1,2)+... AN*C(1,N)
'C(2,N+1)=A1*C(2,1)+A2*C(2,2)+... AN*C(2,N)
' . . .
' . . .
'C(N,N+1)=A1*C(N,1)+A2*C(N,2)+... AN*C(N,N)


DIM i AS INTEGER, J AS INTEGER, k AS INTEGER, n1 AS INTEGER, jj AS INTEGER
DIM kk AS INTEGER



n1 = N + 1

FOR J = 1 TO N
FOR k = 1 TO n1
C(J, k) = 0!
FOR i = 1 TO M
C(J, k) = C(J, k) + X(i, J) * X(i, k)
NEXT i
NEXT k
NEXT J


END SUB

SUB NORMALIZEvector (a() AS SINGLE, an() AS SINGLE)


'GIVEN THE X,Y,Z COMPONENTS OF A VECTOR A(3)
'COMPUTE THE COMPONENTS OF A NORMALIZED VECTOR An(3)
'7/8/91 by ebb

tv = SQR(a(1) ^ 2 + a(2) ^ 2 + a(3) ^ 2)
an(1) = a(1) / tv
an(2) = a(2) / tv
an(3) = a(3) / tv


END SUB

SUB pause

'WAITS TILL A KEY IS HIT

PRINT
PRINT "HIT ANY KEY TO CONTINUE"
pauseabit:
a$ = INKEY$
IF a$ = "" GOTO pauseabit

END SUB

SUB POSITIONMATRIXdata

'gets the position/matrix output from the bird
'and stores in shared variables

'caller must set outmode=0 for point before calling this routine

'revised5/21/91 now have Z and Numwords in this routine

SHARED BIRDDATA() AS SINGLE, POSK AS SINGLE
SHARED done AS INTEGER, OUT.MODE AS INTEGER, ItoF AS SINGLE
SHARED X AS SINGLE, Y AS SINGLE, z AS SINGLE, M() AS SINGLE
SHARED Numwords AS INTEGER



DIM i  AS INTEGER, J AS INTEGER, k AS INTEGER
PRINT #1, "Z";         'pos/matrix mode
Numwords = 12          '12 words to get


CALL readbird           'get x,y,z and orientation words

'convert position to inches
X = BIRDDATA(1) * POSK
Y = BIRDDATA(2) * POSK
z = BIRDDATA(3) * POSK

'arrange the BIRDDATA values in matrix format

i = 4
FOR J = 1 TO 3
  FOR k = 1 TO 3
    M(k, J) = BIRDDATA(i) * ItoF     'convert to fractional
    i = i + 1
  NEXT k
NEXT J


END SUB

SUB readbird

SHARED Numwords AS INTEGER, BIRDDATA() AS SINGLE, com$
SHARED done AS INTEGER, OUT.MODE AS INTEGER


DIM CPOS AS INTEGER, II AS INTEGER, LSbyte AS INTEGER, MSbyte AS INTEGER
DIM WORD AS LONG, TEST AS INTEGER



'PROCEDURE READBIRD
'
'READS BIRD DATA IN INTEGER FORMAT INTO ARRAY BIRDDATA()
'USING THE POINT MODE. USER MUST SETUP THE OUTPUT MODE, IE MATRIX, ANGLES
'ECT , BEFORE CALLING THIS ROUTINE AND USER MUST
'SET 'Numwords' TO THE NUMBER OF WORDS TO BE GOTTEN FOR A GIVEN
'MODE, IE Numwords=9 IF MATRIX OUTPUT SELECTED

'DIFFERS FROM READ.BIRD.DATA BY NOT LOOKING FOR KEYBOAD HIT AND ALWAYS IN
'POINT MODE


REQUESTdata2:
 '
PRINT #1, "B"; 'SEND REQUEST TO BIRD

'GET Numwords*2 BYTES FROM BIRD

TIMER ON                        'WILL TRAP IF RS232 HANGS

PORThung3:
IF LOC(1) = 0 GOTO PORThung3     'WAIT TILL SOMETHING IS IN BUFFER
TIMER OFF                       'SHUT OFF TIMER TRAP
B$ = INPUT$(Numwords * 2, #1)   'READ THE REQUESTED NUMBER OF BYTES FROM RS232

'
'EXTRACT Numwords WORDS FROM THE STRING CONVERTING TO BIPOLAR

FOR II = 1 TO Numwords
  CPOS = 2 * II - 1
  'GET LS BYTE
  LSbyte = ASC(MID$(B$, CPOS, 1))
  '
  'CHECK FOR DATA PHASING ERROR.
  'FIRST BYTE OF FIRST WORD SHOULD BE=1
  'FIRST BYTE OF ALL OTHER WORDS SHOULD BE=0
  'JUST CHECKING FIRST WORD DOESN'T SEEM TO BE ENOUGH SINCE IF BYTES ARE
  'OUT OF ORDER THE FIRST BIT MAY BE A DATA BIT =1 AND GIVE A FALSE INDICATION
  '
  IF II = 1 THEN    'CHECK LSBYTE OF WORD 1 FOR A 1
  TEST = LSbyte AND &H80
  IF TEST = 128 THEN GOTO FORMmsb3   'IF MSB=1 THEN OK EXIT
  PRINT "PHASING ERROR"
  CLOSE #1         'FLUSH THE BUFFER
  OPEN com$ FOR RANDOM AS #1
  a$ = INKEY$
  IF a$ <> "" THEN GOTO ENDITALL3   'GET OUT OF A LOCK UP IF KEY HIT

  GOTO REQUESTdata2
  END IF

'
 IF II = 2 THEN
    TEST = LSbyte AND &H80
    IF TEST = 0 THEN GOTO FORMmsb3   'IF MSB=0 THEN OK EXIT
    PRINT "PHASING ERROR"
    CLOSE #1         'FLUSH THE BUFFER
    OPEN com$ FOR RANDOM AS #1
    GOTO REQUESTdata2
 END IF
'
FORMmsb3:
  LSbyte = (LSbyte AND &H7F) * 2 'for formatted BIRD data
  'IF (LSbyte > 128) THEN LSbyte = LSbyte - 128
  'LSbyte = LSbyte * 2

  'GET MS BYTE
  MSbyte = ASC(MID$(B$, CPOS + 1, 1))
  WORD = (MSbyte * 256! + LSbyte) * 2 'for formatted BIRD data

  'CONVERT TO 16 BIT BIPOLAR BETWEEN -32768 AND 32767
  IF WORD > 32767! THEN WORD = WORD - 65536!
   BIRDDATA(II) = WORD     'TEMPORARILY SAVE DATA
NEXT II

ENDITALL3:

END SUB

SUB STATUSdecode (STAT AS INTEGER)

'decodes the Bird STATUS byte

'written 10/20/90 by ebblood
'revised 11/2/90 bit 6 message changed from xon/off to factory use

DIM bmode AS INTEGER

PRINT "STATUS BIT #        "

'decode bit 7
PRINT "     7           ";
IF (STATUS AND &H80) / 128 = 1 THEN
PRINT "FACTORY TEST COMMANDS ENABLED"
ELSE
PRINT "USER COMMANDS ENABLED "
END IF

'decode bit 6  XON/XOFF STATUS    NOT ACCESSABLE VIA USER COMMAND
PRINT "     6           ";
IF (STATUS AND &H40) / 64 = 1 THEN
PRINT "Reserved for factory use only"
ELSE
PRINT "Reserved for factory use only"
END IF

'decode bit 5
PRINT "     5           ";
PRINT "NOT USED"

'decode bit 4
PRINT "     4           ";
IF (STATUS AND &H10) / 16 = 1 THEN
PRINT "The Bird is asleep"
ELSE
PRINT "The Bird is awake"
END IF

'decode bits 3,2,1
PRINT "   3,2,1         ";
bmode = (STATUS AND &HE) / 2   'keep bits 3,2,1
IF bmode = 1 THEN PRINT "POSITION outputs selected"
IF bmode = 2 THEN PRINT "ANGLE outputs selected"
IF bmode = 3 THEN PRINT "MATRIX outputs selected"
IF bmode = 4 THEN PRINT "POSITION/ANGLE outputs selected"
IF bmode = 5 THEN PRINT "POSITION/MATRIX outputs selected"
IF bmode = 6 THEN PRINT "FACTORY CAL outputs selected"

'decode bit 0
PRINT "     0           ";

IF (STATUS AND &H1) = 1 THEN
PRINT "Stream mode"
ELSE
PRINT "Point mode"
END IF

PRINT
PRINT

END SUB

SUB TIPxyz (Xs AS SINGLE, Ys AS SINGLE, Zs AS SINGLE)

'returns the stylus x,y,z coordinates measured in the default reference frame

SHARED X AS SINGLE, Y AS SINGLE, z AS SINGLE
SHARED Xo AS SINGLE, Yo AS SINGLE, Zo AS SINGLE
SHARED M() AS SINGLE

        CALL POSITIONMATRIXdata  'get pos/matrix data via shared parameters

        'COMPUTE STYLUS TIP COORDINATES Xs,Ys,Zs given the bird receiver coordinates
        'X,Y,Z , the offsets Xo,Yo,Zo, and the receiver orientation matrix M()


        Xs = X + Xo * M(1, 1) + Yo * M(2, 1) + Zo * M(3, 1)
        Ys = Y + Xo * M(1, 2) + Yo * M(2, 2) + Zo * M(3, 2)
        Zs = z + Xo * M(1, 3) + Yo * M(2, 3) + Zo * M(3, 3)


END SUB

SUB TWOpointDISTANCE

'determines the total vector distance between two points

SHARED NUMtoAVERAGE AS INTEGER
DIM P1(3) AS SINGLE, P2(3) AS SINGLE


CALL CHECKforOFFSETS          'check if tip offsets calibrated yet
PRINT
PRINT
INPUT "How many measurements to average together >=1  ", NUMtoAVERAGE
IF NUMtoAVERAGE <= 0 THEN NUMtoAVERAGE = 1

anothertwo:
PRINT
PRINT
PRINT " HOLD THE STYLUS TIP ON POINT 1"
PRINT " hit any key when ready to take measurements"
PRINT "do not move the sytlus until the computer beeps"
PRINT

CALL pause
CALL MEASUREandAVERAGE(NUMtoAVERAGE, P1(1), P1(2), P1(3))'collect and average x,y,z
PRINT CHR$(7)        'RING BELL WHEN POINT COLLECTED
PRINT USING "###.##   "; P1(1); P1(2); P1(3)'print the tip values

PRINT
PRINT
PRINT " HOLD THE STYLUS TIP ON point 2"
PRINT " hit any key when ready to take measurements"
PRINT "do not move the sytlus until the computer beeps"
PRINT

CALL pause
CALL MEASUREandAVERAGE(NUMtoAVERAGE, P2(1), P2(2), P2(3))'collect and average x,y,z
PRINT CHR$(7)        'RING BELL WHEN POINT COLLECTED
PRINT USING "###.##   "; P2(1); P2(2); P2(3)'print the tip values

range = SQR((P1(1) - P2(1)) ^ 2! + (P1(2) - P2(2)) ^ 2! + (P1(3) - P2(3)) ^ 2!)
PRINT
PRINT
PRINT "TOTAL VECTOR DISTANCE BETWEEN THE TWO POINTS  ";
PRINT USING "###.##"; range
PRINT
PRINT
PRINT
PRINT "hit D when done or any key to continue"
chkkey:
a$ = INKEY$
IF a$ = "" THEN GOTO chkkey
a$ = UCASE$(a$)     'if user hit a lower case key, convert to upper case
IF a$ = "D" THEN EXIT SUB
GOTO anothertwo
END SUB


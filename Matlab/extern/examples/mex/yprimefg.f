








C
C YPRIMEG.FOR - Gateway function for YPRIME.FOR
C
C This is an example of the FORTRAN code required for interfacing
C a .MEX file to MATLAB.
C
C This subroutine is the main gateway to MATLAB.  When a MEX function
C  is executed MATLAB calls the MEXFUNCTION subroutine in the corresponding
C  MEX file.  
C
C Copyright 1984-2004 The MathWorks, Inc.
C $Revision: 1.9.2.1 $
C
      SUBROUTINE MEXFUNCTION(NLHS, PLHS, NRHS, PRHS)
C-----------------------------------------------------------------------
C     (pointer) Replace integer by integer*8 on 64-bit platforms
C
      INTEGER PLHS(*), PRHS(*)

C-----------------------------------------------------------------------
C

      INTEGER NLHS, NRHS
C
C-----------------------------------------------------------------------
C     (pointer) Replace integer by integer*8 on 64-bit platforms
C
      INTEGER MXCREATEDOUBLEMATRIX, MXGETPR

C-----------------------------------------------------------------------
C

      INTEGER MXGETM, MXGETN
C
C KEEP THE ABOVE SUBROUTINE, ARGUMENT, AND FUNCTION DECLARATIONS FOR USE
C IN ALL YOUR FORTRAN MEX FILES.
C---------------------------------------------------------------------
C
C-----------------------------------------------------------------------
C     (pointer) Replace integer by integer*8 on 64-bit platforms
C
      INTEGER YPP, TP, YP

C-----------------------------------------------------------------------
C

      INTEGER M, N
      REAL*8 RYPP(4), RTP, RYP(4)

C
C CHECK FOR PROPER NUMBER OF ARGUMENTS
C
      IF (NRHS .NE. 2) THEN
        CALL MEXERRMSGTXT('YPRIME requires two input arguments')
      ELSEIF (NLHS .GT. 1) THEN
        CALL MEXERRMSGTXT('YPRIME requires one output argument')
      ENDIF
C
C CHECK THE DIMENSIONS OF Y.  IT CAN BE 4 X 1 OR 1 X 4.
C
      M = MXGETM(PRHS(2))
      N = MXGETN(PRHS(2))
C
      IF ((MAX(M,N) .NE. 4) .OR. (MIN(M,N) .NE. 1)) THEN
        CALL MEXERRMSGTXT('YPRIME requires that Y be a 4 x 1 vector')
      ENDIF
C
C CREATE A MATRIX FOR RETURN ARGUMENT
C
      PLHS(1) = MXCREATEDOUBLEMATRIX(M,N,0)
C
C ASSIGN POINTERS TO THE VARIOUS PARAMETERS
C
      YPP = MXGETPR(PLHS(1))
C
      TP = MXGETPR(PRHS(1))
      YP = MXGETPR(PRHS(2))
C
C COPY RIGHT HAND ARGUMENTS TO LOCAL ARRAYS OR VARIABLES
      CALL MXCOPYPTRTOREAL8(TP, RTP, 1)
      CALL MXCOPYPTRTOREAL8(YP, RYP, 4)
C
C DO THE ACTUAL COMPUTATIONS IN A SUBROUTINE
C       CREATED ARRAYS.  
C
      CALL YPRIME(RYPP,RTP,RYP)
C
C COPY OUTPUT WHICH IS STORED IN LOCAL ARRAY TO MATRIX OUTPUT
      CALL MXCOPYREAL8TOPTR(RYPP, YPP, 4)
C
      RETURN
      END

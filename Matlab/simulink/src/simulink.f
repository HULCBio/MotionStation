C $Revision: 1.9 $









      SUBROUTINE MEXFUNCTION(NLHS, PLHS, NRHS, PRHS)






C     .. Scalar arguments ..
      INTEGER          NLHS, NRHS
C     .. Array arguments ..
C-----------------------------------------------------------------------
C     (pointer) Replace integer by integer*8 on the DEC Alpha and the
C     SGI 64-bit platforms
C
      INTEGER          PLHS(*), PRHS(*)
C-----------------------------------------------------------------------
C

C=======================================================================
C   Purpose:
C      Glue routine for making FORTRAN MEX-file systems and blocks
C   Synopsis:
C      [sys,x0] = usersys(t,x,u,flag)
C   Arguments:
C   Description:
C      This file should be linked with the subroutines that return  
C      derivatives, outputs, discrete states and sample times. 
C      Use a syntax of the form:
C                mex usersys.f simulink.f
C      where usersys.f is the name of the user-defined function.
C
C     Note, the .F files are designed to be passed through the C language 
C     preprocessor before passing them onto the fortran compiler. The
C     .f files are created from the .F files.
C
C  Algorithm:
C      Usersys is a MEX-file
C=======================================================================
C  Written:
C      Aleksandar Bozin  Mar 03, 1992
C  Modifications, bug fixes and extensions:
C      Ned Gulley        Apr 29, 1992
C      Copyright 1990-2002 The MathWorks, Inc.
C=======================================================================
C     .. Parameters ..
      INTEGER*4       NSIZES
      PARAMETER       (NSIZES=6)
      REAL*8          HUGE
      PARAMETER       (HUGE=1.0E+33)
C     .. Local scalars ..
C-----------------------------------------------------------------------
C     (pointer) Replace integer by integer*8 on the DEC Alpha and the
C     SGI 64-bit platforms
C
      INTEGER          X0, SIZEOUT, T, X, U, SYS
C-----------------------------------------------------------------------
C

      INTEGER*4        I, FLAG
C     .. Local arrays ..
      INTEGER*4        LSIZE(NSIZES)
      REAL*8           DSIZE(NSIZES)
C     .. External subroutines ..
      EXTERNAL         MXCOPYREAL8TOPTR, MEXERRMSGTXT
      EXTERNAL         SIZES 

      EXTERNAL         INITCOND
      EXTERNAL         DERIVS, DSTATES, OUTPUT, DOUTPUT, SINGUL
      EXTERNAL         TNEXT, DCOPY

C     .. External functions ..
	EXTERNAL         SAMPLHIT

      LOGICAL          SAMPLHIT

C-----------------------------------------------------------------------
C     (pointer) Replace integer by integer*8 on the DEC Alpha and the
C     SGI 64-bit platforms
C
      INTEGER          MXCREATEFULL, MXGETPR
C-----------------------------------------------------------------------
C

      EXTERNAL         MXCREATEFULL, MXGETPR
      DOUBLE PRECISION MXGETSCALAR
      EXTERNAL         MXGETSCALAR
      INTEGER*4        MXGETM, MXGETN
      EXTERNAL         MXGETM, MXGETN
C     .. Intrinsic functions ..
      INTRINSIC        IABS, MAX0, MIN0, DBLE
C     .. Scalars in common ..
      REAL*8           CURHIT, NXTHIT
C     .. Arrays in common ..
      INTEGER*4        MDLSIZES(NSIZES)
C     .. Common blocks ..
      COMMON           /SIMLAB/CURHIT, NXTHIT, MDLSIZES



C     .. Executable statements ..

C
C     Check validity of arguments
C
      IF (NRHS .EQ. 0) THEN
         IF (NLHS .GT. 2) THEN
            CALL MEXERRMSGTXT('Too many output arguments.')
         ENDIF
C
C     Special case FLAG=0, return sizes and initial conditions
C
         PLHS(1) = MXCREATEFULL(NSIZES, 1, 0)
         SIZEOUT = MXGETPR(PLHS(1))
         DO 100 I = 1,NSIZES
            LSIZE(I) = 0
  100    CONTINUE
         CALL SIZES(LSIZE)
         DO 150 I = 1,NSIZES
            MDLSIZES(I) = LSIZE(I)
            DSIZE(I) = DBLE(LSIZE(I))
  150    CONTINUE
         CALL MXCOPYREAL8TOPTR(DSIZE, SIZEOUT, NSIZES)         
         IF (NLHS .GT. 1) THEN
            PLHS(2) = MXCREATEFULL(MDLSIZES(1)+MDLSIZES(2), 1, 0)
            X0 = MXGETPR(PLHS(2))
            CALL INITCOND(%VAL(X0))
         ENDIF
         CURHIT = -HUGE
         NXTHIT = HUGE
         RETURN
      ENDIF
C
C     Right hand side arguments 
C
      IF ((NLHS .GT. 2) .OR. (NRHS .NE. 4)) THEN
         CALL MEXERRMSGTXT('Wrong number of input arguments.')
      ENDIF
C
C     Check for correct dimensions of input arguments
C
      M = MXGETM(PRHS(4))
      N = MXGETN(PRHS(4))
      IF ((M .NE. 1) .OR. (N .NE. 1)) THEN
         CALL MEXERRMSGTXT('Flag must be a scalar variable.')
      ENDIF
C
C     The sizes vector is needed in most cases, if for nothing else it
C     is used for error checking.
C
      DO 200 I = 1,NSIZES
         LSIZE(I) = 0
  200 CONTINUE
      CALL SIZES(LSIZE)
      DO 250 I = 1,NSIZES
         MDLSIZES(I) = LSIZE(I)
  250 CONTINUE

      FLAG = INT(MXGETSCALAR(PRHS(4)))
      IF (FLAG .EQ. 0) THEN
         IF (NLHS .GT. 2) THEN
            CALL MEXERRMSGTXT('Too many output arguments.')
         ENDIF
C
C        Special case FLAG=0, return sizes and initial conditions
C
         PLHS(1) = MXCREATEFULL(NSIZES, 1, 0)
         SIZEOUT = MXGETPR(PLHS(1))
         DO 300 I = 1,NSIZES
            DSIZE(I) = DBLE(LSIZE(I))
  300    CONTINUE
         CALL MXCOPYREAL8TOPTR(DSIZE, SIZEOUT, NSIZES)          
         IF (NLHS .GT. 1) THEN
            PLHS(2) = MXCREATEFULL(MDLSIZES(1)+MDLSIZES(2), 1, 0)
            X0 = MXGETPR(PLHS(2))
            CALL INITCOND(%VAL(X0))
         ENDIF
         CURHIT = -HUGE
         NXTHIT = HUGE
         RETURN
      ENDIF
C
C     Error checking (can be omitted for speed but may cause
C     segmentation faults if called with the wrong sizes of
C     arguments)
C
      IF ((NLHS .GT. 1) .OR. (NRHS .NE. 4)) THEN
         CALL MEXERRMSGTXT('Too many output arguments.')
      ENDIF
C
C     Time parameter
C
      M = MXGETM(PRHS(1))
      N = MXGETN(PRHS(1))
      IF ((M .NE. 1) .OR. (N .NE. 1)) THEN
         CALL MEXERRMSGTXT('Time must be a scalar variable.')
      ENDIF
C
C     State vector
C
      M = MXGETM(PRHS(2))
      N = MXGETN(PRHS(2))
      IF ((M*N) .NE. MDLSIZES(1)+MDLSIZES(2)) THEN
         CALL MEXERRMSGTXT('State vector of wrong size.')
      ENDIF
C
C     Input vector
C
      M = MXGETM(PRHS(3))
      N = MXGETN(PRHS(3))
      IF ((M*N) .NE. MDLSIZES(4)) THEN
         CALL MEXERRMSGTXT('Input vector of wrong size.')
      ENDIF
C
C     Check flag value and return appropriate vector
C
      T = MXGETPR(PRHS(1))
      X = MXGETPR(PRHS(2))
      U = MXGETPR(PRHS(3))
      IF (IABS(FLAG) .GT. 5) THEN
         IF (IABS(FLAG) .EQ. 9) THEN
            PLHS(1) = MXCREATEFULL(0, 0, 0)
            GOTO 900
         ELSE
            CALL MEXERRMSGTXT('Not a valid flag number.')
         ENDIF
      ENDIF
      GOTO (400,500,600,700,800) IABS(FLAG)
C
C     Flag is 1 or -1, return state derivatives
C
  400 CONTINUE
         IF (NLHS .GE. 0) THEN
            PLHS(1) = MXCREATEFULL(MDLSIZES(1), 1, 0)
         ENDIF
         SYS = MXGETPR(PLHS(1))
	CALL DERIVS(%VAL(T), %VAL(X), %VAL(U), %VAL(SYS))
         GOTO 900
C
C     Flag is 2 or -2, return discrete states
C
  500 CONTINUE
         IF (NLHS .GE. 0) THEN
            PLHS(1) = MXCREATEFULL(MDLSIZES(2), 1, 0)
         ENDIF
	IF (MDLSIZES(2) .NE. 0) THEN
         SYS = MXGETPR(PLHS(1))
         IF (SAMPLHIT(%VAL(T))) THEN
	    CALL DSTATES(%VAL(T), %VAL(X), %VAL(U), %VAL(SYS))
	 ELSE
	    CALL DCOPY(%VAL(X), MDLSIZES(1)+1, %VAL(SYS), MDLSIZES(2))
         ENDIF
	ENDIF
         GOTO 900
C
C     Flag is 3, return system outputs 
C
  600 CONTINUE
         IF (NLHS .GE. 0) THEN
            PLHS(1) = MXCREATEFULL(MDLSIZES(3), 1, 0)
         ENDIF
         SYS = MXGETPR(PLHS(1))
         IF (SAMPLHIT(%VAL(T))) THEN
            CALL DOUTPUT(%VAL(T), %VAL(X), %VAL(U), %VAL(SYS))
         ENDIF
	 CALL OUTPUT(%VAL(T), %VAL(X), %VAL(U), %VAL(SYS))
         GOTO 900
C
C     Flag is 4, return next time interval for update
C
  700 CONTINUE
         IF (NLHS .GE. 0) THEN
            PLHS(1) = MXCREATEFULL(1, 1, 0)
         ENDIF
         SYS = MXGETPR(PLHS(1))
         IF (MDLSIZES(2) .GT. 0) THEN
            CALL TNEXT(%VAL(T), %VAL(X), %VAL(U), %VAL(SYS))
         ENDIF
         CALL MXCOPYREAL8TOPTR(NXTHIT, SYS, 1)
         GOTO 900
C
C     Flag is 5, return the values of the system root functions
C
  800 CONTINUE
         IF (NLHS .GE. 0) THEN
            PLHS(1) = MXCREATEFULL(MDLSIZES(5), 1, 0)
         ENDIF
	IF (MDLSIZES(5) .NE. 0) THEN
         SYS = MXGETPR(PLHS(1))
	 CALL SINGUL(%VAL(T), %VAL(X), %VAL(U), %VAL(SYS))
	ENDIF
         GOTO 900
C
C     Last card of MEXFUNCTION
C
  900 CONTINUE
      RETURN
      END

	
      REAL*8 FUNCTION HITFCN(TS, OFFSET, T)
C     .. Scalar arguments ..
      REAL*8           TS, OFFSET, T
C=======================================================================
C     Description:
C       Function to calculate the next sample time
C     Input arguments:
C       T        time
C       OFFSET   offset time
C       TS       sample time
C     Remark:
C       This function should not be called by the user.
C=======================================================================
C     .. Parameters ..
      INTEGER*4       NSIZES
      PARAMETER       (NSIZES=6)
      REAL*8          HUGE
      PARAMETER       (HUGE=1.0E+33)
C     .. Local scalars ..
      REAL*8          NSAMPL
C     .. Intrinsic functions ..
      INTRINSIC        AINT
C     .. Executable statements ..

      NSAMPL = (T-OFFSET)/TS
      HITFCN = OFFSET+(1.0+AINT(NSAMPL+1.0E-13*(1.0+NSAMPL)))*TS
      RETURN
      END

      SUBROUTINE TNEXT(T, X, U, TN)
C     .. Scalar arguments ..
      REAL*8           T
C     .. Array arguments ..
      REAL*8           X(*), U(*), TN(*)
C=======================================================================
C     Description:
C       Function to return the next sample time
C     Input arguments:
C       T        time
C       X        state vector
C       U        input vector
C     Output arguments:
C       TN       a scalar which contains the next sample time
C     Remark:
C       This function should not be called directly by the user.
C=======================================================================
C     .. Parameters ..
      INTEGER*4       NSIZES
      PARAMETER       (NSIZES=6)
      REAL*8          HUGE
      PARAMETER       (HUGE=1.0E+33)
C     .. Local scalars ..
      REAL*8          TS, OFFSET
C     .. External subroutines ..
      EXTERNAL         TSAMPL
C     .. External functions ..
      DOUBLE PRECISION HITFCN
      EXTERNAL         HITFCN
C     .. Scalars in common ..
      REAL*8           CURHIT, NXTHIT
C     .. Arrays in common ..
      INTEGER*4        MDLSIZES(NSIZES)
C     .. Common blocks ..
      COMMON           /SIMLAB/CURHIT, NXTHIT,	 MDLSIZES
C     .. Executable statements ..

      CALL TSAMPL(T, X, U, TS, OFFSET)
      IF (CURHIT .EQ. -HUGE) THEN
         CURHIT = HITFCN(TS, OFFSET, T-TS)
      ELSE
         CURHIT = NXTHIT
      ENDIF
      NXTHIT = HITFCN(TS, OFFSET, T)
      TN(1) = NXTHIT
      
      RETURN
      END
      
      LOGICAL FUNCTION SAMPLHIT(T)
C     .. Scalar arguments ..
      REAL*8           T
C=======================================================================
C     Purpose:
C       Function to check whether it is a sample hit or not
C     Input arguments:
C       T        time
C     Description:
C       This functions returns a boolean variable which can be used
C       to decide whether a sample hit occured or not.
C     Remark:
C       Called internally, but can be used by the user as well.
C=======================================================================
C     .. Parameters ..
      INTEGER*4       NSIZES
      PARAMETER       (NSIZES=6)
C     .. Scalars in common ..
      REAL*8           CURHIT, NXTHIT
C     .. Arrays in common ..
      INTEGER*4        MDLSIZES(NSIZES)
C     .. Common blocks ..
      COMMON           /SIMLAB/CURHIT, NXTHIT, MDLSIZES
C     .. Executable statements ..

      IF (T .EQ. CURHIT) THEN
         SAMPLHIT = .TRUE.
      ELSE
          SAMPLHIT = .FALSE.
      ENDIF
      
      RETURN
      END

      SUBROUTINE DCOPY(X, OFFSET, Y, N)
C     .. Scalar arguments ..
      INTEGER          OFFSET, N
C     .. Array arguments ..
      REAL*8           X(*), Y(*)
C=======================================================================
C     Purpose:
C       Function to copy one array into another
C     Input arguments:
C       X        input array
C       OFFSET   an index of the first element to be copied
C       N        number of elements to be copied
C     Output arguments:
C       Y        a vector containing a copy of the input vector
C=======================================================================
C     .. Local scalars ..
      INTEGER          I, IB
C     .. Executable statements ..

      IB = OFFSET
      DO 100 I = 1,N
          Y(I) = X(IB)
          IB = IB+1
  100 CONTINUE
      
      RETURN
      END

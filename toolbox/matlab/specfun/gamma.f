








C     Fortran MEX gateway function for the Cody Gamma function.
C
C     Computes, for real x:
C         Gamma function: gamma(x).
C     MATLAB usage:
C         y = gamma(x)
C
C     $Revision: 1.7.2.2 $ $Date: 2003/07/31 05:26:33 $
C
      SUBROUTINE MEXFUNCTION(NLHS, PLHS, NRHS, PRHS)
      INTEGER PLHS(*), PRHS(*)
      INTEGER NLHS, NRHS
C
      INTEGER MXCREATENUMERICARRAY, MXGETDATA, MXGETDIMENSIONS
      INTEGER MXISSINGLE, MXISDOUBLE, MXISCOMPLEX, MXISSPARSE, MXGETCLASSID
      INTEGER MXGETNUMBEROFDIMENSIONS, MXGETNUMBEROFELEMENTS
C
C-----------------------------------------------------------------------
C
      REAL*4 SX
      REAL*8 X,Y,DGAMMA
      INTEGER I, ISSNGL,ISDBL,CLASSID,NDIMS
      INTEGER PX,PY,PDIMS
C
C     Exact values of gamma(1:23)
C
     
      REAL*8 GAM(23) /
     +  1.0D0,
     +  1.0D0,
     +  2.0D0,
     +  6.0D0,
     +  24.0D0,
     +  120.0D0,
     +  720.0D0,
     +  5040.0D0,
     +  40320.0D0,
     +  362880.0D0,
     +  3628800.0D0,
     +  39916800.0D0,
     +  479001600.0D0,
     +  6227020800.0D0,
     +  87178291200.0D0,
     +  1307674368000.0D0,
     +  20922789888000.0D0,
     +  355687428096000.0D0,
     +  6402373705728000.0D0,
     +  121645100408832000.0D0,
     +  2432902008176640000.0D0,
     +  51090942171709440000.0D0,
     +  1124000727777607680000.0D0 /
C
C     Input arguments
C
      IF (NRHS .LT. 1) CALL MEXERRMSGTXT('Not enough input arguments.')
      IF (NRHS .GT. 1) CALL MEXERRMSGTXT('Too many input arguments.')
      IF (NLHS .GT. 1) CALL MEXERRMSGTXT('Too many output arguments.')
      ISSNGL = MXISSINGLE(PRHS(1))
      ISDBL = MXISDOUBLE(PRHS(1))
      IF (ISSNGL .NE. 1 .AND. ISDBL .NE. 1)
     +   CALL MEXERRMSGTXT('Input must be single or double.')
      IF (MXISCOMPLEX(PRHS(1)) .EQ. 1)
     +   CALL MEXERRMSGTXT('Input must be real.')
      IF (MXISSPARSE(PRHS(1)) .EQ. 1)
     +   CALL MEXERRMSGTXT('Input must be full.')
C
C     Allocate output
C
      CLASSID = MXGETCLASSID(PRHS(1))
      NDIMS = MXGETNUMBEROFDIMENSIONS(PRHS(1))
      PDIMS = MXGETDIMENSIONS(PRHS(1))
      PLHS(1) = MXCREATENUMERICARRAY(NDIMS,%val(PDIMS),CLASSID,0)
C
C     Pointers to input and output arrays
C
      PX = MXGETDATA(PRHS(1))
      PY = MXGETDATA(PLHS(1))
C
C     Loop over elements
C
      N = MXGETNUMBEROFELEMENTS(PRHS(1))
      if (ISDBL .EQ. 1) then
         DO I = 1, N
C
C           Pick up one element of the input
C
            CALL MXCOPYPTRTOREAL8(PX,X,1)
C
C           Evaluate function, including NaN test
C
            IF (X .GE. 1.D0 .AND.
     +          X .LE. 23.D0 .AND.
     +          X .EQ. DINT(X)) THEN
                Y = GAM(IDINT(X))
            ELSEIF (X .EQ. X) THEN
                Y = DGAMMA(X)
            ELSE
C               X is NaN
                Y = X
            ENDIF
C
C           Copy result to output array
C
            CALL MXCOPYREAL8TOPTR(Y,PY,1)
C
C           Increment pointers
C
            PX = PX + 8
            PY = PY + 8
         ENDDO
      ELSE
         DO I = 1, N
C
C           Pick up one element of the input
C
            CALL MXCOPYPTRTOREAL4(PX,SX,1)
C
C           Evaluate function, including NaN test
C
            IF (SX .GE. 1.D0 .AND.
     +          SX .LE. 23.D0 .AND.
     +          SX .EQ. AINT(SX)) THEN
                Y = GAM(INT(SX))
                CALL MXCOPYREAL4TOPTR(SNGL(Y),PY,1)
            ELSEIF (SX .EQ. SX) THEN
                Y = DGAMMA(DBLE(SX))
                CALL MXCOPYREAL4TOPTR(SNGL(Y),PY,1)
            ELSE
C               SX is single(NaN)
                CALL MXCOPYREAL4TOPTR(SX,PY,1)
            ENDIF
C
C           Increment pointers
C
            PX = PX + 4
            PY = PY + 4
         ENDDO
      ENDIF
      RETURN
      END
C
      DOUBLE PRECISION FUNCTION DGAMMA(X)
C----------------------------------------------------------------------
C
C This routine calculates the GAMMA function for a real argument X.
C   Computation is based on an algorithm outlined in reference 1.
C   The program uses rational functions that approximate the GAMMA
C   function to at least 20 significant decimal digits.  Coefficients
C   for the approximation over the interval (1,2) are unpublished.
C   Those for the approximation for X .GE. 12 are from reference 2.
C   The accuracy achieved depends on the arithmetic system, the
C   compiler, the intrinsic functions, and proper selection of the
C   machine-dependent constants.
C
C
C*******************************************************************
C*******************************************************************
C
C Explanation of machine-dependent constants
C
C beta   - radix for the floating-point representation
C maxexp - the smallest positive power of beta that overflows
C XBIG   - the largest argument for which GAMMA(X) is representable
C          in the machine, i.e., the solution to the equation
C                  GAMMA(XBIG) = beta**maxexp
C XINF   - the largest machine representable floating-point number;
C          approximately beta**maxexp
C EPS    - the smallest positive floating-point number such that
C          1.0+EPS .GT. 1.0
C XMININ - the smallest positive floating-point number such that
C          1/XMININ is machine representable
C
C     Approximate values for some important machines are:
C
C                            beta       maxexp        XBIG
C
C CRAY-1         (S.P.)        2         8191        966.961
C Cyber 180/855
C   under NOS    (S.P.)        2         1070        177.803
C IEEE (IBM/XT,
C   SUN, etc.)   (S.P.)        2          128        35.040
C IEEE (IBM/XT,
C   SUN, etc.)   (D.P.)        2         1024        171.624
C IBM 3033       (D.P.)       16           63        57.574
C VAX D-Format   (D.P.)        2          127        34.844
C VAX G-Format   (D.P.)        2         1023        171.489
C
C                            XINF         EPS        XMININ
C
C CRAY-1         (S.P.)   5.45E+2465   7.11E-15    1.84E-2466
C Cyber 180/855
C   under NOS    (S.P.)   1.26E+322    3.55E-15    3.14E-294
C IEEE (IBM/XT,
C   SUN, etc.)   (S.P.)   3.40E+38     1.19E-7     1.18E-38
C IEEE (IBM/XT,
C   SUN, etc.)   (D.P.)   1.79D+308    2.22D-16    2.23D-308
C IBM 3033       (D.P.)   7.23D+75     2.22D-16    1.39D-76
C VAX D-Format   (D.P.)   1.70D+38     1.39D-17    5.88D-39
C VAX G-Format   (D.P.)   8.98D+307    1.11D-16    1.12D-308
C
C*******************************************************************
C*******************************************************************
C
C Error returns
C
C  The program returns the value XINF for singularities or
C     when overflow would occur.  The computation is believed
C     to be free of underflow and overflow.
C
C MathWorks modifcation: Replace XINF by IEEE Infinity.
C
C  Intrinsic functions required are:
C
C     INT, DBLE, EXP, LOG, REAL, SIN
C
C
C References: "An Overview of Software Development for Special
C              Functions", W. J. Cody, Lecture Notes in Mathematics,
C              506, Numerical Analysis Dundee, 1975, G. A. Watson
C              (ed.), Springer Verlag, Berlin, 1976.
C
C              Computer Approximations, Hart, Et. Al., Wiley and
C              sons, New York, 1968.
C
C  Latest modification: October 12, 1989
C
C  Authors: W. J. Cody and L. Stoltz
C           Applied Mathematics Division
C           Argonne National Laboratory
C           Argonne, IL 60439
C
C----------------------------------------------------------------------
      INTEGER I,N
      LOGICAL PARITY
      DOUBLE PRECISION 
     1    C,CONV,EPS,FACT,HALF,ONE,P,PI,Q,RES,SQRTPI,SUM,TWELVE,
     2    TWO,X,XBIG,XDEN,XINF,XMININ,XNUM,Y,Y1,YSQ,Z,ZERO
      DIMENSION C(7),P(8),Q(8)





C----------------------------------------------------------------------
C  Mathematical constants
C----------------------------------------------------------------------
      DATA ONE,HALF,TWELVE,TWO,ZERO/1.0D0,0.5D0,12.0D0,2.0D0,0.0D0/,
     1     SQRTPI/0.9189385332046727417803297D0/,
     2     PI/3.1415926535897932384626434D0/
C----------------------------------------------------------------------
C  Machine dependent parameters
C----------------------------------------------------------------------
C     DATA XBIG,XMININ,EPS/171.624D0,2.23D-308,2.22D-16/,
C    1     XINF/1.79D308/
      DATA XBIG,XMININ,EPS/171.624D0,2.23D-308,2.22D-16/

      DATA XINF/'7FF0000000000000'X/

   
C----------------------------------------------------------------------
C  Numerator and denominator coefficients for rational minimax
C     approximation over (1,2).
C----------------------------------------------------------------------
      DATA P/-1.71618513886549492533811D+0,2.47656508055759199108314D+1,
     1       -3.79804256470945635097577D+2,6.29331155312818442661052D+2,
     2       8.66966202790413211295064D+2,-3.14512729688483675254357D+4,
     3       -3.61444134186911729807069D+4,6.64561438202405440627855D+4/
      DATA Q/-3.08402300119738975254353D+1,3.15350626979604161529144D+2,
     1      -1.01515636749021914166146D+3,-3.10777167157231109440444D+3,
     2        2.25381184209801510330112D+4,4.75584627752788110767815D+3,
     3      -1.34659959864969306392456D+5,-1.15132259675553483497211D+5/
C----------------------------------------------------------------------
C  Coefficients for minimax approximation over (12, INF).
C----------------------------------------------------------------------
      DATA C/-1.910444077728D-03,8.4171387781295D-04,
     1     -5.952379913043012D-04,7.93650793500350248D-04,
     2     -2.777777777777681622553D-03,8.333333333333333331554247D-02,
     3      5.7083835261D-03/

C----------------------------------------------------------------------
C  Statement functions for conversion between integer and float
C----------------------------------------------------------------------
      CONV(I) = DBLE(I)



      PARITY = .FALSE.
      FACT = ONE
      N = 0
      Y = X
      IF (Y .LE. ZERO) THEN
C----------------------------------------------------------------------
C  Argument is negative
C----------------------------------------------------------------------
            Y = -X
            Y1 = AINT(Y)
            RES = Y - Y1
            IF (RES .NE. ZERO) THEN
                  IF (Y1 .NE. AINT(Y1*HALF)*TWO) PARITY = .TRUE.
                  FACT = -PI / SIN(PI*RES)
                  Y = Y + ONE
               ELSE
                  RES = XINF
                  GO TO 900
            END IF
      END IF
C----------------------------------------------------------------------
C  Argument is positive
C----------------------------------------------------------------------
      IF (Y .LT. EPS) THEN
C----------------------------------------------------------------------
C  Argument .LT. EPS
C----------------------------------------------------------------------
            IF (Y .GE. XMININ) THEN
                  RES = ONE / Y
               ELSE
                  RES = XINF
                  GO TO 900
            END IF
         ELSE IF (Y .LT. TWELVE) THEN
            Y1 = Y
            IF (Y .LT. ONE) THEN
C----------------------------------------------------------------------
C  0.0 .LT. argument .LT. 1.0
C----------------------------------------------------------------------
                  Z = Y
                  Y = Y + ONE
               ELSE
C----------------------------------------------------------------------
C  1.0 .LT. argument .LT. 12.0, reduce argument if necessary
C----------------------------------------------------------------------
                  N = INT(Y) - 1
                  Y = Y - CONV(N)
                  Z = Y - ONE
            END IF
C----------------------------------------------------------------------
C  Evaluate approximation for 1.0 .LT. argument .LT. 2.0
C----------------------------------------------------------------------
            XNUM = ZERO
            XDEN = ONE
            DO 260 I = 1, 8
               XNUM = (XNUM + P(I)) * Z
               XDEN = XDEN * Z + Q(I)
  260       CONTINUE
            RES = XNUM / XDEN + ONE
            IF (Y1 .LT. Y) THEN
C----------------------------------------------------------------------
C  Adjust result for case  0.0 .LT. argument .LT. 1.0
C----------------------------------------------------------------------
                  RES = RES / Y1
               ELSE IF (Y1 .GT. Y) THEN
C----------------------------------------------------------------------
C  Adjust result for case  2.0 .LT. argument .LT. 12.0
C----------------------------------------------------------------------
                  DO 290 I = 1, N
                     RES = RES * Y
                     Y = Y + ONE
  290             CONTINUE
            END IF
         ELSE
C----------------------------------------------------------------------
C  Evaluate for argument .GE. 12.0,
C----------------------------------------------------------------------
            IF (Y .LE. XBIG) THEN
                  YSQ = Y * Y
                  SUM = C(7)
                  DO 350 I = 1, 6
                     SUM = SUM / YSQ + C(I)
  350             CONTINUE
                  SUM = SUM/Y - Y + SQRTPI
                  SUM = SUM + (Y-HALF)*LOG(Y)
                  RES = EXP(SUM)
               ELSE
                  RES = XINF
                  GO TO 900
            END IF
      END IF
C----------------------------------------------------------------------
C  Final adjustments and return
C----------------------------------------------------------------------
      IF (PARITY) RES = -RES
      IF (FACT .NE. ONE) RES = FACT / RES
  900 DGAMMA = RES
      RETURN
C ---------- Last line of GAMMA ----------
      END


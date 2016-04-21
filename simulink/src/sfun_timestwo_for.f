C
C File:  SFUN_TIMESTWO_FOR.F
C
C Abstract:
C     A sample Level 1 FORTRAN representation of a 
C     timestwo S-function.
C
C     The basic mex command for this example is:
C
C     >> mex sfun_timestwo_for.f simulink.f
C
C     Copyright 1990-2002 The MathWorks, Inc.
C
C     $Revision: 1.4 $
C
C=====================================================
C     Function:  SIZES
C       
C     Abstract:
C       Set the size vector.
C
C       SIZES returns a vector which determines model 
C       characteristics.  This vector contains the 
C       sizes of the state vector and other
C       parameters. More precisely,
C       SIZE(1)  number of continuous states
C       SIZE(2)  number of discrete states
C       SIZE(3)  number of outputs
C       SIZE(4)  number of inputs
C       SIZE(5)  number of discontinuous roots in 
C                the system
C       SIZE(6)  set to 1 if the system has direct 
C                feedthrough of its inputs, 
C                otherwise 0
C
C=====================================================
C
      SUBROUTINE SIZES(SIZE)
C     .. Array arguments ..
      INTEGER*4        SIZE(*)
C     .. Parameters ..
      INTEGER*4       NSIZES
      PARAMETER       (NSIZES=6)

      SIZE(1) = 0
      SIZE(2) = 0
      SIZE(3) = 1
      SIZE(4) = 1
      SIZE(5) = 0
      SIZE(6) = 1

      RETURN
      END

C
C=====================================================
C
C     Function:  OUTPUT
C
C     Abstract:  
C       Perform output calculations for continuous 
C       signals.
C
C=====================================================
C     .. Parameters ..
      SUBROUTINE OUTPUT(T, X, U, Y)
      REAL*8           T
      REAL*8           X(*), U(*), Y(*)

      Y(1) = U(1) * 2.0

      RETURN
      END

C
C=====================================================
C
C     Stubs for unused functions.
C
C=====================================================

      SUBROUTINE INITCOND(X0)
      REAL*8           X0(*)
C --- Nothing to do.
      RETURN
      END

      SUBROUTINE DERIVS(T, X, U, DX)
      REAL*8           T, X(*), U(*), DX(*)
C --- Nothing to do.
      RETURN
      END

      SUBROUTINE DSTATES(T, X, U, XNEW)
      REAL*8           T, X(*), U(*), XNEW(*)
C --- Nothing to do.
      RETURN
      END

      SUBROUTINE DOUTPUT(T, X, U, Y)
      REAL*8           T, X(*), U(*), Y(*)
C --- Nothing to do.
      RETURN
      END
      
      SUBROUTINE TSAMPL(T, X, U, TS, OFFSET)
      REAL*8           T,TS,OFFSET,X(*),U(*)
C --- Nothing to do.
      RETURN
      END
      
      SUBROUTINE SINGUL(T, X, U, SING)
      REAL*8           T, X(*), U(*), SING(*)
C --- Nothing to do.
      RETURN
      END

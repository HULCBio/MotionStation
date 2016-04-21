C=======================================================================
C     VDPMEX.F
C
C     $Revision: 1.11 $
C
C     This is a FORTRAN representation of the Van der Pol system.
C     It works in conjunction with the the file simulink.f.
C
C     To compile this system, use the syntax:
C          mex vdpmex.f simulink.f
C
C     Note, the .F files are designed to be passed through the C language 
C     preprocessor before passing them onto the fortran compiler. The
C     .f files are created from the .F files.
C     
C
C=======================================================================
C  Written:
C      Ned Gulley        Apr 28, 1992
C      Copyright 1990-2002 The MathWorks, Inc.
C=======================================================================
C
C=======================================================================
      SUBROUTINE SIZES(SIZE)
C     .. Array arguments ..
      INTEGER*4        SIZE(*)
C=======================================================================
C     Purpose:
C       Function to set size vector
C     Input arguments:
C       None
C     Output arguments:
C       SIZE     a vector of model sizes
C     Description:
C       Sizes returns a vector which determines model characteristics.
C       This vector contains the sizes of the state vector and other
C       parameters. More precisely,
C       SIZE(1)  number of continuous states
C       SIZE(2)  number of discrete states
C       SIZE(3)  number of outputs
C       SIZE(4)  number of inputs
C       SIZE(5)  number of discontinuous roots in the system
C       SIZE(6)  set to 1 if the system has direct feedthrough of its
C                inputs, otherwise 0
C=======================================================================
C     .. Parameters ..
      INTEGER*4       NSIZES
      PARAMETER       (NSIZES=6)
C     .. Local scalars ..
C     .. Local arrays ..
C     .. Executable statements ..
      SIZE(1) = 2
      SIZE(2) = 0
      SIZE(3) = 1
      SIZE(4) = 0
      SIZE(5) = 0
      SIZE(6) = 0

      RETURN
      END

      SUBROUTINE INITCOND(X0)
C     .. Array arguments ..
      REAL*8           X0(*)
C=======================================================================
C     Purpose:
C       Function to set initial condition vector
C     Input arguments:
C       None
C     Output arguments:
C       X0       a vector of initial conditions
C=======================================================================
C     .. Local scalars ..
C     .. Local arrays ..
C     .. Executable statements ..
      X0(1) = 2.00
      X0(2) = 0.00

      RETURN
      END

      SUBROUTINE DERIVS(T, X, U, DX)
C     .. Scalar arguments ..
      REAL*8           T
C     .. Array arguments ..
      REAL*8           X(*), U(*), DX(*)
C=======================================================================
C     Purpose:
C       Function to return derivatives
C     Input arguments:
C       T        time
C       X        state vector
C       U        input vector
C     Output arguments:
C       DX       state vector derivatives
C     Remark:
C       The state vector is partitioned into continuous and discrete
C       states. The first states contain the continuous states, and
C       the last states contain the discrete states.
C=======================================================================
C     .. Local scalars ..
C     .. Local arrays ..
C     .. Executable statements ..
      DX(2) = X(2)*(1 - X(1)*X(1)) - X(1)
      DX(1) = X(2)

      RETURN
      END

      SUBROUTINE DSTATES(T, X, U, XNEW)
C     .. Scalar arguments ..
      REAL*8           T
C     .. Array arguments ..
      REAL*8           X(*), U(*), XNEW(*)
C=======================================================================
C     Purpose:
C       Function to perform discrete state update
C     Input arguments:
C       T        time
C       X        state vector
C       U        input vector
C     Output arguments:
C       XNEW     next state values
C     Remark:
C       The state vector is partitioned into continuous and discrete
C       states. The first states contain the continuous states, and
C       the last states contain the discrete states.
C=======================================================================
C     .. Local scalars ..
C     .. Local arrays ..
C     .. Executable statements ..
      
      RETURN
      END

      SUBROUTINE OUTPUT(T, X, U, Y)
C     .. Scalar arguments ..
      REAL*8           T
C     .. Array arguments ..
      REAL*8           X(*), U(*), Y(*)
C=======================================================================
C     Purpose:
C       Function to return continuous outputs
C     Input arguments:
C       T        time
C       X        state vector
C       U        input vector
C     Output arguments:
C       Y        output vector
C     Remark:
C       The state vector is partitioned into continuous and discrete
C       states. The first states contain the continuous states, and
C       the last states contain the discrete states.
C=======================================================================
C     .. Local scalars ..
C     .. Local arrays ..
C     .. Executable statements ..

      Y(1) = X(1)

      RETURN
      END
      
      SUBROUTINE DOUTPUT(T, X, U, Y)
C     .. Scalar arguments ..
      REAL*8           T
C     .. Array arguments ..
      REAL*8           X(*), U(*), Y(*)
C=======================================================================
C     Purpose:
C       Function to return discrete outputs
C     Input arguments:
C       T        time
C       X        state vector
C       U        input vector
C     Output arguments:
C       Y        output vector
C     Remark:
C       The state vector is partitioned into continuous and discrete
C       states. The first states contain the continuous states, and
C       the last states contain the discrete states.
C       This procedure is called only if it is a sample hit.
C=======================================================================
C     .. Local scalars ..
C     .. Local arrays ..
C     .. Executable statements ..
      
      RETURN
      END
      
      SUBROUTINE TSAMPL(T, X, U, TS, OFFSET)
C     .. Scalar arguments ..
      REAL*8           T,TS,OFFSET
C     .. Array arguments ..
      REAL*8           X(*), U(*)
C=======================================================================
C     Purpose:
C       Function to return the sample and offset times
C     Input arguments:
C       T        time
C       X        state vector
C       U        input vector
C     Output arguments:
C       TS       sample time
C       OFFSET   offset time
C=======================================================================
C     .. Local scalars ..
C     .. Local arrays ..
C     .. Executable statements ..
      
      RETURN
      END
      
      
      SUBROUTINE SINGUL(T, X, U, SING)
C     .. Scalar arguments ..
      REAL*8           T
C     .. Array arguments ..
      REAL*8           X(*), U(*), SING(*)
C=======================================================================
C     Purpose:
C       Function to return singularities
C     Input arguments:
C       T        time
C       X        state vector
C       U        input vector
C     Output arguments:
C       SING     singularities
C=======================================================================
C     .. Local scalars ..
C     .. Local arrays ..
C     .. Executable statements ..

      RETURN
      END






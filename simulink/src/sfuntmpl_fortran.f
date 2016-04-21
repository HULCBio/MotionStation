C
C File:  sfuntmpl_fortran.f
C
C Abstract:
C     A template for writing Level 1 FORTRAN S-functions.
C     This file can be compiled and run in Simulink --
C     it will merely pass the input to the output.
C
C     The basic mex command for building this S-function is:
C
C      >> mex sfuntmpl_fortran.f simulink.f
C
C     Copyright 1990-2002 The MathWorks, Inc.
C
C     $Revision: 1.4 $
C
C
C=====================================================
C     Subroutine:  SIZES
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
C       SIZE(6)  Direct feedthrough flag (1=yes, 0=no).
C                A port has direct feedthrough if the input is used in either
C                the OUTPUT or TNEXT (see simulink.f).
C                See matlabroot/simulink/src/sfuntmpl_directfeed.txt.
C
C=======================================================================
      SUBROUTINE SIZES(SIZE)
      INTEGER*4  SIZE(*)
      INTEGER*4  NSIZES
      PARAMETER (NSIZES=6)

      SIZE(1) = 0
      SIZE(2) = 0
      SIZE(3) = 1
      SIZE(4) = 1
      SIZE(5) = 0
      SIZE(6) = 1

      RETURN
      END

C=======================================================================
C     Subroutine: INITCOND
C       
C     Abstract:
C       Function to set initial condition vector
C     Input arguments:
C       None
C     Output arguments:
C       X0       a vector of initial conditions
C=======================================================================
      SUBROUTINE INITCOND(X0)
      REAL*8 X0(*)

      RETURN
      END

C=======================================================================
C     Subroutine:  DERIVS
C       
C     Abstract:
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
      SUBROUTINE DERIVS(T, X, U, DX)
      REAL*8 T
      REAL*8 X(*), U(*), DX(*)

      RETURN
      END


C=======================================================================
C     Subroutine:  OUTPUT
C       
C     Abstract:
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
      SUBROUTINE OUTPUT(T, X, U, Y)
      REAL*8           T
      REAL*8           X(*), U(*), Y(*)

      Y(1) = U(1)

      RETURN
      END

      
C=======================================================================
C     Subroutine:  DSTATES
C       
C     Abstract:
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
      SUBROUTINE DSTATES(T, X, U, XNEW)
      REAL*8 T
      REAL*8 X(*), U(*), XNEW(*)
      
      RETURN
      END


C=======================================================================
C     Subroutine:  DOUTPUT
C       
C     Abstract:
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
      SUBROUTINE DOUTPUT(T, X, U, Y)
      REAL*8 T
      REAL*8 X(*), U(*), Y(*)
      RETURN
      END
      

C=======================================================================
C     Subroutine:  TSAMPL
C       
C     Abstract:
C       Function to return the sample and offset times
C     Input arguments:
C       T        time
C       X        state vector
C       U        input vector
C     Output arguments:
C       TS       sample time
C       OFFSET   offset time
C=======================================================================
      SUBROUTINE TSAMPL(T, X, U, TS, OFFSET)
      REAL*8           T,TS,OFFSET
      REAL*8           X(*), U(*)

      TS     = 0.0
      OFFSET = 0.0
      
      RETURN
      END
      
      
C=======================================================================
C     Subroutine:  TSINGUL
C       
C     Abstract:
C       Function to return singularities
C     Input arguments:
C       T        time
C       X        state vector
C       U        input vector
C     Output arguments:
C       SING     singularities
C=======================================================================
      SUBROUTINE SINGUL(T, X, U, SING)
      REAL*8 T
      REAL*8 X(*), U(*), SING(*)

      RETURN
      END

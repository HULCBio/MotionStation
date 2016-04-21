C The actual YPRIME subroutine in FORTRAN
C
C Copyright 1984-2000 The MathWorks, Inc.
C $Revision: 1.4 $
C

      SUBROUTINE YPRIME(YP, T, Y)
      REAL*8 YP(4), T, Y(4)

      REAL*8 MU, MUS, R1, R2
      
      MU = 1.0/82.45
      MUS = 1.0 - MU

      R1 = SQRT((Y(1)+MU)**2 + Y(3)**2)
      R2 = SQRT((Y(1)-MUS)**2 + Y(3)**2)

      YP(1) = Y(2)
      YP(2) = 2*Y(4) + Y(1) - MUS*(Y(1)+MU)/(R1**3) - 
     & MU*(Y(1)-MUS)/(R2**3)

      YP(3) = Y(4)
      YP(4) = -2*Y(2) + Y(3) - MUS*Y(3)/(R1**3) - 
     & MU*Y(3)/(R2**3)

      RETURN
      END


      SUBROUTINE Atmos(alt, sigma, delta, theta)
C
C Calculation of the 1976 standard atmosphere to 86 km.
C This is used to show how to interface Simulink to an
C existing Fortran subroutine.
C
C Copyright 1990-2002 The MathWorks, Inc.
C
C $Revision: 1.4 $
C
      IMPLICIT NONE

C --- I/O variables

      REAL alt
      REAL sigma
      REAL delta
      REAL theta

C --- Local variables

      INTEGER i,j,k     
      REAL h            
      REAL tgrad, tbase 
      REAL tlocal       
      REAL deltah       
      REAL REARTH, GMR

C --- Initialize values for 1976 atmosphere

      DATA REARTH /6369.0/    ! earth radius (km)
      DATA GMR    /34.163195/ ! gas constant

      REAL htab(8), ttab(8), ptab(8), gtab(8)
      DATA htab /0.0, 11.0, 20.0, 32.0, 47.0, 51.0, 71.0, 84.852/
      DATA ttab /288.15, 216.65, 216.65, 228.65, 270.65, 270.65,
     &           214.65, 186.946/
      DATA ptab /1.0, 2.233611E-1, 5.403295E-2, 8.5666784E-3,
     &           1.0945601E-3, 6.6063531E-4, 3.9046834E-5, 3.68501E-6/
      DATA gtab /-6.5, 0.0, 1.0, 2.8, 0.0, -2.8, -2.0, 0.0/

C --- Convert geometric to geopotential altitude

      h=alt*REARTH/(alt+REARTH)

C --- Binary search for altitude interval
      i = 1
      j = 8

 100  k=(i+j)/2
      IF (h .lt. htab(k)) THEN
        j = k
      ELSE
        i = k
      END IF
      IF (j .le. i+1) GOTO 110
      GO TO 100
 110  CONTINUE

C --- Calculate local temperature

      tgrad  = gtab(i)
      tbase  = ttab(i)
      deltah = h - htab(i)
      tlocal = tbase + tgrad*deltah
      theta  = tlocal/ttab(1)

C --- Calculate local pressure

      IF (tgrad .eq. 0.0) THEN
        delta = ptab(i)*EXP(-GMR*deltah/tbase)
      ELSE
        delta = ptab(i)*(tbase/tlocal)**(GMR/tgrad)
      END IF

C --- Calculate local density

      sigma = delta/theta

      RETURN
      END

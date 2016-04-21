## Copyright (C) 1997, 2000, 2004, 2005, 2006, 2007 Kai P. Mueller
##
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{sys} =} Boeing707 ()
## Creates a linearized state-space model of a Boeing 707-321 aircraft
## at @var{v}=80 m/s 
## @iftex
## @tex
## ($M = 0.26$, $G_{a0} = -3^{\\circ}$, ${\\alpha}_0 = 4^{\\circ}$, ${\\kappa}= 50^{\\circ}$).
## @end tex
## @end iftex
## @ifnottex
## (@var{M} = 0.26, @var{Ga0} = -3 deg, @var{alpha0} = 4 deg, @var{kappa} = 50 deg).
## @end ifnottex
##
## System inputs: (1) thrust and (2) elevator angle.
##
## System outputs:  (1) airspeed and (2) pitch angle.
##
## @strong{Reference}: R. Brockhaus: @cite{Flugregelung} (Flight
## Control), Springer, 1994.
## @end deftypefn

## Author: Kai P. Mueller <mueller@ifr.ing.tu-bs.de>
## Created: September 28, 1997

function outsys = Boeing707 ()

  if (nargin != 0)
    print_usage ();
  endif

  a = [-0.46E-01,            0.10681415316, 0.0,   -0.17121680433;
       -0.1675901504661613, -0.515,         1.0,    0.6420630320636088E-02;
        0.1543104215347786, -0.547945,     -0.906, -0.1521689385990753E-02;
        0.0,                 0.0,           1.0,    0.0];

  b = [0.1602300107479095,      0.2111848453E-02;
       0.8196877780963616E-02, -0.3025E-01;
       0.9173594317692437E-01, -0.75283075;
       0.0,                     0.0];

  c = [1.0, 0.0, 0.0, 0.0;
       0.0, 0.0, 0.0, 1.0];

  d = zeros (2, 2);

  inam = {"thrust"; "rudder"};
  onam = {"speed"; "pitch"};
  ## snam = {"x1"; "x2"; "x3"; "x4"};

  outsys = ss (a, b, c, d, "inname", inam, "outname", onam);

endfunction

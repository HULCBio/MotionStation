## Copyright (C) 1998, 1999, 2000, 2002, 2005, 2006, 2007 Auburn University
## Copyright (C) 2010, 2011   Lukas F. Reichlin
##
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {[@var{axis}, @var{angle}] =} q2rot (@var{q})
## Extract vector/angle form of a unit quaternion @var{q}.
##
## @strong{Inputs}
## @table @var
## @item q
## Unit quaternion describing the rotation.
## @end table
##
## @strong{Outputs}
## @table @var
## @item axis
## Eigenaxis as a 3-d unit vector @code{[x, y, z]}.
## @item angle
## Rotation angle in radians.  The positive direction is
## determined by the right-hand rule applied to @var{axis}.
## @end table
##
## @strong{Example}
## @example
## @group
## octave:1> axis = [0, 0, 1]
## axis =
##    0   0   1
## octave:2> angle = pi/4
## angle =  0.78540
## octave:3> q = rot2q (axis, angle)
## q = 0.9239 + 0i + 0j + 0.3827k
## octave:4> [vv, th] = q2rot (q)
## vv =
##    0   0   1
## th =  0.78540
## octave:5> theta = th*180/pi
## theta =  45.000
## octave:6> 
## @end group
## @end example
##
## @end deftypefn

## Adapted from: quaternion by A. S. Hodel <a.s.hodel@eng.auburn.edu>
## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: May 2010
## Version: 0.1

function [vv, theta] = q2rot (q)

  if (nargin != 1 || nargout != 2)
    print_usage ();
  endif

  if (! isa (q, "quaternion") || ! isscalar (q.w))
    error ("q2rot: require scalar quaternion as input");
  endif

  if (abs (norm (q) - 1) > 1e-12)
    warning ("q2rot: ||q||=%e, setting=1 for vv, theta", norm (q));
    q = unit (q);
  endif

  s = q.s;
  vv = [q.x, q.y, q.z];

  theta = acos (s) * 2;

  if (abs (theta) > pi)
    theta = theta - sign (theta) * pi;
  endif

  sin_th_2 = norm (vv);

  if (sin_th_2 != 0)
    vv ./= sin_th_2;
  endif

endfunction
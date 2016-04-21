## Copyright (C) 2010, 2011, 2012   Lukas F. Reichlin
## Copyright (c) 2011 Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
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
## Power operator of quaternions.  Used by Octave for "q.^x".
## Exponent x can be scalar or of appropriate size.

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: May 2010
## Version: 0.4

function a = power (a, b)

  if (nargin != 2)
    error ("quaternion: power: this is a binary operator");
  endif

  if (isa (b, "quaternion"))          # exponent is a quaternion
    a = exp (log (a) .* b);           # a could be real, but log doesn't care
  elseif (! isreal (b))
    error ("quaternion:invalidArgument", "quaternion: power: invalid exponent");
  elseif (b == -1)                    # special case for ldivide and rdivide
    norm2 = norm2 (a);                # a is quaternion because b is not,
    a.w = a.w ./ norm2;               # otherwise octave wouldn't call
    a.x = -a.x ./ norm2;              # quaternion's power operator.
    a.y = -a.y ./ norm2;
    a.z = -a.z ./ norm2;
  else                                # exponent is real
    na = abs (a);
    nv = normv (a);
    th = acos (a.w ./ na);
    nab = na.^b;
    snt = sin (b.*th);
    a.w = nab .* cos (b.*th);
    a.x = (a.x ./ nv) .* nab .* snt;
    a.y = (a.y ./ nv) .* nab .* snt;
    a.z = (a.z ./ nv) .* nab .* snt;
  endif

endfunction

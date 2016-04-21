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
## Matrix power operator of quaternions.  Used by Octave for "q^x".

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: May 2010
## Version: 0.2

function q = mpower (a, b)

  if (nargin != 2)
    error ("quaternion: mpower: this is a binary operator");
  endif

  [r, c] = size (a);
  
  if (r != c)
    error ("quaternion: mpower: quaternion matrix must be square");
  endif
  
  if (r == 1 && c == 1)                 # a scalar, b?
    q = a .^ b;                         # b could be a quaternion
  elseif (is_real_array (b) && isscalar (b) && fix (b) == b)
    e = fix (abs (b));
    switch (sign (b))
      case -1                           # q^-e
        a = inv (a);
        q = a;
      case 0                            # q^0
        q = eye (r);                    # alternative: q = quaternion (eye (r))
        return;
      case 1;                           # q^e
        q = a;
    endswitch  
    for k = 2 : e
      q *= a;                           # improvement?: q^8 = ((q^2)^2)^2, q^9 = (((q^2)^2)^2)*q
    endfor
  else
    error ("quaternion: mpower: case not implemented yet");
    q = expm (logm (a) * b);            # don't know whether this formula is correct
  endif

  ## TODO: - q1 ^ q2
  ##       - arrays

endfunction

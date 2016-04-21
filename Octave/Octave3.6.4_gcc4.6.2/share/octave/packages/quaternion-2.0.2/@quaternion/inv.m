## Copyright (C) 2010, 2011, 2012   Lukas F. Reichlin
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
## @deftypefn {Function File} {@var{qinv} =} inv (@var{q})
## Return inverse of a quaternion.
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: May 2010
## Version: 0.3

function a = inv (a)

  if (nargin != 1)
    print_usage ();
  endif

  if (isscalar (a.w))
    norm2 = norm2 (a);
    a.w = a.w / norm2;
    a.x = -a.x / norm2;
    a.y = -a.y / norm2;
    a.z = -a.z / norm2;
  elseif (issquare (a.w))
    ## blockwise inversion, use recursion
    ## the formula is well-known from linear algebra
    n = rows (a);       # a is square
    m1 = fix (n/2);
    m2 = m1 + 1;

    A = subsref (a, substruct ("()", {1:m1, 1:m1}));
    B = subsref (a, substruct ("()", {1:m1, m2:n}));
    C = subsref (a, substruct ("()", {m2:n, 1:m1}));
    D = subsref (a, substruct ("()", {m2:n, m2:n}));

    iA = inv (A);
    iAB = iA * B;
    CiA = C * iA;
    X = inv (D - C * iAB);
    Y = X * CiA;
    
    a = [iA + iAB*Y, -iAB*X;
                 -Y,      X];
  else
    error ("quaternion: inv: require square matrices of quaternions");
  endif

endfunction

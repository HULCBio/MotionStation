## Copyright (C) 2010, 2012   Lukas F. Reichlin
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
## @deftypefn {Function File} {@var{q} =} diag (@var{v})
## @deftypefnx {Function File} {@var{q} =} diag (@var{v}, @var{k})
## Return a diagonal quaternion matrix with quaternion vector V on diagonal K.
## The second argument is optional. If it is positive,
## the vector is placed on the K-th super-diagonal.
## If it is negative, it is placed on the -K-th sub-diagonal.
## The default value of K is 0, and the vector is placed
## on the main diagonal.
## Given a matrix argument, instead of a vector, @command{diag}
## extracts the @var{K}-th diagonal of the matrix.
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: May 2010
## Version: 0.2

function a = diag (a, b = 0)

  if (nargin == 0 || nargin > 2)
    print_usage ();
  endif

  a.w = diag (a.w, b);
  a.x = diag (a.x, b);
  a.y = diag (a.y, b);
  a.z = diag (a.z, b);

endfunction


%!shared R, S, T, U
%! Q = quaternion (2, 3, 4, 5);
%! R = diag ([Q, Q, Q]);
%! W = diag ([2, 2, 2]);
%! X = diag ([3, 3, 3]);
%! Y = diag ([4, 4, 4]);
%! Z = diag ([5, 5, 5]);
%! S = quaternion (W, X, Y, Z);
%! T = diag (R);
%! U = [Q; Q; Q];
%!assert (R == S);
%!assert (T == U);

## Copyright (C) 2012 Benjamin Lewis <benjf5@gmail.com>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{a} =} cubicwgt (@var{series})
##
## Returns the input series, windowed by a polynomial similar to a Hanning
## window.  To window an arbitrary section of the series, subtract or add an
## offset to it to adjust the centre of the window; for an offset of k, the call
## would be cubicwgt (@var{s} - k).  Similarly, the radius of the window is 1;
## if an arbitrary radius r is desired, dividing the series by the radius after
## centering is the best way to adjust to fit the window: cubicwgt ((@var{s} -
## k) / r).
##
## The windowing function itself is:
## w = 1 + ( x ^ 2 * ( 2 x - 3 ) ), x in [-1,1], else w = 0.
##
## @end deftypefn

function a = cubicwgt (s) 

  if (nargin != 1)
     print_usage ();
  endif

  ## s is the value/vector/matrix to be windowed
  a = abs (s);
  a = ifelse ((a < 1), 1 + ((a .^ 2) .* (2 .* a - 3)), 0);

endfunction


%!shared h, m, k
%! h = 2;
%! m = 0.01;
%! k = [0, 3, 1.5, -1, -0.5, -0.25, 0.75];
%!assert (cubicwgt (h), 0 );
%!assert (cubicwgt (m), 1 + m ^ 2 * (2 * m - 3));
%!assert (cubicwgt (k), [1.00000, 0.00000, 0.00000, 0.00000, ...
%!                       0.50000, 0.84375, 0.15625], 1e-6); 
%! ## Tests cubicwgt on two scalars and two vectors; cubicwgt will work
%! ## on any array input. 

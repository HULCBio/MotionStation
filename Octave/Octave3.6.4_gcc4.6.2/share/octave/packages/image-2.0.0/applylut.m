## Copyright (C) 2004 Josep Mones i Teixidor <jmones@puntbarra.com>
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
## @deftypefn {Function File} {@var{A} =} applylut (@var{BW}, @var{LUT})
## Uses lookup tables to perform a neighbour operation on binary images.
##
## A = applylut(BW,LUT) returns the result of a neighbour operation
## using the lookup table @var{LUT} which can be created by makelut.
##
## It first computes a matrix with the index of each element in the
## lookup table. To do this, it convolves the original matrix with a
## matrix which assigns each of the neighbours a bit in the resulting
## index. Then @var{LUT} is accessed to compute the result.
##
## @seealso{makelut}
## @end deftypefn

function A = applylut (BW, LUT)
  if (nargin != 2)
    print_usage;
  endif

  nq=log2(length(LUT));
  n=sqrt(nq);
  if (floor(n)!=n)
    error ("applylut: LUT length is not as expected. Use makelut to create it.");
  endif
  w=reshape(2.^[nq-1:-1:0],n,n);
  A=LUT(filter2(w,BW)+1);
endfunction

%!demo
%! lut = makelut (inline ('sum (x (:)) >= 3', 'x'), 3);
%! S = applylut (eye (5), lut);
%! disp (S)
%! ## Everything should be 0 despite a diagonal which doesn't reach borders.

%!assert(prod(applylut(eye(3),makelut(inline('x(1,1)==1','x'),2))==eye(3))==1); % 2-by-2 test
%!assert(prod(applylut(eye(3),makelut(inline('x(2,2)==1','x'),3))==eye(3))==1); % 3-by-3 test
%!assert(prod(applylut(eye(3),makelut(inline('x(3,3)==1','x'),3))== \
%!              applylut(eye(3),makelut(inline('x(2,2)==1','x'),2)))==1);

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
## @deftypefn {Function File} {@var{lut} =} makelut (@var{fun}, @var{n})
## @deftypefnx {Function File} {@var{lut} =} makelut (@var{fun}, @var{n}, @var{P1}, @var{P2}, @dots{})
## Create a lookup table which can be used by applylut.
##
## lut = makelut(fun,n) returns a vector which can be used by applylut
## as a lookup table. 
##
## @var{fun} can be a function object as created by inline, or simply a
## string which contains the name of a function. @var{fun} should accept a
## @var{n}-by-@var{n} matrix whose elements are binary (0 or 1) and
## returns an scalar (actually anything suitable to be included in a
## vector).
##
## makelut calls @var{fun} with all possible matrices and builds a
## vector with its result, suitable to be used by applylut. The length
## of this vector is 2^(@var{n}^2), so 16 for 2-by-2 and 512 for 3-by-3.
##
## makelut also passes parameters @var{P1}, @var{P2}, .... to @var{fun}.
##
## @seealso{applylut}
## @end deftypefn

function lut = makelut (fun, n, varargin)
  if (nargin < 2)
    print_usage;
  elseif (n < 2)
    error ("makelut: n should be a natural number >= 2");
  endif

  nq=n^2;
  c=2^nq;
  lut=zeros(c,1);
  w=reshape(2.^[nq-1:-1:0],n,n);
  for i=0:c-1
    idx=bitand(w,i)>0;
    lut(i+1)= feval(fun, idx, varargin{:});
  endfor
endfunction

%!demo
%! makelut(inline('sum(x(:))>=3','x'), 2)
%! % Returns '1' if one or more values
%! % in the input matrix are 1

%!assert(prod(makelut(inline('sum(x(:))==2','x'),2)==makelut(inline('sum(x(:))==a*b*c*d','x','a','b','c','d'),2,2/(3*4*5),3,4,5))); # test multiple params
%!assert(prod(makelut(inline('x(1,1)==1','x'),2)==[zeros(2^3,1);ones(2^3,1)])==1); # test 2-by-2
%!assert(prod(makelut(inline('x(1,1)==1','x'),3)==[zeros(2^8,1);ones(2^8,1)])==1); # test 3-by-3
%!assert(prod(makelut(inline('x(1,1)==1','x'),4)==[zeros(2^15,1);ones(2^15,1)])==1); # test 4-by-4
%!assert(prod(makelut(inline('x(2,1)==1','x'),3)==[zeros(2^7,1);ones(2^7,1);zeros(2^7,1);ones(2^7,1)])==1); # another test for 3-by-3

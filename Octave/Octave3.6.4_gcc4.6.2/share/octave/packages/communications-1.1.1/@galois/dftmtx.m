## Copyright (C) 2002 David Bateman
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
## @deftypefn {Function File} {@var{d} = } dftmtx (@var{a})
##
## Form a matrix, that can be used to perform Fourier transforms in
## a Galois Field.
##
## Given that @var{a} is an element of the Galois Field GF(2^m), and
## that the minimum value for @var{k} for which @code{@var{a} ^ @var{k}} 
## is equal to one is @code{2^m - 1}, then this function produces a 
## @var{k}-by-@var{k} matrix representing the discrete Fourier transform    
## over a Galois Field with respect to @var{a}. The Fourier transform of
## a column vector is then given by @code{dftmtx(@var{a}) * @var{x}}.
##
## The inverse Fourier transform is given by @code{dftmtx(1/@var{a})}
## @end deftypefn

function d = dftmtx(a)

  if (nargin != 1)
    error ("usage: d = dftmtx (a)");
  endif
    
  if (!isgalois(a))
    error("dftmtx: argument must be a galois variable");
  endif

  m = a.m;
  prim = a.prim_poly;
  n = 2^a.m - 1;
  if (n > 255)
    error ([ "dftmtx: argument must be in Galois Field GF(2^m), where" ...
           " m is not greater than 8"]); 
  endif

  if (length(a) ~= 1)
    error ("dftmtx: argument must be a scalar");
  endif

  mp = minpol(a);
  if ((mp(1) ~= 1) || !isprimitive(mp))
    error("dftmtx: argument must be a primitive nth root of unity");
  endif
  
  step = log(a);
  step = step.x;
  row = exp(gf([0:n-1], m, prim));
  d = zeros(n);
  for i=1:n;
    d(i,:) = row .^ mod(step*(i-1),n);
  end
  
endfunction

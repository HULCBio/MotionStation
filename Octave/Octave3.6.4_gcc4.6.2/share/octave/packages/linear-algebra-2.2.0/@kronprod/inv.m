## Copyright (C) 2010  Soren Hauberg
## 
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3, or (at your option)
## any later version.
## 
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details. 
## 
## You should have received a copy of the GNU General Public License
## along with this file.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} inv (@var{KP})
## Return the inverse of the Kronecker product @var{KP}.
##
## If @var{KP} is the Kronecker product of two square matrices @var{A} and @var{B},
## the inverse will be computed as the Kronecker product of the inverse of
## @var{A} and @var{B}.
##
## If @var{KP} is square but not a Kronecker product of square matrices, the
## inverse will be computed using the SVD
## @seealso{@@kronprod/sparse}
## @end deftypefn

function retval = inv (KP)
  ## Check input
  if (nargin != 1)
    print_usage ();
  endif
  
  if (!isa (KP, "kronprod"))
    error ("inv: input argument must be of class 'kronprod'");
  endif
  
  ## Do the computations
  [n, m] = size (KP.A);
  [q, r] = size (KP.B);
  if (n == m && q == r) # A and B are both square
    retval = kronprod (inv (KP.A), inv (KP.B));
  elseif (n*q == m*r) # kron (A, B) is square
    ## We use the SVD to compute the inverse.
    ## XXX: Should we use 'eig' instead?
    [U, S, V] = svd (KP);
    retval = U * (1./S) * V';
  else
    error ("inv: argument must be a square matrix");
  endif
endfunction

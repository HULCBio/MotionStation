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
## @deftypefn {Function File} det (@var{KP})
## Compute the determinant of a Kronecker product.
##
## If @var{KP} is the Kronecker product of the @var{n}-by-@var{n} matrix @var{A}
## and the @var{q}-by-@var{q} matrix @var{B}, then the determinant is computed
## as
##
## @example
## det (@var{A})^q * det (@var{B})^n
## @end example
##
## If @var{KP} is not a Kronecker product of square matrices the determinant is
## computed by forming the full matrix and then computing the determinant.
## @seealso{det, @@kronprod/trace, @@kronprod/rank, @@kronprod/full}
## @end deftypefn

function retval = det (KP)
  ## Check input
  if (nargin != 1)
    print_usage ();
  endif
  
  if (!isa (KP, "kronprod"))
    error ("det: input argument must be of class 'kronprod'");
  endif

  if (!issquare (KP))
    error ("det: argument must be a square matrix");
  endif

  ## Take action
  [n, m] = size (KP.A);
  [q, r] = size (KP.B);
  if (n == m && q == r) # A and B are both square
    retval = (det (KP.A)^q) * (det (KP.B)^n);
  elseif (n*q == m*r) # kron (A, B) is square
    ## XXX: Can we do something smarter here? We should be able to use the SVD...
    retval = det (full (KP));
  endif
endfunction

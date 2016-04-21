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
## @deftypefn {Function File} kronprod (@var{A}, @var{B})
## @deftypefnx{Function File} kronprod (@var{A}, @var{B}, @var{P})
## Construct a Kronecker product object.
## XXX: Write proper documentation
##
## With two input arguments, the following matrix is represented: kron (A, B);
##
## With three input arguments, the following matrix is represented: P * kron (A, B) * P'
## (P must be a permutation matrix)
##
## @end deftypefn

function retval = kronprod (A, B, P)
  if (nargin == 0)
    KP.A = KP.B = KP.P = [];
  elseif (nargin == 2 && ismatrix (A) && ismatrix (B))
    KP.A = A;
    KP.B = B;
    KP.P = [];
  elseif (nargin == 3 && ismatrix (A) && ismatrix (B))
#          && strcmp (typeinfo (P), "permutation matrix"))
    ## XXX: Check that the size of P is correct
    KP.A = A;
    KP.B = B;
    KP.P = P;
  else
    print_usage ();
  endif
  
  retval = class (KP, "kronprod");
endfunction

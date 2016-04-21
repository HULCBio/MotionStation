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
## @deftypefn {Function File} times (@var{KP})
## XXX: Write documentation
## @end deftypefn

function retval = times (M1, M2)
  ## Check input
  if (nargin == 0)
    print_usage ();
  elseif (nargin == 1)
    ## This seems to be what happens for full and sparse matrices, so we copy this behaviour
    retval = M1;
    return;
  endif
  
  if (!ismatrix (M1) || !ismatrix (M2))
    error ("times: input arguments must be matrices");
  endif
  
  if (!size_equal (M1, M2))
    error ("times: nonconformant arguments (op1 is %dx%d, op2 is %dx%d)",
           rows (M1), columns (M1), rows (M2), columns (M2));
  endif

  ## Take action depending on input types
  M1_is_KP = isa (M1, "kronprod");
  M2_is_KP = isa (M2, "kronprod");
  
  ## Product of Kronecker Products
  ## Check if the size match such that the result is a Kronecker Product
  if (M1_is_KP && M2_is_KP && size_equal (M1.A, M2.A) && size_equal (M1.B, M2.B))
    retval = kronprod (M1.A .* M2.A, M1.B .* M2.B);
  elseif (isscalar (M1) || isscalar (M2)) # Product of Kronecker Product and scalar
    retval = M1 * M2; ## Forward to mtimes.
  else # All other cases.
    ## Form the full matrix or sparse matrix of both matrices
    ## XXX: Can we do something smarter here?
    if (issparse (M1))
      M1 = sparse (M1);
    else
      M1 = full (M1);
    endif
    
    if (issparse (M2))
      M2 = sparse (M2);
    else
      M2 = full (M2);
    endif
    
    retval = M1 .* M2;
  endif
endfunction

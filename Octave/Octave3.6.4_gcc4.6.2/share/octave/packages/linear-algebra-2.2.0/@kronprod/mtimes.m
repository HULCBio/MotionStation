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
## @deftypefn {Function File} mtimes (@var{KP})
## XXX: Write documentation
## @end deftypefn

function retval = mtimes (M1, M2)
  ## Check input
  if (nargin == 0)
    print_usage ();
  elseif (nargin == 1)
    ## This seems to be what happens for full and sparse matrices, so we copy this behaviour
    retval = M1;
    return;
  endif
  
  if (!ismatrix (M1) || !ismatrix (M2))
    error ("mtimes: input arguments must be matrices");
  endif
  
  if (columns (M1) != rows (M2))
    error ("mtimes: nonconformant arguments (op1 is %dx%d, op2 is %dx%d)",
           rows (M1), columns (M1), rows (M2), columns (M2));
  endif

  ## Take action depending on input types
  M1_is_KP = isa (M1, "kronprod");
  M2_is_KP = isa (M2, "kronprod");
  
  if (M1_is_KP && M2_is_KP) # Product of Kronecker Products
    ## Check if the size match such that the result is a Kronecker Product
    if (columns (M1.A) == rows (M2.A) && columns (M1.B) == rows (M2.B))
      retval = kronprod (M1.A * M2.A, M1.B * M2.B);
    else
      ## Form the full matrix of the smallest matrix and use that to compute the
      ## final product
      ## XXX: Can we do something smarter here?
      numel1 = numel (M1);
      numel2 = numel (M2);
      if (numel1 < numel2)
        retval = full (M1) * M2;
      else
        retval = M1 * full (M2);
      endif
    endif
    
  elseif (M1_is_KP && isscalar (M2)) # Product of Kronecker Product and scalar
    if (numel (M1.A) < numel (M1.B))
      retval = kronprod (M2 * M1.A, M1.B);
    else
      retval = kronprod (M1.A, M2 * M1.B);
    endif
    
  elseif (M1_is_KP && ismatrix (M2)) # Product of Kronecker Product and Matrix
    retval = zeros (rows (M1), columns (M2));
    for n = 1:columns (M2)
      M = reshape (M2 (:, n), [columns(M1.B), columns(M1.A)]);
      retval (:, n) = vec (M1.B * M * M1.A');
    endfor
  
  elseif (isscalar (M1) && M2_is_KP) # Product of scalar and Kronecker Product
    if (numel (M2.A) < numel (M2.B))
      retval = kronprod (M1 * M2.A, M2.B);
    else
      retval = kronprod (M2.A, M1 * M2.B);
    endif
    
  elseif (ismatrix (M1) && M2_is_KP) # Product of Matrix and Kronecker Product
    retval = zeros (rows (M1), columns (M2));
    for n = 1:rows (M1)
      M = reshape (M1 (n, :), [rows(M2.B), rows(M2.A)]);
      retval (n, :) = vec (M2.B' * M * M2.A);
    endfor
      
  else
    error ("mtimes: internal error for 'kronprod'");
  endif
endfunction

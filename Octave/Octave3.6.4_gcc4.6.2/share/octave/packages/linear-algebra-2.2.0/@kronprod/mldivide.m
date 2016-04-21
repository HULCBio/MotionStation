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
## @deftypefn {Function File} mldivide (@var{M1}, @var{M2})
## XXX: Write documentation
## @end deftypefn

function retval = mldivide (M1, M2)
  ## Check input
  if (nargin != 2)
    print_usage ();
  endif
  
  if (!ismatrix (M1) || !ismatrix (M2))
    error ("mldivide: both input arguments must be matrices");
  endif
  
  if (rows (M1) != rows (M2))
    error ("mldivide: nonconformant arguments (op1 is %dx%d, op2 is %dx%d)",
           rows (M1), columns (M1), rows (M2), columns (M2));
  endif

  ## Take action depending on types
  M1_is_KP = isa (M1, "kronprod");
  M2_is_KP = isa (M2, "kronprod");
  
  if (M1_is_KP && M2_is_KP) # Left division of Kronecker Products
    error ("mldividide: this part not yet implemented as I'm lazy...");

  elseif (M1_is_KP) # Left division of Kronecker Product and Matrix
    ## XXX: Does this give the same minimum-norm solution as when using
    ## XXX:   full (M1) \ M2
    ## XXX: ? It is the same when M1 is invertible.
    retval = zeros (columns (M1), columns (M2));
    for n = 1:columns (M2)
      M = reshape (M2 (:, n), [rows(M1.B), rows(M1.A)]);
      retval (:, n) = vec ((M1.A \ (M1.B \ M)')');
    endfor

  elseif (M2_is_KP) # Left division of Matrix and Kronecker Product
    error ("mldividide: this part not yet implemented as I'm lazy...");
      
  else
    error ("mldivide: internal error for 'kronprod'");
  endif
endfunction

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
## @deftypefn {Function File} svd (@var{KP})
## XXX: Write documentation
## @end deftypefn

function [U, S, V] = svd (KP)
  if (nargin < 1)
    print_usage ();
  endif
  
  if (!isa (KP, "kronprod"))
    error ("svd: input must be of class 'kronprod'");
  endif
  
  ## XXX: I don't think this works properly for non-square A and B
  
  if (nargout <= 1)
    ## Only singular values were requested
    S_A = svd (KP.A);
    S_B = svd (KP.B);
    U = sort (kron (S_A, S_B), "descend");
  elseif (nargout == 3)
    ## The full SVD was requested
    [U_A, S_A, V_A] = svd (KP.A);
    [U_B, S_B, V_B] = svd (KP.B);

    ## Compute and sort singular values
    [sv, idx] = sort (kron (diag (S_A), diag (S_B)), "descend");
    
    ## Form matrices
    S = resize (diag (sv), [rows(KP), columns(KP)]);
    #Pu = eye (rows (KP)) (idx, :);
    U = kronprod (U_A, U_B, idx);
    #Pv = eye (columns (KP)) (idx, :);
    V = kronprod (V_A, V_B, idx);
  else
    print_usage ();
  endif
endfunction

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
## @deftypefn {Function File} {@var{lambda} =} eig (@var{KP})
## @deftypefnx{Function File} {[var{V}, @var{lambda}] =} eig (@var{KP})
## XXX: Write help text
## @seealso{eig, @kronprod/svd}
## @end deftypefn

function [V, lambda] = eig (KP, A)
  ## XXX: This implementation provides a different permutation of eigenvalues and
  ## eigenvectors compared to 'eig (full (KP))'

  ## Check input
  if (nargin == 0 || nargin > 2)
    print_usage ();
  endif
  
  if (!isa (KP, "kronprod"))
    error ("eig: first input argument must be of class 'kronprod'");
  endif
  
  if (!issquare (KP))
    error ("eig: first input must be a square matrix");
  endif
  
  ## Take action
  if (nargin == 1)
    if (nargout <= 1)
      ## Only eigenvalues were requested
      if (issquare (KP.A) && issquare (KP.B))
        lambda_A = eig (KP.A);
        lambda_B = eig (KP.B);
        V = kronprod (lambda_A, lambda_B);
      else
        ## We should be able to do this using SVD
        error ("eig not implemented (yet) for Kronecker products of non-square matrices");
      endif

    elseif (nargout == 2)
      ## Both eigenvectors and eigenvalues were requested
      if (issquare (KP.A) && issquare (KP.B))
        [V_A, lambda_A] = eig (KP.A);
        [V_B, lambda_B] = eig (KP.B);
        V = kronprod (V_A, V_B);
        lambda = kronprod (lambda_A, lambda_B);
      else
        ## We should be able to do this using SVD
        error ("eig not implemented (yet) for Kronecker products of non-square matrices");
      endif
    endif
    
  elseif (nargin == 2)
    ## Solve generalised eigenvalue problem
    ## XXX: Is there a fancy way of doing this?
    [V, lambda] = eig (full (KP), full (A));
  endif
endfunction

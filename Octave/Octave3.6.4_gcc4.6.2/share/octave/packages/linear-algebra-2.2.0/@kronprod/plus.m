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
## @deftypefn {Function File} plus (@var{a}, @var{a})
## Return the sum of a Kronecker product and another matrix. This is performed
## by forming the full matrix of both inputs and is as such a potential expensive
## operation.
## @seealso{plus, @@kronprod/minus}
## @end deftypefn

function retval = plus (M1, M2)
  if (nargin == 0 || nargin > 2)
    print_usage ();
  elseif (nargin == 1)
    ## This seems to be the behaviour for the built-in types so we copy that
    retval = M1;
    return;
  endif
  
  if (!ismatrix (M1) || !ismatrix (M2))
    error ("plus: input arguments must be matrics");
  endif
  
  if (!size_equal (M1, M2))
    error ("plus: nonconformant arguments (op1 is %dx%d, op2 is %dx%d)",
           rows (M1), columns (M1), rows (M2), columns (M2));
  endif
  
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
  
  retval = M1 + M2;
endfunction

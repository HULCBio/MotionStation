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
## @deftypefn {Function File} rdivide (@var{a}, @var{b})
## XXX: Write help text.
## @end deftypefn

function retval = rdivide (a, b)
  ## Check input
  if (nargin < 2)
    print_usage ();
  endif
  
  if (!ismatrix (a) || !ismatrix (a))
    error ("rdivide: input arguments must be scalars or matrices");
  endif
  
  if (!size_equal (a, b) || !isscalar (b))
    error ("times: nonconformant arguments (op1 is %dx%d, op2 is %dx%d)",
           rows (a), columns (a), rows (b), columns (b));
  endif

  ## Take action depending on input
  if (isscalar (a) && isa (b, "kronprod"))
    retval = kronprod (a ./ b.A, 1 ./ b.B);
  elseif (isa (a, "kronprod") && isscalar (b))
    if (numel (a.A) < numel (a.B))
      retval = kronprod (a.A ./ b, a.B);
    else
      retval = kronprod (a.A, a.B ./ b);
    endif
  elseif (isa (a, "kronprod") && isa (b, "kronprod"))
    ## XXX: Can we do something smarter here?
    retval = full (a) ./ full (b);
  else
    ## XXX: We should probably handle sparse cases and all sorts of other
    ## situations better here
    retval = full (a) ./ full (b);
  endif
endfunction

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
## @deftypefn {Function File} size (@var{KP})
## @deftypefnx{Function File} size (@var{KP}, @var{dim})
## Return the size of the Kronecker product @var{KP} as a vector.
## @seealso{size, @@kronprod/rows, @@kronprod/columns, @@kronprod/numel}
## @end deftypefn

function retval = size (KP, dim)
  if (nargin < 1)
    print_usage ();
  endif
  
  if (!isa (KP, "kronprod"))
    error ("size: input must be of class 'kronprod'");
  endif
  if (nargin > 1 && !(isscalar (dim) && dim == round (dim) && dim > 0))
    error ("size: optional second input must be a positive integer");
  endif
  
  retval = size (KP.A) .* size (KP.B);
  if (nargin > 1)
    retval = retval (dim);
  endif
endfunction

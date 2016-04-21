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
## @deftypefn {Function File} mpower (@var{KP}, @var{k})
## XXX: Write documentation
## @end deftypefn

function retval = mpower (KP, k)
  ## Check input
  if (nargin != 2)
    print_usage ();
  endif
  
  if (!ismatrix (KP))
    error ("mpower: first input argument must be a matrix");
  endif
  
  if (!isscalar (k))
    error ("mpower: second input argument must be a scalar");
  endif

  ## Do the actual computation
  if (issquare (KP.A) && issquare (KP.B) && k == round (k))
    retval = kronprod (KP.A^k, KP.B^k);
  elseif (issquare (KP))
    ## XXX: Can we do something smarter here?
    retval = full (KP)^k;
  else
    error ("for A^b, A must be square");
  endif
endfunction

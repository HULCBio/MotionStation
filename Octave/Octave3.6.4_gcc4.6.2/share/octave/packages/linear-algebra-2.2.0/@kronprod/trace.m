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
## @deftypefn {Function File} trace (@var{KP})
## Returns the trace of the Kronecker product @var{KP}.
##
## If @var{KP} is a Kronecker product of two square matrices, the trace is
## computed as the product of the trace of these two matrices. Otherwise the
## trace is computed by forming the full matrix.
## @seealso{@@kronprod/det, @@kronprod/rank, @@kronprod/full}
## @end deftypefn

function retval = trace (KP)
  if (nargin != 1)
    print_usage ();
  endif
  
  if (!isa (KP, "kronprod"))
    error ("trace: input must be of class 'kronprod'");
  endif
  
  if (issquare (KP.A) && issquare (KP.B))
    retval = trace (KP.A) * trace (KP.B);
  else
    ## XXX: Can we do something smarter here? Using 'eig' or 'svd'?
    retval = trace (full (KP));
  endif
endfunction

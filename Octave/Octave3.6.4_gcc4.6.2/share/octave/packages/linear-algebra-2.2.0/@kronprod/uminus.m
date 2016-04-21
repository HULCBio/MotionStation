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
## @deftypefn {Function File} uminus (@var{KP})
## Returns the unary minus operator working on the Kronecker product @var{KP}.
## This corresponds to @code{-@var{KP}} and simply returns the Kronecker
## product with the sign of the smallest matrix in the product reversed.
## @seealso{@@kronprod/uminus}
## @end deftypefn

function KP = uplus (KP)
  if (nargin != 1)
    print_usage ();
  endif
  
  if (!isa (KP, "kronprod"))
    error ("uplus: input must be of class 'kronprod'");
  endif
  
  if (numel (KP.A) < numel (KP.B))
    KP.A *= -1;
  else
    KP.B *= -1;
  endif
endfunction

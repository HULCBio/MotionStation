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
## @deftypefn {Function File} numel (@var{KP})
## Return the number of elements in the Kronecker product @var{KP}.
## @seealso{numel, @@kronprod/rows, @@kronprod/columns, @@kronprod/size}
## @end deftypefn

function retval = numel (KP)
  if (nargin != 1)
    print_usage ();
  endif
  
  if (!isa (KP, "kronprod"))
    error ("numel: input must be of class 'kronprod'");
  endif
  
  retval = prod (size (KP.A) .* size (KP.B));
endfunction

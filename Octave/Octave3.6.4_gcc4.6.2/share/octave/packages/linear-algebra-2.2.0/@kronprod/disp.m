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
## @deftypefn {Function File} disp (@var{KP})
## Show the content of the Kronecker product @var{KP}. To avoid evaluating the
## Kronecker product, this function displays the two matrices defining the product.
## To display the actual values of @var{KP}, use @code{disp (full (@var{KP}))}.
##
## This function is equivalent to @code{@@kronprod/display}.
## @seealso{@@kronprod/display, @@kronprod/full}
## @end deftypefn

function disp (KP)
  display (KP);
endfunction

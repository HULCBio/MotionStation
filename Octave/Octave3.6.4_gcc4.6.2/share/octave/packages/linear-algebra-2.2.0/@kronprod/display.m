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
## @deftypefn {Function File} display (@var{KP})
## Show the content of the Kronecker product @var{KP}. To avoid evaluating the
## Kronecker product, this function displays the two matrices defining the product.
## To display the actual values of @var{KP}, use @code{display (full (@var{KP}))}.
## @seealso{@@kronprod/displ, @@kronprod/full}
## @end deftypefn

function display (KP)
  if (nargin != 1)
    print_usage ();
  endif
  
  if (!isa (KP, "kronprod"))
    error ("display: input argument must be of class 'kronprod'");
  endif
  
  if (isempty (KP.P))
    disp ("Kronecker Product of A and B with");
    disp ("A = ");
    disp (KP.A);
    disp ("B = ");
    disp (KP.B);
  else
    disp ("Permuted Kronecker Product of A and B (i.e. P * kron (A, B) * P') with");
    disp ("A = ");
    disp (KP.A);
    disp ("B = ");
    disp (KP.B);
    disp ("P = ");
    disp (KP.P);
  endif
endfunction

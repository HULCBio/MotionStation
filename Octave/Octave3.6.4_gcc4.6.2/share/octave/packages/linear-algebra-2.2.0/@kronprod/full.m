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
## @deftypefn {Function File} full (@var{KP})
## Return the full matrix representation of the Kronecker product @var{KP}.
##
## If @var{KP} is the Kronecker product of an @var{n}-by-@var{m} matrix and a
## @var{q}-by-@var{r} matrix, then the result is a @var{n}@var{q}-by-@var{m}@var{r}
## matrix. Thus, the result can require vast amount of memory, so this function
## should be avoided whenever possible.
## @seealso{full, @@kronprod/sparse}
## @end deftypefn

function retval = full (KP)
  if (nargin != 1)
    print_usage ();
  endif
  
  if (!isa (KP, "kronprod"))
    error ("full: input argument must be of class 'kronprod'");
  endif
  
  retval = full (kron (KP.A, KP.B));
  if (!isempty (KP.P))
    #retval = KP.P * retval * KP.P';
    retval = retval (KP.P, KP.P);
  endif
endfunction

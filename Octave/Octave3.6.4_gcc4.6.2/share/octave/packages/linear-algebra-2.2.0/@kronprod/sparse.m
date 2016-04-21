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
## @deftypefn {Function File} sparse (@var{KP})
## Return the Kronecker product @var{KP} represented as a sparse matrix.
## @seealso{sparse, @@kronprod/issparse, @@kronprod/full}
## @end deftypefn

function retval = sparse (KP)
  if (nargin != 1)
    print_usage ();
  endif
  
  if (!isa (KP, "kronprod"))
    error ("sparse: input argument must be of class 'kronprod'");
  endif

  ## XXX: Would this be better? kron (sparse (KP.A), sparse (KP.B)))
  retval = sparse (kron (KP.A, KP.B));
endfunction

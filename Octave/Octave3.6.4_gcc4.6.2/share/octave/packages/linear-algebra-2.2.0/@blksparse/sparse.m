## Copyright (C) 2010 VZLU Prague
## 
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} sparse (@var{x})
## Converts a block sparse matrix to (built-in) sparse.
## @end deftypefn

function sp = sparse (s)
  bsiz = s.bsiz;
  i = repmat (shiftdim (s.i, -2), bsiz);
  j = repmat (shiftdim (s.j, -2), bsiz);
  [iofs, jofs] = ndgrid (1:bsiz(1), 1:bsiz(2));
  k = ones (1, size (s.sv, 3));
  i = sub2ind ([bsiz(1), s.siz(1)], iofs(:,:,k), i);
  j = sub2ind ([bsiz(2), s.siz(2)], jofs(:,:,k), j);

  sp = sparse (i(:), j(:), s.sv(:), bsiz(1)*s.siz(1), bsiz(2)*s.siz(2));
endfunction

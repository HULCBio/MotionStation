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
## @deftypefn {Function File} display (@var{x})
## Displays the block sparse matrix.
## @end deftypefn

function display (s)
  printf ("%s = \n\n", argn);
  nbl = size (s.sv, 3);
  header = "Block Sparse Matrix (rows = %d, cols = %d, block = %dx%d, nblocks = %d)\n\n";
  printf (header, s.siz .* s.bsiz, s.bsiz, nbl)
  if (nbl == 0)
    return;
  endif
  rng = [s.i, s.j] * diag (s.bsiz);
  rng = [rng(:,1) + 1-s.bsiz(1), rng(:,1), rng(:,2) + 1-s.bsiz(2), rng(:,2)];
  for k = 1:nbl
    printf ("(%d:%d, %d:%d) ->\n\n", rng(k,:));
    disp (s.sv(:,:,k));
    puts ("\n");
  endfor
endfunction



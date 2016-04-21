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
## @deftypefn {Function File} full (@var{x})
## Converts a block sparse matrix to full.
## @end deftypefn

function f = full (s)
  f = zeros ([s.bsiz, s.siz]);
  f(:,:, sub2ind (s.siz, s.i, s.j)) = s.sv;
  f = reshape (permute (f, [1, 3, 2, 4]), s.bsiz .* s.siz);
endfunction


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

function ss = subsref (s, subs)
  if (length (subs) != 1)
    error ("blksparse: invalid index chain");
  endif
  if (strcmp (subs(1).type, "()"))
    ind = subs(1).subs;
    if (length (ind) == 2)
      idx = make_block_index (ind{1}, s.bsiz(1));
      jdx = make_block_index (ind{2}, s.bsiz(2));
      ## Use sparse indexing to solve it all.
      sn = sparse (s.i, s.j, 1:size (s.sv, 3), s.siz(1), s.siz (2));
      sn = sn(idx, jdx);
      [i, j, k] = find (sn);
      ss = s;
      ss.i = i;
      ss.j = j;
      ss.sv = s.sv(:,:,k);
      ss.siz = size (sn);
    else
      error ("blksparse: linear indexing is not supported");
    endif
  else
    error ("blksparse: only supports () indexing");
  endif

endfunction

function bi = make_block_index (i, bs)
  if (strcmp (i, ':'))
    bi = i;
  else
    if (rem (numel (i), bs) == 0)
      ba = reshape (i, bs, []);
      bi = ba(1,:);
      if (any (rem (bi, bs) != 1) || any ((ba != bsxfun (@plus, bi, [0:bs-1].'))(:)))
        error ("blksparse: index must preserve block structure");
      else
        bi = ceil (bi / bs); 
      endif
    else
      error ("blksparse: index must preserve block structure");
    endif
  endif
endfunction

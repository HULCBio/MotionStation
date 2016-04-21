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
## @deftypefn {Function File} mtimes (@var{x}, @var{y})
## Multiplies a block sparse matrix with a full matrix, or two block sparse
## matrices. Multiplication of block sparse * sparse is not implemented.
## If one of arguments is a scalar, it's a scalar multiply.
## @end deftypefn

function c = mtimes (a, b)
  if (isa (a, "blksparse"))
    if (isa (b, "blksparse"))
      c = mtimes_ss (a, b);
    else
      c = mtimes_sm (a, b);
    endif
  elseif (isa (b, "blksparse"))
    c = mtimes_ms (a, b);
  else
    error ("blksparse: invalid arguments to mtimes");
  endif
endfunction

function y = mtimes_sm (s, x)
  if (isscalar (x))
    y = s;
    y.sv *= x;
    return;
  elseif (issparse (x))
    error ("blksparse * sparse not implemented.");
  endif
  siz = s.siz;
  bsiz = s.bsiz;
  ## Check sizes.
  [xr, xc] = size (x);
  if (xr != siz(2)*bsiz(2))
    gripe_nonconformant (siz.*bsiz, [xr, xc]);
  endif
  ## Form blocks.
  x = reshape (x, bsiz(2), siz(2), xc);
  x = permute (x, [1, 3, 2]);
  ## Scatter.
  xs = x(:,:,s.j);
  ## Multiply.
  ys = blkmm (s.sv, xs);
  ## Gather.
  y = accumdim (s.i, ys, 3, siz(1));
  y = permute (y, [1, 3, 2]);
  ## Narrow blocks.
  y = reshape (y, bsiz(1)*siz(1), xc);
endfunction

function y = mtimes_ms (x, s)
  if (isscalar (x))
    y = s;
    y.sv *= x;
    return;
  elseif (issparse (x))
    error ("sparse * blksparse not implemented.");
  endif
  siz = s.siz;
  bsiz = s.bsiz;
  ## Check sizes.
  [xr, xc] = size (x);
  if (xc != siz(1)*bsiz(1))
    gripe_nonconformant ([xr, xc], siz.*bsiz);
  endif
  ## Form blocks.
  x = reshape (x, xr, bsiz(2), siz(2));
  ## Scatter.
  xs = x(:,:,s.i);
  ## Multiply.
  ys = blkmm (xs, s.sv);
  ## Gather.
  y = accumdim (s.j, ys, 3, siz(2));
  ## Narrow blocks.
  y = reshape (y, xr, bsiz(2)*siz(2));
endfunction

function s = mtimes_ss (s1, s2)

  ## Conformance check.
  siz1 = s1.siz;
  bsiz1 = s1.bsiz;
  siz2 = s2.siz;
  bsiz2 = s2.bsiz;
  if (bsiz1(2) != bsiz2(1))
    gripe_nonconformant (bsiz1, bsiz2, "block sizes");
  elseif (siz1(2) != siz2(1))
    gripe_nonconformant (bsiz1.*siz1, bsiz2.*siz2);
  endif

  ## Hardcore hacks, man!
  ss = sparse (s1.i, s1.j, 1:length (s1.i), "unique");
  ss = ss(:,s2.i);
  [i, j, k] = find (ss);
  sv = blkmm (s1.sv(:,:,k), s2.sv(:,:,j));
  j = s2.j(j);

  s = blksparse (i, j, sv, siz1(1), siz2(2));
  
endfunction

function gripe_nonconformant (s1, s2, what = "arguments")
  error ("Octave:nonconformant-args", ...
  "nonconformant %s (op1 is %dx%d, op2 is %dx%d)", what, s1, s2);
endfunction

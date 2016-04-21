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
## @deftypefn {Function File} mrdivide (@var{x}, @var{y})
## Performs a left division with a block sparse matrix.
## If @var{y} is a block sparse matrix, it must be either diagonal
## or triangular, and @var{x} must be full.
## If @var{y} is built-in sparse or full, @var{x} is converted
## accordingly, then the built-in division is used.
## @end deftypefn

function c = mrdivide (a, b)
  if (isa (b, "blksparse"))
    if (issparse (a))
      error ("blksparse: sparse / block sparse not implemented");
    else
      c = mrdivide_ms (a, b);
    endif
  elseif (issparse (b))
    c = sparse (a) / b;
  else
    c = full (a) / b;
  endif
endfunction

function y = mrdivide_ms (x, s)
  siz = s.siz;
  bsiz = s.bsiz;
  if (bsiz(1) != bsiz(2) || siz(1) != siz(2))
    error ("blksparse: can only divide by square matrices with square blocks");
  endif

  ## Check sizes.
  [xr, xc] = size (x);
  if (xc != siz(2)*bsiz(2))
    gripe_nonconformant (siz.*bsiz, [xr, xc]);
  endif

  if (isempty (s) || isempty (x))
    y = x;
    return;
  endif

  ## Form blocks.
  x = reshape (x, xr, bsiz(2), siz(2));

  sv = s.sv;
  si = s.i;
  sj = s.j;
  ns = size (sv, 3);

  n = siz(2);
  nb = bsiz(2);
  d = find (si == sj);
  full_diag = length (d) == n;

  isdiag = full_diag && ns == n; # block diagonal
  islower = full_diag && all (si >= sj); # block upper triangular
  isupper = full_diag && all (si <= sj); # block lower triangular

  if (isdiag)
    xx = num2cell (x, [1, 2]);
    ss = num2cell (sv, [1, 2]);
    yy = cellfun (@mldivide, ss, xx, "uniformoutput", false);
    y = cat (3, yy{:});
    clear xx ss yy;
  elseif (isupper)
    y = zeros (size (x));
    ## this is the dot version
    y(:,:,1) = x(:,:,1) / sv(:,:,1);
    for j = 2:n
      k = d(j-1)+1:d(j)-1;
      xy = blkmm (y(:,:,si(k)), sv(:,:,k));
      y(:,:,j) = (x(:,:,j) - sum (xy, 3)) / sv(:,:,d(j));
    endfor
  elseif (islower)
    y = zeros (size (x));
    ## this is the dot version
    y(:,:,n) = x(:,:,n) / sv(:,:,ns);
    for j = n-1:-1:1
      k = d(j)+1:d(j+1)-1;
      xy = blkmm (y(:,:,si(k)), sv(:,:,k));
      y(:,:,j) = (x(:,:,j) - sum (xy, 3)) / sv(:,:,d(j));
    endfor
  else
    error ("blksparse: mldivide: matrix must be block triangular or diagonal");
  endif

  ## Narrow blocks.
  y = reshape (y, xr, bsiz(2)*siz(2));
endfunction

function gripe_nonconformant (s1, s2, what = "arguments")
  error ("Octave:nonconformant-args", ...
  "nonconformant %s (op1 is %dx%d, op2 is %dx%d)", what, s1, s2);
endfunction



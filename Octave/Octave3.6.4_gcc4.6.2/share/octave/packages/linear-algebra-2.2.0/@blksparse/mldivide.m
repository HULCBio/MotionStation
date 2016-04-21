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
## @deftypefn {Function File} mldivide (@var{x}, @var{y})
## Performs a left division with a block sparse matrix.
## If @var{x} is a block sparse matrix, it must be either diagonal
## or triangular, and @var{y} must be full.
## If @var{x} is built-in sparse or full, @var{y} is converted
## accordingly, then the built-in division is used.
## @end deftypefn

function c = mldivide (a, b)
  if (isa (a, "blksparse"))
    if (issparse (b))
      error ("blksparse: block sparse \\ sparse not implemented");
    else
      c = mldivide_sm (a, b);
    endif
  elseif (issparse (a))
    c = a \ sparse (b);
  else
    c = a \ full (b);
  endif
endfunction

function y = mldivide_sm (s, x)
  siz = s.siz;
  bsiz = s.bsiz;
  if (bsiz(1) != bsiz(2) || siz(1) != siz(2))
    error ("blksparse: can only divide by square matrices with square blocks");
  endif

  ## Check sizes.
  [xr, xc] = size (x);
  if (xr != siz(1)*bsiz(1))
    gripe_nonconformant (siz.*bsiz, [xr, xc]);
  endif

  if (isempty (s) || isempty (x))
    y = x;
    return;
  endif

  ## Form blocks.
  x = reshape (x, bsiz(1), siz(1), xc);
  x = permute (x, [1, 3, 2]);

  sv = s.sv;
  si = s.i;
  sj = s.j;
  ns = size (sv, 3);

  n = siz(1);
  nb = bsiz(1);
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
  elseif (islower)
    y = x;
    ## this is the axpy version
    for j = 1:n-1
      y(:,:,j) = sv(:,:,d(j)) \ y(:,:,j);
      k = d(j)+1:d(j+1)-1;
      xy = y(:,:,j*ones (1, length (k)));
      y(:,:,si(k)) -= blkmm (sv(:,:,k), xy);
    endfor
    y(:,:,n) = sv(:,:,ns) \ y(:,:,n);
  elseif (isupper)
    y = x;
    ## this is the axpy version
    for j = n:-1:2
      y(:,:,j) = sv(:,:,d(j)) \ y(:,:,j);
      k = d(j-1)+1:d(j)-1;
      xy = y(:,:,j*ones (1, length (k)));
      y(:,:,si(k)) -= blkmm (sv(:,:,k), xy);
    endfor
    y(:,:,1) = sv(:,:,1) \ y(:,:,1);
  else
    error ("blksparse: mldivide: matrix must be block triangular or diagonal");
  endif

  ## Narrow blocks.
  y = permute (y, [1, 3, 2]);
  y = reshape (y, bsiz(1)*siz(1), xc);
endfunction

function gripe_nonconformant (s1, s2, what = "arguments")
  error ("Octave:nonconformant-args", ...
  "nonconformant %s (op1 is %dx%d, op2 is %dx%d)", what, s1, s2);
endfunction


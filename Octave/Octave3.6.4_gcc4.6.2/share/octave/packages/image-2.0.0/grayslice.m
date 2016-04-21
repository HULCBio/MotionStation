## Copyright (C) 2000 Kai Habel <kai.habel@gmx.de>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{X} =} grayslice (@var{I},@var{n})
## @deftypefnx {Function File} {@var{X} =} grayslice (@var{I},@var{v})
## Creates an indexed image @var{X} from an intensitiy image @var{I}
## using multiple threshold levels.
## A scalar integer value @var{n} sets the levels to
## @example
## 
## @group
## 1  2       n-1
## -, -, ..., ---
## n  n        n
## @end group
## @end example
##
## X = grayslice(I,5);
##
## For irregular threshold values a real vector @var{v} can be used.
## The values must be in the range [0,1].
##
## @group
## X = grayslice(I,[0.1,0.33,0.75,0.9])
## @end group
##
## @seealso{im2bw, gray2ind}
## @end deftypefn

function X = grayslice (I, v)

  if (nargin != 2)
    print_usage;
  endif

  if (isscalar (v) && isnumeric (v) && (fix (v) == v))
    v = (1:v - 1) / v;

  elseif (isvector(v))
    if (any (v < 0) || (any (v > 1)))
      error ("Slice vector must be in range [0,1]")
    endif
    v = [0,v,1];

  else
    error ("Second argument 'v' must be either an integer scalar or a vector");
  endif

  [r, c] = size (I);
  [m, n] = sort ([v(:); I(:)]);
  lx = length (v);
  o = cumsum (n <= lx);
  idx = o (find(n>lx));
  [m, n] = sort (I(:));
  [m, n] = sort (n);
  X = reshape (idx(n), r, c);

endfunction

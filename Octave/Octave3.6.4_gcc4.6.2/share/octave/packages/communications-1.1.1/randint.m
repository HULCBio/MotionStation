## Copyright (C) 2001 Laurent Mazet
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
## @deftypefn {Function File} {@var{b} = } randint (@var{n})
## @deftypefnx {Function File} {@var{b} = } randint (@var{n},@var{m})
## @deftypefnx {Function File} {@var{b} = } randint (@var{n},@var{m},@var{range})
## @deftypefnx {Function File} {@var{b} = } randint (@var{n},@var{m},@var{range},@var{seed})
##
## Generate a matrix of random binary numbers. The size of the matrix is
## @var{n} rows by @var{m} columns. By default @var{m} is equal to @var{n}.
##
## The range in which the integers are generated will is determined by
## the variable @var{range}. If @var{range} is an integer, the value will
## lie in the range [0,@var{range}-1], or [@var{range}+1,0] if @var{range}
## is negative. If @var{range} contains two elements the intgers will lie 
## within these two elements, inclusive. By default @var{range} is 
## assumed to be [0:1].
##
## The variable @var{seed} allows the random number generator to be seeded
## with a fixed value. The initial seed will be restored when returning.
## @end deftypefn

## 2001 FEB 07
##   initial release

function b = randint (n, m, range, seed)

  switch (nargin)
    case 1,
      m = n;
      range = [0,1];
      seed = Inf;
    case 2,
      range = [0,1];
      seed = Inf;
    case 3,
      seed = Inf;      
    case 4,
    otherwise
      usage ("b = randint (n, [m, [range, [seed]]])");
  endswitch

  ## Check range
  if (length (range) == 1)
    if (range < 0)
      range = [range+1, 0];
    else
      range = [0, range-1];
    endif
  elseif ( prod (size (range)) != 2)
    error ("randint: range must be a 2 element vector");
  endif
  range = sort (range);
  
  ## Check seed;
  if (!isinf (seed))
    old_seed = rand ("seed");
    rand ("seed", seed);
  endif

  b = range (1) - 1 + ceil (rand (n, m) * (range (2) - range (1) + 1));
  
  ## Get back to the old
  if (!isinf (seed))
    rand ("seed", old_seed);
  endif

endfunction

%!shared n, m, seed, a1, a2, a3, a4, a5, a6
%!    n = 10; m = 32; seed = 1; a1 = randint(n); a2 = randint(n,n); 
%!    a3 = randint(n,n,m); a4 = randint(n,n,[-m,m]); 
%!    a5 = randint(n,n,m, seed); a6 = randint(n,n,m, seed);

%!error randint ();
%!error randint (n,n,n,n,n);
%!assert (size(a1) == [n, n] && size(a2) == [n, n]);
%!assert (max ([a1(:); a2(:)]) <= 1 && min([a1(:); a2(:)]) >= 0);
%!assert (size(a3) == [n, n] && size(a4) == [n, n]);
%!assert (max (a3(:)) < m && min(a3(:)) >= 0);
%!assert (max (a4(:)) <= m && min(a4(:)) >= -m);
%!assert (a5(:) == a6(:));

%!test
%! a = randint(10,10,-32);
%! assert (max(a(:)) <= 0 && min(a(:)) > -32);

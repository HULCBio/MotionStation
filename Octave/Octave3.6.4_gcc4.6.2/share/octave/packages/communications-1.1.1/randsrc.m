## Copyright (C) 2003 David Bateman
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
## @deftypefn {Function File} {@var{b} = } randsrc (@var{n})
## @deftypefnx {Function File} {@var{b} = } randsrc (@var{n},@var{m})
## @deftypefnx {Function File} {@var{b} = } randsrc (@var{n},@var{m},@var{alphabet})
## @deftypefnx {Function File} {@var{b} = } randsrc (@var{n},@var{m},@var{alphabet},@var{seed})
##
## Generate a matrix of random symbols. The size of the matrix is
## @var{n} rows by @var{m} columns. By default @var{m} is equal to @var{n}.
##
## The variable @var{alphabet} can be either a row vector or a matrix with 
## two rows. When @var{alphabet} is a row vector the symbols returned in
## @var{b} are chosen with equal probability from @var{alphabet}. When
## @var{alphabet} has two rows, the second row determines the probabilty
## with which each of the symbols is chosen. The sum of the probabilities
## must equal 1. By default @var{alphabet} is [-1 1].
##
## The variable @var{seed} allows the random number generator to be seeded
## with a fixed value. The initial seed will be restored when returning.
## @end deftypefn

## 2003 FEB 13
##   initial release

function b = randsrc (n, m, alphabet, seed)

  switch (nargin)
    case 0,
      m = 1;
      n = 1;
      alphabet = [-1,1];
      seed = Inf;
    case 1,
      m = n;
      alphabet = [-1,1];
      seed = Inf;
    case 2,
      alphabet = [-1,1];
      seed = Inf;
    case 3,
      seed = Inf;      
    case 4,
    otherwise
      usage ("b = randsrc (n, [m, [alphabet, [seed]]])");
  endswitch

  ## Check alphabet
  [ar,ac] = size (alphabet);
  if (ac == 1)
    b = alphabet (1, 1) * ones (n, m);
    return;
  endif

  if (ar == 1)
    prob = [1:ac] / ac;
  elseif (ar == 2)
    prob = alphabet(2,:);
    alphabet = alphabet(1,:);
    if (abs(1-sum(prob)) > eps)
      error ("randsrc: probabilities must added up to one");
    endif
    prob = cumsum(prob);
  else
    error ("randsrc: alphabet must have 1 or 2 rows");
  endif
  
  ## Check seed;
  if (!isinf (seed))
    old_seed = rand ("seed");
    rand ("seed", seed);
  endif
  
  ## Create indexes with the right probabilities
  tmp = rand (n, m);
  b = ones (n, m);
  for i = 1:ac-1 
    b = b + (tmp > prob(i));
  end

  ## Map the indexes to the symbols
  b = alphabet(b);
  
  ## BUG: the above gives a row vector for some reason. Force what we want
  b = reshape(b, n, m);
    
  ## Get back to the old
  if (!isinf (seed))
    rand ("seed", old_seed);
  endif

endfunction

%!shared n, alph1, alph2, seed, a1, a2, a3, a4, a5, a6
%!    n = 10; alph1 = [0,1;0.3,0.7]; alph2 = ['a','b']; seed = 1; 
%!    a1 = randsrc(n); a2 = randsrc(n,n);
%!    a3 = randsrc(n,n,alph1); a4 = randsrc(n,n,alph2); 
%!    a5 = randsrc(n,n,alph1,seed); a6 = randsrc(n,n,alph1,seed);

%!error randsrc (n,n,n,n,n);
%!assert (size(a1) == [n, n] && size(a2) == [n, n]);
%!assert (max ([a1(:); a2(:)]) <= 1 && min([a1(:); a2(:)]) >= -1);
%!assert (size(a3) == [n, n] && size(a4) == [n, n]);
%!assert (max (a3(:)) <= 1 && min(a3(:)) >= 0);
%!assert (max(toascii(a4(:))) <= toascii('b'))
%!assert (max(toascii(a4(:))) >= toascii('a'))
%!assert (a5(:) == a6(:));

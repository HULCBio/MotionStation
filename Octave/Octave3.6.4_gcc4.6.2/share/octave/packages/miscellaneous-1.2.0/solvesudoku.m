## Copyright (C) 2009 Jaroslav Hajek <highegg@gmail.com>
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
## @deftypefn{Function File} [@var{x}, @var{ntrial}] = solvesudoku (@var{s})
## Solves a classical 9x9 sudoku. @var{s} should be a 9x9 array with 
## numbers from 0:9. 0 indicates empty field.
## Returns the filled table or empty matrix if no solution exists.
## If requested, @var{ntrial} returns the number of trial-and-error steps needed.
## @end deftypefn

## This uses a recursive backtracking technique combined with revealing new singleton
## fields by logic. The beauty of it is that it is completely vectorized.

function [x, ntrial] = solvesudoku (s)

  if (nargin != 1)
    print_usage ();
  endif

  if (! (ismatrix (s) && ndims (s) == 2 && all (size (s) == [9, 9])))
    error ("needs a 9x9 matrix");
  endif

  if (! ismember (unique (s(:)), 0:9))
    error ("matrix must contain values from 0:9");
  endif

  if (! verifysudoku (s))
    error ("matrix is not a valid sudoku grid");
  endif

  [x, ntrial] = solvesudoku_rec (s);

endfunction

function ok = verifysudoku (s)
  [i, j, k] = find (s);
  b = false (9, 9, 9);
  b(sub2ind ([9, 9, 9], i, j, k)) = true;
  okc = sum (b, 1) <= 1;
  okr = sum (b, 2) <= 1;
  b = reshape (b, [3, 3, 3, 3, 9]);
  ok3 = sum (sum (b, 1), 3) <= 1;
  ok = all (okc(:) & okr(:) & ok3(:));
endfunction

function [x, ntrial] = solvesudoku_rec (s)

  x = s;
  ntrial = 0;

  ## Run until the logic is exhausted.
  do
    b = getoptions (x);
    s = x;
    x = getsingletons (b, x);
    finished = isempty (x) || all (x(:));
  until (finished || all ((x == s)(:)));
  
  if (! finished)
    x = [];
    ## Find the field with minimum possibilities.
    sb = sum (b, 3);
    sb(s != 0) = 10;
    [msb, i] = min (sb(:));
    [i, j] = ind2sub ([9, 9], i);
    ## Try all guesses.
    for k = find (b(i,j,:))'
      s(i,j) = k;
      [x, ntrial1] = solvesudoku_rec (s);
      ntrial += 1 + ntrial1;
      if (! isempty (x))
        ## Found solutions.
        break;
      endif
      s(i,j) = 0;
    endfor
  endif

endfunction

## Given a 9x9x9 logical array of allowed values, get the logical singletons.
function s = getsingletons (b, s)

  n0 = sum (s(:) != 0);
  
  ## Check for fields with only one option.
  sb = sum (b, 3);
  if (any (sb(:) == 0))
    s = [];
    return;
  else
    s1 = sb == 1;
    ## We want to return as soon as some new singletons are found.
    [s(s1), xx] = find (reshape (b, [], 9)(s1, :).');
    if (sum (s(:) != 0) > n0)
      return;
    endif
  endif

  ## Check for columns where a number has only one field left.
  sb = squeeze (sum (b, 1));
  if (any (sb(:) == 0))
    s = [];
    return;
  else
    s1 = sb == 1;
    [j, k] = find (s1);
    [i, xx] = find (b(:, s1));
    s(sub2ind ([9, 9], i, j)) = k;
    if (sum (s(:) != 0) > n0)
      return;
    endif
  endif

  ## Ditto for rows.
  sb = squeeze (sum (b, 2));
  if (any (sb(:) == 0))
    s = [];
    return;
  else
    s1 = sb == 1;
    [i, k] = find (s1);
    [j, xx] = find (permute (b, [2, 1, 3])(:, s1));
    s(sub2ind ([9, 9], i, j)) = k;
    if (sum (s(:) != 0) > n0)
      return;
    endif
  endif

  ## 3x3 tiles.
  bb = reshape (b, [3, 3, 3, 3, 9]);
  sb = squeeze (sum (sum (bb, 1), 3));
  if (any (sb(:) == 0))
    s = [];
    return;
  else
    s1 = reshape (sb == 1, 9, 9);
    [j, k] = find (s1);
    [i, xx] = find (reshape (permute (bb, [1, 3, 2, 4, 5]), 9, 9*9)(:, s1));
    [i1, i2] = ind2sub ([3, 3], i);
    [j1, j2] = ind2sub ([3, 3], j);
    s(sub2ind ([3, 3, 3, 3], i1, j1, i2, j2)) = k;
    if (sum (s(:) != 0) > n0)
      return;
    endif
  endif

endfunction

## Given known values (singletons), calculate options.
function b = getoptions (s)

  ## Find true values.
  [i, j, s] = find (s);
  ## Columns.
  bc = true (9, 9, 9);
  bc(:, sub2ind ([9, 9], j, s)) = false;
  ## Rows. 
  br = true (9, 9, 9);
  br(:, sub2ind ([9, 9], i, s)) = false;
  ## 3x3 tiles.
  b3 = true (3, 3, 3, 3, 9);
  b3(:, :, sub2ind ([3, 3, 9], ceil (i/3), ceil (j/3), s)) = false;
  ## Permute elements to correct order.
  br = permute (br, [2, 1, 3]);
  b3 = reshape (permute (b3, [1, 3, 2, 4, 5]), [9, 9, 9]);
  ## The singleton fields themselves.
  bb = true (9*9, 9);
  bb(sub2ind ([9, 9], i, j), :) = false;
  bb = reshape (bb, [9, 9, 9]);
  ## Form result.
  b = bc & br & b3 & bb;
  ## Correct singleton fields.
  b = reshape (b, 9, 9, 9);
  b(sub2ind ([9, 9, 9], i, j, s)) = true;

endfunction


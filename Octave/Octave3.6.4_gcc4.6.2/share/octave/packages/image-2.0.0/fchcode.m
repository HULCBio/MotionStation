## Copyright (C) 2010 Andrew Kelly, IPS Radio & Space Services
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
## @deftypefn {Function File} {@var{fcc} = } fchcode (@var{bound})
## Determine the Freeman chain code for a boundary.
##
## @code{fchcode} computes the Freeman chain code for the @var{n}-connected
## boundary @var{bound}. @var{n} must be either 8 or 4.
##
## @var{bound} is a K-by-2 matrix containing the row/column coordinates of points
## on the boundary. Optionally, the first point can be repeated as the last point,
## resulting in a (K+1)-by-2 matrix.
##
## @var{fcc} is a structure containing the following elements.
##
## @example
##  x0y0   = Row/column coordinates where the code starts (1-by-2) 
##  fcc    = Freeman chain code (1-by-K)
##  diff   = First difference of fcc (1-by-K)
## @end example
##
## The code uses the following directions.
##
## @example
##  3 2 1
##  4 . 0
##  5 6 7
## @end example
##
## @seealso{bwboundaries}
## @end deftypefn

function fcc = fchcode (bound)

  # ensure the boundary start and end points are the same
  if (!isempty (bound) && !isequal (bound (1, :), bound (end, :)))
    bound = [bound; bound(1, :)];
  endif

  # number of boundary points
  n = max (0, rows (bound)-1);

  # structure in which to return results
  fcc = struct (\
    'x0y0', zeros (1, n), \
    'fcc',  zeros (1, n), \
    'diff', zeros (1, n) \
  );

  # an empty boundary?
  if (isempty (bound))
    return;
  endif

  # direction map
  dir = [3,  2,  1; \
         4, NaN, 0; \
         5,  6,  7];
  
  # coordinates
  ROW = 1;
  COL = 2;

  # direction changes as row/column indexes into DIR
  ch = 2 + diff (bound, 1, ROW);
  
  # starting point
  fcc.x0y0 = bound (1, :);

  # chain code
  fcc.fcc = dir (sub2ind (size (dir), ch (:, ROW), ch (:, COL)))';

  # chain code difference
  fcc.diff = mod (diff ([fcc.fcc, fcc.fcc(1)]), 8);
endfunction

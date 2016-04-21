## Copyright (C) 2008 Soren Hauberg <soren@hauberg.org>
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
## @deftypefn {Function File} @var{accum}= hough_circle (@var{bw}, @var{r})
## Perform the Hough transform for circles with radius @var{r} on the
## black-and-white image @var{bw}.
##
## As an example, the following shows how to compute the Hough transform for circles
## with radius 3 or 7 in the image @var{im}
## @example
## bw = edge(im);
## accum = hough_circle(bw, [3, 7]);
## @end example
## If @var{im} is an NxM image @var{accum} will be an NxMx2 array, where
## @var{accum}(:,:,1) will contain the Hough transform for circles with 
## radius 3, and @var{accum}(:,:,2) for radius 7. To find good circles you
## now need to find local maximas in @var{accum}, which can be a hard problem.
## If you find a local maxima in @var{accum}(row, col, 1) it means that a
## good circle exists with center (row,col) and radius 3.
##
## @seealso{houghtf}
## @end deftypefn

function accum = hough_circle(bw, r)
  ## Check input arguments
  if (nargin != 2)
    error("hough_circle: wrong number of input arguments");
  endif

  if (!ismatrix(bw) || ndims(bw) != 2)
    error("hough_circle: first arguments must be a 2-dimensional matrix");
  endif

  if (!isvector(r) || !isreal(r) || any(r<0))
    error("hough_circle: radius arguments must be a positive vector or scalar");
  endif

  ## Create the accumulator array.
  accum = zeros(size(bw,1), size(bw,2), length(r));

  ## Find the pixels we need to look at
  [R, C] = find(bw);

  ## Iterate over different radius
  for j = 1:length(r)
    rad = r(j);

    ## Compute a filter containing the circle we're looking for.
    circ = circle(rad);

    ## Iterate over all interesting image points
    for i =1:length(R)
      row = R(i);
      col = C(i);

      ## Compute indices for the accumulator array
      a_rows = max(row-rad,1) : min(row+rad, size(accum,1));
      a_cols = max(col-rad,1) : min(col+rad, size(accum,2));

      ## Compute indices for the circle array (the filter)
      c_rows = max(rad-row+2,1) : min(rad-row+1+size(accum,1), size(circ,1));
      c_cols = max(rad-col+2,1) : min(rad-col+1+size(accum,2), size(circ,2));

      ## Update the accumulator array
      accum( a_rows, a_cols, j ) += circ ( c_rows, c_cols );
    endfor
  endfor
endfunction

## Small auxilary function that creates an (2r+1)x(2r+1) image containing
## a circle with radius r and center (r+1, r+1).
function circ = circle(r)
  circ = zeros(round(2*r+1));
  col = 1:size(circ,2);
  for row=1:size(circ,1)
    tmp = (row-(r+1)).^2 + (col-(r+1)).^2;
    circ(row,col) = (tmp <= r^2);
  endfor
  circ = bwmorph(circ, 'remove');
endfunction

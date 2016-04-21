## Copyright (C) 2006 Søren Hauberg <soren@hauberg.org>
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
## @deftypefn {Function File} @var{BW2} = bwperim(@var{BW1})
## @deftypefnx{Function File} @var{BW2} = bwperim(@var{BW1}, @var{n})
## Find the perimeter of objects in binary images.
##
## A pixel is part of an object perimeter if its value is one and there
## is at least one zero-valued pixel in its neighborhood.
##
## By default the neighborhood of a pixel is 4 nearest pixels, but
## if @var{n} is set to 8 the 8 nearest pixels will be considered.
## @end deftypefn

function out = bwperim(bw, n=4)
  ## Input checking
  if (nargin < 1)
    print_usage();
  endif
  if (!isbw(bw) || ndims(bw)!=2)
    error("bwperim: first input argument must be a 2-dimensional binary image");
  endif
  if (!isscalar(n) || (n!=4 && n!=8))
    error("bwperim: second argument must be 4 or 8");
  endif
  
  ## Make sure bw is logical;
  bw = logical (bw);
  
  ## Translate image by one pixel in all directions
  [rows, cols] = size(bw);
  north = [bw(2:end, :); zeros(1, cols, "logical")];
  south = [zeros(1, cols, "logical"); bw(1:end-1, :)];
  west  = [bw(:, 2:end), zeros(rows, 1, "logical")];
  east  = [zeros(rows, 1, "logical"), bw(:, 1:end-1)];
  if (n == 8)
    north_east = north_west = south_east = south_west = zeros (rows, cols, "logical");
    north_east (1:end-1, 2:end)   = bw (2:end, 1:end-1);
    north_west (1:end-1, 1:end-1) = bw (2:end, 2:end);
    south_east (2:end, 2:end)     = bw (1:end-1, 1:end-1);
    south_west (2:end, 1:end-1)   = bw (1:end-1, 2:end);
  endif
  
  ## Do the comparing
  if (n == 4)
    out = bw;
    idx = (north == bw) & (south == bw) & (west == bw) & (east == bw);
    out(idx) = false;
  else # n == 8
    out = bw;
    idx = (north == bw) & (north_east == bw) & ...
          (east  == bw) & (south_east == bw) & ...
          (south == bw) & (south_west == bw) & ...
          (west  == bw) & (north_west == bw);
    out (idx) = false;
  endif
endfunction

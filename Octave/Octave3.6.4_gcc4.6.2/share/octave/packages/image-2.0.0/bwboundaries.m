## Copyright (C) 2010 Soren Hauberg <soren@hauberg.org>
## Copyright (C) Andrew Kelly, IPS Radio & Space Services
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
## @deftypefn {Function File} {@var{boundaries} = } bwboundaries(@var{BW})
## @deftypefnx {Function File} {@var{boundaries} = } bwboundaries(@var{BW}, @var{conn})
## @deftypefnx {Function File} {@var{boundaries} = } bwboundaries(@var{BW}, @var{conn}, @var{holes})
## @deftypefnx {Function File} {[@var{boundaries}, @var{labels}] = } bwboundaries(@dots{})
## @deftypefnx {Function File} {[@var{boundaries}, @var{labels}, @var{num_labels}] = } bwboundaries(@dots{})
## Trace the boundaries of the objects in a binary image.
##
## @var{boundaries} is a cell array in which each element is the boundary of an
## object in the binary image @var{BW}. The clockwise boundary of each object is 
## computed by the @code{boundary} function.
##
## By default the boundaries are computed using 8-connectivity. This can be 
## changed to 4-connectivity by setting @var{conn} to 4.
##
## By default @code{bwboundaries} computes all boundaries in the image, i.e.
## both interior and exterior object boundaries. This behaviour can be changed
## through the @var{holes} input argument. If this is @t{'holes'},
## both boundary types are considered. If it is instead @t{'noholes'}, only exterior
## boundaries will be traced.
##
## If two or more output arguments are requested, the algorithm also returns
## the labelled image computed by @code{bwlabel} in @var{labels}. The number
## of labels in this image is optionally returned in @var{num_labels}.
## @seealso{boundary, bwlabel}
## @end deftypefn

function [bound, labels, num_labels] = bwboundaries (bw, conn=8, holes="holes")
  # check arguments
  if (nargin < 1)
    error ("bwboundaries: not enough input arguments");
  endif
  if (!ismatrix (bw) || ndims (bw) != 2)
    error ("bwboundaries: first input argument must be a NxM matrix");
  endif
  if (!isscalar (conn) || (conn != 4 && conn != 8))
    error ("bwboundaries: second input argument must be 4 or 8");
  endif
  if (!ischar (holes) || !any (strcmpi (holes, {'holes', 'noholes'})))
    error ("bwboundaries: third input must be either \'holes\' or \'noholes\'");
  endif
  
  bw = logical (bw);
  
  # process each connected region separately
  [labels, num_labels] = bwlabel (bw, conn);
  bound = cell (num_labels, 1);
  for k = 1:num_labels
    bound {k} = __boundary__ ((labels == k), conn);
  endfor
  
  # compute internal boundaries as well?
  if (strcmpi (holes, "holes"))
    filled = bwfill (bw, "holes", conn);
    holes = (filled & !bw);
    [intBounds, intLabels, numIntLabels] = bwboundaries (holes, conn, "noholes");

    bound (end+1 : end+numIntLabels, 1) = intBounds;
    intLabels (intLabels != 0) += num_labels;
    labels += intLabels;
  endif
endfunction

%!demo
%! ## Generate a simple image
%! bw = false (100);
%! bw (10:30, 40:80) = true;
%! bw (40:45, 40:80) = true;
%!
%! ## Find boundaries
%! bounds = bwboundaries (bw);
%!
%! ## Plot result
%! imshow (bw);
%! hold on
%! for k = 1:numel (bounds)
%!   plot (bounds {k} (:, 2), bounds {k} (:, 1), 'r', 'linewidth', 2);
%! endfor
%! hold off

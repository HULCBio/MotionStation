## Copyright (C) 2010 Soren Hauberg
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
## @deftypefn {Function File} {@var{cc} = } bwconncomp (@var{BW})
## @deftypefnx {Function File} {@var{cc} = } bwconncomp (@var{BW}, @var{connectivity})
## Trace the boundaries of objects in a binary image.
##
## @code{bwconncomp} traces the boundaries of objects in a binary image @var{BW}
## and returns information about them in a structure with the following fields.
##
## @table @t
## @item Connectivity
## The connectivity used in the boundary tracing.
## @item ImageSize
## The size of the image @var{BW}.
## @item NumObjects
## The number of objects in the image @var{BW}.
## @item PixelIdxList
## A cell array containing where each element corresponds to an object in @var{BW}.
## Each element is represented as a vector of linear indices of the boundary of
## the given object.
## @end table
##
## The connectivity used in the tracing is by default 4, but can be changed
## by setting the @var{connectivity} input parameter to 8. Sadly, this is not
## yet implemented.
## @seealso{bwlabel, bwboundaries, ind2sub}
## @end deftypefn

function CC = bwconncomp (bw, N = 4)
  ## Check input
  if (nargin < 1)
    error ("bwconncomp: not enough input arguments");
  endif
  if (!ismatrix (bw) || ndims (bw) != 2)
    error ("bwconncomp: first input argument must be a NxM matrix");
  endif
  if (!isscalar (N) || !any (N == [4])) #, 8]))
    error ("bwconncomp: second input argument must be 4");
  endif
  
  ## Trace boundaries
  B = bwboundaries (bw, N);

  ## Convert from (x, y) index to linear indexing
  P = cell (numel (B), 1);
  for k = 1:numel (B)
    P {k} = sub2ind (size (bw), B {k} (:, 2), B {k} (:, 1));
  endfor
  
  ## Return result
  CC = struct ("Connectivity", N, "ImageSize", size (bw), "NumObjects", numel (B));
  CC.PixelIdxList = P;
endfunction

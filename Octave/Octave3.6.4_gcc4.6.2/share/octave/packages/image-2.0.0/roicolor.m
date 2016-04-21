## Copyright (C) 2004 Josep Mones i Teixidor <jmones@puntbarra.com>
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
## @deftypefn {Function File} {@var{BW} =} roicolor (@var{A}, @var{low}, @var{high})
## @deftypefnx {Function File} {@var{BW} = } roicolor (@var{A},@var{v})
## Select a Region Of Interest of an image based on color.
##
## BW = roicolor(A,low,high) selects a region of interest (ROI) of an
## image @var{A} returning a black and white image in a logical array (1 for
## pixels inside ROI and 0 outside ROI), which is formed by all pixels
## whose values lie within the colormap range specified by [@var{low}
## @var{high}].
##
## BW = roicolor(A,v) selects a region of interest (ROI) formed by all
## pixels that match values in @var{v}.
## @end deftypefn

function BW = roicolor (A, p1, p2)
  if (nargin < 2 || nargin > 3)
    print_usage;
  endif

  if (nargin == 2)
    if (!isvector(p1))
      error("BW = roicolor(A, v): v should be a vector.");
    endif
    BW=logical(zeros(size(A)));
    for c=p1
      BW|=(A==c);
    endfor
  elseif (nargin==3)
    if (!isscalar(p1) || !isscalar(p2))
      error("BW = roicolor(A, low, high): low and high must be scalars.");
    endif
    BW=logical((A>=p1)&(A<=p2));
  endif
endfunction

%!demo
%! roicolor([1:10],2,4);
%! % Returns '1' where input values are between 2 and 4 (both included).

%!assert(roicolor([1:10],2,4),logical([0,1,1,1,zeros(1,6)]));
%!assert(roicolor([1,2;3,4],3,3),logical([0,0;1,0]));
%!assert(roicolor([1,2;3,4],[1,4]),logical([1,0;0,1]));

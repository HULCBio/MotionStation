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
## @deftypefn {Function File} @var{B} = imopen (@var{A}, @var{se})
## Perform morphological opening on a given image.
## The image @var{A} must be a grayscale or binary image, and @var{se} must be a
## structuring element.
##
## The opening corresponds to an erosion followed by a dilation of the image, i.e.
## @example
## B = imdilate(imerode(A, se), se);
## @end example
## @seealso{imdilate, imerode, imclose}
## @end deftypefn

function retval = imopen(im, se)
  ## Checkinput
  if (nargin != 2)
    print_usage();
  endif
  if (!ismatrix(im) || !isreal(im))
    error("imopen: first input argument must be a real matrix");
  endif
  if (!ismatrix(se) || !isreal(se))
    error("imopen: second input argument must be a real matrix");
  endif
  
  ## Perform filtering
  retval = imdilate(imerode(im, se), se);

endfunction

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
## @deftypefn {Function File} @var{B} = imclose (@var{A}, @var{se})
## Perform morphological closing on a given image.
## The image @var{A} must be a grayscale or binary image, and @var{se} must be a
## structuring element.
##
## The closing corresponds to a dilation followed by an erosion of the image, i.e.
## @example
## B = imerode(imdilate(A, se), se);
## @end example
## @seealso{imdilate, imerode, imclose}
## @end deftypefn

function retval = imclose (im, se)
  ## Checkinput
  if (nargin != 2)
    print_usage();
  endif
  if (!ismatrix(im) || !isreal(im))
    error("imclose: first input argument must be a real matrix");
  endif
  if (!ismatrix(se) || !isreal(se))
    error("imclose: second input argument must be a real matrix");
  endif
  
  ## Perform filtering
  retval = imerode(imdilate(im, se), se);

endfunction

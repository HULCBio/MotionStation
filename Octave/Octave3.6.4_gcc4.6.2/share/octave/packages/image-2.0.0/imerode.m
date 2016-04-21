## Copyright (C) 2004 Josep Mones i Teixidor <jmones@puntbarra.com>
## Copyright (C) 2008 Soren Hauberg <soren@hauberg.org>
## Copyright (C) 2011 Carnë Draug <carandraug+dev@gmail.com>
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
## @deftypefn {Function File} {@var{B} =} imerode (@var{A}, @var{se})
## Perform morphological erosion on a given image.
##
## The image @var{A} must be a grayscale or binary image, and @var{se} a
## structuring element. Both must have the same class, e.g., if @var{A} is a
## logical matrix, @var{se} must also be logical. Note that the erosion
## algorithm is different for each class, being much faster for logical
## matrices. As such, if you have a binary matrix, you should use @code{logical}
## first. This will also reduce the memory usage of your code.
##
## The center of @var{SE} is calculated using floor((size(@var{SE})+1)/2).
##
## Pixels outside the image are considered to be 0.
##
## @seealso{imdilate, imopen, imclose}
## @end deftypefn

function retval = imerode(im, se)
  ## Checkinput
  if (nargin != 2)
    print_usage();
  endif
  if (!ismatrix(im) || !isreal(im))
    error("imerode: first input argument must be a real matrix");
  elseif (!ismatrix(se) || !isreal(se))
    error("imerode: second input argument must be a real matrix");
  elseif ( !strcmp(class(im), class(se)) )
    error("imerode: image and structuring element must have the same class");
  endif

  ## Perform filtering
  ## If image is binary/logical, try to use filter2 (much faster)
  if (islogical(im))
    thr     = sum(se(:));
    retval  = filter2(se,im) == thr;
  else
    retval  = ordfiltn(im, 1, se, 0);
  endif

endfunction

%!demo
%! imerode(ones(5,5),ones(3,3))
%! % creates a zeros border around ones.

%!assert(imerode(eye(3),[1])==eye(3));                                           # using [1] as a mask returns the same value
%!assert(imerode([0,1,0;1,1,1;0,1,0],[0,0,0;0,0,1;0,1,1])==[1,0,0;0,0,0;0,0,0]); # check if it works with non-symmetric SE

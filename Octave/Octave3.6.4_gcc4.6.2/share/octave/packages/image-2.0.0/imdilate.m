## Copyright (C) 2004 Josep Mones i Teixidor <jmones@puntbarra.com>
## Copyright (C) 2008 Soren Hauberg <soren@hauberg.org>
## Copyright (C) 2010 Carnë Draug <carandraug+dev@gmail.com>
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
## @deftypefn {Function File} {@var{B} =} imdilate (@var{A}, @var{se})
## Perform morphological dilation on a given image.
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
## @seealso{imerode, imopen, imclose}
## @end deftypefn

function retval = imdilate(im, se)
  ## Checkinput
  if (nargin != 2)
    print_usage();
  endif
  if (!ismatrix(im) || !isreal(im))
    error("imdilate: first input argument must be a real matrix");
  elseif (!ismatrix(se) || !isreal(se))
    error("imdilate: second input argument must be a real matrix");
  elseif ( !strcmp(class(im), class(se)) )
    error("imdilate: image and structuring element must have the same class");
  endif

  ## Perform filtering
  ## Filtering must be done with the reflection of the structuring element (they
  ## are not always symmetrical)
  se      = imrotate(se, 180);

  ## If image is binary/logical, try to use filter2 (much faster)
  if (islogical(im))
    retval  = filter2(se,im)>0;
  else
    retval  = ordfiltn(im, sum(se(:)!=0), se, 0);
  endif

endfunction

%!demo
%! imdilate(eye(5),ones(2,2))
%! % returns a thick diagonal.

%!assert(imdilate(eye(3),[1]), eye(3));                     # using [1] as a mask returns the same value
%!assert(logical(imdilate(eye(3),[1])), logical(eye(3)));   # same with logical matrix
%!assert(imdilate(eye(3),[1,0,0]), [0,0,0;1,0,0;0,1,0]);                            # check if it works with non-symmetric SE
%!assert(imdilate(logical(eye(3)),logical([1,0,0])), logical([0,0,0;1,0,0;0,1,0])); # same with logical matrix
## test if center is correctly calculated on even masks. There's no right way,

## it all depends what is considered the center of the structuring element. The
## expected answer here is what Matlab does
%!xtest assert(imdilate(eye(5),[1,0,0,0]), [0,0,0,0,0;1,0,0,0,0;0,1,0,0,0;0,0,1,0,0;0,0,0,1,0]);

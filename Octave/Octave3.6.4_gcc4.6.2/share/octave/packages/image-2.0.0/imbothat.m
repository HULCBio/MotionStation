## Copyright (C) 2005  Carvalho-Mariel
## Copyright (C) 2010-2011 Carnë Draug <carandraug+dev@gmail.com>
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
## @deftypefn {Function File} @var{B} = imbothat (@var{A}, @var{se})
## Perform morphological bottom hat filtering.
##
## The image @var{A} must be a grayscale or binary image, and @var{se} must be a
## structuring element. Both must have the same class, e.g., if @var{A} is a
## logical matrix, @var{se} must also be logical.
##
## A bottom-hat transform is also known as 'black', or 'closing', top-hat
## transform.
##
## @seealso{imerode, imdilate, imopen, imclose, imtophat, mmgradm}
## @end deftypefn

function retval = imbothat (im, se)

  ## Checkinput
  if (nargin != 2)
    print_usage();
  endif
  if (!ismatrix(im) || !isreal(im))
    error("imbothat: first input argument must be a real matrix");
  elseif (!ismatrix(se) || !isreal(se))
    error("imbothat: second input argument must be a real matrix");
  elseif ( !strcmp(class(im), class(se)) )
    error("imbothat: image and structuring element must have the same class");
  endif

  ## Perform filtering
  ## Note that in case that the transform is to applied to a logical image,
  ## subtraction must be handled in a different way (x & !y) instead of (x - y)
  ## or it will return a double precision matrix
  if (islogical(im))
    retval = imclose(im, se) & !im;
  else
    retval = imclose(im, se) - im;
  endif

endfunction

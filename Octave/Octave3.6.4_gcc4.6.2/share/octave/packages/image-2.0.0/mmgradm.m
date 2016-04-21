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
## @deftypefn {Function File} @var{grad} = mmgradm(@var{A}, @var{se})
## @deftypefnx {Function File} @var{grad} = mmgradm(@var{A}, @var{se_dil}, @var{se_ero})
## Calculates the morphological gradient @var{grad} of a given image @var{A}.
##
## In the first form, the same structuring element @var{se} is used for dilation
## and erosion. In the second form, @var{se_dil} and @var{se_ero} are the
## corresponding structuring elements used for dilation and erosion
##
## The image @var{A} must be a grayscale or a binary image.
##
## The morphological gradient of a image corresponds to its erosion subtracted
## to its dilation.
##
## @seealso{imerode, imdilate, imopen, imclose, imtophat, imbothat}
## @end deftypefn

function grad = mmgradm (im, se_dil, se_ero)

  ## sanity checks
  if (nargin == 1)
    error ("Structuring element must be specified");
  elseif (nargin == 2)              # if only one SE is specified, use it for both erosion and dilation
    se_ero  = se_dil;
  elseif (nargin == 3)
    # all is good
  else
    print_usage;
  endif

  dilated   = imdilate  (im, se_dil);
  eroded    = imerode   (im, se_ero);

  grad      = dilated - eroded;
endfunction

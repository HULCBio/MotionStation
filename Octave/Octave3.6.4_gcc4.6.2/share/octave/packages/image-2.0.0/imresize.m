## Copyright (C) 2005 Søren Hauberg <soren@hauberg.org>
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
## @deftypefn {Function File} @var{B}= imresize (@var{A}, @var{m})
## Scales the image @var{A} by a factor @var{m} using bicubic neighbour
## interpolation. If @var{m} is less than 1 the image size will be reduced,
## and if @var{m} is greater than 1 the image will be enlarged.
##
## @deftypefnx {Function File} @var{B}= imresize (@var{A}, @var{m}, @var{interp})
## Same as above except @var{interp} interpolation is performed instead of
## using nearest neighbour. @var{interp} can be any interpolation method supported by interp2.
## By default, bicubic interpolation is used.
##
## @deftypefnx {Function File} @var{B}= imresize (@var{A}, [@var{mrow} @var{mcol}])
## Scales the image @var{A} to be of size @var{mrow}x@var{mcol}.
##
## @deftypefnx {Function File} @var{B}= imresize (@var{A}, [@var{mrow} @var{mcol}], @var{interp})
## Same as above except @var{interp} interpolation is performed. @var{interp} can
## be any interpolation method supported by interp2.
## @seealso{imremap, imrotate, interp2}
## @end deftypefn

function ret = imresize(im, m, interp = "bicubic")
  if (nargin < 2)
    error ("imresize: not enough input arguments");
  endif
  
  [row, col, num_planes, tmp] = size (im);
  if (tmp != 1 || (num_planes != 1 && num_planes != 3))
    error ("imresize: the first argument has must be an image");
  endif

  ## Handle the argument that describes the size of the result
  if (length (m) == 1)
    new_row = round (row*m);
    new_col = round (col*m);
  elseif (length (m) == 2)
    new_row = m (1);
    new_col = m (2);
    m = min (new_row/row, new_col/col);
  else
    error ("imresize: second argument mest be a scalar or a 2-vector");
  end

  ## Handle the method argument
  if (!any (strcmpi (interp, {"nearest", "linear", "bilinear", "cubic", "bicubic", "pchip"})))
    error ("imresize: unsupported interpolation method");
  endif

  
  ## Perform the actual resizing
  [XI, YI] = meshgrid (linspace (1,col, new_col), linspace (1, row, new_row) );
  ret = imremap (im, XI, YI, interp);
endfunction

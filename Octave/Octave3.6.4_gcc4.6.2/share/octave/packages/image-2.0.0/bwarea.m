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
## @deftypefn {Function File} {@var{total} =} bwarea (@var{bw})
## Estimate total area of objects on the image @var{bw}.
##
## The image @var{bw} can be of any class, even non-logical, in which case non
## zero valued pixels are considered to be an object.
##
## This algorithm is not the same as counting the number of pixels belonging to
## an object as it tries to estimate the area of the original object.  The value
## of each pixel to the total area is weighted in relation to its neighbour
## pixels.
##
## @seealso{im2bw, bweuler, bwperim, regionprops}
## @end deftypefn

function total = bwarea (bw)
  if (nargin != 1)
    print_usage;
  elseif (!isimage (bw) || ndims (bw) != 2)
    error("bwarea: input image must be a 2D image");
  elseif (!islogical (bw))
    bw = (bw != 0)
  endif
  
  four = ones (2);
  two  = diag ([1 1]);

  fours = conv2 (bw, four);
  twos  = conv2 (bw, two);

  nQ1 = sum (fours(:) == 1);
  nQ3 = sum (fours(:) == 3);
  nQ4 = sum (fours(:) == 4);
  nQD = sum (fours(:) == 2 & twos(:) != 1);
  nQ2 = sum (fours(:) == 2 & twos(:) == 1);

  total = 0.25*nQ1 + 0.5*nQ2 + 0.875*nQ3 + nQ4 + 0.75*nQD;

endfunction

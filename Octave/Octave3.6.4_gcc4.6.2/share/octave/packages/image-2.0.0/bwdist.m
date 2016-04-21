## Copyright (C) 2006 Stefan Gustavson
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
## @deftypefn {Function File} {@var{D} =} bwdist(@var{bw})
##
## Computes the distance transform of the image @var{bw}.
## @var{bw} should be a binary 2D array, either a Boolean array or a
## numeric array containing only the values 0 and 1.
## The return value @var{D} is a double matrix of the same size as @var{bw}.
## Elements with value 0 are considered background pixels, elements
## with value 1 are considered object pixels. The return value
## for each background pixel is the distance (according to the chosen
## metric) to the closest object pixel. For each object pixel the
## return value is 0.
## 
## @deftypefnx{Function File} {@var{D} =} bwdist(@var{bw}, @var{method})
## 
## @var{method} is a string to choose the distance metric. Currently
## available metrics are 'euclidean', 'chessboard', 'cityblock' and
## 'quasi-euclidean', which may each be abbreviated to any string
## starting with 'e', 'ch', 'ci' and 'q', respectively.
## If @var{method} is not specified, 'euclidean' is the default.
## 
## @deftypefnx {Function File} {[@var{D},@var{C}] =} bwdist(@var{bw}, @var{method})
## 
## If a second output argument is given, the linear index for the
## closest object pixel is returned for each pixel. (For object
## pixels, the index points to the pixel itself.) The return value
## @var{C} is a matrix the same size as @var{bw}.
## @end deftypefn

# This M wrapper is an almost direct pass-through to an oct function,
# but it might prove useful for a future extension to handle N-D data.
# The algorithm implemented by __bwdist() is 2D-only.

function [D, C] = bwdist(bw, method = "euclidean")
  
  if (!ischar(method))
    error("bwdist: method name must be a string");
  endif

  if (nargout < 2)
    D = __bwdist(bw, method);
  else
    [D, C] = __bwdist(bw, method);
  endif

endfunction

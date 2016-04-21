## Copyright (C) 2000 Kai Habel <kai.habel@gmx.de>
## Copyright (C) 2008 Jonas Wagner <j.b.w@gmx.ch>
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
## @deftypefn {Function File} @var{J} = histeq (@var{I}, @var{n})
## Histogram equalization of a gray-scale image. The histogram contains
## @var{n} bins, which defaults to 64.
##
## @var{I}: Image in double format, with values from 0.0 to 1.0
##
## @var{J}: Returned image, in double format as well
## @seealso{imhist}
## @end deftypefn

function J = histeq (I, n)
  if (nargin == 0)
    print_usage();
  elseif (nargin == 1)
    n = 64;
  endif

  [r,c] = size(I); 
  I = mat2gray(I);
  [X,map] = gray2ind(I, n);
  [nn,xx] = imhist(I, n);
  Icdf = 1 / prod(size(I)) * cumsum(nn);
  J = reshape(Icdf(X),r,c);
  plot(Icdf,'b');
  legend( 'Image Cumulative Density Function');
endfunction

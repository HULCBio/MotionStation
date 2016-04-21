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
## @deftypefn {Function File} {@var{cc} =} normxcorr2 (@var{template}, @var{img})
## @deftypefnx {Function File} {@var{cc} =} normxcorr2 (@var{template}, @var{img})
## Compute the normalized 2D cross correlation.
##
## The output matrix @var{cc} shows the correlation coefficients of @var{template}
## for each position in @var{img}.
## @seealso{conv2, corr2, xcorr2}
## @end deftypefn

function cc = normxcorr2 (temp, img)
  if (nargin != 2)
    print_usage;
  elseif (rows (temp) > rows (img) || columns (temp) > columns (img))
    error ("normxcorr2: template must be same size or smaller than image");
  endif
  cc = xcorr2 (img, temp, "coeff");
endfunction

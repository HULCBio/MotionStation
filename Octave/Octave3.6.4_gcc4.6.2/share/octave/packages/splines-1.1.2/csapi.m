## Copyright (C) 2000 Kai Habel
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
## @deftypefn {Function File} {@var{pp} = } csapi (@var{x}, @var{y})
## @deftypefnx {Function File} {@var{yi} = } csapi (@var{x}, @var{y}, @var{xi})
## cubic spline interpolation
##
## @seealso{ppval, spline, csape}
## @end deftypefn

## Author:  Kai Habel <kai.habel@gmx.de>
## Date: 3. dec 2000

function ret = csapi (x, y, xi)

  ret = csape(x,y,'not-a-knot');

  if (nargin == 3)
    ret = ppval(ret,xi);
  endif

endfunction

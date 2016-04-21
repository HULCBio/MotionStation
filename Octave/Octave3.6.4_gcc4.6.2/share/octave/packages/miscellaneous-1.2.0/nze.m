## Copyright (C) 2010 VZLU Prague
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
## @deftypefn{Function File} {[@var{y}, @var{f}] = } nze (@var{x}) 
## Extract nonzero elements of @var{x}. Equivalent to @code{@var{x}(@var{x} != 0)}.
## Optionally, returns also linear indices.
## @end deftypefn

## Author:        Etienne Grossmann <etienne@egdn.net>
## Author:        Jaroslav Hajek <highegg@gmail.com>

function [y, f] = nze (x)
  nz = x != 0;
  y = x(nz);
  if (nargout > 1)
    f = find (nz);
  endif
endfunction

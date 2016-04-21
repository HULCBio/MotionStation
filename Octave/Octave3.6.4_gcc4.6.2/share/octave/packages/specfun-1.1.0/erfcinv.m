## Copyright (C) 2006   Sylvain Pelissier   <sylvain.pelissier@gmail.com>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} erfcinv (@var{x})
## Compute the inverse complementary error function.
## @seealso{erfc,erf,erfinv}
## @end deftypefn

function y = erfcinv(x)
  if (nargin != 1)
    print_usage;
  endif
  y = erfinv(1-x);
endfunction

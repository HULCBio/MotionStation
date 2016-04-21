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
## @deftypefn {Function File} {@var{y} =} expint (@var{x})
## Compute the exponential integral,
## @verbatim
##                    infinity
##                   /
##       expint(x) = | exp(t)/t dt
##                   /
##                  x
## @end verbatim
## @seealso{expint_E1, expint_Ei}
## @end deftypefn

function y = expint(x)
  if (nargin != 1)
    print_usage;
  endif
  y = expint_E1(x);
endfunction

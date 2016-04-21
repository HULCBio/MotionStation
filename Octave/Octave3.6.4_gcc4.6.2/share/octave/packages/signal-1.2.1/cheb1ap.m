## Copyright (C) 2013 Carnë Draug <carandraug+dev@gmail.com>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {[@var{z}, @var{p}, @var{g}] =} cheb1ap (@var{n}, @var{Rp})
## Design lowpass analog Chebyshev type I filter.
##
## This function exists only for matlab compatibility and is equivalent to
## @code{cheby1 (@var{n}, @var{Rp}, 1, "s")}
##
## @seealso{cheby1}
## @end deftypefn

function [z, p, g] = cheb1ap (n, Rp)
  if (nargin != 2)
    print_usage();
  elseif (! isscalar (n) || ! isnumeric (n) || fix (n) != n || n <= 0)
    error ("cheb1ap: N must be a positive integer")
  elseif (! isscalar (Rp) || ! isnumeric (Rp) || Rp < 0)
    error ("cheb1ap: RP must be a non-negative scalar")
  endif
  [z, p, g] = cheby1 (n, Rp, 1, "s");
endfunction

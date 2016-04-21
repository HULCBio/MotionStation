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
## @deftypefn {Function File} {[@var{z}, @var{p}, @var{g}] =} cheb2ap (@var{n}, @var{Rs})
## Design lowpass analog Chebyshev type II filter.
##
## This function exists only for matlab compatibility and is equivalent to
## @code{cheby2 (@var{n}, @var{Rs}, 1, "s")}
##
## @seealso{cheby2}
## @end deftypefn

function [z, p, g] = cheb2ap (n, Rp)
  if (nargin != 2)
    print_usage();
  elseif (! isscalar (n) || ! isnumeric (n) || fix (n) != n || n <= 0)
    error ("cheb2ap: N must be a positive integer")
  elseif (! isscalar (Rs) || ! isnumeric (Rs) || Rs < 0)
    error ("cheb2ap: RS must be a non-negative scalar")
  endif
  [z, p, g] = cheby2 (n, Rs, 1, "s");
endfunction

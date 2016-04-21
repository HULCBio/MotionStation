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
## @deftypefn {Function File} {[@var{z}, @var{p}, @var{g}] =} buttap (@var{n})
## Design lowpass analog Butterworth filter.
##
## This function exists only for matlab compatibility and is equivalent to
## @code{butter (@var{n}, 1, "s")}
##
## @seealso{butter}
## @end deftypefn

function [z, p, g] = buttap (n)
  if (nargin != 1)
    print_usage();
  elseif (! isscalar (n) || ! isnumeric (n) || fix (n) != n || n <= 0)
    error ("buttap: N must be a positive integer")
  endif
  [z, p, g] = butter (n, 1, "s");
endfunction

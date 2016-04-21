## Copyright (C) 2001 Kai Habel
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
## @deftypefn {Function File} { } fnder (@var{pp}, @var{order})
## differentiate the spline in pp-form 
##
## @seealso{ppval}
## @end deftypefn

## Author:  Kai Habel <kai.habel@gmx.de>
## Date: 20. feb 2001

function dpp = fnder (pp, o)

  if (nargin < 1 || nargin > 2)
    print_usage;
  endif
  if (nargin < 2)
    o = 1;
  endif

  [X, P, N, K, D] = unmkpp (pp);
  c = columns (P);
  r = rows (P);

  for i = 1:o
    #pp.P = polyder (pp.P); matrix capable polyder is needed.
    P = P(:, 1:c - 1) .* kron ((c - 1):- 1:1, ones (r,1));
  endfor

  dpp = mkpp (X, P);

endfunction

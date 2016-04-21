## Copyright (C) 2003 Paul H. C. Eilers <p.eilers@erasmusmc.nl>
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
## @deftypefn {Function File} {@var{D} =} ddmat (@var{x}, @var{o})
## Compute divided differencing matrix of order @var{o}
##
## @itemize @w
## @item Input
##   @itemize @w
##     @item @var{x}:  vector of sampling positions
##     @item @var{o}:  order of diffferences
##   @end itemize
## @item Output
##   @itemize @w
##     @item @var{D}:  the matrix; @var{D} * Y gives divided differences of order @var{o}
##   @end itemize
## @end itemize
##
## References:  Anal. Chem. (2003) 75, 3631.
##
## @end deftypefn

## corrected the recursion multiplier; JJS 2/25/08
## added error check that x is a column vector; JJS 4/13/09

function D = ddmat(x, d)
  if (nargin != 2)
    print_usage;
  elseif ( !iscolumn (x) )
    error("x should be a column vector")
  endif
  m = length(x);
  if d == 0
    D = speye(m);
  else
    dx = x((d + 1):m) - x(1:(m - d));
    V = sparse(diag(1 ./ dx));
    D = d * V * diff(ddmat(x, d - 1));
  endif
endfunction

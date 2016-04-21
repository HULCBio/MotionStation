## Copyright (C) 2013 Mike Miller <mtmiller@ieee.org>
##
## This program is free software: you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation, either version 3 of the License, or (at your option) any later
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
## @deftypefn  {Function File} {} fwht (@var{x})
## @deftypefnx {Function File} {} fwht (@var{x}, @var{n})
## @deftypefnx {Function File} {} fwht (@var{x}, @var{n}, @var{order})
## Compute the Walsh-Hadamard transform of @var{x} using the Fast
## Walsh-Hadamard Transform (FWHT) algorithm.  If the input is a matrix,
## the FWHT is calculated along the columns of @var{x}.
##
## The number of elements of @var{x} must be a power of 2; if not, the
## input will be extended and filled with zeros.  If a second argument
## is given, the input is truncated or extended to have length @var{n}.
##
## The third argument specifies the @var{order} in which the returned
## Walsh-Hadamard transform coefficients should be arranged.  The
## @var{order} may be any of the following strings:
##
## @table @asis
## @item "sequency"
## The coefficients are returned in sequency order.  This is the default
## if @var{order} is not given.
##
## @item "hadamard"
## The coefficients are returned in Hadamard order.
##
## @item "dyadic"
## The coefficients are returned in Gray code order.
## @end table
##
## @seealso{ifwht}
## @end deftypefn

## Author: Mike Miller

function y = fwht (x, n, order)

  if (nargin < 1 || nargin > 3)
    print_usage ();
  elseif (nargin == 1)
    n = order = [];
  elseif (nargin == 2)
    order = [];
  endif

  [y, n] = __fwht_opts__ ("fwht", x, n, order);
  y /= n;

endfunction

%!assert (isempty (fwht ([])));
%!assert (fwht (zeros (16)), zeros (16));
%!assert (fwht (ones (16, 1)), [1; (zeros (15, 1))]);
%!assert (fwht (zeros (17, 1)), zeros (32, 1));
%!assert (fwht ([1 -1 1 -1 1 -1 1 -1]), [0 0 0 0 0 0 0 1]);

%!test
%! x = randi (16, 16);
%! assert (ifwht (fwht (x)), x);

%% Test input validation
%!error fwht ();
%!error fwht (1, 2, 3, 4);
%!error fwht (0, 0);
%!error fwht (0, 5);
%!error fwht (0, [], "invalid");

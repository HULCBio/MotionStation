## Copyright (C) 1994-2012 John W. Eaton
##
## This file is part of Octave.
##
## Octave is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## Octave is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Mapping Function} {} asech (@var{x})
## Compute the inverse hyperbolic secant of each element of @var{x}.
## @seealso{sech}
## @end deftypefn

## Author: jwe

function y = asech (x)

  if (nargin != 1)
    print_usage ();
  endif

  y = acosh (1 ./ x);

endfunction

%!test
%! v = [0, pi*i];
%! x = [1, -1];
%! assert(all (abs (asech (x) - v) < sqrt (eps)));

%!error asech ();

%!error asech (1, 2);


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
## @deftypefn {Mapping Function} {} acsc (@var{x})
## Compute the inverse cosecant in radians for each element of @var{x}.
## @seealso{csc, acscd}
## @end deftypefn

## Author: jwe

function y = acsc (x)

  if (nargin != 1)
    print_usage ();
  endif

  y = asin (1 ./ x);

endfunction

%!test
%! rt2 = sqrt (2);
%! rt3 = sqrt (3);
%! v = [pi/6, pi/4, pi/3, pi/2, pi/3, pi/4, pi/6];
%! x = [2, rt2, 2*rt3/3, 1, 2*rt3/3, rt2, 2];
%! assert(all (abs (acsc (x) - v) < sqrt (eps)));

%!error acsc ();

%!error acsc (1, 2);


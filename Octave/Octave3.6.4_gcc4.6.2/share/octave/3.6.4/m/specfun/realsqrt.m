## Copyright (C) 2008-2012 David Bateman
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
## @deftypefn {Function File} {} realsqrt (@var{x})
## Return the real-valued square root of each element of @var{x}.  Report an
## error if any element results in a complex return value.
## @seealso{sqrt, realpow, reallog}
## @end deftypefn

function y = realsqrt (x)
  if (nargin != 1)
    print_usage ();
  elseif (iscomplex (x) || any (x(:) < 0))
    error ("realsqrt: produced complex result");
  else
    y = sqrt (x);
  endif
endfunction

%!assert (sqrt(1:5),realsqrt(1:5))
%!test
%! x = rand (10,10);
%! assert (sqrt(x),realsqrt(x))
%!error (realsqrt(-1))

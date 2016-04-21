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
## @deftypefn {Function File} {} reallog (@var{x})
## Return the real-valued natural logarithm of each element of @var{x}.  Report
## an error if any element results in a complex return value.
## @seealso{log, realpow, realsqrt}
## @end deftypefn

function y = reallog (x)
  if (nargin != 1)
    print_usage ();
  elseif (iscomplex (x) || any (x(:) < 0))
    error ("reallog: produced complex result");
  else
    y = log (x);
  endif
endfunction

%!assert (log(1:5),reallog(1:5))
%!test
%! x = rand (10,10);
%! assert (log(x),reallog(x))
%!error (reallog(-1))

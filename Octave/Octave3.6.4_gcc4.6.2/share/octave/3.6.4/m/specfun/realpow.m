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
## @deftypefn {Function File} {} realpow (@var{x}, @var{y})
## Compute the real-valued, element-by-element power operator.  This is
## equivalent to @w{@code{@var{x} .^ @var{y}}}, except that @code{realpow}
## reports an error if any return value is complex.
## @seealso{reallog, realsqrt}
## @end deftypefn

function z = realpow (x, y)
  if (nargin != 2)
    print_usage ();
  else
    z = x .^ y;
    if (iscomplex (z))
      error ("realpow: produced complex result");
    endif
  endif
endfunction

%!assert (power (1:10, 0.5:0.5:5), realpow (1:10, 0.5:0.5:5))
%!assert ([1:10] .^ [0.5:0.5:5], realpow (1:10, 0.5:0.5:5))
%!test
%! x = rand (10,10);
%! y = randn (10,10);
%! assert (x.^y,realpow(x,y))
%!assert (realpow(1i,2),-1)
%!error (realpow(-1, 1/2))

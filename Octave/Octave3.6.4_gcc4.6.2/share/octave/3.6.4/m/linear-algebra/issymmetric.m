## Copyright (C) 1996-2012 John W. Eaton
## Copyright (C) 2009 VZLU Prague
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
## @deftypefn  {Function File} {} issymmetric (@var{x})
## @deftypefnx {Function File} {} issymmetric (@var{x}, @var{tol})
## Return true if @var{x} is a symmetric matrix within the tolerance specified
## by @var{tol}.  The default tolerance is zero (uses faster code).
## Matrix @var{x} is considered symmetric if
## @code{norm (@var{x} - @var{x}.', Inf) / norm (@var{x}, Inf) < @var{tol}}.
## @seealso{ishermitian, isdefinite}
## @end deftypefn

## Author: A. S. Hodel <scotte@eng.auburn.edu>
## Created: August 1993
## Adapted-By: jwe

function retval = issymmetric (x, tol = 0)

  if (nargin < 1 || nargin > 2)
    print_usage ();
  endif

  retval = isnumeric (x) && issquare (x);
  if (retval)
    if (tol == 0)
      retval = all ((x == x.')(:));
    else
      norm_x = norm (x, inf);
      retval = norm_x == 0 || norm (x - x.', inf) / norm_x <= tol;
    endif
  endif

endfunction

%!assert(issymmetric (1));
%!assert(!(issymmetric ([1, 2])));
%!assert(issymmetric ([]));
%!assert(issymmetric ([1, 2; 2, 1]));
%!assert(!(issymmetric ("test")));
%!assert(issymmetric ([1, 2.1; 2, 1.1], 0.2));
%!assert(issymmetric ([1, 2i; 2i, 1]));
%!assert(!(issymmetric ("t")));
%!assert(!(issymmetric (["te"; "et"])));
%!error issymmetric ([1, 2; 2, 1], 0, 0);
%!error issymmetric ();

%!test
%! s.a = 1;
%! assert(!(issymmetric (s)));

## Copyright (C) 2009 Javier Enciso <j4r.e4o@gmail.com>
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
## @deftypefn {Function file} {@var{x}, @var{y}} hilbert_curve (@var{n})
## Creates an iteration of the Hilbert space-filling curve with @var{n} points. 
## The argument @var{n} must be of the form @code{2^M}, where @var{m} is an 
## integer greater than 0.
## 
## @example
## n = 8
## [x ,y] = hilbert_curve (n);
## line (x, y, "linewidth", 4, "color", "blue");
## @end example
## 
## @end deftypefn

function [x, y] = hilbert_curve (n)

  if (nargin != 1)
    print_usage ();
  endif
  
  check_power_of_two (n);
  if (n == 2)
    x = [0, 0, 1, 1];
    y = [0, 1, 1, 0];
  else
    [x1, y1] = hilbert_curve (n/2);
    x = [y1, x1, n/2 + x1, n - 1 - y1];
    y = [x1, n/2 + y1, n/2 + y1, n/2 - 1 - x1];
  endif
  
endfunction

function check_power_of_two (n)
  if (frac_part (log (n) / log (2)) != 0)
    error ("hilbert_curve: input argument must be a power of 2.")
  endif
endfunction

function d = frac_part (f)
  d = f - floor (f);
endfunction

%!test
%! n = 2;
%! expect = [0, 0, 1, 1; 0, 1, 1, 0];
%! [get(1,:), get(2,:)] = hilbert_curve (n);
%! if (any(size (expect) != size (get)))
%!   error ("wrong size: expected %d,%d but got %d,%d", size (expect), size (get));
%! elseif (any (any (expect!=get)))
%!   error ("didn't get what was expected.");
%! endif

%!test
%! n = 5;
%!error hilbert_curve (n);

%!demo
%! clf
%! n = 4;
%! [x, y] = hilbert_curve (n);
%! line (x, y, "linewidth", 4, "color", "blue");
%! % -----------------------------------------------------------------------
%! % the figure window shows an iteration of the Hilbert space-fillig curve 
%! % with 4 points on each axis.

%!demo
%! clf
%! n = 64;
%! [x, y] = hilbert_curve (n);
%! line (x, y, "linewidth", 2, "color", "blue");
%! % ----------------------------------------------------------------------
%! % the figure window shows an iteration of the Hilbert space-fillig curve 
%! % with 64 points on each axis.

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
## @deftypefn {Function file} {@var{x}, @var{y}} peano_curve (@var{n})
## Creates an iteration of the Peano space-filling curve with @var{n} points. 
## The argument @var{n} must be of the form @code{3^M}, where @var{m} is an 
## integer greater than 0.
## 
## @example
## n = 9;
## [x, y] = peano_curve (n);
## line (x, y, "linewidth", 4, "color", "red");
## @end example
## 
## @end deftypefn

function [x, y] = peano_curve (n)
  
  if (nargin != 1)
    print_usage ();
  endif
  
  check_power_of_three (n);
  if (n == 3)
    x = [0, 0, 0, 1, 1, 1, 2, 2, 2];
    y = [0, 1, 2, 2, 1, 0, 0, 1, 2];
  else
    [x1, y1] = peano_curve (n/3);
    x2 = n/3 - 1 - x1;
    x3 = n/3 + x1;
    x4 = n - n/3 - 1 - x1;
    x5 = n - n/3 + x1;
    x6 = n - 1 - x1;
    y2 = n/3 + y1;
    y3 = n - n/3 + y1;
    y4 = n - 1 - y1;
    y5 = n - n/3 - 1 - y1;
    y6 = n/3 - 1 - y1;
    x = [x1, x2, x1, x3, x4, x3, x5, x6, x5];
    y = [y1, y2, y3, y4, y5, y6, y1, y2, y3];
  endif
  
endfunction

function check_power_of_three (n)
  if (frac_part (log (n) / log (3)) != 0)
    error ("peano_curve: input argument must be a power of 3.")
  endif
endfunction

function d = frac_part (f)
  d = f - floor (f);
endfunction

%!test
%! n = 3;
%! expect(1,:) = [0, 0, 0, 1, 1, 1, 2, 2, 2];
%! expect(2,:) = [0, 1, 2, 2, 1, 0, 0, 1, 2];
%! [get(1,:), get(2,:)] = peano_curve (n);
%! if (any(size (expect) != size (get)))
%!   error ("wrong size: expected %d,%d but got %d,%d", size (expect), size (get));
%! elseif (any (any (expect!=get)))
%!   error ("didn't get what was expected.");
%! endif

%!test
%! n = 5;
%!error peano_curve (n);

%!demo
%! clf
%! n = 9;
%! [x, y] = peano_curve (n);
%! line (x, y, "linewidth", 4, "color", "red");
%! % --------------------------------------------------------------------
%! % the figure window shows an iteration of the Peano space-fillig curve 
%! % with 9 points on each axis.

%!demo
%! clf
%! n = 81;
%! [x, y] = peano_curve (n);
%! line (x, y, "linewidth", 2, "color", "red");
%! % --------------------------------------------------------------------
%! % the figure window shows an iteration of the Peano space-fillig curve 
%! % with 81 points on each axis.

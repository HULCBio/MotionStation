## Copyright (C) 1999 Paul Kienzle
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; If not, see <http://www.gnu.org/licenses/>.

## Clip values outside the range to the value at the boundary of the
## range.
##
## X = clip(X)
##   Clip to range [0, 1]
##
## X = clip(X, hi)
##   Clip to range [0, hi]
##
## X = clip(X, [lo, hi])
##   Clip to range [lo, hi]

## TODO: more clip modes, such as three level clip(X, [lo, mid, hi]), which
## TODO: sends everything above hi to hi, below lo to lo and between to
## TODO: mid; or infinite peak clipping, which sends everything above mid
## TODO: to hi and below mid to lo.

function x = clip (x, range)

  if (nargin == 2)
    if (length(range) == 1)
      range = [0, range];
    end
  elseif (nargin == 1)
    range = [0, 1];
  else
    usage("X = clip(X [, range])");
  end
  try wfi = warning("query", "Octave:fortran-indexing").state;
  catch wfi = "off";
  end
  unwind_protect
    x (find (x > range (2))) = range (2);
    x (find (x < range (1))) = range (1);
  unwind_protect_cleanup
    warning(wfi, "Octave:fortran-indexing");
  end_unwind_protect

endfunction

%!error clip
%!error clip(1,2,3)
%!assert (clip(pi), 1)
%!assert (clip(-pi), 0)
%!assert (clip([-1.5, 0, 1.5], [-1, 1]), [-1, 0, 1]);
%!assert (clip([-1.5, 0, 1.5]', [-1, 1]'), [-1, 0, 1]');
%!assert (clip([-1.5, 1; 0, 1.5], [-1, 1]), [-1, 1; 0, 1]);
%!assert (isempty(clip([],1)));

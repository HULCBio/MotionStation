## Copyright (C) 1998, 2000, 2004, 2005, 2007
##               Auburn University.  All rights reserved.
##
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {} __axis_limits__ (@var{axdata})
## Determine axis limits for 2-D data (column vectors); leaves a 10%
## margin around the plots.
## Inserts margins of +/- 0.1 if data is one-dimensional 
## (or a single point).
##
## @strong{Input}
## @table @var
## @item axdata
## @var{n} by 2 matrix of data [@var{x}, @var{y}].
## @end table
##
## @strong{Output}
## @table @var
## @item axvec
## Vector of axis limits appropriate for call to @command{axis} function.
## @end table
## @end deftypefn

function axvec = __axis_limits__ (axdata)

  if (nargin < 1 || isempty (axdata))
    axdata = 0;
  endif

  ## compute axis limits
  minv = min (axdata);
  maxv = max (axdata);
  delv = (maxv-minv)/2;             # breadth of the plot
  midv = (minv + maxv)/2;           # midpoint of the plot
  axmid = [midv(1), midv(1), midv(2), midv(2)];
  axdel = [-0.1, 0.1, -0.1, 0.1];   # default plot width (if less than 2-d data)
  if (max (delv) == 0)
    if (midv(1) != 0)
      axdel(1:2) = [-0.1*midv(1), 0.1*midv(1)];
    endif
    if (midv(2) != 0)
      axdel(3:4) = [-0.1*midv(2), 0.1*midv(2)];
    endif
  else
    ## they're at least one-dimensional
    tolv = max(1e-8, 1e-8*abs(midv));
    if (abs (delv(1)) >= tolv(1))
      axdel(1:2) = 1.1*[-delv(1),delv(1)];
    endif
    if (abs (delv(2)) >= tolv(2))
      axdel(3:4) = 1.1*[-delv(2),delv(2)];
    endif
  endif
  axvec = axmid + axdel;

endfunction

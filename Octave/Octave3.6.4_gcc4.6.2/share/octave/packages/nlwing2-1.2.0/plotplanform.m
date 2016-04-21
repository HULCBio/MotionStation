% Copyright (C) 2009  VZLU Prague, a.s., Czech Republic
% 
% Author: Jaroslav Hajek <highegg@gmail.com>
% 
% This file is part of NLWing2.
% 
% NLWing2 is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this software; see the file COPYING.  If not, see
% <http://www.gnu.org/licenses/>.
% 

% -*- texinfo -*-
% @deftypefn{Function File} plotplanform (ac, npan = 80)
% @end deftypefn

function plotplanform (wing)
  zac = wing.zac;
  xac = wing.xac;
  cac = wing.cac;

  x = [zac; flipud(zac)];
  y = [xac - 1/4*cac; flipud(xac + 3/4*cac)];

  if (wing.sym)
    x = [x; -x];
    y = [y; y];
  else
    x(end+1,:) = x(1,:);
    y(end+1,:) = y(1,:);
  endif

  plot (x, y);
  r = 0.05 * max(abs (x));
  lims = [min(x) - r, max(x) + r];
  set (gca, "xlim", lims);
  set (gca, "ylim", lims);

endfunction

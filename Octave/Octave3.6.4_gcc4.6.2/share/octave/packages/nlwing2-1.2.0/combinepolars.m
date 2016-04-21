% Copyright (C) 2008  VZLU Prague, a.s., Czech Republic
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
% @deftypefn{Function File} {pol =} combinepolars (pol1, pol2, coef)
% @deftypefnx{Function File} {pol =} combinepolars (pol1, pol2, c1, c2, c)
% Combines two polars to get a specific interpolation. Useful when
% you repeatedly change the chord length at a particular section,
% and you don't want to recalculate each time using different local
% Reynolds number. A good streategy here is evaluate the boundary values
% or a few more and then interpolate.
% You can either directly specify an interpolation coefficient (pol1 is 1, pol2 is 0),
% or a pair of chord lengths and a requested chord length.
% @end deftypefn

function pol = combinepolars (pol1, pol2, varargin)
  if (nargin == 3)
    c = varargin{1};
  elseif (nargin == 5)
    [c1, c2, c] = deal (varargin{1:3});
    # interpolate according to log(Re).
    c = (log (c) - log (c2)) / (log (c1) - log (c2));
  else
    print_usage ();
  endif
  d = 1-c;
  pol.a0 = c*pol1.a0 + d*pol2.a0;
  pol.amax = c*pol1.amax + d*pol2.amax;
  pol.clmax = c*pol1.clmax + d*pol2.clmax;
  alpha1 = pol1.cl.x; alpha2 = pol2.cl.x;
  # try to honor the minimum resolution.
  xmin = min (alpha1(1), alpha2(1));
  xmax = max (alpha1(end), alpha2(end));
  dx = min (min (diff (alpha1)), min (diff (alpha2)));
  dx = max (dx, 1e-3*(xmax - xmin));
  ialpha = unique (round (([alpha1; alpha2] - xmin) / dx));
  alpha = xmin + ialpha * dx;
  pol.cl = pchip (alpha, c*ppval (pol1.cl, alpha) + d*ppval (pol2.cl, alpha));
  pol.cld = polppder (pol.cl);
  pol.cd = pchip (alpha, c*ppval (pol1.cd, alpha) + d*ppval (pol2.cd, alpha));
  pol.cm = pchip (alpha, c*ppval (pol1.cm, alpha) + d*ppval (pol2.cm, alpha));
  if (isfield (pol1, "z"))
    pol.z = c*pol1.z + d*pol2.z;
  endif
endfunction

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
% @deftypefn{Function File} {dg =} floweq (g, flow)
% evaluates the right-hand sides of the spanwise flow equations
% given the spanwise distribution of flow control quantities (scaled
% circulations).
% @end deftypefn

function eq = floweq (g, flow)

  % calc local velocities
  vx = flow.vxg*g + flow.vx0; 
  vy = flow.vyg*g + flow.vy0;
  % local angles of attack
  alfa = atan2 (vy, vx);
  % interpolate local lifts
  wing = flow.wing;
  cl = spwinterp (alfa, wing, [wing.pol.cl]);
  % calc g differences
  v = sqrt (vx.^2 + vy.^2);
  eq = 0.5 * cl .* v - g;

endfunction

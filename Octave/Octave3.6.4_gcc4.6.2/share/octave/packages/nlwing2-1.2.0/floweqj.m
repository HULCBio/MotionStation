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
% @deftypefn{Function File} {dg =} floweqj (g, flow)
% this function calculates the jacobian of @w{floweq} w.r.t. @var{g}.
% @end deftypefn

function eqj = floweqj (g, flow)

  % calc local velocities
  vx = flow.vxg*g + flow.vx0; 
  vy = flow.vyg*g + flow.vy0;
  % local angles of attack
  alfa = atan2 (vy, vx);
  wing = flow.wing;
  cl = spwinterp (alfa, wing, [wing.pol.cl]);
  cld = spwinterp (alfa, wing, [wing.pol.cld], true);
  v = sqrt (vx.^2 + vy.^2);
  gvx = 0.5 * (vx .* cl - vy .* cld) ./ v;
  gvy = 0.5 * (vy .* cl + vx .* cld) ./ v;
  eqj = diag (gvx) * flow.vxg + diag (gvy) * flow.vyg - eye (length (g));

endfunction

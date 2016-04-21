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
% @deftypefn{Function File} {flow1 =} predictor (flow, dalfad)
% Predicts a flow change when the global angle of attack is increased,
% using a Euler finite-difference method. @var{dalfad} specifies the angle
% step in degrees. Returns empty matrix if not successful.
% @end deftypefn

function flow1 = predictor (flow, dalfad)

  dalfa = dalfad * pi/180;
  np = length (flow.g);

  flow1 = makeflow (flow.wing, flow.alfa + dalfa);
  flow1.alfad = flow.alfad + dalfad;
  % use the formula J(g,a)*dg ~ F(g,a+da) [- F(g,a)]
  oeq = floweq (flow.g, flow1);
  ores = norm (oeq);
  if (norm (oeq - flow.eq) < norm (oeq))
    oeq -= flow.eq;
  endif
  flow1.g = flow.g - flow.eqj \ oeq;

  % new gs with new flow
  flow1.eq = floweq (flow1.g, flow1);
  flow1.res = norm (flow1.eq);

  % check improvement
  if (flow1.res < ores)
    flow1.res /= sqrt (np);
    flow1.eqj = floweqj (flow1.g, flow1);
  else
    flow1 = [];
  endif

endfunction

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
% @deftypefn{Function File} {flow1 =} setalfa (flow, alfad)
% Sets angle of attack directly for a flow. This can be used if
% @w{predictor} fails. The scaled circulations are taken
% from the flow if present. Only @code{flow.wing} is mandatory,
% any other fields need not be initialized. Thus, this function
% can be used as initialization code.
% @end deftypefn

function flow1 = setalfa (flow, alfad)

  alfa = alfad * pi/180;
  if (! isfield (flow, 'alfa') || alfa != flow.alfa)
    flow1 = makeflow (flow.wing, alfa);
  else
    flow1 = flow;
  endif
  flow1.alfad = alfad;

  if (isfield (flow, 'g'))
    flow1.g = flow.g;
  else
    flow1.g = 1e-4*ones (flow.wing.np, 1);
  endif

  flow1.eq = floweq (flow1.g, flow1);
  flow1.res = norm (flow1.eq);
  flow1.eqj = floweqj (flow1.g, flow1);

endfunction


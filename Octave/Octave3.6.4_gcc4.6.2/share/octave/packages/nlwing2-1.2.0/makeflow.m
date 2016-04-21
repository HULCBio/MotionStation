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
% @deftypefn{Function File} {flow =} makeflow (wing, alfa)
% Initializes the flow at a particular global angle of attack
% by computing the sensitivity matrices.
% @end deftypefn

function flow = makeflow (wing, alfa)

  flow.wing = wing;
  flow.alfa = alfa;
  % create sensitivity tensor
  [vxg, vyg, flow.vx0, flow.vy0] = ...
    vitensor (alfa, wing.xac, wing.yac, wing.zac, wing.sym);
  flow.vxg = vxg * diag (wing.ch);
  flow.vyg = vyg * diag (wing.ch);

endfunction

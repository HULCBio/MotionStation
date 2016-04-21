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
% @deftypefn{Function File} {[cl, cd, cm, ad] =} qcalc (flow)
% Calculates local spanwise quantities for a given flow state.
% @table @var
% @item cl
% local lift coefficient
% @item cd
% local viscous drag coefficient
% @item cl
% local moment coefficient
% @item cm
% local flow twist (difference of local induced angle of attack and global angle of attack)
% @item alc
% @end table
% @end deftypefn

function [cl, cd, cm, ad] = qcalc (flow)
  % calc local velocities
  vx = flow.vxg*flow.g + flow.vx0; 
  vy = flow.vyg*flow.g + flow.vy0;
  % local angles of attack
  alfa = atan2 (vy, vx); 
  ad = alfa - flow.alfa;
  % interpolate local lifts
  wing = flow.wing;
  cl = spwinterp (alfa, wing, [wing.pol.cl]);
  cd = spwinterp (alfa, wing, [wing.pol.cd]);
  cm = spwinterp (alfa, wing, [wing.pol.cm]);
endfunction

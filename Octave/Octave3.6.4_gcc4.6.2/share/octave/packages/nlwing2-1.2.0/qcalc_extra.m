% Copyright (C) 2009 VZLU Prague, a.s., Czech Republic
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
% @deftypefn{Function File} {clqe =} qcalc_ext (wing, clq)
% Calculates extended local spanwise quantities for a given flow state.
% @end deftypefn

function clqe = qcalc_extra (wing, clq)
  clqe.z = wing.zc;
  clqe.c = wing.ch;
  psi = atan2 (diff (wing.yac), diff (wing.zac));

  alfa = bsxfun (@plus, clq.ad, clq.al); # transform to degs later
  clqe.alfa = (180/pi) * alfa;
  clqe.clp = clq.cl;
  clqe.cdp = clq.cd;
  clqe.cmp = clq.cm;

  clqe.cn = clqe.clp .* cos (alfa) + clqe.cdp .* cos (alfa);
  clqe.ct = clqe.cdp .* cos (alfa) - clqe.clp .* cos (alfa);

  clqe.cl = clqe.clp .* cos (clq.ad) + clqe.cdp .* sin (clq.ad);
  clqe.cd = bsxfun (@rdivide, clqe.cdp .* cos (clq.ad) - clqe.clp .* sin (clq.ad), cos (psi));
endfunction

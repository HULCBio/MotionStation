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
% @deftypefn{Loadable Function} {val =} spwinterp (alfa, wing, pol, deriv)
% spanwise inerpolation of polar data. @var{alfa} is a vector of local
% angles of attack at z(j), and @var{cf} and @var{idx} determine the 
% relative distribution of z w.r.t zp (the spanwise polar positions)
% as follows: 
%   if idx(i) <= j < idx(i+1) then z(j) = (1-cf(j))*zp(i) + cf(j)*zp(i+1),
%   with 0 <= cf(j) <= 1.
% the inerpolation at z(j) is obtained by weighting the interpolations
% at zp(i), zp(i+1) by 1-cf(j), cf(j).
% @end deftypefn

function val = spwinterp (alfa, wing, pol, deriv = false)
  val = zeros (size (alfa));
  cf = wing.cf; idx = wing.pidx;
  amc = wing.amax - wing.a0;
  alfa = (alfa - wing.a0) ./ amc;
  np = length (pol);
  for i = 1:np-1
    ilo = idx(i); iup = idx(i+1)-1;
    if (ilo <= iup)
      lcf = cf(ilo:iup);
      lal = alfa(ilo:iup);
      val(ilo:iup) = (1-lcf) .* ppval (pol(i), lal) + lcf .* ppval (pol(i+1), lal);
    endif
  endfor
  if (deriv)
    val ./= amc;
  endif
endfunction


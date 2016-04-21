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
% @deftypefn{Function File} {[a0, amax, clmax] =} liftanalyze (al, cl)
% analyzes a lift curve. Searches for a zero-lift and max-lift
% angle.
% @end deftypefn

function [a0, amax, clmax] = liftanalyze (al, cl, pn = '')
  if (pn)
    wpref = ["liftanalyze (", pn, "): "];
  else
    wpref = "liftanalyze: ";
  endif
  [clmin, imin] = min (cl);
  [clmax, imax] = max (cl);
  if (imin >= imax || clmax < 0)
    error ([wpref, "unphysical lift curve"]);
  endif
  if (clmin > 0)
    warning ([wpref, "polar starts at positive lift"]);
  endif
  if (imax == length (cl))
    warning ([wpref, "maximum lift at end of lift curve"]);
  endif
  amax = al(imax);

  if (any (cl(imin+1:imax) <= cl(imin:imax-1)))
    warning ([wpref, "multimodal lift curve"]);
    % Try to reduce the range to find a monotonic subinterval.
    if (clmin >= 0)
      ilo = imin;
      iup = imin + 1;
    else
      ilo = find (cl < 0, 1, "last");
      iup = find (cl > 0, 1, "first");
    endif
    imin = max (imin, ilo - 2);
    imax = min (imax, iup + 2);
    if (any (cl(imin+1:imax) <= cl(imin:imax-1)))
      imin = ilo;
      imax = iup;
    endif
  endif

  try
    a0 = interp1 (cl(imin:imax), al(imin:imax), 0, "extrap");
  catch
    % Catch error here to give the polar name.
    error ([wpref, "failed to estimate zero lift"]);
  end_try_catch
endfunction

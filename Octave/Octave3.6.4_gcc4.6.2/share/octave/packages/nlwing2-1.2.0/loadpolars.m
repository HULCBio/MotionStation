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
% @deftypefn{Function File} {pol =} loadpolars (pn)
% Load an airfoil polar data in the form of 4 column matrix,
% specified as
% @verbatim
% <angle of attack> <lift coefficient> <moment coefficient> <drag coefficient>
% @end verbatim
% The angles of attack should form an increasing sequence.
% @var{pn} can either be a single name, a cell array of names,
% or a structure with a "names" field containing a cell array of names,
% and a "z" field containing spanwise coordinates of polars. 
% In the latter case, pol.z will contain the z values. 
% Duplicate loads are avoided, i.e. a file specified twice will only be
% loaded once and then copied.
% @end deftypefn

function pol = loadpolars (pn)

  if (ischar (pn))
    if (rows (pn) != 1)
      pol = loadpolars (cellstr (pn));
      return;
    endif
    dat = load ('-ascii', pn);
    alpha = dat(:,1) * pi/180;
    [a0, amax, pol.clmax] = liftanalyze (alpha, dat(:,2), pn);
    pol.a0 = a0; pol.amax = amax;
    alpha = (alpha - a0) ./ (amax - a0);
    pol.cl = pchip (alpha, dat(:,2));
    pol.cld = polppder (pol.cl);
    pol.cd = pchip (alpha, dat(:,3));
    pol.cm = pchip (alpha, dat(:,4));
  elseif (iscellstr (pn))
    % remove duplicates
    [pnu, inu, inu] = unique (pn(:));
    polu = cellfun (@loadpolars, pnu);
    pol = reshape (polu(inu), size (pn));
  elseif (isstruct (pn))
    names = reshape ({pn.names}, size (pn));
    pol = loadpolars (names);
    [pol.z] = pn.z;
  else
    error ("loadpolars: invalid input");
  endif

endfunction

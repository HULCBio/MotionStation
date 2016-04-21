% Copyright (C) 2010  VZLU Prague, a.s., Czech Republic
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
% @deftypefn{Loadable Function} {clq1 =} clqinterp (clq, alfa1)
% Interpolates the clq structure on a different sequence of angles of attack
% (in degrees). Uses linear interpolation.
% @end deftypefn

function clq1 = clqinterp (clq, alfa1)

  if (nargin != 2 || ! isstruct (clq) || ! ismatrix (alfa1))
    print_usage ();
  endif

  alfa = clq.alfa;
  transform = @(q) interp1 (alfa.', q.', alfa1.', "extrap").';
  clq1 = structfun (transform, clq, "uniformoutput", false);
  clq1.alfa = alfa1;
  clq1.al = alfa1 * (pi/180);

  % interpolating zsep makes little sense, so let's remove it.
  clq1 = rmfield (clq1, "zsep");

endfunction



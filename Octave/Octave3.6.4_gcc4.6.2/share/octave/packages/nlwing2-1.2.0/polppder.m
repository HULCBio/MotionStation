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

% @deftypefn{Function File} {ppd =} polppder (pp)
% Differentiates a piecewise polynomial structure.
% @end deftypefn
function ppd = polppder (pp)
  [x, p, n, k] = unmkpp (pp);
  if (k <= 1)
    pd = zeros (rows (p), 1);
    k = 1;
  else
    k -= 1;
    pd = p(:,1:k) * diag (k:-1:1);
  endif
  ppd = mkpp (x, pd);
endfunction

% Copyright (C) 2008  VZLU Prague, a.s., Czech Republic
% 
% Author: Jaroslav Hajek <highegg@gmail.com>
% 
% This file is part of OctGPR.
% 
% OctGPR is free software; you can redistribute it and/or modify
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
% @deftypefn {Function File} {[U, ur, iu]} = rbf_centers (@var{X}, @var{nu}, @var{theta})
% Selects a given number of RBF centers based on Lloyd's clustering algorithm.
% 
% @end deftypefn
function [U, ur, iu] = rbf_centers (X, nu, theta)

  if (nargin == 3)
    X *= diag (theta);
  elseif (nargin != 2)
    print_usage ();
  endif

  % the D^2 weighting initialization

  D = Inf;
  kk = 1:rows (X);
  cp = kk;

  for i = 1:nu
    jj = sum (rand() * cp(end) < cp);
    k(i) = kk(jj);
    kk(jj) = [];
    U = X(k(i),:);
    D = min (D, pdist2_mw(X, U, 'ssq')');
    cp = cumsum (D(kk));
  endfor

  
  % now perform the k-means algorithm

  U = X(k,:);
  D = pdist2_mw (U, X, 'ssq');
  [xx, j] = min (D);

  it = 0;
  do
    for i = 1:columns (X)
      U(:,i) = accumarray (j.', X(:,i), [nu, 1]);
    endfor
    N = accumarray (j.', ones (1, length (j)), [nu, 1]);
    U = diag (N) \ U;
    i = find (all (U == 0, 2));
    U(i,:) = X(ceil (rand (1, length (i)) * rows (X)), :);
    j1 = j;
    D = pdist2_mw (U, X, 'ssq');
    [xx, j] = min (D);
    fprintf (stderr, "k-means iteration %d\r", ++it);
  until (all (j == j1))
  fprintf (stderr, "\n");

  if (nargout > 2)
    iu = j;
  endif

  if (nargout > 1)
    ur = zeros (nu, 1);
    for i = 1:nu
      ij = (j == i);
      ur(i) = sqrt (max (D(i,ij)));
    endfor
  endif

  if (nargin == 3)
    U = dmult (U, 1./theta);
    if (any(theta == 0))
      U(:,theta == 0) = 0;
    endif
  endif

endfunction   

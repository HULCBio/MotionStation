% Copyright (C) 2008  Jaroslav Hajek <highegg@gmail.com>
% 
% This file is part of OctaveForge.
% 
% OctaveForge is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
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

% function benchmark_stmm (n, nvec)
% description:
% Sparse transposed matrix-vector multiplication benchmark.
% This is to test the "compound operators" feature introduced in Octave.
%
% arguments:
% n = dimension of matrix
% nvec = number of vector op repeats
%
% results:
% time_tmm = Time for A'*B (B n^2-by-nvec matrix)
% time_tmv = Time for A'*v nvec-times (v vector)
% time_mtm = Time for B*A' (B nvec-by-n^2 matrix)
% time_mtv = Time for v*A' nvec-times (v vector)
%

function results = benchmark_stmm (n, nvec)

  benchutil_default_arg ('n', 300);
  benchutil_default_arg ('nvec', 100);

  benchutil_initialize (mfilename)

  disp ('constructing sparse matrix')
  n = 300; % size of the grid
  m = n^2; % number of points
  X = (n-1)*rand (m, 1); Y = (n-1)*rand (m, 1);
  IX = ceil (X); JY = ceil (Y);
  
  A = sparse(m, n^2);
  A = A + sparse (1:m, sub2ind ([n, n], IX  , JY  ), (IX+1-X).*(JY+1-Y), m, n^2);
  A = A + sparse (1:m, sub2ind ([n, n], IX+1, JY  ), (X - IX).*(JY+1-Y), m, n^2);
  A = A + sparse (1:m, sub2ind ([n, n], IX  , JY+1), (IX+1-X).*(Y - JY), m, n^2);
  A = A + sparse (1:m, sub2ind ([n, n], IX+1, JY+1), (X - IX).*(Y - JY), m, n^2);
  
  v = ones (m, nvec);
  tic; u = A'*v; time_tmm = toc;
  benchutil_set_result ('time_tmm')
  
  v = ones (m, 1);
  tic; 
  for i=1:nvec
    u = A'*v; 
  end
  time_tmv = toc;
  benchutil_set_result ('time_tmv')
  
  v = ones (nvec, m);
  tic; u = v*A'; time_mtm = toc;
  benchutil_set_result ('time_mtm')
  
  v = ones (1, m);
  tic; 
  for i=1:nvec
    u = v*A'; 
  end
  time_mtv = toc;
  benchutil_set_result ('time_mtv')
  

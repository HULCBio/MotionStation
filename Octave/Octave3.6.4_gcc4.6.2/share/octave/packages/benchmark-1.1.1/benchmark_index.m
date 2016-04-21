% Copyright (C) 2009  VZLU Prague
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

% function benchmark_index (n, rep)
% description:
% Test speed of array indexing.
%
% arguments:
% n = array size
% rep = number of repeats
%
% results:
% time_slice1 = time for a(i:j)
% time_slice1s = time for a(i:k:j)
% time_slice1v = time for a(idx)
% time_slice2c = time for a(:,i:j)
% time_slice2r = time for a(i:j,:)
% time_slice2cv = time for a(:,idx)
% time_slice2rv = time for a(idx,:)
% time_slicenc = time for a(:,:,i:j,k)
% time_slicend = time for a(:,:,k,i:j)
% time_slicens = time for a(i,j,k,:)
% time_spreadr = time for a(ones(1, k), :), a row vector
% time_spreadc = time for a(:, ones(1, k)), a column vector
%

function results = benchmark_index (n, rep)

  benchutil_default_arg ('n', 4e6);
  benchutil_default_arg ('rep', 100);

  benchutil_initialize (mfilename)

  a = rand (1, n);

  i = 10; 
  j = n - 10;

  tic; 
  for irep = 1:rep
    b = a(i:j);
  end
  time_slice1 = toc;
  benchutil_set_result ('time_slice1')

  k = 2;

  tic; 
  for irep = 1:rep
    b = a(i:k:j);
  end
  time_slice1s = toc;
  benchutil_set_result ('time_slice1s')

  idx = cumsum (rand (1, n));
  idx = ceil (idx / idx(end) * n);

  tic; 
  for irep = 1:rep
    b = a(idx);
  end
  time_slice1v = toc;
  benchutil_set_result ('time_slice1v')

  m = floor (sqrt(n));
  a = rand (m);

  i = 5; 
  j = m - 5;

  tic; 
  for irep = 1:rep
    b = a(:,i:j);
  end
  time_slice2c = toc;
  benchutil_set_result ('time_slice2c')

  tic; 
  for irep = 1:rep
    b = a(i:j,:);
  end
  time_slice2r = toc;
  benchutil_set_result ('time_slice2r')

  idx = cumsum (rand (1, m));
  idx = ceil (idx / idx(end) * m);

  tic; 
  for irep = 1:rep
    b = a(:,idx);
  end
  time_slice2cv = toc;
  benchutil_set_result ('time_slice2cv')

  tic; 
  for irep = 1:rep
    b = a(idx,:);
  end
  time_slice2rv = toc;
  benchutil_set_result ('time_slice2rv')

  m = floor (sqrt (n / 6));
  a = rand (2, m, m, 3);

  i = 5;
  j = m - 5;
  k = 2;

  tic; 
  for irep = 1:rep
    b = a(:,:,i:j,k);
  end
  time_slicenc = toc;
  benchutil_set_result ('time_slicenc')

  m = floor (sqrt (n / 6));
  a = rand (2, m, 3, m);

  i = 5;
  j = m - 5;
  k = 2;

  tic; 
  for irep = 1:rep
    b = a(:,:,k,i:j);
  end
  time_slicend = toc;
  benchutil_set_result ('time_slicend')

  m = floor (n / 12);
  a = rand (2, 2, 3, m);

  tic; 
  for irep = 1:rep
    b = a(2,1,3,:);
  end
  time_slicens = toc;
  benchutil_set_result ('time_slicens')

  m = floor (sqrt (n));
  a = rand (1, m);

  tic; 
  for irep = 1:rep
    b = a(ones(1, m), :);
  end
  time_spreadr = toc;
  benchutil_set_result ('time_spreadr')

  a = rand (m, 1);

  tic; 
  for irep = 1:rep
    b = a(:, ones(1, m));
  end
  time_spreadc = toc;
  benchutil_set_result ('time_spreadc')


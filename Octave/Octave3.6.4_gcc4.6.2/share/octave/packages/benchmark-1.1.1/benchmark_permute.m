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

% function benchmark_permute (n)
% description:
% Test speed of array permuting.
%
% arguments:
% n = dimension size (n^5 is number of elements)
%
% results:
%
% time_21345 = time for [2,1,3,4,5] permutation
% time_13425 = time for [1,3,4,2,5] permutation
% time_34125 = time for [3,4,1,2,5] permutation
% time_45123 = time for [4,5,1,2,3] permutation
%

function results = benchmark_permute (n, rep)

  benchutil_default_arg ('n', 30);

  benchutil_initialize (mfilename)

  a = zeros (n, n, n, n, n);

  tic; b = permute (a, [2,1,3,4,5]); time_21345 = toc
  benchutil_set_result ('time_21345')
  
  tic; b = permute (a, [1,3,4,2,5]); time_13425 = toc
  benchutil_set_result ('time_13425')
  
  tic; b = permute (a, [3,4,1,2,5]); time_34125 = toc
  benchutil_set_result ('time_34125')

  tic; b = permute (a, [4,5,1,2,3]); time_45123 = toc
  benchutil_set_result ('time_45123')


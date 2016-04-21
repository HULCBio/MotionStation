% Reduce array using callback fundtions.
% [S,N] = reduce(SELF,FUNRED,FUNELEM,DIM)
% Reduce array using the function FUNRED applied to all elements 
% after the function FUNELEM was applied along dimension DIM.

function [s,n] = reduce(self,funred,funelem,dim)

sz = size(self);
if nargin == 3
  dim = find(sz ~= 1,1);
  if isempty(dim)
    dim = 1;
  end
end

idx.type = '()';
nd = length(sz);
idx.subs = cell(1,nd);
for i=1:nd
  idx.subs{i} = ':';
end

n = size(self,dim);

if n == 0
  s = [];
else
  idx.subs{dim} = 1;  
  s = funelem(subsref(self,idx));
  
  for i=2:n
    idx.subs{dim} = i;  
    s = funred(s,funelem(subsref(self,idx)));
  end
end



% Copyright (C) 2012 Alexander Barth <barth.alexander@gmail.com>
%
% This program is free software; you can redistribute it and/or modify
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
% along with this program; If not, see <http://www.gnu.org/licenses/>.


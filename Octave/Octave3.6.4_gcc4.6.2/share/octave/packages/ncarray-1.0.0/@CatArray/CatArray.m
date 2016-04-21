% C = CatArray(dim,{array1,array2,...})
%
% Create a concatenated array from a cell-list of arrays. Individual
% elements can be accessed by subscribs, e.g.:
% C(2,3)


function retval = CatArray(dim,arrays)

self.dim = dim;
self.arrays = arrays;
self.na = length(arrays);

% number of dimensions
self.nd = length(size(arrays{1}));
if dim > self.nd
    self.nd = dim;
end

self.size = ones(self.na,self.nd);
self.start = ones(self.na,self.nd);

% get size of all arrays
for i=1:self.na
    tmp = size(arrays{i});
    self.size(i,1:length(tmp)) = tmp;
end

% check if dimensions are consistent
ncd = 1:self.nd ~= dim;
for i=2:self.na
    if ~all(self.size(i,ncd) == self.size(1,ncd))
        error('Array number %d has inconsistent dimension',i);
    end    
end

% start index of each sub-array

for i=2:self.na
    self.start(i,:) = self.start(i-1,:);
    self.start(i,dim) = self.start(i,dim) + self.size(i-1,dim);
end

self.end = self.start + self.size - 1;

self.sz = self.size(1,:);
self.sz(dim) = sum(self.size(:,dim));
self.overlap = false;
self.bounds = [0; cumsum(prod(self.size,2))];

retval = class(self,'CatArray',BaseArray(self.sz));


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


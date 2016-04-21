% Create a BaseArray.
% BA = BaseArray(SZ)
% Create a BaseArray of size SZ. BaseArray is an abstract class. 
% Derived classes should implement the methods subsref and subsasgn.
% BaseArray implements several reduction methods such as sum, prod and mean.
% SZ should have least two elements.
% 
function retval = BaseArray(sz)

self.sz = sz;

retval = class(self,'BaseArray');


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


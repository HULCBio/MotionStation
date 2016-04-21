function mag = vecmag2(vec)
% 
% VECMAG2: Squared magnitude of a set of vectors.
% 
% Calling Sequence:
% 
%   mvec = vecmag2(vec)
% 
% INPUT:
% 
%   vec		: An array of column vectors represented by a matrix of
% 		size (dim,nv), where dim is the dimension of the vector and
% 		nv the number of vectors.
%
% OUTPUT:
% 
%   mvec	: Squared magnitude of the vectors, vector of size (1,nv).
% 
% Description:
% 
%   Determines the squared magnitude of the vectors.
% 
% Examples:
% 
%   Find the squared magnitude of the two vectors (0.0,2.0,1.3)
%   and (1.5,3.4,2.3)
% 
%   mvec = vecmag2([0.0 1.5; 2.0 3.4; 1.3 2.3]);
%
%    Copyright (C) 2000 Mark Spink
%
%    This program is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 2 of the License, or
%    (at your option) any later version.

%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program.  If not, see <http://www.gnu.org/licenses/>.

mag = sum(vec.^2);

end

% Compute the central moment.
% M = moment (X, ORDER, DIM)
% compute the central moment of the given order along dimension DIM.

function s = moment(self,order,varargin)

m = mean(self,varargin{:});

funred = @plus;
funelem = @(x) (x-m).^order;

[s,n] = reduce(self,funred,funelem,varargin{:});

if isempty(s)
  s = NaN;
else
  s = s/n;
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


% Compute the variance.
% V = var (X, OPT, DIM)
% Compute the variance along dimension DIM.
% If OPT is equal to 1, then the variance is bias-corrected.

function s = var(self,opt,varargin)

if nargin == 1
  opt = 0;
elseif isempty(opt)
  opt = 0;
end

m = mean(self,varargin{:});

funred = @plus;
funelem = @(x) (x-m).^2;

[s,n] = reduce(self,funred,funelem,varargin{:});

if isempty(s)
  s = 0;
else
  if opt == 0
    s = s/(n-1);
  else
    s = s/n;
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


function self = subsasgn(self,idx,x)

[idx_global,idx_local,sz] = idx_global_local_(self,idx);




for j=1:self.na
    % get subset from global array x
    subset = subsref(x,idx_global{j});
    
    % set subset in j-th array
    subsasgn(self.arrays{j},idx_local{j},subset);   
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


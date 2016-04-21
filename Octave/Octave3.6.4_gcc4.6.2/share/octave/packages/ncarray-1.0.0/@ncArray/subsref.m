% Subscripted element selection operation.
% out = subsref (A, idx)
% Perform the subscripted element selection operation according to the subscript specified by idx. 
% A slice of the NetCDF variable can be load by using A(index1,index2,...) and attributes 
% can be loaded by A.attribute_name or A.('attribute_name')
% If index selection is followed by struct selection 'coord', then the coordinates corresponding to the
% slice are loaded:
% For example, the coordinate of element A(4,3) are:
% [lon,lat] = A(4,3).coord;

function varargout = subsref(self,idx)

if strcmp(idx(1).type,'()')
    
    % no subscripts mean that we load all () -> (:,:,...)
    if isempty(idx(1).subs)
        for i=1:self.nd
            idx(1).subs{i} = ':';
        end
    end
end

% catch expressions like:
% data(:,:,:).coord

if length(idx) == 2 && strcmp(idx(2).type,'.') && strcmp(idx(2).subs,'coord')    
    for i=1:length(self.coord)
        % get indeces of the dimensions of the i-th coordinate which are also
        % coordinate of the variable
        
        % replace dummy by ~ once older version have died
        [dummy,j] = intersect(self.dims,self.coord(i).dims);
        j = sort(j);
        idx_c.type = '()';
        idx_c.subs = idx(1).subs(j);
        
        varargout{i} = subsref(self.coord(i).val,idx_c);
    end       
else
    % pass subsref to underlying ncBaseArray
    varargout{1} = subsref(self.var,idx);
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


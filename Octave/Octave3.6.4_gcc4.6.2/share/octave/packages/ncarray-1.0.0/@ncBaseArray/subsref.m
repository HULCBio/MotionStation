function x = subsref(self,idx)

assert(length(idx) == 1)

if strcmp(idx.type,'()')
    % load data
    
    if strcmp(idx.type,'()') && length(idx.subs) == 1 ...
            && length(idx.subs) < self.nd
        % reference like A([2 3 1 5])
        
        if self.tooBigToLoad                                   
            % number of elements in x
            ind = idx.subs{1};
            
            % transform index to subscript
            subs = cell(1,self.nd);
            [subs{:}] = ind2sub(size(self),ind);
            
            % make a nice array length(ind) by self.nd
            subs = cell2mat(subs);
            
            % output array
            x = zeros(size(ind));
            x(:) = NaN;
            
            
            % get every element
            % can be quite slow
            idxe.type = '()';
            idxe.subs = cell(1,self.nd);
            
            for i=1:length(ind)
                idxe.subs = mat2cell(subs(i,:),1,ones(1,self.nd));
                x(i) = subsref(self,idxe);
            end
        else
            % load full array
            tmp = full(self);
            x = subsref(tmp,idx);
        end
    else
        [start, count, stride] = ncsub(self,idx);
        
        if any(count == 0)
            x = zeros(count);
        else
            x = ncread(cached_decompress(self.filename),self.varname,...
                start,count,stride);
        end
    end
elseif strcmp(idx.type,'.')
    % load attribute
    name = idx.subs;
    index = strmatch(name,{self.vinfo.Attributes(:).Name});
    
    if isempty(index)
        error('variable %s has no attribute called %s',self.varname,name);
    else
        x = self.vinfo.Attributes(index).Value;
    end
else
    error('not supported');
    
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


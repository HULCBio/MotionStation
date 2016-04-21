function B = subsref(self,idx)

% handle case with a single subscript
% for example CA(234)

if strcmp(idx.type,'()') && length(idx.subs) == 1
    % indices of elements in B
    ind = idx.subs{1};
    
    % output array
    B = zeros(size(ind));
    B(:) = NaN;
    
    if self.overlap 
        % transform index to subscript
        subs = cell(1,self.nd);
        [subs{:}] = ind2sub(size(self),ind);
        
        % make a nice array length(ind) by self.nd
        subs = cell2mat(subs);
        
        
        % get every element
        idxe.type = '()';
        idxe.subs = cell(1,self.nd);
        
        for i=1:length(ind)
            idxe.subs = mat2cell(subs(i,:),1,ones(1,self.nd));
            %B(i) = subsref_canonical(self,idxe);
            
            [idx_global,idx_local,sz] = idx_global_local_(self,idxe);
            tmp = zeros(sz);
            tmp(:) = NaN;
            
            
            for j=1:self.na
                % get subset from j-th array
                subset = subsref(self.arrays{j},idx_local{j});
                
                % set subset in global array B
                tmp = subsasgn(tmp,idx_global{j},subset);
            end
            B(i) = tmp;
            
        end
    else
        % assume all arrays does not overlap
                
        for j=1:self.na
            sel = self.bounds(j) < ind & ind <= self.bounds(j+1);
            B(sel) = self.arrays{j}(ind(sel) - self.bounds(j));
        end
        
    end
elseif strcmp(idx.type,'.')
  % load attributes from first array
    B = subsref(self.arrays{1},idx);
else
    B = subsref_canonical(self,idx);
end

end

% for this function we assume that idx.subs has the same dimension than
% the array

function B = subsref_canonical(self,idx)
[idx_global,idx_local,sz] = idx_global_local_(self,idx);

B = zeros(sz);
B(:) = NaN;

for j=1:self.na
    % get subset from j-th array
    subset = subsref(self.arrays{j},idx_local{j});
    
    % set subset in global array B
    B = subsasgn(B,idx_global{j},subset);
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


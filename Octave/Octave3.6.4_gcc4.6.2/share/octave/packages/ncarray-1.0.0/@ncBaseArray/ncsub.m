function [start, count, stride] = ncsub(self,idx)

assert(strcmp(idx.type,'()'))

% number of dimension (including singleton dimensions)
%n = length(size(self));
n = self.nd;

% number of subscripts
ns = length(idx.subs);

if ns == 0
    % load all
    start = ones(1,n);
    count = self.sz;
    stride = ones(1,n);
else
    
    start = ones(1,ns);
    count = ones(1,ns);
    stride = ones(1,ns);
    
    % sz is the size padded by 1 if more indices are given than n
    sz = ones(1,ns);
    sz(1:length(self.sz)) = self.sz;
    
    for i=1:ns
        if isempty(idx.subs{i})
            count(i) = 0;
            
        elseif strcmp(idx.subs{i},':')
            count(i) = sz(i);
            
        else
            tmp = idx.subs{i};
            
            if length(tmp) == 1
                start(i) = tmp;
            else
                test = tmp(1):tmp(2)-tmp(1):tmp(end);
                
                if all(tmp == test)
                    start(i) = tmp(1);
                    stride(i) = tmp(2)-tmp(1);
                    count(i) = (tmp(end)-tmp(1))/stride(i) +1;
                else
                    error('indeces');
                end
            end
        end
    end
    
    assert(all(count(n+1:end) == 1 | count(n+1:end) == 0))
    assert(all(start(n+1:end) == 1))
    
    if ~any(count == 0)
        count = count(1:n);
        start = start(1:n);
        stride = stride(1:n);
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


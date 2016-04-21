function y = blkdiag(varargin)
%BLKDIAG  Block diagonal concatenation of input arguments.
%
%                                   |A 0 .. 0|
%   Y = BLKDIAG(A,B,...)  produces  |0 B .. 0|
%                                   |0 0 ..  |
%
%   See also DIAG, HORZCAT, VERTCAT

% Copyright 1984-2003 The MathWorks, Inc. 
% $Revision: 1.7.4.2 $Date: 2003/11/24 23:23:56 $

if any(~cellfun('isclass',varargin,'double'))
    y = [];
    for k=1:nargin
        x = varargin{k};
        [p1,m1] = size(y); [p2,m2] = size(x);
        y = [y zeros(p1,m2); zeros(p2,m1) x];
    end
    return
end

isYsparse = false;

for k=1:nargin
    x = varargin{k};
    [p2(k+1),m2(k+1)] = size(x); %Precompute matrix sizes
    if ~isYsparse&&issparse(x)
        isYsparse = true;
    end
end
%Precompute cumulative matrix sizes
p1 = cumsum(p2);
m1 = cumsum(m2);
if isYsparse
    y = sparse([]);
    for k=1:nargin
        y = [y sparse(p1(k),m2(k)); sparse(p2(k),m1(k)) varargin{k}];
    end
else
    y = zeros(p1(end),m1(end)); %Preallocate for full doubles only
    for k=1:nargin
        y(p1(k)+1:p1(k+1),m1(k)+1:m1(k+1)) = varargin{k};
    end
end

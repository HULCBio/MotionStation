function out = triu(in, diagonal)
% Embedded MATLAB Library function.
%
% Limitations:
% It only supports input of dimension 1 or 2. 

% $INCLUDE(DOC) toolbox/matlab/elmat/triu.m $%
% Copyright 2002-2004 The MathWorks, Inc.
% $Revision: 1.1.6.3 $  $Date: 2004/04/14 23:58:47 $

eml_assert(nargin > 0, 'error','Not enough input arguments.');
eml_assert( length(size(in)) == 1 || length(size(in))== 2, 'error', 'Dimension argument must be one or two.');
eml_assert(nargin < 2 || isscalar(diagonal),'error','Diagonal input must be a scalar.');

if nargin>1
    diagonal1 = fix(real(diagonal));
else
    diagonal1 = 0;
end

out=in;

m = size(in,1);
n = size(in,2);
k = diagonal1-1;
jend = min(m+k,n);
if jend < 1,
    return;
end

for j=1:jend
    for i=max(j-k,1):m
        out(i,j)=0;
    end
end

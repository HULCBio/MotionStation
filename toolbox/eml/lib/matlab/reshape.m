function out = reshape(X, M, N)
% Embedded MATLAB Library function.
%
% Limitations:
% 1) Only supports 1 and 2 dimensional matrices
% 2) Only works with numeric arrays
% 3) Cannot handle one empty SIZE argument to automatically figure out
%    the other

% $INCLUDE(DOC) toolbox/eml/lib/matlab/reshape.m $
%  Copyright 2002-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.4 $  $Date: 2004/04/14 23:58:37 $

eml_assert(nargin > 1, 'error', 'Too few input arguments');

% Empty in = empty out
if(isempty(X))
    out = zeros(M,N,class(X));
    return;
end

%--------------------------------------------------------------------------------------------------------------------------
% Size argument can be specified as a 1x2 row vector or as two separate scalars
%
% If nargin == 2, assume that the second argument is SIZE -- it'd better be a 1x2 vector
% If nargin == 3, assume size is specified by two scalars -- inputs 2 and 3 better be scalars
%--------------------------------------------------------------------------------------------------------------------------
if(nargin == 2)
    eml_assert(size(M,1) == 1 && size(M,2) == 2, 'error', 'Size vector must be a row vector with two elements');
     m = M(1);
     n  = M(2);
end
if(nargin == 3)
    if(isempty(M) ||  isempty(N))
        eml_assert(1==0, 'error', 'Size can not have unknown dimensions.');
    end   
    eml_assert(size(M,1) == 1 && size(M,2) == 1, 'error', 'Size arguments must be integer scalars.');
    eml_assert(size(N,1) == 1 && size(N,2) == 1, 'error', 'Size arguments must be integer scalars.');
    m = M;
    n  = N;
 end
 
eml_assert(m*n == size(X,1)*size(X,2), 'error', 'To RESHAPE the number of elements must not change.');
 
% Convert input matrix into a vector
tempHolder = initVar(X, zeros(1, size(X,1)*size(X,2),class(X)));
count = 0;
for j=1:size(X,2)
    for i=1:size(X,1)
        count=count+1;
        tempHolder(count) = X(i,j);
    end
end

% Fill in output matrix with elements from tempHolder
out = initVar(X, zeros(m,n,class(X)));
count = 0;
for j=1:n
    for i=1:m
        count=count+1;
        out(i,j) = tempHolder(count);
    end
end


%--------------------------------------------%
% Initialize var as real or complex %
%--------------------------------------------%
function out = initVar(x,in)
    if(~isreal(x))
        out = complex(in);
    else
        out = in;
    end
    

% [EOF]

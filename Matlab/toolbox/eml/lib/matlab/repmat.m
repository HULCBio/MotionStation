function out = repmat(A, M, N) 
% Embedded MATLAB Library function.
%     
% Limitations:
% 1) Only supports 1 and 2 dimensional matrices.
% 2) Cannot handle negative values for M,N (MATLAB treats
%    negative dimensions as if they were zero.)

% $INCLUDE(DOC) toolbox/eml/lib/matlab/repmat.m $%
%  Copyright 2002-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.6 $  $Date: 2004/04/14 23:58:36 $

eml_assert(nargin > 1, 'error', 'Too few input arguments');

% Empty in = empty out
if(isempty(A))
    out = [];
    return;
end

%----------------------------------------------------------------------------------------------------------------------------
% Size argument can be specified as a 1x2 row vector or as two separate scalars
%
% If nargin == 2, assume that the second argument is SIZE -- it can be a 1x2 vector or a scalar
% If nargin == 3, assume size is specified by two scalars -- inputs 2 and 3 better be scalars
%----------------------------------------------------------------------------------------------------------------------------
if(nargin == 2)
    if(size(M,1) == 1 && size(M,2) == 2) %support for REPMAT(A, [M,N])
         m = M(1);
         n  = M(2);
    elseif(size(M,1) == 1 && size(M,2) == 1) %support for REPMAT(A, M)
        m = M(1);
        n = M(1);
    else
        eml_assert(1==0, 'error', 'Incorrect size argument.  Size must be entered as two integer scalars or a 1x2 vector of integer scalars.');
    end
end
if(nargin == 3) %support for REPMAT(A, M, N)
    if(isempty(M) ||  isempty(N))
        eml_assert(1==0, 'error', 'Size can not have unknown dimensions.');  %cannot have REPMAT(A, [], N) or REPMAT(A, M, [])
    end   
    eml_assert(size(M,1) == 1 && size(M,2) == 1, 'error', 'Size arguments must be integer scalars.'); %cannot have REPMAT(A, [X,Y], N)
    eml_assert(size(N,1) == 1 && size(N,2) == 1, 'error', 'Size arguments must be integer scalars.'); %cannot have REPMAT(A, M, [X,Y])
    m = M;
    n  = N;
 end

eml_assert( m >= 0, 'error', 'M must not be negative,' );
eml_assert( n >= 0, 'error', 'N must not be negative,' );
eml_assert(double(int32(m)) == m, 'error', 'M must be an integer');
eml_assert(double(int32(n)) == n, 'error', 'N must be an integer');

if (m < 0 || n < 0),
    out = zeros(m,n);
    return;
end

% Initialize output
[numrowsA, numcolsA] = size(A);
out = initVar(A, zeros(m*numrowsA, n*numcolsA,class(A)));

% Get output
for i=1:m
    for j=1:n
        out = enhanceOut(out,A,i,j);
    end
end


%----------------------------------------
% Tile output with input matrix
%----------------------------------------
function out = enhanceOut(out,A,m,n)
    [numrowsA, numcolsA] = size(A);
    row_displacement = numrowsA * (m-1);
    col_displacement   = numcolsA * (n-1);
    
    for i=1:numrowsA
        for j=1:numcolsA
            out(row_displacement+i, col_displacement+j) = A(i,j);
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

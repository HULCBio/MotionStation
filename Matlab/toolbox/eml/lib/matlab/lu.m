function [L,U,permMatrix] = lu(A)
% Embedded MATLAB Library function.
%
% Limitations:
% 1) No NaN & Inf inputs.
% 2) Can only return three outputs.

% $INCLUDE(DOC) toolbox/eml/lib/matlab/lu.m $
% Copyright 2002-2004 The MathWorks, Inc.
% $Revision: 1.1.6.3 $  $Date: 2004/03/21 22:08:14 $

eml_assert(nargin > 0, 'error', 'Not enough input arguments.');
eml_assert(nargout == 3,'error',...
    'Embedded MATLAB only supports [L,U,P] = LU(A)');
eml_assert(isfloat(A), 'error', ['Function ''lu'' is not defined for values of class ''' class(A) '''.']);

if isempty(A),
    L = [];
    U = [];
    permMatrix = [];
    return
end

if(any(any(isinf(A))))
    error('Unsupported: Input must not contain Inf');
end

if(any(any(isnan(A))))
    error('Unsupported: Input must not contain NaN');
end
 
% Init
X = A;
m = size(A,1);
n = size(A,2);

% Initialize row-pivot indices
pivot = 1:m;

% Loop over each column
for k = 1:m
    p = k;

    % This is needed for non-square matrices
    if(k > n), break; end

    maxval = abs(X(k,k));
  
    % Scan the lower triangular part of this column only
    % Record row of largest value   
    for i = k+1:m
        if(abs(X(i,k)) > maxval)
            maxval = abs(X(i,k));
            p = i;
        end
    end

%     Would like to be able to replace the above FOR loop with this in the future:
%           [maxval,p] = max(abs(X(k:n,k)));
%           p = p+k-1;
%
%     Can't do it today because of current eML limitation ==> have to know sizes
    

    % Swap rows if max value if not in row k
    if(p ~= k)
%         for a = 1:n
%             temp = X(p,a);
%             X(p,a) = X(k,a);
%             X(k,a) = temp;
%         end
        X([p,k],:) = X([k,p],:); % <--- Replace the above FOR loop (commented out) with this

        % Swap pivot row indices
        pivot([p,k]) = pivot([k,p]); 
    end

    if(X(k,k) == 0)
        error('Input matrix is singular');
    end

    %--- Do column reduction now ---%

    % Divide lower triangular part of column by max
    Adiag = X(k,k);
    for i = k+1:m
        X(i,k) = X(i,k) / Adiag;
    end

    % Subtract multiple of column from remaining columns
    for j = k+1:n
        for i = k+1:m
            X(i,j) = X(i,j) - X(i,k)*X(k,j);
        end
    end
end

[L,U] = breakuplu(X);
permMatrix = getPermMatrix(pivot,class(X));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Breakup LU into separate L and U matrices
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [L,U] = breakuplu(X)
    m = size(X,1);
    n = size(X,2);

    if (isreal(X))
        if(m <= n)
            L = zeros(m, m, class(X));
            U = zeros(m, n, class(X));
        else
            L = zeros(m, n, class(X));
            U = zeros(n, n, class(X));
        end
    else
        if(m <= n)
            L = complex(zeros(m, m, class(X)));
            U = complex(zeros(m, n, class(X)));
        else
            L = complex(zeros(m, n, class(X)));
            U = complex(zeros(n, n, class(X)));
        end
    end

    for i = 1:m
        for j = 1:n
            if(i > j)
                L(i,j) = X(i,j);
            end
            if(i == j)
                L(i,j) = 1;
                U(i,j) = X(i,j);
            end
            if(i < j)
                U(i,j) = X(i,j);
            end
        end
    end

   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Convert pivot into permutation matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function p = getPermMatrix(pivot, cls)
    N = length(pivot);
    p = zeros(N,cls);
    for i = 1:N
        p(i,pivot(i)) = 1;
    end

function bool = isfloat(x)
    bool = isa(x,'double') || isa(x,'single');

% [EOF]

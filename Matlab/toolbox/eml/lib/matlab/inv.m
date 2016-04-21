function y = inv(X)
% Embedded MATLAB Library function.
%
% Limitations:
% No known limitations.

% $INCLUDE(DOC) toolbox/eml/lib/matlab/inv.m $%
% Copyright 2002-2004 The MathWorks, Inc.
% $Revision: 1.1.6.3 $  $Date: 2004/03/21 22:08:02 $
% Comments:
% Find matrix inverse by doing LU decomposition and
% column-by-column forward & backward substitution.

% Check arguments
eml_assert(nargin > 0, 'error', 'Not enough input arguments.');
eml_assert(isfloat(X), 'error', ['Function ''inv'' is not defined for values of class ''' class(X) '''.']);
eml_assert(size(X,1) == size(X,2), 'error', 'Matrix must be square.');

    if (isempty(X))
        y = X;
        return;
    end;

    if(isreal(X))
        y = zeros(size(X), class(X));
    else
        y = complex(zeros(size(X), class(X)));
    end

    if(size(X,1)==1 && size(X,2)==1)
        y = 1/X;
        return;
    elseif (size(X,1)==2 && size(X,2)==2)
        det = X(1,1)*X(2,2)-X(2,1)*X(1,2);
        y = [X(2,2), -X(1,2);-X(2,1),X(1,1)]/det;
        return;
    end

    [L,U,p] = lu(X);
    
    N = size(X,1);
    for j = 1:N
        if(isreal(X))
            col = zeros(N,1,class(X));
        else
            col = complex(zeros(N,1,class(X)));
        end
        col(j) = 1;
        col = forwardSubstitution(L,col);
        col = backSubstitution(U,col);
        for i = 1:N
            y(i,j) = col(i);
        end
    end
    y = y*p;


%%%%%%%%%%%%%%%%%%%%%%
% Forward substitution
%%%%%%%%%%%%%%%%%%%%%%
function x = forwardSubstitution(L,b)
    n = size(L,1);

    if(isreal(L))
        x = zeros(size(b), class(L));
    else
        x = complex(zeros(size(b), class(L)));
    end

    for i = 1:n
        sumval = b(i);
        for j = 1:n
            if(i ~= j)
                sumval = sumval - L(i,j);
            end
        end
        x(i) = sumval/L(i,i);
        for k = 1:n
            L(k,i) = L(k,i) * x(i);
        end
    end


%%%%%%%%%%%%%%%%%%%
% Back substitution
%%%%%%%%%%%%%%%%%%%
function x = backSubstitution(U,b)
    n = size(U,1);

    if(isreal(U))
        x = zeros(size(b), class(U));
    else
        x = complex(zeros(size(b), class(U)));
    end

    for i = n:-1:1
        sumval = b(i);
        for j = 1:n
            if(j ~= i)
                sumval = sumval - U(i,j);
            end
        end
        x(i) = sumval/U(i,i);
        for k = 1:n
            U(k,i) = U(k,i) * x(i);
        end
    end


function bool = isfloat(x)
    bool = isa(x,'double') || isa(x,'single');

% [EOF]

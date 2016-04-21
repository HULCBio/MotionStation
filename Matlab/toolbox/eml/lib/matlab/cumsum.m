function sum = cumsum(X,dim)
% Embedded MATLAB Library function.
%
% Limitations:
% No known limitations.

% $INCLUDE(DOC) toolbox/eml/lib/matlab/cumsum.m $
%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $  $Date: 2004/04/14 23:58:08 $

eml_assert(nargin > 0, 'error', 'Not enough input arguments.');
eml_assert(isfloat(X), 'error', ['Function ''cumsum'' is not defined for values of class ''' class(X) '''.']);

% If no dim is supplied, we should search vectors along their nonsingleton
% dimension and matrices columnwise.
if nargin == 1
    if size(X,1) == 1;
        dim = 2;
    else
        dim = 1;
    end
end

eml_assert(isscalar(dim), 'error', 'Dimension argument must be a scalar with value 1 or 2');
eml_assert(dim == 1 || dim == 2,'error','Dimension argument ''dim'' must be either 1 or 2');

% if either dimension is 0, we should just return the matrix
if min(size(X)) == 0
    sum = X;
    return
end

%%% POSSIBLE ERROR; additional check for empty
if isempty(X)
    sum = X;
    return
end

if dim == 1
    % summing along each column

    % handle degenerate case where there is only one element in each column
    if size(X,1) == 1
        sum = X;
        return
    end

    % initialize and accumulate
    sum = match_zero(X);
    for jj = 1:size(X,2)
        sum(1,jj) = X(1,jj);
        for ii = 2:size(X,1)
            sum(ii,jj) = sum(ii-1,jj) + X(ii,jj);
        end
    end
else
    % summing along each row

    % handle degenerate case where there is only one element in each row
    if size(X,2) == 1
        sum = X;
        return
    end

    % initialize and accumulate
    sum = match_zero(X);
    for ii = 1:size(X,1)
        sum(ii,1) = X(ii,1);
        for jj = 2:size(X,2)
            sum(ii,jj) = sum(ii,jj-1) + X(ii,jj);
        end
    end
end

% matches type with a matrix of all zeros
function B = match_zero(X)

if isreal(X)
    B = zeros(size(X),class(X));
else
    B = zeros(size(X),class(X)) + 0i;
end

function bool = isfloat(x)
    bool = isa(x,'double') || isa(x,'single');

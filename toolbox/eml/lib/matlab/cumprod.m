function prod = cumprod(X,dim)
% Embedded MATLAB Library function.
%
% Limitations:
% No known limitations.

% $INCLUDE(DOC) toolbox/eml/lib/matlab/cumprod.m $
% Copyright 2002-2004 The MathWorks, Inc.
% $Revision: 1.1.6.4 $  $Date: 2004/04/14 23:58:07 $

eml_assert(nargin > 0, 'error', 'Not enough input arguments.');
eml_assert(isfloat(X), 'error', ['Function ''cumprod'' is not defined for values of class ''' class(X) '''.']);

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
eml_assert(dim == 1 || dim == 2,'Dimension argument ''dim'' must be either 1 or 2');

% if either dimension is 0, we should just return the matrix
if min(size(X)) == 0
    prod = X;
    return
end

%%% POSSIBLE ERROR; additional check for empty
if isempty(X)
    prod = X;
    return
end

if dim == 1
    % take product along each column

    % handle degenerate case where there is only one element in each column
    if size(X,1) == 1
        prod = X;
        return
    end

    % set prod equal to X to set the data type correctly and to initialize 
    % the first row.  Note that all other rows will be overwritten.
    prod = X;
    for jj = 1:size(X,2)
        % start with second row
        for ii = 2:size(X,1)
            prod(ii,jj) = prod(ii-1,jj) * X(ii,jj);
        end
    end
else
    % taking product along each row

    % handle degenerate case where there is only one element in each row
    if size(X,2) == 1
        prod = X;
        return
    end

    % set prod equal to X to set the data type correctly and to initialize 
    % the first column.  Note that all other columns will be overwritten.
    prod = X;
    for ii = 1:size(X,1)
        for jj = 2:size(X,2)
            prod(ii,jj) = prod(ii,jj-1) * X(ii,jj);
        end
    end
end

function bool = isfloat(x)
    bool = isa(x,'double') || isa(x,'single');

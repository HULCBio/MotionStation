function sigma = moment(x,order)
% MOMENT Central moments of all orders.
%   SIGMA = MOMENT(X,ORDER) returns the ORDER-th central sample moment of
%   the values in X.  For vector input, SIGMA is MEAN((X-MEAN(X)).^ORDER).
%   For a matrix input, MOMENT(X,ORDER) returns a row vector containing the
%   central moment of each column of X.  For N-D arrays, MOMENT operates
%   along the first non-singleton dimension.
%
%   The first central moment is exactly zero. The second central moment is
%   the variance, using a divisor of N instead of N-1, where N is the
%   sample size.
%
%   See also MEAN, STD, VAR, SKEWNESS, KURTOSIS.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.8.2.2 $  $Date: 2003/11/01 04:27:03 $

if nargin < 2
    error('stats:moment:TooFewInputs', 'Moment requires two inputs.');
elseif ~isscalar(order)
    error('stats:moment:BadOrder', 'ORDER must be a scalar.');
end

% The output size for [] is a special case, handle it here.
if isequal(x,[])
    sigma = NaN;
    return;
end;

% Figure out which dimension mean will work along
sz = size(x);
dim = find(sz ~= 1, 1);
if isempty(dim)
    dim = 1;
end

% Return the first moment exactly.
if order == 1
    sigma = mean(zeros(size(x)));
    
else
% Compute non-trivial moments.
    % Need to tile the output of mean to center X.
    tile = ones(1,ndims(x));
    tile(dim) = sz(dim);
    
    % Center X and compute the specified moment.
    warn = warning('off','MATLAB:divideByZero');
    meanx = mean(x);
    warning(warn);
    sigma = mean((x - repmat(meanx, tile)).^order);
end

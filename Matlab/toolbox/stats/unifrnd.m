function r = unifrnd(a,b,varargin)
%UNIFRND Random arrays from continuous uniform distribution.
%   R = UNIFRND(A,B) returns an array of random numbers chosen from the
%   continuous uniform distribution on the interval from A to B.  The size
%   of R is the common size of A and B if both are arrays.  If either
%   parameter is a scalar, the size of R is the size of the other
%   parameter.
%
%   R = UNIFRND(A,B,M,N,...) or R = UNIFRND(A,B,[M,N,...]) returns an
%   M-by-N-by-... array.
%
%   See also UNIFCDF, UNIFINV, UNIFPDF, UNIFSTAT, UNIDRND, RANDOM.

%   UNIFRND uses a linear transformation of standard uniform random values.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.12.4.3 $  $Date: 2004/01/24 09:37:20 $

if nargin < 2
    error('stats:unifrnd:TooFewInputs','Requires at least two input arguments.'); 
end

[err, sizeOut] = statsizechk(2,a,b,varargin{:});
if err > 0
    error('stats:unifrnd:InputSizeMismatch','Size information is inconsistent.');
end

r = a + (b-a) .* rand(sizeOut);

% Fill in elements corresponding to illegal parameter values
if ~isscalar(a) || ~isscalar(b)
    r(a > b) = NaN;
elseif a > b
    r(:) = NaN;
end

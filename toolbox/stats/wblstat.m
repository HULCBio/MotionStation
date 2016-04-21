function [m,v] = wblstat(A,B)
%WBLSTAT Mean and variance of the Weibull distribution.
%   [M,V] = WBLSTAT(A,B) returns the mean and variance of the Weibull
%   distribution with scale parameter A and shape parameter B.
%
%   The sizes of M and V are the common size of the input arguments.  A
%   scalar input functions as a constant matrix of the same size as the
%   other inputs.
%
%   See also WBLCDF, WBLFIT, WBLINV, WBLLIKE, WBLPDF, WBLRND.

%   References:
%     [1] Lawless, J.F. (1982) Statistical Models and Methods for Lifetime Data, Wiley,
%         New York.
%     [2} Meeker, W.Q. and L.A. Escobar (1998) Statistical Methods for Reliability Data,
%         Wiley, New York.
%     [3] Crowder, M.J., A.C. Kimber, R.L. Smith, and T.J. Sweeting (1991) Statistical
%         Analysis of Reliability Data, Chapman and Hall, London

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.4.4.1 $  $Date: 2003/11/01 04:29:43 $

if nargin < 2
    error('stats:wblstat:TooFewInputs',...
          'Requires at least two input arguments.');
end

% Return NaN for out of range parameters.
A(A <= 0) = NaN;
B(B <= 0) = NaN;

gam1 = gamma(1 + (1 ./ B));
gam2 = gamma(1 + (2 ./ B));
gamdiff = gam2 - gam1.^2;

% Force an Inf for very small B instead of a possible Inf-Inf==NaN.
gamdiff(gam2 == Inf) = Inf;

try
    m = A .* gam1;
    v = A.^2 .* gamdiff;
catch
    error('stats:wblstat:InputSizeMismatch',...
          'Non-scalar arguments must match in size.');
end
v(v < 0) = 0; % roundoff can make this < 0 for large B (1e8, say)

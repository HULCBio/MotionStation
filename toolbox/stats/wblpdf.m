function y = wblpdf(x,A,B)
%WBLPDF Weibull probability density function (pdf).
%   Y = WBLPDF(X,A,B) returns the pdf of the Weibull distribution
%   with scale parameter A and shape parameter B, evaluated at the
%   values in X.  The size of Y is the common size of the input arguments.
%   A scalar input functions as a constant matrix of the same size as the
%   other inputs.
%
%   Default values for A and B are 1 and 1, respectively.
%
%   See also WBLCDF, WBLFIT, WBLINV, WBLLIKE, WBLRND, WBLSTAT, PDF.

%   References:
%     [1] Lawless, J.F. (1982) Statistical Models and Methods for Lifetime Data, Wiley,
%         New York.
%     [2} Meeker, W.Q. and L.A. Escobar (1998) Statistical Methods for Reliability Data,
%         Wiley, New York.
%     [3] Crowder, M.J., A.C. Kimber, R.L. Smith, and T.J. Sweeting (1991) Statistical
%         Analysis of Reliability Data, Chapman and Hall, London

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 1.4.4.1 $  $Date: 2003/11/01 04:29:41 $

if nargin < 2
    A = 1;
end
if nargin < 3
    B = 1;
end

% Return NaN for out of range parameters.
A(A <= 0) = NaN;
B(B <= 0) = NaN;

try
    z = x ./ A;

    % Negative data would create complex values when B < 1, potentially
    % creating spurious NaNi's in other elements of y.  Map them to the far
    % right tail, which will be forced to zero.
    z(z < 0) = Inf;

    w = exp(-(z.^B));
catch
    error('stats:wblpdf:InputSizeMismatch',...
          'Non-scalar arguments must match in size.');
end
y = z.^(B-1) .* w .* B ./ A;

% Force zero for extreme right tail, instead of Inf*exp(-Inf)==NaN.  This
% also catches negative x values.
y(w == 0) = 0;

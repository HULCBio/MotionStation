function y = betapdf(x,a,b)
%BETAPDF Beta probability density function.
%   Y = BETAPDF(X,A,B) returns the beta probability density
%   function with parameters A and B at the values in X.
%
%   The size of Y is the common size of the input arguments. A scalar input
%   functions as a constant matrix of the same size as the other inputs.

%   References:
%      [1]  M. Abramowitz and I. A. Stegun, "Handbook of Mathematical
%      Functions", Government Printing Office, 1964, 26.1.33.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 2.11.2.5 $  $Date: 2004/01/24 09:33:04 $

if nargin < 3
   error('stats:betapdf:TooFewInputs','Requires three input arguments.');
end

% Return NaN for out of range parameters.
a(a<=0) = NaN;
b(b<=0) = NaN;

% Out of range x could create a spurious NaN*i part to y, prevent that.
% These entries will get set to zero later.
xOutOfRange = (x<0) | (x>1);
x(xOutOfRange) = .5;

try
    % When a==1, the density has a limit of beta(a,b) at x==0, and
    % similarly when b==1 at x==1.  Force that, instead of 0*log(0) = NaN.
    warn = warning('off','MATLAB:log:logOfZero');
    logkerna = (a-1).*log(x);   logkerna(a==1 & x==0) = 0;
    logkernb = (b-1).*log(1-x); logkernb(b==1 & x==1) = 0;
    warning(warn);
    y = exp(logkerna+logkernb - betaln(a,b));
catch
    warning(warn);
    error('stats:betapdf:InputSizeMismatch',...
          'Non-scalar arguments must match in size.');
end

% Fill in for the out of range x values, but don't overwrite NaNs from
% nonpositive params.
y(xOutOfRange & ~isnan(a) & ~isnan(b)) = 0;

function [nlogL,avar] = wbllike(params,data,censoring,freq)
%WBLLIKE Negative log-likelihood for the Weibull distribution.
%   NLOGL = WBLLIKE(PARAMS,DATA) returns the negative of the log-likelihood
%   for the Weibull distribution, evaluated at parameters PARAMS(1) = A
%   and PARAMS(2) = B, given DATA.  NLOGL is a scalar.
%
%   [NLOGL, AVAR] = WBLLIKE(PARAMS,DATA) returns the inverse of Fisher's
%   information matrix, AVAR.  If the input parameter values in PARAMS are
%   the maximum likelihood estimates, the diagonal elements of AVAR are
%   their asymptotic variances.  AVAR is based on the observed Fisher's
%   information, not the expected information.
%
%   [...] = WBLLIKE(PARAMS,DATA,CENSORING) accepts a boolean vector of the
%   same size as DATA that is 1 for observations that are right-censored
%   and 0 for observations that are observed exactly.
%
%   [...] = WBLLIKE(PARAMS,DATA,CENSORING,FREQ) accepts a frequency vector
%   of the same size as DATA.  FREQ typically contains integer frequencies
%   for the corresponding elements in DATA, but may contain any non-integer
%   non-negative values.  Pass in [] for CENSORING to use its default
%   value.
%
%   See also WBLCDF, WBLFIT, WBLINV, WBLPDF, WBLRND, WBLSTAT.

%   References:
%     [1] Lawless, J.F. (1982) Statistical Models and Methods for Lifetime Data, Wiley,
%         New York.
%     [2} Meeker, W.Q. and L.A. Escobar (1998) Statistical Methods for Reliability Data,
%         Wiley, New York.
%     [3] Crowder, M.J., A.C. Kimber, R.L. Smith, and T.J. Sweeting (1991) Statistical
%         Analysis of Reliability Data, Chapman and Hall, London

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.4.4.1 $  $Date: 2003/11/01 04:29:40 $

if nargin < 2
    error('stats:wbllike:TooFewInputs','Requires two input arguments');
elseif numel(data) > length(data)
    error('stats:wbllike:InvalidData','DATA must be a vector.');
end
if nargin < 3 | isempty(censoring)
    censoring = 0; % make this a scalar, will expand when needed
elseif ~isequal(size(data), size(censoring))
    error('stats:wbllike:InputSizeMismatch',...
          'DATA and CENSORING must have the same size.');
end
if nargin < 4 | isempty(freq)
    freq = 1; % make this a scalar, will expand when needed
elseif isequal(size(data), size(freq))
    zerowgts = find(freq == 0);
    if numel(zerowgts) > 0
        data(zerowgts) = [];
        if numel(censoring)==numel(freq), censoring(zerowgts) = []; end
        freq(zerowgts) = [];
    end
else
    error('stats:wbllike:InputSizeMismatch',...
          'DATA and FREQ must have the same size.');
end

A = params(1);
B = params(2);

% Return NaN for out of range parameters or data.
A(A <= 0) = NaN;
B(B <= 0) = NaN;
data(data < 0) = NaN;

% Compute the individual log-likelihood terms.  Force a log(0) for data from
% extreme right tail, instead of getting Inf*exp(-Inf)==NaN.
z = data ./ A;
logz = log(z);
z2B = exp(B.*logz);
L = ((B-1).*logz + log(B./A)).*(1-censoring) - z2B;
L(z == Inf) = -Inf;

% Sum up the individual contributions, and return the negative log-likelihood.
nlogL = -sum(freq.*L);

% Compute the negative hessian at the parameter values, and invert to get
% the observed information matrix.
if nargout == 2
    unc = (1-censoring);
    nH11 = sum(freq .* (B .* ((1+B).*z2B - unc))) ./ A.^2;
    nH12 = -sum(freq .* (((1+B.*logz).*z2B - unc))) ./ A;
    nH22 = sum(freq .* ((logz.^2).*z2B + unc ./ B.^2));
    avar = [nH22 -nH12; -nH12 nH11] / (nH11*nH22 - nH12*nH12);
end

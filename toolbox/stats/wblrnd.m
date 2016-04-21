function r = wblrnd(A,B,varargin)
%WBLRND Random arrays from the Weibull distribution.
%   R = WBLRND(A,B) returns an array of random numbers chosen from the
%   Weibull distribution with scale parameter A and shape parameter B.  The
%   size of R is the common size of A and B if both are arrays.  If either
%   parameter is a scalar, the size of R is the size of the other
%   parameter.
%
%   R = WBLRND(A,B,M,N,...) or  R = WBLRND(A,B,[M,N,...]) returns an
%   M-by-N-by-... array.
%
%   See also WBLCDF, WBLFIT, WBLINV, WBLLIKE, WBLPDF, WBLSTAT, RANDOM.

%   WBLRND uses the inversion method.

%   References:
%     [1] Lawless, J.F. (1982) Statistical Models and Methods for Lifetime Data, Wiley,
%         New York.
%     [2} Meeker, W.Q. and L.A. Escobar (1998) Statistical Methods for Reliability Data,
%         Wiley, New York.
%     [3] Crowder, M.J., A.C. Kimber, R.L. Smith, and T.J. Sweeting (1991) Statistical
%         Analysis of Reliability Data, Chapman and Hall, London.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.4.4.2 $  $Date: 2003/11/01 04:29:42 $

if nargin < 2
    error('stats:wblrnd:TooFewInputs','Requires at least two input arguments.');
end

[err, sizeOut] = statsizechk(2,A,B,varargin{:});
if err > 0
    error('stats:wblrnd:InputSizeMismatch','Size information is inconsistent.');
end

% Return NaN for elements corresponding to illegal parameter values.  Both
% A or B equal to zero are allowed.
A(A < 0) = NaN;
B(B < 0) = NaN;

% Generate uniform random values, and apply the Weibull inverse CDF.
r = A .* (-log(rand(sizeOut))) .^ (1./B); % == wblinv(u, A, B)

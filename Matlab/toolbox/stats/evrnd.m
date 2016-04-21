function r = evrnd(mu,sigma,varargin)
%EVRND Random arrays from the extreme value distribution.
%   R = EVRND(MU,SIGMA) returns an array of random numbers chosen from the
%   type 1 extreme value distribution with location parameter MU and scale
%   parameter SIGMA.  The size of R is the common size of MU and SIGMA if
%   both are arrays.  If either parameter is a scalar, the size of R is the
%   size of the other parameter.
%
%   R = EVRND(MU,SIGMA,M,N,...) or R = EVRND(MU,SIGMA,[M,N,...]) returns an
%   M-by-N-by-... array.
%
%   The type 1 extreme value distribution is also known as the Gumbel
%   distribution.  If Y has a Weibull distribution, then X=log(Y) has the
%   type 1 extreme value distribution.
%
%   See also EVCDF, EVFIT, EVINV, EVLIKE, EVPDF, EVSTAT, RANDOM.

%   EVRND uses the inversion method.

%   References:
%     [1] Lawless, J.F. (1982) Statistical Models and Methods for Lifetime Data, Wiley,
%         New York.
%     [2} Meeker, W.Q. and L.A. Escobar (1998) Statistical Methods for Reliability Data,
%         Wiley, New York.
%     [3] Crowder, M.J., A.C. Kimber, R.L. Smith, and T.J. Sweeting (1991) Statistical
%         Analysis of Reliability Data, Chapman and Hall, London.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.4.4.3 $  $Date: 2004/01/24 09:33:30 $

if nargin < 2
    error('stats:evrnd:TooFewInputs','Requires at least two input arguments.');
end

[err, sizeOut] = statsizechk(2,mu,sigma,varargin{:});
if err > 0
    error('stats:evrnd:InputSizeMismatch','Size information is inconsistent.');
end

% Return NaN for elements corresponding to illegal parameter values.
sigma(sigma < 0) = NaN;

% Generate uniform random values, and apply the extreme value inverse CDF.
r = log( -log(rand(sizeOut)) ) .* sigma + mu;

function [m,v] = expstat(mu)
%EXPSTAT Mean and variance of the exponential distribution.
%   [M,V] = EXPSTAT(MU) returns the mean and variance of the exponential
%   distribution with location parameter MU.  M and V are the size of the
%   input argument.
%
%   See also EXPCDF, EXPFIT, EXPINV, EXPLIKE, EXPPDF, EXPRND.

%   References:
%     [1] Lawless, J.F. (1982) Statistical Models and Methods for Lifetime Data, Wiley,
%         New York.
%     [2} Meeker, W.Q. and L.A. Escobar (1998) Statistical Methods for Reliability Data,
%         Wiley, New York.
%     [3] Crowder, M.J., A.C. Kimber, R.L. Smith, and T.J. Sweeting (1991) Statistical
%         Analysis of Reliability Data, Chapman and Hall, London.

%     Copyright 1993-2004 The MathWorks, Inc. 
%     $Revision: 2.12.4.2 $  $Date: 2004/01/24 09:33:40 $

if nargin < 1
    error('stats:expstat:TooFewInputs',...
          'Requires at least one input argument.');
end

% Return NaN for out of range parameters.
mu(mu <= 0) = NaN;

m = mu;
v = mu.^2;

function [m,v] = evstat(mu,sigma)
%EVSTAT Mean and variance of the extreme value distribution.
%   [M,V] = EVSTAT(MU,SIGMA) returns the mean and variance of the type 1
%   extreme value distribution with location parameter MU and scale
%   parameter SIGMA.
%
%   The sizes of M and V are the common size of the input arguments.  A
%   scalar input functions as a constant matrix of the same size as the
%   other inputs.
%
%   The type 1 extreme value distribution is also known as the Gumbel
%   distribution.  If Y has a Weibull distribution, then X=log(Y) has the
%   type 1 extreme value distribution.
%
%   See also EVCDF, EVFIT, EVINV, EVLIKE, EVPDF, EVRND.

%   References:
%     [1] Lawless, J.F. (1982) Statistical Models and Methods for Lifetime Data, Wiley,
%         New York.
%     [2} Meeker, W.Q. and L.A. Escobar (1998) Statistical Methods for Reliability Data,
%         Wiley, New York.
%     [3] Crowder, M.J., A.C. Kimber, R.L. Smith, and T.J. Sweeting (1991) Statistical
%         Analysis of Reliability Data, Chapman and Hall, London

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.3.4.2 $  $Date: 2004/01/24 09:33:31 $

if nargin < 2
    error('stats:evstat:TooFewInputs',...
          'Requires at least two input arguments.');
end

% Return NaN for out of range parameters.
sigma(sigma <= 0) = NaN;

try
    m = mu + psi(1) .* sigma; % -psi(1) is euler's constant
    v = (pi .* sigma).^2 ./ 6 + zeros(size(mu)); % expand v's size to match mu if necessary
catch
    error('stats:evstat:InputSizeMismatch',...
          'Non-scalar arguments must match in size.');
end

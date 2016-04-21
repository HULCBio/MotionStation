function g = rc2lar(k)
%RC2LAR Convert reflection coefficients to log area ratios.
%   G = RC2LAR(K) returns the log area ratios corresponding to the reflection
%   coefficients, K.
%
%   The log area ratio is defined by G = log((1+k)/(1-k)) , where the K is the
%   reflection coefficient.
%
%   See also LAR2RC, RC2POLY, RC2AC, RC2IS.

%   References:
%   [1] J. Makhoul, "Linear Prediction: A Tutorial Review," Proc. IEEE,
%   Vol.63, No.4, pp.561-580, Apr 1975.
%   [2] ITU-T Recommendation G.729 (03/96)
%
%   Author(s): A. Ramasubramanian
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/04/15 01:15:49 $

if ~isreal(k),
    error('Log area ratios not defined for complex reflection coefficients.');
end

if max(abs(k)) >= 1,
    error('All reflection coefficients should have magnitude less than unity.');
end

% Use the relation, atanh(x) = (1/2)*log((1+k)/(1-k))

g = -2*atanh(-k);

% [EOF] rc2lar.m

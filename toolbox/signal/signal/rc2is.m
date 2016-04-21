function inv_sin = rc2is(k)
%RC2IS Convert reflection coefficients to inverse sine parameters.
%   INV_SIN = RC2IS(K) returns the inverse sine parameters corresponding 
%   to the reflection coefficients, K.
%
%   See also IS2RC, RC2POLY, RC2AC, RC2LAR.

%   Reference: J.R. Deller, J.G. Proakis, J.H.L. Hansen, "Discrete-Time 
%   Processing of Speech Signals", Prentice Hall, Section 7.4.5.
%
%   Author(s): A. Ramasubramanian
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/04/15 01:15:55 $

if ~isreal(k),
 error('Inverse sine parameters not defined for complex reflection coefficients.');
end           

if max(abs(k)) >= 1,
    error('All reflection coefficients should have magnitude less than unity.');
end

inv_sin = (2/pi)*asin(k);

% [EOF] rc2is.m

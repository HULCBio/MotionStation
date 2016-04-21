function k = is2rc(inv_sin)
%IS2RC  Convert inverse sine parameters to reflection coefficients.
%   K = IS2RC(INV_SIN) returns the reflection coefficients corresponding 
%   to the inverse sine parameters, INV_SIN. 
%
%   See also RC2IS, POLY2RC, AC2RC, LAR2RC.

%   Reference: J.R. Deller, J.G. Proakis, J.H.L. Hansen, "Discrete-Time 
%   Processing of Speech Signals", Prentice Hall, Section 7.4.5.
%
%   Author(s): A. Ramasubramanian
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/04/15 01:15:58 $

if ~isreal(inv_sin),
    error('Inverse sine parameters must be real.');
end

k = sin(inv_sin*pi/2);

% [EOF] is2rc.m
function y = asecd(x)
%ASECD  Inverse secant, result in degrees.
%   ASECD(X) is the inverse secant, expressed in degrees,
%   of the elements of X.
%
%   See also SECD, ASEC.

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2003/11/24 23:23:46 $

if ~isreal(x)
    error('MATLAB:asecd:ComplexInput', 'Argument should be real.');
end

y = 180/pi*acos(1./x);

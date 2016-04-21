function y = acscd(x)
%ACSCD  Inverse cosecant, result in degrees.
%   ACSCD(X) is the inverse cosecant, expressed in degrees,
%   of the elements of X.
%
%   See also CSCD, ACSC.

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2003/11/24 23:23:45 $

if ~isreal(x)
    error('MATLAB:acscd:ComplexInput', 'Argument should be real.');
end

y = 180/pi*asin(1./x);

function y = acotd(x)
%ACOTD  Inverse cotangent, result in degrees.
%   ACOTD(X) is the inverse cotangent, expressed in degrees,
%   of the elements of X.
%
%   See also COTD, ACOT.

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2003/11/24 23:23:44 $

if ~isreal(x)
    error('MATLAB:acotd:ComplexInput', 'Argument should be real.');
end

y = 180/pi*atan(1./x);

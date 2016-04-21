function y = asind(x)
%ASIND  Inverse sine, result in degrees.
%   ASIND(X) is the inverse sine, expressed in degrees,
%   of the elements of X.
%
%   SIND, ASIN.

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2003/11/24 23:23:47 $

if ~isreal(x)
    error('MATLAB:asind:ComplexInput', 'Argument should be real.');
end

y = 180/pi*asin(x);

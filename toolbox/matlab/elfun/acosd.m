function y = acosd(x)
%ACOSD  Inverse cosine, result in degrees.
%   ACOSD(X) is the inverse cosine, expressed in degrees,
%   of the elements of X.
%
%   See also COSD, ACOS.

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2003/11/24 23:23:43 $

if ~isreal(x)
    error('MATLAB:acosd:ComplexInput', 'Argument should be real.');
end

y = 180/pi*acos(x);

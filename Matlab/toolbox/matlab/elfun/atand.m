function y = atand(x)
%ATAND  Inverse tangent, result in degrees.
%   ATAND(X) is the inverse tangent, expressed in degrees,
%   of the elements of X.
%
%   See also TAND, ATAN.

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2003/11/24 23:23:48 $

if ~isreal(x)
    error('MATLAB:atand:ComplexInput', 'Argument should be real.');
end

y = 180/pi*atan(x);

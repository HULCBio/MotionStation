function y = secd(x)
%SECD   Secant of argument in degrees.
%   SECD(X) is the secant of the elements of X, expressed in degrees.
%   For odd integers n, secd(n*90) is infinite, whereas sec(n*pi/2) is large
%   but finite, reflecting the accuracy of the floating point value for pi.
%
%   See also ASECD, SEC.

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2003/11/24 23:23:52 $

if ~isreal(x)
    error('MATLAB:secd:ComplexInput', 'Argument should be real.');
end

y = 1./cosd(x);

function y = cscd(x)
%CSCD   Cosecant of argument in degrees.
%   CSCD(X) is the cosecant of the elements of X, expressed in degrees.
%   For integers n, cscd(n*180) is infinite, whereas csc(n*pi) is large
%   but finite, reflecting the accuracy of the floating point value for pi.
%
%   See also ACSCD, CSC.

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2003/11/24 23:23:51 $

if ~isreal(x)
    error('MATLAB:cscd:ComplexInput', 'Argument should be real.');
end

y = 1./sind(x);

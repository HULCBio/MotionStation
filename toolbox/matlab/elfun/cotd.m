function y = cotd(x)
%COTD   Cotangent of argument in degrees.
%   COTD(X) is the cotangent of the elements of X, expressed in degrees.
%   For integers n, cotd(n*180) is infinite, whereas cot(n*pi) is large
%   but finite, reflecting the accuracy of the floating point value of pi.
%
%   See also ACOTD, COT.

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2003/11/24 23:23:50 $

if ~isreal(x)
    error('MATLAB:cotd:ComplexInput', 'Argument should be real.');
end

y = 1./tand(x);

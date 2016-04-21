function y = erf(x)
%ERF Error function.
%   Y = ERF(X) is the error function for each element of X.  X must be
%   real. The error function is defined as:
%
%     erf(x) = 2/sqrt(pi) * integral from 0 to x of exp(-t^2) dt.
%
%   See also ERFC, ERFCX, ERFINV.

%   Ref: Abramowitz & Stegun, Handbook of Mathematical Functions, sec. 7.1.

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 5.13.4.2 $  $Date: 2003/07/31 05:26:29 $

% Derived from a FORTRAN program by W. J. Cody.
% See ERFCORE.

y = erfcore(x,0);

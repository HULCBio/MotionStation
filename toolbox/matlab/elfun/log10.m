function y = log10(x)
%LOG10  Common (base 10) logarithm.
%   LOG10(X) is the base 10 logarithm of the elements of X.   
%   Complex results are produced if X is not positive.
%
%   See also LOG, LOG2, EXP, LOGM.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.10.4.1 $  $Date: 2004/01/24 09:21:36 $

% Compute y = log2(x)/log2(10) with an averaging process so that roundoff
% errors cancel and log10(10^k) == k for all integers k = -307:308.
% Use y = log2(x)/c1 + log2(x)/c2 where c1 = 2*log2(10)+2.5*eps,
% c2 = 2*log2(10)-1.5*eps are successive floating point numbers on
% either side of 2*log2(10).

y = log2(x);
y = y/6.64385618977472436 + y/6.64385618977472525;

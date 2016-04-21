function y = acsc(z)
%ACSC   Inverse cosecant.
%   ACSC(X) is the inverse cosecant of the elements of X.
%
%   See also CSC, ACSCD.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.7.4.2 $  $Date: 2004/04/16 22:05:44 $

y = asin(1./z);

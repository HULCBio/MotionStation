function y = asec(z)
%ASEC   Inverse secant.
%   ASEC(X) is the inverse secant of the elements of X.
%
%   See also SEC, ASECD.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.7.4.2 $  $Date: 2004/04/16 22:05:46 $

y = acos(1./z);

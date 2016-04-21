function y = erfcx(x)
%ERFCX  Scaled complementary error function.
%   Y = ERFCX(X) is the scaled complementary error function for each
%   element of X.  X must be real.  The scaled complementary error
%   function is defined as: 
%
%     erfcx(x) = exp(x^2) * erfc(x)
%
%   which is approximately (1/sqrt(pi)) * 1/x for large x.
%
%   See also ERF, ERFC, ERFINV.

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 5.10.4.2 $  $Date: 2003/07/31 05:26:32 $

% Derived from a FORTRAN program by W. J. Cody.

y = erfcore(x,2);

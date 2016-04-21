function y = betaln(z,w)
%BETALN Logarithm of beta function.
%   Y = BETALN(Z,W) computes the natural logarithm of the beta
%   function for corresponding elements of Z and W.   The arrays Z and
%   W must be the same size (or either can be scalar).  BETALN is
%   defined as:
%
%       BETALN = LOG(BETA(Z,W)) 
%
%   and is obtained without computing BETA(Z,W). Since the beta
%   function can range over very large or very small values, its
%   logarithm is sometimes more useful.
%
%   See also BETAINC, BETA.

%   Reference: Abramowitz & Stegun, sec. 6.2.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.8 $  $Date: 2002/04/15 03:55:42 $

y = gammaln(z)+gammaln(w)-gammaln(z+w);

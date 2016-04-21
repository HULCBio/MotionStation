function y = beta(z,w,v)
%BETA   Beta function.
%   Y = BETA(Z,W) computes the beta function for corresponding
%   elements of Z and W.  The beta function is defined as
%
%   beta(z,w) = integral from 0 to 1 of t.^(z-1) .* (1-t).^(w-1) dt.
%
%   The arrays Z and W must be the same size (or either can be
%   scalar).
%
%   See also BETAINC, BETALN.

%   C. Moler, 2-1-91.
%   Ref: Abramowitz & Stegun, sec. 6.2.
%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 5.10.4.1 $  $Date: 2003/05/01 20:43:29 $

if nargin<2,
  error('MATLAB:beta:NotEnoughInputs', 'Not enough input arguments.');
elseif nargin == 2
    y = exp(gammaln(z)+gammaln(w)-gammaln(z+w));
elseif nargin == 3
    warning('MATLAB:beta:ObsoleteUsage',['This usage of BETA(X,Z,W) is ' ...
            'obsolete and will be eliminated\n         in future versions.' ...
            '  Please use BETAINC(X,Z,W) instead.']);
    y = betainc(z,w,v);
end

function [logL,avar] = betalike(params,data)
%BETALIKE Negative beta log-likelihood function.
%   LOGL = BETALIKE(PARAMS,DATA) returns the negative of beta log-likelihood  
%   function for the parameters PARAMS(1) = A and PARAMS(2) = B, given DATA.
%
%   [LOGL, AVAR] = BETALIKE(PARAMS,DATA) adds the inverse of Fisher's
%   information matrix, AVAR.  If the input parameter values in PARAMS
%   are the maximum likelihood estimates, the diagonal elements of AVAR
%   are their asymptotic variances.  AVAR is based on the observed
%   Fisher's information, not the expected information.
%
%   BETALIKE is a utility function for maximum likelihood estimation. 
%   See also BETAFIT, GAMLIKE, MLE, NORMLIKE, WBLLIKE.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.14.4.2 $  $Date: 2004/01/16 20:08:54 $

if nargin < 2, 
    error('stats:betalike:TooFewInputs','Requires two input arguments.');
end

[n, m] = size(data);
if nargout == 2 & max(m,n) == 1
   error('stats:betalike:NotEnoughData',...
         'To compute AVAR, DATA must have at least two elements.');
end

if n == 1
   data = data';
   n = m;
end
data(data>=1 | data <=0 | isnan(data)) = [];

a = params(1);
b = params(2);
ld = log(data);
l1d = log(1-data);
bl = betaln(a,b);

logL = n*bl+(1-a)*sum(ld)+(1-b)*sum(l1d);

if nargout == 2
  delta = sqrt(max(eps(class(a)),eps(class(b))));
  J = [(bl-betaln(a+delta,b))/delta+ld, (bl-betaln(a,b+delta))/delta+l1d];
  [Q,R]= qr(J,0);
  Rinv = R\eye(2);
  avar = Rinv*Rinv';
end

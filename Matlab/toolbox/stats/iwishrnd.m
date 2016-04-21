function [a,di] = iwishrnd(sigma,df,di)
%IWISHRND Generate inverse Wishart random matrix
%   W=IWISHRND(SIGMA,DF) generates a random matrix W whose inverse
%   has the Wishart distribution with covariance matrix SIGMA and 
%   with DF degrees of freedom.
%
%   W=IWISHRND(SIGMA,DF,DI) expects DI to be the Cholesky factor of
%   the inverse of SIGMA.  If you call IWISHRND multiple times using
%   the same value of SIGMA, it's more efficient to supply DI instead
%   of computing it each time.
%
%   [W,DI]=IWISHRND(SIGMA,DF) returns DI so it can be used again in
%   future calls to IWISHRND.
%
%   See also WISHRND.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.4.4.3 $  $Date: 2004/01/24 09:34:13 $

% Error checking
if nargin<2
   error('stats:iwishrnd:TooFewInputs','Two arguments are required.');
end

[n,m] = size(sigma);
if n~=m
   error('stats:iwishrnd:BadCovariance','Covariance matrix must be square.');
end
if (nargin<3) & ~all(all(abs(sigma-sigma') <= ...
                         abs(sigma) * sqrt(eps(class(sigma)))))
   error('stats:iwishrnd:BadCovariance',...
         'Covariance matrix must be symmetric.');
end
if (prod(size(df))~=1) | (df<=0)
   error('stats:iwishrnd:BadDf',...
         'Degrees of freedom must be a positive scalar.')
end
if (df<n)
   error('stats:iwishrnd:BadDf',...
         'Degrees of freedom must be no smaller than the dimension of SIGMA.');
end

% Get Cholesky factor for inv(sigma) unless that's already done
if nargin<3
   [d,p] = chol(sigma);
   if p>0
      error('stats:iwishrnd:BadSigma',...
            'SIGMA must be symmetric and positive definite.');
   end
   di = d\eye(size(d));
end

% Note:  the following would be more correct using inv(sigma) as the
% first argument, but that's not really necessary if we've already
% factored inv(sigma).
a = wishrnd(sigma,df,di);
a = a\eye(size(a));

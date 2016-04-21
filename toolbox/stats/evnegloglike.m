function [nll,ngrad] = evnegloglike(params,x,cens,freq)
%EVNEGLOGLIKE Negative log-likelihood for the extreme value distribution.
%
%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/03/22 23:55:02 $
mu = params(1);
sigma = params(2);
nunc = sum(1-cens);
z = (x - mu) ./ sigma;
expz = exp(z);
nll = sum(expz) - sum(z(~cens)) + nunc.*log(sigma);
if nargout > 1
    ngrad = [-sum(expz)./sigma + nunc./sigma, ...
             -sum(z.*expz)./sigma + sum(z(~cens))./sigma + nunc./sigma];
end

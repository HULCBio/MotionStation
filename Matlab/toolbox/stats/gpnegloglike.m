function nll = gpnegloglike(params, data, cens, freq)
%GPNEGLOGLIKE Negative log-likelihood for the Generalized Pareto Distribution.
% The input PARAMS is a vector containing the values of k and sigma at
% which to evaluate the log-likelihood.  The input DATA contains the data
% which we are fitting.   The inputs CENS and FREQ are not used in this
% example.
%
%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/03/22 23:55:06 $
k     = params(1);   % Tail index parameter
sigma = params(2);   % Scale parameter

n = numel(data);

if abs(k) > eps
    if k > 0 || max(data) < -sigma./k
        % The log-likelihood is the log of the GPD probability density
        % function.  GPDnegloglike returns the negative of that.
        nll = n*log(sigma) + ((k+1)./k) * sum(log1p((k./sigma)*data));
    else
        % We need to enforce non-box constraints on the parameters:  the
        % support of the GPD when k<0 is 0 < y < abs(sigma/k).  Return a
        % large value for the negative log-likelihood.
        nll = realmax;
    end
else
    % The limit of the GPD as k->0 is an exponential.  We have to handle
    % that case explicity, otherwise the above calculation would try to
    % compute (1/0) * log(1) == Inf*0, which results in a NaN value.
    nll = n*log(sigma) + sum(data)./sigma;
end

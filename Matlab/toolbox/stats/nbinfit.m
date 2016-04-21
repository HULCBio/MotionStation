function [parmhat, parmci] = nbinfit(x, alpha, options)
%NBINFIT Parameter estimates for negative binomial data.
%   NBINFIT(X) Returns the maximum likelihood estimates of the
%   parameters of the negative binomial distribution given the data in
%   the vector, X.
%
%   [PARMHAT, PARMCI] = NBINFIT(X,ALPHA) returns MLEs and 100(1-ALPHA)
%   percent confidence intervals given the data.  By default, the
%   optional parameter ALPHA = 0.05 corresponding to 95% conf. intervals.
%
%   [ ... ] = NBINFIT( ..., OPTIONS) specifies control parameters for the
%   numerical optimization used to compute ML estimates.  This argument can
%   be created by a call to STATSET.  See STATSET('nbinfit') for parameter
%   names and default values.
%
%   See also NBINCDF, NBININV, NBINPDF, NBINRND, NBINSTAT, MLE, STATSET.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 1.5.4.6 $  $Date: 2004/02/01 22:10:26 $

% The default options include turning fminsearch's display off.  This
% function gives its own warning/error messages, and the caller can turn
% display on to get the text output from fminsearch if desired.
if nargin < 3 || isempty(options)
    options = statset('nbinfit');
else
    options = statset(statset('nbinfit'),options);
end
if nargin < 2 || isempty(alpha)
    alpha = 0.05;
end
p_int = [alpha/2; 1-alpha/2];

if min(size(x)) > 1
    error('stats:nbinfit:InvalidData','The first argument must be a vector.');
end

% Illegal data return an error.
if ~all(0 <= x & isfinite(x) & x == round(x))
    error('stats:nbinfit:InvalidData','Negative or non-integer data.');
end
if ~isfloat(x)
    x = double(x);
end

xbar = mean(x);
s2   = var(x);

% Ensure that a NB fit is appropriate.
if s2 <= xbar
    parmhat = cast([Inf 1.0],class(x));
    parmci = cast([Inf 1; Inf 1],class(x));
    warning('stats:nbinfit:MeanExceedsVariance',...
            'The sample mean exceeds the sample variance -- use POISSFIT instead.');
    return
end

% Use Method of Moments estimates as starting point for MLEs.
rhat = (xbar.*xbar) ./ (s2-xbar);
phat = xbar ./ s2;

% Parametrizing with mu=r(1-p)/p makes this a 1-D search for rhat.
muhat = xbar;
[rhat,nll,err,output] = ...
    fminsearch(@negloglike, rhat, options, length(x), x, sum(x), options.TolBnd);
if (err == 0)
    % fminsearch may print its own output text; in any case give something
    % more statistical here, controllable via warning IDs.
    if output.funcCount >= options.MaxFunEvals
        wmsg = 'Maximum likelihood estimation did not converge.  Function evaluation limit exceeded.';
    else
        wmsg = 'Maximum likelihood estimation did not converge.  Iteration limit exceeded.';
    end
    if rhat > 100 % shape became very large
       wmsg = sprintf('%s\n%s', wmsg, ...
                      'The Poisson distribution might provide a better fit.');
    end
    warning('stats:nbinfit:IterOrEvalLimit',wmsg);
elseif (err < 0)
    error('stats:nbinfit:NoSolution', ...
          'Unable to reach a maximum likelihood solution.');
end
phat = rhat ./ (muhat + rhat);
parmhat = [rhat phat];

if nargout > 1
   [logL, info] = nbinlike(parmhat, x);
   sigma = sqrt(diag(info));
   parmci = norminv([p_int p_int], [parmhat; parmhat], [sigma'; sigma']);
end

%-------------------------------------------------------------------------

function nll = negloglike(r, n, x, sumx, tolBnd)
% Objective function for fminsearch().  Returns the negative of the
% (profile) log-likelihood for the negative binomial, evaluated at
% r.  From the likelihood equations, phat = rhat/(xbar+rhat), and so the
% 2-D search for [rhat phat] reduces to a 1-D search for rhat -- also
% equivalent to reparametrizing in terms of mu=r(1-p)/p, where muhat=xbar
% can be found explicitly.

% Restrict r to the open interval (0, Inf).
if r < tolBnd
    nll = Inf;

else
    xbar = sumx / n;
    nll = -sum(gammaln(r+x)) + n*gammaln(r) ...
                - n*r*log(r/(xbar+r)) - sumx*log(xbar/(xbar+r));
end
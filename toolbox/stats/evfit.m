function [parmhat, parmci] = evfit(x,alpha,censoring,freq,options)
%EVFIT Parameter estimates and confidence intervals for extreme value data.
%   PARMHAT = EVFIT(X) returns maximum likelihood estimates of the
%   parameters of the type 1 extreme value distribution given the data in
%   X.  PARMHAT(1) is the location parameter, mu, and PARMHAT(2) is the
%   scale parameter, sigma.
%
%   [PARMHAT,PARMCI] = EVFIT(X) returns 95% confidence intervals for the
%   parameter estimates.
%
%   [PARMHAT,PARMCI] = EVFIT(X,ALPHA) returns 100(1-ALPHA) percent
%   confidence intervals for the parameter estimates.
%
%   [...] = EVFIT(X,ALPHA,CENSORING) accepts a boolean vector of the same
%   size as X that is 1 for observations that are right-censored and 0 for
%   observations that are observed exactly.
%
%   [...] = EVFIT(X,ALPHA,CENSORING,FREQ) accepts a frequency vector of the
%   same size as X.  FREQ typically contains integer frequencies for the
%   corresponding elements in X, but may contain any non-integer
%   non-negative values.
%
%   [...] = EVFIT(X,ALPHA,CENSORING,FREQ,OPTIONS) specifies control
%   parameters for the iterative algorithm used to compute ML estimates.
%   This argument can be created by a call to STATSET.  See STATSET('evfit')
%   for parameter names and default values.
%
%   Pass in [] for ALPHA, CENSORING, or FREQ to use their default values.
%
%   The type 1 extreme value distribution is also known as the Gumbel
%   distribution.  If Y has a Weibull distribution, then X=log(Y) has the
%   type 1 extreme value distribution.
%
%   See also EVCDF, EVINV, EVLIKE, EVPDF, EVRND, EVSTAT, MLE, STATSET.

%   References:
%     [1] Lawless, J.F. (1982) Statistical Models and Methods for Lifetime Data, Wiley,
%         New York.
%     [2} Meeker, W.Q. and L.A. Escobar (1998) Statistical Methods for Reliability Data,
%         Wiley, New York.
%     [3] Crowder, M.J., A.C. Kimber, R.L. Smith, and T.J. Sweeting (1991) Statistical
%         Analysis of Reliability Data, Chapman and Hall, London

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 1.5.4.7 $  $Date: 2004/04/16 22:21:58 $

% Illegal data return an error.
if ~isvector(x)
    error('stats:evfit:VectorRequired','X must be a vector.');
end

if nargin < 2 || isempty(alpha)
    alpha = 0.05;
end
if nargin < 3 || isempty(censoring)
    censoring = zeros(size(x));
elseif ~isempty(censoring) && ~isequal(size(x), size(censoring))
    error('stats:evfit:InputSizeMismatch',...
          'X and CENSORING must have the same size.');
end
if nargin < 4 || isempty(freq)
    freq = ones(size(x));
elseif ~isempty(freq) && ~isequal(size(x), size(freq))
    error('stats:evfit:InputSizeMismatch',...
          'X and FREQ must have the same size.');
else
    zerowgts = find(freq == 0);
    if numel(zerowgts) > 0
        x(zerowgts) = [];
        censoring(zerowgts) = [];
        freq(zerowgts) = [];
    end
end

% The default options include turning fzero's display off.  This function
% gives its own warning/error messages, and the caller can turn display on
% to get the text output from fzero if desired.
if nargin < 5 || isempty(options)
    options = statset('evfit');
else
    options = statset(statset('evfit'),options);
end

classX = class(x);

n = sum(freq);
ncensored = sum(freq.*censoring);
nuncensored = n - ncensored;
rangex = range(x);
maxx = max(x);

% When all observations are censored, the likelihood surface is flat and
% at its maximum for any mu > max(x), can't make a fit.
if n == 0 || nuncensored == 0 || ~isfinite(rangex)
    parmhat = NaN(1,2,classX);
    parmci = NaN(2,2,classX);
    return
    
elseif ncensored == 0
    % The likelihood surface for constant data has its maximum at the
    % boundary sigma==0.  Return something reasonable anyway.
    if rangex < realmin(classX)
        parmhat = [x(1) 0];
        if n == 1
            parmci = cast([-Inf 0; Inf Inf], classX);
        else
            parmci = [parmhat; parmhat];
        end
        return
    end
    % Otherwise the data are ok to fit EV distr, go on.

else
    % When all uncensored observations are equal and greater than all the
    % censored observations, the likelihood surface has its maximum at the
    % boundary sigma==0.  Return something reasonable anyway.
    rangexUnc = range(x(censoring==0));
    if rangexUnc < realmin(classX)
        xunc = x(censoring==0);
        if xunc(1) >= maxx
            parmhat = [xunc(1) 0];
            if nuncensored == 1
                parmci = cast([-Inf 0; Inf Inf],classX);
            else
                parmci = [parmhat; parmhat];
            end
            return
        end
    end
    % Otherwise the data are ok to fit EV distr, go on.
end

% Shift x to max(x) == 0, min(x) = -1 to make likelihood eqn more stable.
x0 = (x - maxx) ./ rangex;

% First, get a rough estimate for the scale parameter sigma as a starting value.
%
% Use MM when there is no censoring ...
if ncensored == 0
    sigmahat = (sqrt(6)*std(x0))/pi;
    wgtmeanUnc = sum(freq.*x0) ./ n;
    
else
    % ... or use the "least squares" method when there is censoring ...
    if rangexUnc > 0
        [p,q] = ecdf(x0, 'censoring',censoring, 'frequency',freq);
        pmid = (p(1:(end-1))+p(2:end)) / 2;
        linefit = polyfit(log(-log((1-pmid))), q(2:end), 1);
        sigmahat = linefit(1);
        
        % ...unless there's only one uncensored value.
    else
        sigmahat = ones(classX);
    end
    wgtmeanUnc = sum(freq.*x0.*(1-censoring)) ./ nuncensored;
end

% Bracket the root of the scale parameter likelihood eqn ...
if lkeqn(sigmahat, x0, freq, wgtmeanUnc) > 0
    upper = sigmahat; lower = .5 * upper;
    while lkeqn(lower, x0, freq, wgtmeanUnc) > 0
        upper = lower;
        lower = .5 * upper;
        if lower < realmin(classX) % underflow, no positive root
            error('stats:evfit:NoSolution',...
                  'Unable to reach a maximum likelihood solution.');
        end
    end
else
    lower = sigmahat; upper = 2 * lower;
    while lkeqn(upper, x0, freq, wgtmeanUnc) < 0
        lower = upper;
        upper = 2 * lower;
        if upper > realmax(classX) % overflow, no finite root
            error('stats:evfit:NoSolution',...
                  'Unable to reach a maximum likelihood solution.');
        end
    end
end
bnds = [lower upper];

% ... then find the root of the likelihood eqn.  That is the MLE for sigma,
% and the MLE for mu has an explicit sol'n. 
[sigmahat, lkeqnval, err] = fzero(@lkeqn, bnds, options, x0, freq, wgtmeanUnc);
if (err < 0)
    error('stats:evfit:NoSolution',...
          'Unable to reach a maximum likelihood solution.'); % should never happen
elseif eps(abs(lkeqnval)) > options.TolX
    warning('stats:evfit:IllConditioned',...
            'The likelihood equation may be ill-conditioned.');
end
muhat = sigmahat .* log( sum(freq.*exp(x0./sigmahat)) ./ nuncensored );

% Those were parameter estimates for the shifted, scaled data, now
% transform the parameters back to the original location and scale.
parmhat = [(rangex*muhat)+maxx rangex*sigmahat];

if nargout == 2
    probs = [alpha/2; 1-alpha/2];
    [nlogL, acov] = evlike(parmhat, x, censoring, freq);
    
    % Compute the CI for mu using a normal approximation for muhat.  Compute
    % the CI for sigma using a normal approximation for log(sigmahat), and
    % transform back to the original scale.
    transfhat = [parmhat(1) log(parmhat(2))];
    se = sqrt(diag(acov))';
    se(2) = se(2) ./ parmhat(2); % se(log(sigmahat)) = se(sigmahat) / sigmahat
    parmci = norminv([probs, probs], [transfhat; transfhat], [se; se]);
    parmci(:,2) = exp(parmci(:,2));
end


function v = lkeqn(sigma, x, w, xbarWgtUnc)
% Likelihood equation for the extreme value scale parameter.  Assumes that
% sigma is strictly positive and finite, and x has been transformed to be
% non-positive and have a reasonable range.  At least one uncensored x must
% be strictly negative, or else the likelihood eqn will have a root at
% sigma==0.  x should contain the transformed uncensored data and the
% transformed censoring points of the censored data, and xbarWgtUnc should
% be computed from the transformed uncensored data only.
%
% as sigma->0, v->(sigma+xbarWgtUnc-0)->xbarWgtUnc < 0 (because all x <= 0, and at least
%                                                       one uncensored one is < 0)
% as sigma->Inf, v ->(sigma+xbarWgtUnc-xbar)->Inf > 0
%
w = w .* exp(x ./ sigma);
v = sigma + xbarWgtUnc - sum(x .* w) / sum(w);

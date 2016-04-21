function [parmhat, parmci] = gamfit(x, alpha, censoring, freq, options)
%GAMFIT Parameter estimates for gamma distributed data.
%   PARMHAT = GAMFIT(X) returns maximum likelihood estimates of the
%   parameters of a gamma distribution fit to the data in X.  PARMHAT(1)
%   and PARMHAT(2) are estimates of the shape and scale parameters A and B,
%   respectively.
%
%   [PARMHAT,PARMCI] = GAMFIT(X) returns 95% confidence intervals for the
%   parameter estimates.
%
%   [PARMHAT,PARMCI] = GAMFIT(X,ALPHA) returns 100(1-ALPHA) percent
%   confidence intervals for the parameter estimates.
%
%   [...] = GAMFIT(X,ALPHA,CENSORING) accepts a boolean vector of the same
%   size as X that is 1 for observations that are right-censored and 0 for
%   observations that are observed exactly.
%
%   [...] = GAMFIT(X,ALPHA,CENSORING,FREQ) accepts a frequency vector of
%   the same size as X.  FREQ typically contains integer frequencies for
%   the corresponding elements in X, but may contain any non-negative values.
%
%   [...] = GAMFIT(X,ALPHA,CENSORING,FREQ,OPTIONS) specifies control
%   parameters for the iterative algorithm used to compute ML estimates
%   when there is censoring.  This argument can be created by a call to
%   STATSET.  See STATSET('gamfit') for parameter names and default values.
%
%   Pass in [] for ALPHA, CENSORING, or FREQ to use their default values.
%
%   See also GAMCDF, GAMINV, GAMLIKE, GAMPDF, GAMRND, GAMSTAT, MLE, STATSET.

%   References:
%      [1] Evans, M., Hastings, N., and Peacock, B. (1993) Statistical
%          Distributions, 2nd ed., Wiley.
%      [2] Lawless, J.F. (1982) Statistical Models and Methods for Lifetime
%          Data, Wiley.
%      [3} Meeker, W.Q. and L.A. Escobar (1998) Statistical Methods for
%          Reliability Data, Wiley.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 2.14.6.7 $  $Date: 2004/02/01 22:10:22 $

% Need to look for the old 3-arg form: gamfit(x,alpha,options)
oldSyntax = false;

if nargin < 2 || isempty(alpha)
    alpha = 0.05;
end
if nargin < 3 || isempty(censoring)
    censoring = 0; % make this a scalar, will expand when needed
elseif nargin == 3 && isstruct(censoring)
    % This is the grandfathered 3-arg form gamfit(x,alpha,options)
    options = censoring;
    censoring = 0;
    oldSyntax = true;
elseif ~isequal(size(x), size(censoring))
    error('stats:gamfit:InputSizeMismatch',...
          'X and CENSORING must have the same size.');
end
if nargin < 4 || isempty(freq)
    n = numel(x);
    freq = 1; % make this a scalar, will expand when needed
elseif isequal(size(x), size(freq))
    n = sum(freq);
    zerowgts = find(freq == 0);
    if numel(zerowgts) > 0
        x(zerowgts) = [];
        if numel(censoring)==numel(freq), censoring(zerowgts) = []; end
        freq(zerowgts) = [];
    end
else
    error('stats:gamfit:InputSizeMismatch',...
          'X and FREQ must have the same size.');
end
if nargin < 5 && ~oldSyntax
    options = [];
end

ncen = sum(freq.*censoring);
nunc = n - ncen;

if min(size(x)) > 1
    error('stats:gamfit:VectorRequired','X must be a vector.');

% Illegal data return an error.  Zeros are allowed when there is no censoring.
elseif ncen == 0 && any(x < 0)
    error('stats:gamfit:BadData','X must be non-negative.');
elseif ncen > 0 && any(x <= 0)
    error('stats:gamfit:BadData',...
          'X must be positive when censoring is present.');
end

% Weed out cases which cannot really be fit, no data or all censored.  When
% all observations are censored, the likelihood surface approaches a maximum
% (zero) for any a as b->Inf.
if n == 0 || nunc == 0 || any(~isfinite(x))
    parmhat = cast([NaN, NaN],class(x));
    parmci = cast([NaN NaN; NaN NaN],class(x));
    return
end

% Scale the data to have unit mean (in the uncensored case at least) to
% allow parameter estimation even for extremely large or small data.
scalex = sum(freq.*x) ./ n;
if scalex < realmin(class(x))
    parmhat = cast([NaN, 0],class(x));
    parmci = cast([NaN 0; NaN 0],class(x));
    return
end
x = x ./ scalex;

% No censoring, estimation is somewhat simpler in this case.
if ncen == 0
    sumx = n; % x was scaled to make sumx exactly n.
    xbar = 1; % x was scaled to make sumx/n exactly 1.
    s2 = sum(freq.*(x-xbar).^2) ./ n;

    % With constant data, the likelihood surface becomes infinite as
    % a->Inf, b->0, so return that.  In this parameterization, that's as
    % good as can be done. (This test is equivalent to giving up if the
    % moment estimate of ahat is > 4.5e+013).
    if s2 <= 100.*eps(xbar.^2)
        parmhat = cast([Inf 0],class(x));
        if nunc > 1
            parmci = cast([Inf 0; Inf 0],class(x));
        else
            parmci = cast([0 0; Inf Inf],class(x));
        end
        return
    end

    % Use Method of Moments estimates as starting point for MLEs.
    s2 = s2 .* n./(n-1);
    ahat = xbar.^2 ./ s2;
    bhat = s2 / xbar;

    % Ensure that ML is possible -- if not, fall back to MM.
    if any(x == 0)
        parmhat = [ahat bhat.*scalex];
        parmci = cast([NaN NaN; NaN NaN],class(x));
        warning('stats:gamfit:ZerosInData',...
                'Zeros in data -- returning method of moments estimates.');
        return

    % Otherwise, find MLEs.
    else
        % The default options include turning fzero's display off.  This
        % function gives its own warning/error messages, and the caller can
        % turn display on to get the text output from fzero if desired.
        options = statset(statset('gamfit'), options);

        % From the likelihood equations, bhat = xbar/ahat, so the 2D
        % log-likelihood reduces to a 1D profile.  First, bracket the
        % root of the scale parameter likelihood eqn ...
        sumlogx = sum(freq.*log(x));
        const = sumlogx./n - log(sumx/n);
        if lkeqn(ahat, const) > 0
            upper = ahat; lower = .5 * upper;
            while lkeqn(lower, const) > 0
                upper = lower;
                lower = .5 * upper;
                if lower < realmin(class(x)) % underflow, no positive root
                    error('stats:gamfit:NoSolution',...
                          'Unable to reach a maximum likelihood solution.');
                end
            end
        else
            lower = ahat; upper = 2 * lower;
            while lkeqn(upper, const) < 0
                lower = upper;
                upper = 2 * lower;
                if upper > realmax(class(x)) % overflow, no finite root
                    error('stats:gamfit:NoSolution',...
                          'Unable to reach a maximum likelihood solution.');
                end
            end
        end
        bnds = [lower upper];

        % ... then find the root of the likelihood eqn.  That is the MLE for a,
        % and the MLE for b has an explicit sol'n.
        [ahat, lkeqnval, err] = fzero(@lkeqn, bnds, options, const);
        if (err < 0) % should never happen
            error('stats:gamfit:NoSolution',...
                  'Unable to reach a maximum likelihood solution.');
        elseif eps(abs(lkeqnval)) > options.TolX
            warning('stats:gamfit:IllConditioned',...
                    'The likelihood equation may be ill-conditioned.');
        end
        parmhat = [ahat xbar./ahat];
    end

% Past this point, we have censoring, and the data are guaranteed to be
% strictly positive, with a full-length censoring vector.
else % ncen > 0
    if numel(freq) ~= numel(x)
        freq = ones(size(x));
    end
    logx = log(x);
    uncens = (censoring==0);
    cens = ~uncens;
    xunc = x(uncens);
    xcen = x(cens);
    logxunc = logx(uncens);
    logxcen = logx(cens);
    frequnc = freq(uncens);
    freqcen = freq(cens);

    % With constant uncensored data, need to make sure maximum likelihood
    % estimates are possible.
    xuncbar = sum(frequnc.*xunc) ./ nunc;
    s2unc = sum(frequnc.*(xunc-xuncbar).^2) ./ nunc;
    if s2unc <= 100.*eps(xuncbar.^2)

        % When all uncensored observations are equal and greater than all
        % the censored observations, the likelihood surface becomes
        % infinite as a->Inf, b->0, so return that.
        if max(xunc) == max(x)
            parmhat = cast([Inf 0],class(x));
            if nunc > 1
                parmci = cast([Inf 0; Inf 0],class(x));
            else
                parmci = cast([0 0; Inf Inf],class(x));
            end
            return
        end

        % Otherwise, there are censored observations greater than the
        % uncensored ones, and ML estimation is possible.  Since there's
        % effectively only one uncensored value, pick some default starting
        % values for the parameter estimates.
        parmhat = [2 xuncbar./2];

    else
        % Get a rough estimate for weibull parameters using the "least
        % squares" method, equate moments to a gamma distn to get starting
        % values for ML estimation.
        [p,q] = ecdf(logx, 'censoring',censoring, 'frequency',freq);
        pmid = (p(1:(end-1))+p(2:end)) / 2;
        linefit = polyfit(log(-log((1-pmid))), q(2:end), 1);
        wblparms = [exp(linefit(2)) 1./linefit(1)];
        [m,v] = wblstat(wblparms(1),wblparms(2));
        parmhat = [m.*m./v v./m];
    end

    sumxunc = sum(xunc.*frequnc);
    sumlogxunc = sum(logxunc.*frequnc);

    % The default options include turning statsfminbx's display off.  This
    % function gives its own warning/error messages, and the caller can
    % turn display on to get the text output from statsfminbx if desired.
    options = statset(statset('gamfit'), options);
    % For data with censoring, TolBnd is applied to both the shape
    % parameter a and the scale parameter b.
    tolBnd = options.TolBnd;
    options = optimset(options);
    dflts = struct('DerivativeCheck','off', 'HessMult',[], ...
        'HessPattern',ones(2,2), 'PrecondBandWidth',Inf, ...
        'TypicalX',ones(2,1), 'MaxPCGIter',1, 'TolPCG',0.1);

    if any(parmhat < tolBnd)
        parmhat = [2 xuncbar./2];
    end

    % Maximize the log-likelihood with respect to a and b.
    funfcn = {'fungrad' 'gamfit' @negloglike [] []};
    [parmhat, nll, lagrange, err, output] = ...
        statsfminbx(funfcn, parmhat, [tolBnd; tolBnd], [Inf; Inf], options, ...
                    dflts, 1, sumxunc, sumlogxunc, nunc, xcen, logxcen, freqcen);
    if (err == 0)
        % statsfminbx may print its own output text; in any case give something
        % more statistical here, controllable via warning IDs.
        if output.funcCount >= options.MaxFunEvals
            wmsg = 'Maximum likelihood estimation did not converge.  Function evaluation limit exceeded.';
        else
            wmsg = 'Maximum likelihood estimation did not converge.  Iteration limit exceeded.';
        end
        warning('stats:gamfit:IterOrEvalLimit',wmsg);
    elseif (err < 0)
        error('stats:gamfit:NoSolution',...
              'Unable to reach a maximum likelihood solution.');
    end
end

if nargout == 2
    % Have to put the default scalar censoring and frequency vectors back
    % to empties for gamlike.
    if numel(freq) ~= numel(x), freq = []; end
    if numel(censoring) ~= numel(x), censoring = []; end

    % Compute CIs on the log scale for both params
    [logL, acov] = gamlike(parmhat, x, censoring, freq);
    selog = sqrt(diag(acov))' ./ parmhat;
    logparmhat = log(parmhat);
    p_int = [alpha/2; 1-alpha/2];
    parmci = exp(norminv([p_int p_int], [logparmhat; logparmhat], [selog; selog]));
end

% Remove the scaling.
parmhat(2) = parmhat(2) .* scalex;
if nargout == 2
    parmci(:,2) = parmci(:,2) .* scalex;
end


function v = lkeqn(a, const)
% Objective function for gamma maximum likelihood estimation with no
% censoring.  Returns the derivative of the negative profile log-likelihood
% evaluated at a.  From the likelihood equations, bhat = xbar/ahat, and so
% the 2-D maximization of L over [a b] reduces to a 1-D root search over a.
v = -const - log(a) + psi(a);


function [nll,ngrad] = ...
    negloglike(parms, sumxunc, sumlogxunc, nunc, xcen, logxcen, freqcen)
% Objective function for right-censored gamma maximum likelihood
% estimation.  Returns the negative log-likelihood evaluated at parms.
a = parms(1); loggama = gammaln(a);
b = parms(2); logb = log(b);
zcen = xcen ./ b;
[dScen,Scen] = dgammainc(zcen,a,'upper');
sumlogScen = sum(freqcen.*log(Scen));
sumdlogScen_da = sum(freqcen.*dScen ./ Scen);
sumdlogScen_db = sum(freqcen.*exp(a.*logxcen - (a+1).*logb - zcen - loggama) ./ Scen);
nll = (1-a).*sumlogxunc + nunc.*a.*logb + sumxunc./b + nunc.*loggama - sumlogScen;
ngrad = [-sumlogxunc + nunc.*(logb + psi(a)) - sumdlogScen_da, ...
                                    (nunc.*a - sumxunc./b)./b - sumdlogScen_db];

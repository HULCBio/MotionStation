function [phat, pci] = mle(data,varargin)
%MLE Maximum likelihood estimation.
%   PHAT = MLE(DATA) returns maximum likelihood estimates (MLEs) for the
%   parameters of a normal distribution, computed using the sample data in
%   the vector DATA.
%
%   [PHAT, PCI] = MLE(DATA) returns MLEs and 95% confidence intervals for
%   the parameters.
%
%   [...] = MLE(DATA,'distribution',DIST) computes parameter estimates for
%   the distribution specified by DIST.  DIST is a character string
%   containing the name of one of the distributions supported by MLE.
%
%   [...] = MLE(DATA, ..., 'NAME1',VALUE1,'NAME2',VALUE2,...) specifies
%   optional argument name/value pairs chosen from the following list.
%   Argument names are case insensitive and partial matches are allowed.
%
%        Name           Value
%      'censoring'    A boolean vector of the same size as DATA,
%                     containing ones when the corresponding elements of
%                     DATA are right-censored observations and zeros when
%                     the corresponding elements are exact observations.
%                     Default is all observations observed exactly.
%                     Censoring is not supported for all distributions.
%      'frequency'    A vector of the same size as DATA, containing
%                     non-negative integer frequencies for the corresponding
%                     elements in DATA.  Default is one observation per
%                     element of DATA.
%      'alpha'        A value between 0 and 1 specifying a confidence level
%                     of 100*(1-alpha)% for PCI.  Default is alpha=0.05 for
%                     95% confidence.
%      'ntrials'      A scalar, or a vector of the same size as DATA,
%                     containing the total number of trials for the
%                     corresponding element of DATA.  Applies only to the
%                     binomial distribution.
%      'options'      A structure created by a call to STATSET, containing
%                     numerical options for the fitting algorithm.  Not
%                     applicable to all distributions.
%
%   MLE can also fit a custom distribution that you define using
%   distribution functions, in one of three ways:
%
%   [...] = MLE(DATA,'pdf',PDF,'cdf',CDF,'start',START,...) returns MLEs
%   for the parameters of the distribution defined by the probability
%   density and cumulative distribution functions PDF and CDF.  PDF and CDF
%   are function handles created using @.  They accept as inputs a vector
%   of data and one or more individual distribution parameters, and return
%   vectors of probability density values and cumulative probability
%   values, respectively.  If the 'censoring' name/value pair is not
%   present, you may omit the 'cdf' name/value pair.  MLE computes the
%   estimates by numerically maximizing the distribution's log-likelihood,
%   and START is a vector containing initial values for the parameters.
%
%   [...] = MLE(DATA,'logpdf',LOGPDF,'logsf',LOGSF,'start',START,...)
%   returns MLEs for the parameters of the distribution defined by the log
%   probability density and log survival functions LOGPDF and LOGSF. LOGPDF
%   and LOGSF are function handles created using @.  They accept as inputs
%   a vector of data and one or more individual distribution parameters,
%   and return vectors of logged probability density values and logged
%   survival function values, respectively.  This form is sometimes more
%   robust to the choice of starting point than using PDF and CDF
%   functions.  If the 'censoring' name/value pair is not present, you may
%   omit the 'logsf' name/value pair.  START is a vector containing initial
%   values for the distribution's parameters.
%
%   [...] = MLE(DATA,'nloglf',NLOGLF,'start',START,...) returns MLEs for
%   the parameters of the distribution whose negative log-likelihood is
%   given by NLOGLF.  NLOGLF is a function handle specified using @, that
%   accepts the four input arguments
%      PARAMS - a vector of distribution parameter values
%      DATA   - a vector of data
%      CENS   - a boolean vector of censoring values
%      FREQ   - a vector of integer data frequencies
%   NLOGLF must accept all four arguments even if you do not supply the
%   'censoring' or 'frequency' name/value pairs (see above).  However,
%   NLOGLF can safely ignore its CENS and FREQ arguments in that case.
%   NLOGLF returns a scalar negative log-likelihood value and, optionally,
%   a negative log-likelihood gradient vector (see the 'GradObj' STATSET
%   parameter below).  START is a vector containing initial values
%   for the distribution's parameters.
%
%   PDF, CDF, LOGPDF, LOGSF, or NLOGLF can also be cell arrays whose first
%   element is a function handle as defined above, and whose remaining
%   elements are additional arguments to the function.  MLE places these
%   arguments at the end of the argument list in the function call.
%
%   The following optional argument name/value pairs are valid only when
%   'pdf' and 'cdf', 'logpdf' and 'logcdf', or 'nloglf' are given.
%
%      'lowerbound'   A vector the same size as START containing lower bounds
%                     for the distribution parameters.  Default is -Inf.
%      'upperbound'   A vector the same size as START containing upper bounds
%                     for the distribution parameters.  Default is Inf.
%      'optimfun'     A string, either 'fminsearch' or 'fmincon', naming the
%                     optimization function to be used in maximizing the
%                     likelihood.  Default is 'fminsearch'.  You may only
%                     specify 'fmincon' if the Optimization Toolbox is
%                     available.
%
%   When fitting a custom distribution, use the 'options' parameter to
%   control details of the maximum likelihood optimization.  See
%   STATSET('mlecustom') for parameter names and default values.  MLE
%   interprets the following STATSET parameters for custom distribution
%   fitting as follows:
%
%      'GradObj'      'on' or 'off', indicating whether or not FMINCON
%                     can expect the function provided with the 'nloglf'
%                     name/value pair to return the gradient vector of the
%                     negative log-likelihood as a second output.  Default
%                     is 'off'.  Ignored when using FMINSEARCH.
%      'DerivStep'    The relative difference used in finite difference
%                     derivative approximations when using FMINCON, and
%                     'GradObj' is 'off'.  May be a scalar, or the same
%                     size as START.  EPS^(1/3) by default.  Ignored when
%                     using FMINSEARCH.
%      'FunValCheck'  'on' or 'off', indicating whether or not MLE should
%                     check the values returned by the custom distribution
%                     functions for validity.  Default is 'on'.  A poor
%                     choice of starting point can sometimes cause these
%                     functions to return NaNs, infinite values, or out of
%                     range values if they are written without suitable
%                     error-checking.
%       'TolBnd'      An offset for upper and lower bounds when using
%                     FMINCON.  MLE treats upper and lower bounds as
%                     strict inequalities (i.e., open bounds).  With
%                     FMINCON, this is approximated by creating closed
%                     bounds inset from the specified upper and lower
%                     bounds by TolBnd.  Default is 1e-6.
%
%   See also BETAFIT, BINOFIT, EXPFIT, EVFIT, GAMFIT, NORMFIT, NBINFIT,
%   POISSFIT, RAYLFIT, UNIFIT, WBLFIT, HESSIAN, STATSET.

%   [...] = MLE(..., 'optimOptions', OPTS) specifies additional control
%   parameters for FMINSERCH or FMINCON.  OPTS is a structure created by
%   OPTIMSET.  This is applicable only when fitting custom distributions.
%   Choices of OPTIMSET parameters depend on the optimization function.
%   See OPTIMSET('fminsearch') or OPTIMSET('fmincon').

%   When you supply distribution functions, MLE computes the parameter
%   estimates using an iterative maximization algorithm.  With some models
%   and data, a poor choice of starting point can cause MLE to converge to
%   a local optimum that is not the global maximizer, or to fail to
%   converge entirely. Even in cases for which the log-likelihood is
%   well-behaved near the global maximum, the choice of starting point is
%   often crucial to convergence of the algorithm.  In particular, if the
%   initial parameter values are far from the MLEs, underflow in the
%   distribution functions can lead to infinite log-likelihoods.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 2.14.6.6 $  $Date: 2004/03/02 21:49:14 $

% Check for the grandfathered syntax mle('distname',data,alpha,ntrials)
if ischar(data)
    if nargin < 2
        error('stats:mle:TooFewInputs',...
              'Requires at least two input arguments.');
    elseif nargin <= 4
        dist = data;
        data = varargin{1};
        if nargin < 3
            alpha = [];
        else
            alpha = varargin{2};
        end
        if nargin < 4
            ntrials = [];
        else
            ntrials = varargin{3};
        end
        cens = [];
        freq = [];
        options = [];
    else
        error('stats:mle:InvalidSyntax',...
              'Too many input arguments for this argument syntax.');
    end

else
    pnames = {'distribution' 'censoring' 'frequency' 'alpha' 'ntrials' 'options'...
              'pdf' 'logpdf' 'nloglf'};
    dflts =  {[] [] [] [] [] [] [] [] [] [] []};
    [eid,errmsg,dist,cens,freq,alpha,ntrials,options, ...
          pdf,logpdf,nloglf,otherArgs] = statgetargs(pnames, dflts, varargin{:});
    if ~isempty(eid)
       error(sprintf('stats:mle:%s',eid),errmsg);
    end
end

if ~isvector(data)
    error('stats:mle:InvalidData', 'DATA must be a vector.');
end

% Check sizes of censoring and frequency vectors, and remove any zero
% frequencies.
if ~isempty(cens) && ~isequal(size(data), size(cens))
    error('stats:mle:InputSizeMismatch',...
          'The ''censoring'' vector must be the same size as DATA.');
elseif ~isempty(freq)
    if ~isequal(size(data), size(freq))
        error('stats:mle:InputSizeMismatch',...
              'The ''frequency'' vector must be the same size as DATA.');
    else
        zerowgts = find(freq == 0);
        if numel(zerowgts) > 0
            data(zerowgts) = [];
            if ~isempty(cens), cens(zerowgts) = []; end
            freq(zerowgts) = [];
        end
    end
end

if isempty(dist)
    % If a built-in distribution was not given, and a user-defined
    % distribution was given, then handle that.
    if ~(isempty(pdf) && isempty(logpdf) && isempty(nloglf))
        if nargout < 2
            phat = mlecustom(data,varargin{:});
        else
            [phat, pci] = mlecustom(data,varargin{:});
        end
        return

    % Otherwise default to a normal distribution.
    else
        dist = 'normal';
    end
    
elseif ischar(dist)
    distNames = {'beta', 'bernoulli', 'binomial', 'exponential', 'extreme value', ...
                 'gamma', 'geometric', 'lognormal', 'normal', 'negative binomial', ...
                 'poisson', 'rayleigh', 'discrete uniform', 'uniform', 'weibull'};

    i = strmatch(lower(dist), distNames);
    if numel(i) > 1
        error('stats:mle:AmbiguousDistName', 'Ambiguous distribution name: ''%s''.',dist);
        return
    elseif numel(i) == 1
        dist = distNames{i};
    else % it may be an abbreviation that doesn't partially match the name
        dist = lower(dist);
    end
else
    error('stats:mle:InvalidDistName', 'The value of the ''distribution'' argument must be must be a distribution name.');
end

if isempty(alpha), alpha = 0.05; end

if ~isempty(ntrials) && isempty(strmatch(lower(dist), 'binomial'))
    warning('stats:mle:NtrialsNotNeeded', 'The number of trials is only valid for the binomial distribution.');
end

switch dist
case 'beta'
    if ~isempty(cens)
        error('stats:mle:CensoringNotSupported', 'Censoring is not supported for the beta distribution.');
    end
    if ~isempty(freq), data = expandInput(data,freq); end
    n = numel(data);
    tmp1 = prod((1-data) .^ (1./n));
    tmp2 = prod(data .^ (1./n));
    tmp3 = (1 - tmp1 - tmp2);
    a = 0.5.*(1-tmp1) ./ tmp3;
    b = 0.5.*(1-tmp2) ./ tmp3;
    phat = fminsearch('betalike',[a b],options,data);
    if nargout > 1
        [logL,acov] = betalike(phat,data);
        se = sqrt(diag(acov))';
        p_int = [alpha/2; 1-alpha/2];
        pci = norminv([p_int, p_int], [phat; phat], [se; se]);
    end

case 'bernoulli'
    if ~isempty(cens)
        error('stats:mle:CensoringNotSupported', 'Censoring is not supported for the bernoulli distribution.');
    elseif any(data ~= 0 & data ~= 1)
        error('stats:mle:InvalidBernoulliData', 'Bernoulli data must either be 1 or 0.');
    end
    if ~isempty(freq), data = expandInput(data,freq); end
    if nargout < 2
        phat = binofit(sum(data),numel(data));
    else
        [phat,pci] = binofit(sum(data),numel(data),alpha);
        pci = pci';
    end

case 'binomial'
    if isempty(ntrials)
        error('stats:mle:NtrialsNeeded', 'You must provide the number of trials for a binomial fit.');
    elseif ~isempty(cens)
        error('stats:mle:CensoringNotSupported', 'Censoring is not supported for the binomial distribution.');
    end
    if ~isempty(freq)
        data = expandInput(data,freq);
        if numel(ntrials) ~= 1
            ntrials = expandInput(ntrials,freq);
        end
    end
    n = numel(data);
    data = sum(data);
    if numel(ntrials) == 1
        ntrials = n .* ntrials;
    else
        ntrials = sum(ntrials);
    end
    if nargout < 2
        phat = binofit(data,ntrials);
    else
        [phat,pci] = binofit(data,ntrials,alpha);
        pci = pci';
    end

case 'exponential'
    if nargout < 2
        phat = expfit(data,[],cens,freq);
    else
        [phat,pci] = expfit(data,alpha,cens,freq);
    end

case {'extreme value', 'ev'}
    if nargout < 2
        phat = evfit(data,[],cens,freq,options);
    else
        [phat,pci] = evfit(data,alpha,cens,freq,options);
    end

case 'gamma'
    if nargout < 2
        phat = gamfit(data,[],cens,freq,options);
    else
        [phat,pci] = gamfit(data,alpha,cens,freq,options);
    end

case 'geometric'
    if ~isempty(cens)
        error('stats:mle:CensoringNotSupported', 'Censoring is not supported for the geometric distribution.');
    end
    if ~isempty(freq), data = expandInput(data,freq); end
    phat = 1 ./ (1 + mean(data));
    if nargout > 1
        n = numel(data);
        se = phat .* sqrt((1-phat) ./ n);
        pci = norminv([alpha/2; 1-alpha/2], [phat; phat], [se; se]);
    end

case 'lognormal'
    if nargout < 2
        phat = lognfit(data,[],cens,freq,options);
    else
        [phat,pci] = lognfit(data,alpha,cens,freq,options);
    end
    % If there was no censoring, LOGNFIT estimated the UMVUE for sigsq.
    if isempty(cens)
        if ~isempty(freq), n = sum(freq); else n = numel(data); end
        phat = [phat(1) phat(2).*sqrt((n-1)./n)]; % turn sigma into MLE
    end

case 'normal'
    if nargout < 2
        [muhat,sigmahat] = normfit(data,[],cens,freq,options);
    else
        [muhat,sigmahat,muci,sigmaci] = normfit(data,alpha,cens,freq,options);
        pci = [muci sigmaci];
    end
    % If there was no censoring, NORMFIT estimated the UMVUE for sigsq.
    if isempty(cens)
        if ~isempty(freq), n = sum(freq); else n = numel(data); end
        sigmahat = sigmahat.*sqrt((n-1)./n); % turn sigma into MLE
    end
    phat = [muhat sigmahat];

case {'negative binomial', 'nbin'}
    if ~isempty(cens)
        error('stats:mle:CensoringNotSupported', 'Censoring is not supported for the negative binomial distribution.');
    end
    if ~isempty(freq), data = expandInput(data,freq); end
    if nargout < 2
        phat = nbinfit(data,[],options);
    else
        [phat,pci] = nbinfit(data,alpha,options);
    end

case 'poisson'
    if ~isempty(cens)
        error('stats:mle:CensoringNotSupported', 'Censoring is not supported for the Poisson distribution.');
    end
    if ~isempty(freq), data = expandInput(data,freq); end
    if nargout < 2
        phat = poissfit(data);
    else
        [phat,pci] = poissfit(data,alpha);
    end

case 'rayleigh'
    if ~isempty(cens)
        error('stats:mle:CensoringNotSupported', 'Censoring is not supported for the rayleigh distribution.');
    end
    if ~isempty(freq), data = expandInput(data,freq); end
    if nargout < 2
        phat = raylfit(data);
    else
        [phat,pci] = raylfit(data,alpha);
    end

case {'discrete uniform', 'unid'}
    if ~isempty(cens)
        error('stats:mle:CensoringNotSupported', 'Censoring is not supported for the discrete uniform distribution.');
    end
    if ~isempty(freq), data = expandInput(data,freq); end
    phat = max(data);
    if nargout > 1
        n = numel(data);
        pci = [phat; ceil(phat./alpha.^(1./n))];
    end

case 'uniform'
    if ~isempty(cens)
        error('stats:mle:CensoringNotSupported', 'Censoring is not supported for the uniform distribution.');
    end
    if ~isempty(freq), data = expandInput(data,freq); end
    if nargout < 2
        [ahat,bhat] = unifit(data);
    else
        [ahat,bhat,aci,bci] = unifit(data,alpha);
        pci = [aci bci];
    end
    phat = [ahat bhat];

case {'weibull', 'wbl'}
    if ~strcmp(dist,'wbl')
        warning('stats:mle:ChangedParameters', ...
                'The Statistics Toolbox uses a new parametrization for the\nWEIBULL distribution beginning with release 4.1.');
    end
    if nargout < 2
        phat = wblfit(data,[],cens,freq,options);
    else
        [phat,pci] = wblfit(data,alpha,cens,freq,options);
    end

otherwise
    spec = dfgetdistributions(dist);
    if isempty(spec)
       error('stats:mle:InvalidDistName',...
             'Unrecognized distribution name: ''%s''.',dist);
       return
    elseif length(spec)>1
       error('stats:mle:AmbiguousDistName',...
             'Ambiguous distribution name: ''%s''.',name);
       return
    end
    if nargout<2
       phat = feval(spec.fitfunc,data,[],cens,freq,options);
    else
       [phat,pci] = feval(spec.fitfunc,data,alpha,cens,freq,options);
    end
end


function expanded = expandInput(input,freq)
%EXPANDDATA Expand out an input vector using element frequencies.
if ~isequal(size(input),size(freq))
    error('stats:mle:InputSizeMismatch', 'Input argument sizes must match.');
end
i = cumsum(freq);
j = zeros(1, i(end));
j(i(1:end-1)+1) = 1;
j(1) = 1;
expanded = input(cumsum(j));

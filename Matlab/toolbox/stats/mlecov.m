function acov = mlecov(params, data, varargin)
%MLECOV Asymptotic covariance matrix of maximum likelihood estimators.
%   ACOV = MLECOV(PARAMS, DATA, ...) returns an approximation to the
%   asymptotic covariance matrix of the maximum likelihood estimators of
%   the parameters for a specified distribution.  MLECOV computes a finite
%   difference approximation to the hessian of the log-likelihood at the
%   maximum likelihood estimates PARAMS, given the observed data DATA, and
%   returns the negative inverse of that hessian.  ACOV is a P-by-P matrix,
%   where P is the number of elements in PARAMS.
%
%   You can specify a distribution in one of three ways.
%
%   ACOV = MLECOV(PARAMS, DATA, 'pdf',PDF, 'cdf',CDF) allows you to define
%   a distribution by its probability density and cumulative distribution
%   functions.  PDF and CDF are function handles created using @.  They
%   accept as inputs a vector of data and one or more individual
%   distribution parameters, and return vectors of probability density
%   function values and cumulative distribution values, respectively.  If
%   the 'censoring' name/value pair (see below) is not present, you may
%   omit the 'cdf' name/value pair.
%
%   ACOV = MLECOV(PARAMS, DATA, 'logpdf',LOGPDF, 'logsf',LOGSF) allows you
%   to define a distribution by its log probability density and log
%   survival functions.  LOGPDF and LOGSF are function handles created
%   using @. They accept as inputs a vector of data and one or more
%   individual distribution parameters, and return vectors of logged
%   probability density values and logged survival function values,
%   respectively.  If the 'censoring' name/value pair (see below) is not
%   present, you may omit the 'logsf' name/value pair.
%
%   ACOV = MLECOV(PARAMS, DATA, 'nloglf',NLOGLF) allows you to define a
%   distribution by its log-likelihood function.  NLOGLF is a function
%   handle, specified using @, that accepts the four input arguments
%      PARAMS - a vector of distribution parameter values
%      DATA   - a vector of data
%      CENS   - a boolean vector of censoring values
%      FREQ   - a vector of integer data frequencies
%   NLOGLF must accept all four arguments even if you do not supply the
%   'censoring' or 'frequency' name/value pairs (see below).  However,
%   NLOGLF can safely ignore its CENS and FREQ arguments in that case.
%   NLOGLF returns a scalar negative log-likelihood value, and optionally,
%   the negative log-likelihood gradient vector (see the 'options'
%   name/value pair below).
%
%   PDF, CDF, LOGPDF, LOGSF, or NLOGLF can also be cell arrays whose first
%   element is a function handle as defined above, and whose remaining
%   elements are additional arguments to the function.  MLE places these
%   arguments at the end of the argument list in the function call.
%
%   [...] = MLECOV(PARAMS, DATA, ..., 'PARM1',VAL1, 'PARM2',VAL2, ...)
%   specifies optional argument name/value pairs chosen from the following:
%
%      Name              Value
%      'censoring'    A boolean vector of the same size as DATA,
%                     containing ones when the corresponding elements of
%                     DATA are right-censored observations and zeros when
%                     the corresponding elements are exact observations.
%                     Default is all observations observed exactly.
%      'frequency'    A vector of the same size as DATA, containing
%                     non-negative frequencies for the corresponding
%                     elements in DATA.  Default is one observation per
%                     element of DATA.
%      'options'      A structure created by a call to STATSET, containing
%                     numerical options for the finite difference hessian
%                     calculation.  Applicable STATSET parameters are:
%
%           'GradObj'   - 'on' or 'off', indicating whether or not the
%                         function provided with the 'nloglf' name/value
%                         pair can return the gradient vector of the neg
%                         log-likelihood as its 2nd output.  Default is 'off'.
%           'DerivStep' - Relative step size used in finite differencing
%                         for Hessian calculations.  May be a scalar, or
%                         the same size as PARAMS.  Defaults to EPS^(1/4).
%                         A smaller value may be appropriate if 'GradObj'
%                         is 'on'.
%
%   Example:
%
%       % Fit a beta distribution to some simulated data, and compute the
%       % approximate covariance matrix of the parameter estimates.
%       x = betarnd(1.23, 3.45, 25, 1);
%       phat = mle(x, 'dist','beta')
%       acov = mlecov(phat, x, 'logpdf',@betalogpdf)
%
%       function logpdf = betalogpdf(x,a,b)
%       logpdf = (a-1)*log(x) + (b-1)*log(1-x) - betaln(a,b);
%
%   See also MLE, STATSET.

%   The hessian is the matrix of second partial derivatives of the
%   log-likelihood, taken with respect to the distribution parameters.
%   MLECOV uses central differencing to approximate those second partial
%   derivatives.  When you do not provide a gradient (i.e., using either
%   'pdf' and 'cdf', or 'logpdf' and 'logsf', or 'nloglf' but returning
%   only the log-likelihood), MLECOV uses second order differences on the
%   log-likelihood function.  When you do provide a gradient using
%   'nloglf', MLECOV uses first order differences on the log-likelihood's
%   gradient.

%   References:
%     [1] Cox, D.R., and Hinkley, D.V. (1974) Theoretical Statistics,
%         Chapman and Hall.
%     [2] Lawless, J.F. (1982) Statistical Models and Methods for Lifetime
%         Data, Wiley.  Appendix C.
%     [3] Dennis, J.E., and Schnabel, R.B. (1983) Numerical methods for
%         unconstrained optimization and nonlinear equations,
%         Prentice-Hall.  Section 5.6.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2004/04/04 03:42:15 $

if nargin < 4
    error('stats:mlecov:TooFewInputs','Requires at least four input arguments.');
end

pnames = {'pdf', 'cdf' 'logpdf' 'logsf' 'nloglf' 'censoring' 'frequency' 'options'};
defaults =  {[] [] [] [] [] zeros(size(data)) ones(size(data)) []};
[eid,errmsg,pdf,cdf,logpdf,logsf,nloglf,cens,freq,options] = ...
                                 statgetargs(pnames, defaults, varargin{:});
if ~isempty(eid)
   error(sprintf('stats:mlecov:%s',eid),errmsg);
end

options = statset(statset('mlecov'), options);
haveGrad = strcmp(options.GradObj, 'on');
delta = options.DerivStep;

% Determine how the distribution is specified, and get handles to the
% specified functions.
if ~isempty(nloglf)
    if isa(nloglf,'function_handle')
        addArgs = {};
    elseif iscell(nloglf) && isa(nloglf{1},'function_handle')
        addArgs = nloglf(2:end);
        nloglf = nloglf{1};
    else
        error('stats:mlecov:InvalidNloglf',...
        'The ''nloglf'' parameter value must be a function handle or a cell array\ncontaining a function handle.');
    end
    loglikefun = nloglf;

    % nloglf is called directly, without a wrapper.  Catch errors once, here.
    try
        if haveGrad
            [nll,ngrad] = feval(loglikefun, params, data, cens, freq, addArgs{:});
        else
            nll = feval(loglikefun, params, data, cens, freq, addArgs{:});
        end
    catch
        error('stats:mlecov:NloglfError', ...
              ['The following error occurred while trying to evaluate\nthe ', ...
               'user-supplied nloglf function ''%s'':\n\n%s'], func2str(nloglf),lasterr);
    end

elseif ~isempty(logpdf)
    if isa(logpdf,'function_handle')
        logpdfArgs = {};
    elseif iscell(logpdf) && isa(logpdf{1},'function_handle')
        logpdfArgs = logpdf(2:end);
        logpdf = logpdf{1};
    else
        error('stats:mlecov:InvalidLogpdf','The ''logpdf'' parameter value must be a function handle or a cell array\ncontaining a function handle.');
    end
    if ~isempty(logsf)
        if isa(logsf,'function_handle')
            logsfArgs = {};
        elseif iscell(logsf) && isa(logsf{1},'function_handle')
            logsfArgs = logsf(2:end);
            logsf = logsf{1};
        else
            error('stats:mlecov:InvalidLogsf','The ''logsf'' parameter value must be a function handle or a cell array\ncontaining a function handle.');
        end
    elseif isempty(logsf) && sum(cens) == 0
        logsfArgs = {};
    else
        error('stats:mlecov:LogsfRequired','You must provide a log SF along with the log PDF if the data include censoring.');
    end
    addArgs = { {logpdf logpdfArgs{:}} {logsf logsfArgs{:}} };
    loglikefun = @llf_logpdflogsf;
    haveGrad = false;
    nll = feval(loglikefun, params, data, cens, freq, addArgs{:});

elseif ~isempty(pdf)
    if isa(pdf,'function_handle')
        pdfArgs = {};
    elseif iscell(pdf) && isa(pdf{1},'function_handle')
        pdfArgs = pdf(2:end);
        pdf = pdf{1};
    else
        error('stats:mlecov:InvalidPdf','The ''pdf'' parameter value must be a function handle or a cell array\ncontaining a function handle.');
    end
    if ~isempty(cdf)
        if isa(cdf,'function_handle')
            cdfArgs = {};
        elseif iscell(cdf) && isa(cdf{1},'function_handle')
            cdfArgs = cdf(2:end);
            cdf = cdf{1};
        else
            error('stats:mlecov:InvalidCdf','The ''cdf'' parameter value must be a function handle or a cell array\ncontaining a function handle.');
        end
    elseif isempty(cdf) && sum(cens) == 0
        cdfArgs = {};
    else
        error('stats:mlecov:CdfRequired',...
              'You must provide a CDF with the PDF if the data include censoring.');
    end
    addArgs = { {pdf pdfArgs{:}} {cdf cdfArgs{:}} };
    loglikefun = @llf_pdfcdf;
    haveGrad = false;
    nll = feval(loglikefun, params, data, cens, freq, addArgs{:});

else
    error('stats:mlecov:DistFunsRequired','You must provide function handles as values for either the ''pdf'' and ''cdf'' parameters, or the ''logpdf''\nand ''logsf'' parameters, or the ''nloglf'' parameter.');
end

if isscalar(delta) || isequal(size(delta),size(params))
    deltaparams = delta .* max(abs(params), 1);
else
    error('stats:mlecov:InputSizeMismatch','The value of the STATSET ''GradDiff'' parameter must be a scalar, or the same size as PARAMS.');
end
nparams = numel(params);

if haveGrad
    % Compute first order central differences of the log-likelihood
    % gradient.  H is always a square matrix, regardless of the shape of
    % params or the gradient.  nH is the negative hessian, because
    % loglikefun returns a negative log-likelihood.
    e = zeros(size(params));
    nH = zeros(nparams,nparams);
    for j=1:nparams
        e(j) = deltaparams(j);
        [dum,Gplus]  = feval(loglikefun, params+e, data, cens, freq, addArgs{:});
        [dum,Gminus] = feval(loglikefun, params-e, data, cens, freq, addArgs{:});

        % Normalize the first differences by the increment to get
        % derivative estimates.
        nH(:,j) = (Gplus(:) - Gminus(:)) ./ (2 * deltaparams(j));
        e(j) = 0;
    end

    % All of H has been filled in, ensure that it is symmetric.
    nH = .5.*(nH + nH');

else
    % Compute pure and mixed second order central differences of the
    % log-likelihood function.  H is always a square matrix, regardless of
    % the shape of params.  nH is the negative hessian, because loglikefun
    % returns a negative log-likelihood.
    ej = zeros(size(params));
    ek = zeros(size(params));
    nH = zeros(nparams,nparams);
    for j = 1:nparams
        ej(j) = deltaparams(j);
        for k = 1:(j-1)
            ek(k) = deltaparams(k);
            % Four-point central difference for mixed second partials.
            nH(j,k) = feval(loglikefun, params+ej+ek, data, cens, freq, addArgs{:}) ...
                    - feval(loglikefun, params+ej-ek, data, cens, freq, addArgs{:}) ...
                    - feval(loglikefun, params-ej+ek, data, cens, freq, addArgs{:}) ...
                    + feval(loglikefun, params-ej-ek, data, cens, freq, addArgs{:});
            ek(k) = 0;
        end
        % Five-point central difference for pure second partial.
        nH(j,j) = -  feval(loglikefun, params+2*ej, data, cens, freq, addArgs{:}) ...
                + 16*feval(loglikefun, params+ej,   data, cens, freq, addArgs{:}) ...
                - 30*nll ...
                + 16*feval(loglikefun, params-ej,   data, cens, freq, addArgs{:}) ...
                -    feval(loglikefun, params-2*ej, data, cens, freq, addArgs{:});
        ej(j) = 0;
    end

    % Fill in the upper triangle.
    nH = nH + triu(nH',1);

    % Normalize the second differences by the product of the increments
    % to get derivative estimates.
    nH = nH ./ (4.*deltaparams(:)*deltaparams(:)' + diag(8*deltaparams(:).^2));
end

% The asymptotic cov matrix approximation is the negative inverse of the hessian.
acov = nH \ eye(nparams);


%==========================================================================

function nll = llf_logpdflogsf(params, data, cens, freq, logpdfAddArgs, logsfAddArgs)
% Given function handles to a logPDF and a logSF, evaluate the negative
% log-likelihood for PARAMS given DATA.

logpdf = logpdfAddArgs{1}; logpdfAddArgs = logpdfAddArgs(2:end);
logsf = logsfAddArgs{1}; logsfAddArgs = logsfAddArgs(2:end);

isUncensored = (cens == 0);

% Log-likelihood = logPDF(uncensored values) + logSF(censored values)
%
% First, evaluate the specified logPDF of the uncensored data.
paramsCell = num2cell(params);
try
    logpdfVals = feval(logpdf, data(isUncensored), paramsCell{:}, logpdfAddArgs{:});
catch
    error('stats:mlecov:LogpdfError', ...
          ['The following error occurred while trying to evaluate\nthe ', ...
           'user-supplied logpdf function ''%s'':\n\n%s'], func2str(logpdf),lasterr);
end

% Compute negative log-likelihood from uncensored values, using
% frequencies.
nll = -sum(freq(isUncensored).*logpdfVals);

% If there is censoring, evaluate the specified logSF of the censored data.
if ~isempty(logsf)
    try
        logsfVals = feval(logsf, data(~isUncensored), paramsCell{:}, logsfAddArgs{:});
    catch
        error('stats:mlecov:LogsfError', ...
              ['The following error occurred while trying to evaluate\nthe ', ...
               'user-supplied logsf function ''%s'':\n\n%s'], func2str(logsf),lasterr);
    end

    % Update negative log-likelihood with censored values, using
    % frequencies.
    nll = nll - sum(freq(~isUncensored).*logsfVals);
end


%==========================================================================

function nll = llf_pdfcdf(params, data, cens, freq, pdfAddArgs, cdfAddArgs)
% Given function handles to a PDF and a CDF, evaluate the negative
% log-likelihood for PARAMS given DATA.

pdf = pdfAddArgs{1}; pdfAddArgs = pdfAddArgs(2:end);
cdf = cdfAddArgs{1}; cdfAddArgs = cdfAddArgs(2:end);

isUncensored = (cens == 0);

% Log-likelihood = log(PDF(uncensored values)) + log(1-CDF(censored values))
%
% First, evaluate the specified PDF of the uncensored data.
paramsCell = num2cell(params);
try
    pdfVals = feval(pdf, data(isUncensored), paramsCell{:}, pdfAddArgs{:});
catch
    error('stats:mlecov:PdfError', ...
          ['The following error occurred while trying to evaluate\nthe ', ...
           'user-supplied pdf function ''%s'':\n\n%s'], func2str(pdf),lasterr);
end

% Compute negative log-likelihood from uncensored values, using
% frequencies.
nll = -sum(freq(isUncensored).*log(pdfVals));

% If there is censoring, evaluate the specified CDF of the censored data.
if ~isempty(cdf)
    try
        cdfVals = feval(cdf, data(~isUncensored), paramsCell{:}, cdfAddArgs{:});
    catch
        error('stats:mlecov:CdfError', ...
              ['The following error occurred while trying to evaluate\nthe ', ...
               'user-supplied cdf function ''%s'':\n\n%s'], func2str(cdf),lasterr);
    end

    % Update negative log-likelihood with censored values, using
    % frequencies.
    nll = nll - sum(freq(~isUncensored).*log(1-cdfVals));
end

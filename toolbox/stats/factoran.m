function [Lambda, Psi, T, stats, F] = factoran(X, m, varargin)
%FACTORAN Maximum Likelihood Common Factor Analysis.
%   LAMBDA = FACTORAN(X, M) returns maximum likelihood estimates of the
%   factor loadings, LAMBDA, in a common factor analysis model with M
%   factors.  Rows of the N-by-D data matrix X correspond to observations,
%   columns correspond to variables.  The (i,j)th element of the D-by-M
%   factor loadings matrix LAMBDA is the estimated coefficient, or loading,
%   of the jth factor for the ith variable.  By default, FACTORAN rotates
%   LAMBDA using the varimax criterion (see below).
%
%   [LAMBDA, PSI] = FACTORAN(X, M) returns maximum likelihood estimates of
%   the specific variances in the D-by-1 vector PSI.
%
%   [LAMBDA, PSI, T] = FACTORAN(X, M) returns the M-by-M rotation matrix T
%   used to rotate LAMBDA.
%
%   [LAMBDA, PSI, T, STATS] = FACTORAN(X, M) returns a structure containing
%   information relating to the null hypothesis that the number of common
%   factors is M.  STATS contains the fields
%
%      loglike - the maximized log-likelihood value
%          dfe - the error degrees of freedom, ((D-M)^2 - (D+M))/2
%        chisq - the approximate chi-squared statistic for the null hypothesis
%            p - the right-tail significance level for the null hypothesis
%
%   FACTORAN does not return STATS.chisq and STATS.p unless STATS.dfe is
%   positive and all the specific variance estimates in PSI are positive.
%   FACTORAN does not return STATS.chisq and STATS.p if X is a covariance
%   matrix, unless you use the optional 'Nobs' parameter (see below).
%
%   [LAMBDA, PSI, T, STATS, F] = FACTORAN(X, M) returns predictions of the
%   common factors, also known as factor scores, in the N-by-M matrix F.
%   Rows of F correspond to predictions, columns correspond to factors.
%   FACTORAN cannot compute F if X is a covariance matrix.  FACTORAN rotates
%   F using the same criterion as for LAMBDA.
%
%   [ ... ] = FACTORAN(..., 'PARAM1',val1, 'PARAM2',val2, ...) allows you
%   to specify optional parameter name/value pairs to define the inputs,
%   control the numerical optimization used to fit the model, and specify
%   details of the outputs.  Parameters are:
%
%      'Xtype'     - Type of input in X [ {'data'} | 'covariance' ]
%      'Start'     - Method to select the starting point(s) for PSI in the
%                    optimization.  Choices are:
%                            'random' - Choose D independent Uniform(0,1)
%                                       values
%                        {'Rsquared'} - Choose starting vector as a scale
%                                       factor times DIAG(INV(CORRCOEF(X)))
%                    positive integer - The number of optimizations to
%                                       perform, each initialized as with
%                                       'random'
%                              matrix - A D-by-R matrix of explicit starting
%                                       points.  Each column is one starting
%                                       vector, and FACTORAN performs R
%                                       optimizations.
%      'Delta'     - Lower bound for the PSI during the maximum likelihood
%                    optimization [ 0 <= positive scalar < 1 | {0.005} ]
%      'OptimOpts' - Options for the maximum likelihood optimization,
%                    as created by STATSET.  See STATSET('factoran') for
%                    parameter names and default values.
%      'Nobs'      - Number of observations that went into estimating
%                    X, when X is a covariance matrix [ positive integer ]
%      'Scores'    - Method to be used for predicting F
%                    [ {'wls'} | 'Bartlett' | 'regression' | 'Thomson' ]
%      'Rotate'    - Method to use to rotate factor loadings and scores
%                    [ 'none' | {'varimax'} | 'quartimax' | 'equamax'
%                    | 'parsimax' | 'orthomax' | 'promax' | 'procrustes'
%                    | 'pattern' | function ]
%
%   If 'Rotate' is one of the above strings recognized by ROTATEFACTORS as
%   a valid value of its 'method' parameter, then you may also specify any
%   of the other parameter name/value pairs accepted by ROTATEFACTORS.
%
%   A rotation function can be specified using @, for example @ROTATEFUN,
%   and must be of the form
%
%         function [B, T] = ROTATEFUN(A, P1, P2, ...),
%
%   taking as arguments a D-by-M matrix A of unrotated loadings, plus zero
%   or more additional problem-dependent arguments P1, P2, ..., and
%   returning a D-by-M matrix B of rotated loadings and the corresponding
%   D-by-D rotation matrix T.
%
%   [ ... ] = FACTORAN(..., 'Rotate', ROTATEFUN, 'UserArgs', P1, P2, ...)
%   passes the arguments P1, P2, ... directly to the function ROTATEFUN.
%
%   Examples:
%
%      load carbig;
%      X = [Acceleration Displacement Horsepower MPG Weight];
%      X = X(all(~isnan(X),2),:);
%      [Lambda, Psi, T, stats, F] = factoran(X, 2, 'scores', 'regr')
%
%      % Same estimates, but computed from an estimated covariance matrix
%      [Lambda, Psi, T] = factoran(cov(X), 2, 'Xtype', 'cov')
%
%      % Use promax rotation
%      [Lambda, Psi, T] = factoran(X, 2, 'rotate','promax', 'power',2)
%
%      % Passing args to a rotation function
%      [Lambda Psi T] = ...
%           factoran(X, 2, 'rotate', @myrotation, 'userargs', 1, 'two')
%
%   See also BIPLOT, OPTIMSET, PROCRUSTES, PRINCOMP, PCACOV, ROTATEFACTORS.

% References:
%   Harman, H.H. (1976) Modern Factor Analysis, 3rd Ed., University of
%   Chicago Press, Chicago, 487 pp.
%
%   Joreskog, K.G. (1967) Some contributions to maximum likelihood factor
%   analysis, Psychometrika 32(4):443-482.
%
%   Lawley, D.N. and Maxwell, A.E. (1971) Factor Analysis as a Statistical
%   Method, 2nd Ed., American Elsevier Pub. Co., New York, 153 pp.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 1.6.4.10 $  $Date: 2004/03/02 21:49:08 $

% n = number of observations (if raw data or 'nobs' is supplied)
% d = number of observed variables
% m = desired number of latent factors
%
% Lambda = factor loadings: d x m
% Psi    = specific variances: d x d
% f      = factor scores: n x m

if nargin < 2
    error('stats:factoran:TooFewInputs',...
          'At least two input arguments required.');
end

% Vectors do not make sense here
if min(size(X)) == 1
    error('stats:factoran:NotEnoughData',...
          'X must have more than one row (observation) and more than one column (variable).');
end

d = size(X,2);
df = .5*((d-m)^2 - (d+m));
if (m > d) | (df < 0)
    error('stats:factoran:NotEnoughData',...
          'The number of factors requested, M, is too large for the number of the observed variables.');
end

names = {'xtype' 'scores' 'start'    'nobs' 'delta' 'optimopts' 'rotate'};
dflts = {'data'  'wls'    'rsquared' []     .005    []          'varimax'};
[eid,errmsg,xtype,scores,start,n,delta,options,rotate,userArgs,rotateArgs] ...
                      = statgetargsuser(names, dflts, 'userargs', varargin{:});
if ~isempty(eid)
   error(sprintf('stats:factoran:%s',eid),errmsg);
end

if ischar(xtype)
    xtypeNames = {'data','covariance'};
    i = strmatch(lower(xtype), xtypeNames);
    if length(i) > 1
        error('stats:factoran:BadXtype',...
              'Ambiguous ''Xtype'' parameter value:  %s.', xtype);
    elseif isempty(i)
        error('stats:factoran:BadXtype',...
              'Unknown ''Xtype'' parameter value:  %s.', xtype);
    end
    xtype = xtypeNames{i};

    switch xtype
    case 'data'
        n = size(X,1);  % ignore 'nobs' if raw data provided
        X0 = X - repmat(mean(X),n,1);
        [qrxQ, qrxR] = qr(X0/sqrt(n-1), 0);
        % ML factor analysis requires a positive definite covariance matrix
        s = svd(qrxR);
        if any(s <= eps(class(s))^(3/8) * max(s))
            error('stats:factoran:BadCovariance',...
                  'The covariance matrix of X must be positive definite.');
        end
        D = diag(1./sqrt(sum(qrxR.^2,1))); % standardize to cor matrix
        X0 = X0 * D;
        qrxR = qrxR * D;
        R = qrxR' * qrxR;

    case 'covariance'
        if nargout > 4
            error('stats:factoran:DataRequired',...
                  'Factor scores cannot be predicted without raw data.');
        end
        diagX = diag(X);
        if (size(X,1) ~= d) | any(any(abs(X - X') > 10*eps(abs(max(diagX)))))
            error('stats:factoran:BadCovariance',...
                  'The covariance/correlation matrix must be square and symmetric.');
        elseif any(diagX <= 0) % check _before_ trying to scale cov -> corr
            error('stats:factoran:BadCovariance',...
                  'The covariance/correlation matrix must be positive definite.');
        elseif any(diagX ~= 1) % cov matrix, standardize it
            D = 1./sqrt(diagX);
            R = X .* (D*D');
        else  % cor matrix
            R = X;
        end
        R = .5*(R + R');
        e = eig(R);
        if any(e <= eps(class(e))^(3/4) * max(abs(e)))
            % ML factor analysis requires a positive definite cov/cor matrix
            error('stats:factoran:BadCovariance',...
                  'The covariance/correlation matrix must be positive definite.');
        end
        qrxR = []; % flag to indicate no QR-type calculations possible
    end
else
    error('stats:factoran:BadXtype',...
          'The ''Xtype'' parameter value must be a string.');
end

if ischar(scores)
    scoresNames = {'bartlett','wls','thomson','regression'};
    i = strmatch(lower(scores), scoresNames);
    if length(i) > 1
        error('stats:factoran:BadScores',...
              'Ambiguous ''scores'' parameter value:  %s.', scores);
    elseif isempty(i)
        error('stats:factoran:BadScores',...
              'Unknown ''scores'' parameter value:  %s.', scores);
    end
    scores = scoresNames{i};
else
    error('stats:factoran:BadScores',...
          'The ''scores'' parameter value must be a string.');
end

if ischar(start)
    startNames = {'rsquared','random'};
    i = strmatch(lower(start), startNames);
    if length(i) > 1
        error('stats:factoran:BadStart',...
              'Ambiguous ''start'' parameter value:  %s.', start);
    elseif isempty(i)
        error('stats:factoran:BadStart',...
              'Unknown ''start'' parameter value:  %s.', start);
    end
    start = startNames{i};

    switch start
    case 'rsquared'
        if (isempty(qrxR))
            start = (1-m/(2*d)) * 1./diag(R\eye(d));
        else
            start = (1-m/(2*d)) * 1./sum((qrxR\eye(d)).^2,2);
        end
    case 'random'
        start = rand(d, 1);
    end
elseif isnumeric(start)
    if prod(size(start)) == 1
        % Use 'start' random starting points
        start = rand(d, start);
    elseif size(start,1) == d
        % User-supplied starting value(s), do nothing
    elseif size(start,1) == 1 & size(start,2) == d
        start = start'; % force row vector into column vector
    else
        error('stats:factoran:BadStart','Invalid starting value.');
    end
else
    error('stats:factoran:BadStart',...
          'The ''start'' parameter value must be a string, an integer, or a numeric matrix.');
end

if ischar(rotate)
    % This list also appears in rotatefactors.
    rotateNames = {'none' 'varimax' 'quartimax' 'equamax' 'equimax' ...
                   'parsimax' 'orthomax' 'promax' 'procrustes' 'pattern'};
    i = strmatch(lower(rotate), rotateNames);
    % Let rotatefactors handle ambiguities.
    if isempty(i)
        % Assume that an unrecognized string is a user-defined rotation
        % function name, change it to a handle.  userArgs will have the
        % extra args (if any) in it.
        rotate = str2func(rotate);
        doRotate = true;
    else
        doRotate = ~isequal(i,1); % don't if rotate is 'none'
    end

% Inlines are not accepted, a rotate function needs to return two values
elseif isa(rotate, 'function_handle')
    % A user-defined rotation function, leave it alone.  userArgs will have
    % the extra args (if any) in it.
    doRotate = true;
else
    error('stats:factoran:BadRotate',...
          'The ''rotate'' parameter value must be a string or a function.');
end

% The default options include turning statsfminbx's display off.  This
% function gives its own warning/error messages, and the caller can
% turn display on to get the text output from statsfminbx if desired.
options = optimset(statset(statset('factoran'),options));
dfltOptions = struct('DerivativeCheck','off', 'HessMult',[], ...
    'HessPattern',ones(d), 'PrecondBandWidth',Inf, ...
    'TypicalX',ones(d,1), 'MaxPCGIter',max(1,floor(d/2)), ...
    'TolPCG',0.1);
%
% Done processing input args, begin estimation
%

% Set parameter space boundaries, optimizer will enforce bounds on starting values
lowerBnd = repmat(max(min(delta,1),0), d, 1);
upperBnd = repmat(1, d, 1);

funfcn = {'fungrad' 'factoran' @negloglike @negloglike []};

L = -Inf;
for i = 1:size(start,2)
    % Maximize L(Lambda(Psi), Psi; S) with respect to Psi
    [Psi1, nll, lagrange, err, output] = ...
          statsfminbx(funfcn, start(:,i), lowerBnd, upperBnd, ...
                      options, dfltOptions, 1, R, qrxR, m, d);
    if (err == 0)
        % statsfminbx may print its own output text; in any case give something
        % more statistical here, controllable via warning IDs.
        if output.funcCount >= options.MaxFunEvals
            wmsg = 'Maximum likelihood estimation did not converge.  Function evaluation limit exceeded.';
        else
            wmsg = 'Maximum likelihood estimation did not converge.  Iteration limit exceeded.';
        end
        warning('stats:factoran:IterOrEvalLimit',wmsg);
    elseif (err < 0)
        error('stats:factoran:NoSolution',...
              'Unable to reach a maximum likelihood solution.');
    end

    % Save off the best fit so far
    if nll < -L
        L = -nll;
        Psi = Psi1;
        heywood = any(lagrange.lower > 0); % any(Psi <= delta)
    end
end

% Estimate factor loading matrix Lambda
sqrtPsi = sqrt(Psi);
if (isempty(qrxR))
    invsqrtPsi = 1 ./ sqrtPsi;
    [Omega, Theta] = eig(R .* (invsqrtPsi*invsqrtPsi'));
    theta = diag(Theta);
else
    invsqrtPsi = diag(1 ./ sqrtPsi);
    [U, sqrtTheta, Omega] = svd(qrxR * invsqrtPsi, 0);
    theta = diag(sqrtTheta).^2;
end
[theta, i] = sort(theta); % sort ascending
theta1 = theta(d:-1:(d-m+1));
Omega1 = Omega(:,i(d:-1:(d-m+1)));
Lambda = Omega1 .* (sqrtPsi*sqrt(max(theta1-1,0))');

% Put unrotated loadings in standard form: sort by col norm, force positive sums.
% Do this before rotating so that T will be relative to this standard form.
[ssqL, ord] = sort(sum(Lambda.^2));
Lambda = Lambda(:,fliplr(ord));
Lambda = Lambda .* repmat(sign(sum(Lambda)),d,1);

% Rotate factor loadings
if doRotate && m > 1
    if isa(rotate,'function_handle') % user-specified rotation
        try
            [Lambda, T] = feval(rotate, Lambda, userArgs{:});
        catch
            [errMsg,errID] = lasterr;
            if strcmp('MATLAB:UndefinedFunction', errID) ...
                    && ~isempty(strfind(errMsg, func2str(rotate)))
                error('stats:factoran:RotationFunNotFound',...
                      'The rotation function ''%s'' was not found.', func2str(rotate));
            else
                error('stats:factoran:RotationFunError',...
                      'The rotation function ''%s'' generated the following error:\n%s',...
                      func2str(rotate),lasterr);
            end
        end
    else % a string naming a built-in rotation
        [Lambda, T] = rotatefactors(Lambda, 'method', rotate, rotateArgs{:});
    end

    % Put rotated loadings in standard form, again, and make T match
    [ssqL, ord] = sort(sum(Lambda.^2));
    Lambda = Lambda(:,fliplr(ord));
    T = T(:,fliplr(ord));
    signs = repmat(sign(sum(Lambda)),d,1);
    Lambda = Lambda .* signs;
    T = T .* signs(1:m,:);
else
    T = eye(m);
end

% The test statistic for the hypothesis H0: #factors = m
if nargout > 3
    stats.loglike = L;
    stats.dfe = df;
    wmsgid = 'stats:factoran:NoSignificance';
    if ~isempty(n) & df > 0 & ~heywood
        stats.chisq = -(n - (2*d + 11)/6 - 2*m/3) * L;
        stats.p = 1 - chi2cdf(stats.chisq, stats.dfe);
    elseif isempty(n)
        warning(wmsgid,'Significance cannot be computed without either raw data or the ''nobs'' argument.');
    elseif df == 0
        warning(wmsgid,'Zero degrees of freedom: cannot compute significance.');
    else
        warning(wmsgid,'Some unique variances are zero: cannot compute significance.');
    end
elseif heywood
    warning('stats:factoran:ZeroVariance','Some unique variances are zero.');
end

% Predict factor scores
if nargout > 4
    switch scores
    case {'wls', 'bartlett'}
        F = (X0*invsqrtPsi) / (Lambda'*invsqrtPsi);
    case {'regression', 'thomson'}
        F = [X0*invsqrtPsi zeros(n,m)] / [Lambda'*invsqrtPsi T'];
    end
end


%------------------------------------------------------------------

function [nll, grad] = negloglike(Psi, R, qrxR, m, d)
% Objective function.  Returns the negative of the (profile) log-likelihood
% for the Wishart dist'n, evaluated at
%
%    Sigma = Lambda*Lambda'+Psi
%
% where Lambda == Lambda(Psi) is determined as a function of Psi.  the
% negative log-likelihood reduces to
%
%    -2L = log(|Sigma|/|R|)
%
% Assumes that Psi is bounded between 0 and 1.

% L depends only on the e-values of Psi^(-1/2) * R * Psi^(-1/2), but if the
% gradient is requested, Lambda(Psi) must be computed from the e-vectors.

sqrtPsi = sqrt(Psi);
if (isempty(qrxR))
    invsqrtPsi = 1 ./ sqrtPsi;
    if nargout == 1
        theta = eig(R .* (invsqrtPsi*invsqrtPsi'));
    else
        [Omega, Theta] = eig(R .* (invsqrtPsi*invsqrtPsi'));
        theta = diag(Theta);
    end
else
    invsqrtPsi = diag(1 ./ sqrtPsi);
    if nargout == 1
        theta = svd(qrxR * invsqrtPsi, 0).^2;
    else
        [U, sqrtTheta, Omega] = svd(qrxR * invsqrtPsi, 0);
        theta = diag(sqrtTheta).^2;
    end
end
[theta i] = sort(theta); % sort ascending

% The log-likelihood itself uses the (d-m) smallest e-values
theta0 = theta(1:(d-m));
nll = sum(theta0 - log(theta0)) + m - d;

% The gradient uses the m largest e-values and their e-vectors
if nargout > 1
    theta1 = theta(d:-1:(d-m+1));
    Omega1 = Omega(:,i(d:-1:(d-m+1)));
    Lambda = Omega1 .* (sqrtPsi*sqrt(max(theta1-1,0))');
    grad = (sum(Lambda.^2,2) + Psi - diag(R)) ./ (Psi.^2);

end

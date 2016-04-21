function [beta,r,J] = nlinfit(X,y,model,beta,options)
%NLINFIT Nonlinear least-squares regression.
%   BETA = NLINFIT(X,Y,MODELFUN,BETA0) estimates the coefficients of a
%   nonlinear regression function, using least squares estimation.  Y is a
%   vector of response (dependent variable) values.  Typically, X is a
%   design matrix of predictor (independent variable) values, with one row
%   for each value in Y and one column for each coefficient.  However, X
%   may be any array that MODELFUN is prepared to accept.  MODELFUN is a
%   function, specified using @, that accepts two arguments, a coefficient
%   vector and the array X, and returns a vector of fitted Y values.  BETA0
%   is a vector containing initial values for the coefficients.
%
%   [BETA,R,J] = NLINFIT(X,Y,MODELFUN,BETA0) returns the fitted
%   coefficients BETA, the residuals R, and the Jacobian J of MODELFUN,
%   evaluated at BETA. You can use these outputs with NLPREDCI to produce
%   confidence intervals for predictions, and with NLPARCI to produce
%   confidence intervals for the estimated coefficients.  sum(R.^2)/(N-P),
%   where [N,P] = size(X), is an estimate of the population variance, and
%   inv(J'*J)*sum(R.^2)/(N-P) is an estimate of the covariance matrix of
%   the estimates in BETA.
%
%   [...] = NLINFIT(X,Y,MODELFUN,BETA0,OPTIONS) specifies control parameters
%   for the algorithm used in NLINFIT.  This argument can be created by a
%   call to STATSET.  Applicable STATSET parameters are:
%
%      'MaxIter'   - Maximum number of iterations allowed.  Defaults to 100.
%      'TolFun'    - Termination tolerance on the residual sum of squares.
%                    Defaults to 1e-8.
%      'TolX'      - Termination tolerance on the estimated coefficients
%                    BETA.  Defaults to 1e-8.
%      'Display'   - Level of display output during estimation.  Choices are
%                    'off' (the default), 'iter', or 'final'.
%      'DerivStep' - Relative difference used in finite difference gradient
%                    calculation.  May be a scalar, or the same size as
%                    the parameter vector BETA.  Defaults to EPS^(1/3).
%
%   NLINFIT treats NaNs in Y or MODELFUN(BETA,X) as missing data, and
%   ignores the corresponding rows.
%
%   Examples:
%
%      Use @ to specify MODELFUN:
%         load reaction;
%         beta = nlinfit(reactants,rate,@mymodel,beta);
%
%      where MYMODEL is a MATLAB function such as:
%         function yhat = mymodel(beta, x)
%         yhat = (beta(1)*x(:,2) - x(:,3)/beta(5)) ./ ...
%                        (1+beta(2)*x(:,1)+beta(3)*x(:,2)+beta(4)*x(:,3));
%   
%   See also NLPARCI, NLPREDCI, NLINTOOL, STATSET.

%   References:
%      [1] Seber, G.A.F, and Wild, C.J. (1989) Nonlinear Regression, Wiley.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.22.2.5 $  $Date: 2004/03/02 21:49:16 $

if nargin < 4
    error('stats:nlinfit:TooFewInputs','NLINFIT requires four input arguments.');
elseif ~isvector(y)
    error('stats:nlinfit:NonVectorY','Requires a vector second input argument.');
end
if nargin < 5
    options = statset('nlinfit');
else
    options = statset(statset('nlinfit'), options);
end

% Check sizes of the model function's outputs while initializing the fitted
% values, residuals, and SSE at the given starting coefficient values.
model = fcnchk(model);
try
    yfit = model(beta,X);
catch
    [errMsg,errID] = lasterr;
    if isa(model, 'inline')
        error('stats:nlinfit:ModelFunctionError',...
             ['The inline model function generated the following ', ...
              'error:\n%s'], errMsg);
    elseif strcmp('MATLAB:UndefinedFunction', errID) ...
                && ~isempty(strfind(errMsg, func2str(model)))
        error('stats:nlinfit:ModelFunctionNotFound',...
              'The model function ''%s'' was not found.', func2str(model));
    else
        error('stats:nlinfit:ModelFunctionError',...
             ['The model function ''%s'' generated the following ', ...
              'error:\n%s'], func2str(model),errMsg);
    end
end
if ~isequal(size(yfit), size(y))
    error('stats:nlinfit:WrongSizeFunOutput', ...
          'MODELFUN should return a vector of fitted values the same length as Y.');
end

% Find missing values in either the responses or the fitted values, those
% will be weeded out.
nans = (isnan(y(:)) | isnan(yfit(:))); % a col vector
n = sum(~nans);
p = numel(beta);

sqrteps = sqrt(eps(class(beta)));
J = zeros(n,p,class(yfit));
r = y(:) - yfit(:);
r(nans) = [];
sse = r'*r;

% Set up convergence tolerances from options.
maxiter = options.MaxIter;
betatol = options.TolX;
rtol = options.TolFun;
fdiffstep = options.DerivStep;

zbeta = zeros(size(beta),class(beta));
zerosp = zeros(p,1,class(r));

% Set initial weight for LM algorithm.
lambda = .01;

% Set the level of display
switch options.Display
case 'off',    verbose = 0;
case 'notify', verbose = 1;
case 'final',  verbose = 2;
case 'iter',   verbose = 3;
end

if verbose > 2 % iter
    disp(' ');
    disp('                                     Norm of         Norm of');
    disp('   Iteration             SSE        Gradient           Step ');
    disp('  -----------------------------------------------------------');
    disp(sprintf('      %6d    %12g',0,sse));
end

iter = 0;
breakOut = false;
while iter < maxiter
    iter = iter + 1;
    betaold = beta;
    sseold = sse;

    % Compute a finite difference approximation to the Jacobian
    for k = 1:p
        delta = zbeta;
        if (beta(k) == 0)
            nb = sqrt(norm(beta));
            delta(k) = fdiffstep * (nb + (nb==0));
        else
            delta(k) = fdiffstep*beta(k);
        end
        yplus = model(beta+delta,X);
        dy = yplus(:) - yfit(:);
        dy(nans) = [];
        J(:,k) = dy/delta(k);
    end

    % Levenberg-Marquardt step: inv(J'*J+lambda*D)*J'*r
    Jplus = [J; diag(sqrt(lambda*sum(J.^2)))];
    rplus = [r; zerosp];
    step = Jplus \ rplus;
    beta(:) = beta(:) + step;

    % Evaluate the fitted values at the new coefficients and
    % compute the residuals and the SSE.
    yfit = model(beta,X);
    r = y(:) - yfit(:);
    r(nans) = [];
    sse = r'*r;

    % If the LM step decreased the SSE, decrease lambda to downweight the
    % steepest descent direction.
    if sse < sseold
        lambda = 0.1*lambda;

    % If the LM step increased the SSE, repeatedly increase lambda to
    % upweight the steepest descent direction and decrease the step size
    % until we get a step that does decrease SSE.
    else
        while sse > sseold
            lambda = 10*lambda;
            if lambda > 1e16
                warning('stats:nlinfit:UnableToDecreaseSSE', ...
                        'Unable to find a step that will decrease SSE.  Returning results from last iteration.');
                breakOut = true;
                break
            end
            Jplus = [J; diag(sqrt(lambda*sum(J.^2)))];
            step = Jplus \ rplus;
            beta(:) = betaold(:) + step;
            yfit = model(beta,X);
            r = y(:) - yfit(:);
            r(nans) = [];
            sse = r'*r;
        end
    end
    
    if verbose > 2 % iter
        disp(sprintf('      %6d    %12g    %12g    %12g', ...
                     iter,sse,norm(2*r'*J),norm(step)));
    end

    % Check step size and change in SSE for convergence.
    if norm(step) < betatol*(sqrteps+norm(beta))
        if verbose > 1 % 'final' or 'iter'
            disp('Iterations terminated: relative norm of the current step is less than OPTIONS.TolX');
        end
        break
    elseif abs(sse-sseold) <= rtol*sse
        if verbose > 1 % 'final' or 'iter'
            disp('Iterations terminated: relative change in SSE less than OPTIONS.TolFun');
        end
        break
    elseif breakOut
        break
    end
end

if (iter >= maxiter)
    warning('stats:nlinfit:IterationLimitExceeded', ...
            'Iteration limit exceeded.  Returning results from final iteration.');
end

if nargout > 1
    % Return residuals and Jacobian that have missing vcalues where needed.
    r = y - yfit;
    JJ(~nans,:) = J;
    JJ(nans,:) = NaN;
    J = JJ;
end

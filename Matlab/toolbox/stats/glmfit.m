function [b,dev,stats]=glmfit(x,y,distr,link,estdisp,offset,pwts,const)
%GLMFIT   Fit generalized linear model
%   B=GLMFIT(X,Y,DISTR) fits a generalized linear model using the
%   predictor matrix X, response Y, and distribution DISTR.  The result
%   B is a vector of coefficient estimates.  Acceptable values for distr
%   are 'normal', 'binomial', 'poisson', 'gamma', and 'inverse gaussian'.
%   The distribution parameter is fit as a function of the X columns
%   using the canonical link.
%
%   B=GLMFIT(X,Y,DISTR,LINK,'ESTDISP',OFFSET,PWTS,'CONST') provides more
%   control over the fit.  LINK is the link function to use in place of
%   the canonical link. 'ESTDISP' is 'on' to estimate a dispersion
%   parameter for the binomial or Poisson distribution in computing
%   standard errors, or 'off' to use the theoretical dispersion
%   parameter value.  (The estimated disperson is always used for other
%   distributions.)  OFFSET is a vector that is used as an additional
%   predictor but with a coefficient value fixed at 1.0.  PWTS is a
%   vector of prior weights, such as the frequencies of each observation
%   in X and Y.  'CONST' can be 'on' (the default) to include a constant
%   term or 'off' to omit it.  The coefficient of the constant term is
%   the first element of B.  (Do not enter a column of ones directly
%   into the X matrix.)
%
%   LINK defines a function f that defines the relationship f(mu) = xb
%   between the distribution parameter mu and the linear combination of
%   predictors xb.  You specify f by defining LINK to be any of
%      - the text strings 'identity', 'log', 'logit', 'probit',
%        'comploglog', 'reciprocal', 'logloglink'
%      - a number P, which defines mu = xb^P
%      - a cell array of the form {@FL @FD @FI} where the three
%        functions define the link (FL), the derivative of the link
%        (FD), and the inverse link (FI)
%      - a cell array of three inline functions to define the link,
%        derivative, and inverse link
%
%   [B,DEV,STATS]=GLMFIT(...) returns additional results.  DEV is the
%   value of the deviance at the solution.  STATS is a structure that
%   contains the following fields: dfe (degrees of freedom for error), s
%   (theoretical or estimated dispersion parameter), sfit (estimated
%   dispersion parameter), se (standard errors of coefficient estimates
%   b), coeffcorr (correlation matrix for b), t (t statistics for b), p
%   (p-values for b), resid (residuals), residp (Pearson residuals),
%   residd (deviance residuals), resida (Anscombe residuals).
%
%   Example:
%	    b = glmfit(x, [y N], 'binomial', 'probit')
%      This example fits a probit regression model for y on x.  Each
%      y(i) is the number of successes in N(i) trials.
%
%   See also GLMVAL, REGRESS.

%   References:
%      Dobson, A.J. (1990), "An Introduction to Generalized Linear
%         Models," CRC Press.
%      McCullagh, P., and J.A. Nelder (1990), "Generalized Linear
%         Models," CRC Press.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.3.2.3 $  $Date: 2004/01/16 20:09:23 $

% Supply default values for missing inputs
if (nargin<2)
   error('stats:glmfit:TooFewInputs','At least two arguments are required');
end
if (nargin<3 | isempty(distr)),   distr = 'normal'; end
if (nargin<4 | isempty(link)),    link = 'canonical'; end
if (nargin<5 | isempty(estdisp)), estdisp = 'off'; end
if (nargin<6 | isempty(offset)),  offset = []; end
if (nargin<7 | isempty(pwts)),    pwts = []; end
if (nargin<8 | isempty(const)),   const = 'on'; end

switch(distr)
 case 'normal',           clink = 'identity';
                          estdisp = 'on';
 case 'binomial',         clink = 'logit';
                          if (size(y,2)>1), y(y(:,2)==0,2) = NaN; end
                          if (isempty(estdisp)), estdisp = 'off'; end
 case 'poisson',          clink = 'log';
                          if (isempty(estdisp)), estdisp = 'off'; end
 case 'gamma',            clink = 'reciprocal';
                          estdisp = 'on';
 case 'inverse gaussian', clink = -2;
                          estdisp = 'on';
 otherwise,               error('stats:glmfit:BadDistribution',...
                                'Distribution name is invalid.');
end
varfunc = [distr(distr~=' ') 'variance'];
if (isequal(link, 'canonical')), link = clink; end

% Make sure link function is valid
[emsg,link,dlink,ilink,exponent] = stattestlink(link);
if ~isempty(emsg)
   error('stats:glmfit:BadLink',emsg);
end

% Remove NaN
[anybad wasnan y x offset pwts] = statremovenan(y,x,offset,pwts);
if (anybad>0)
   switch(anybad)
    case 2, error('stats:glmfit:InputSizeMismatch',...
                  'Lengths of X and Y must match.')
    case 3, error('stats:glmfit:InputSizeMismatch',...
                  'Lengths of OFFSET and Y must match.')
    case 4, error('stats:glmfit:InputSizeMismatch',...
                  'Lengths of PWTS and Y must match.')
   end
end
if (isempty(pwts)), pwts = 1; end
if (isempty(offset)), offset = 0; end

% Get binomial N parameter, if necessary
if (isequal(distr, 'binomial'))
   if (size(y,2)~=2)
      error('stats:glmfit:MatrixRequired',...
            'Y must have two columns for the binomial distribution.');
   end
   N = y(:,2);
   y = y(:,1) ./ N;
   varparams = {N};
else
   N = [];
   varparams = {};
end

% Set up for iterations
if (isequal(const,'on')), x = [ones(size(x,1),1) x]; end
x = double(x);
y = double(y);
iter = 0;
iterlim = 100;
[n p] = size(x);
seps = sqrt(eps);
convcrit = 1e-6;
eta = initeta(y,N,distr,link,exponent);
b = zeros(p,1);
b0 = b+1;

while(1)
   iter = iter+1;

   % Compute parameter by using inverse link function
   mu = statglmeval('eval',ilink,eta,exponent{:});

   % Force parameter in bounds
   if (isequal(distr,'binomial'))
      mu = max(0, min(1, mu));
   elseif (isequal(distr,'poisson') | isequal(distr,'gamma') ...
           | isequal(distr,'inverse gaussian'))
      mu = max(0,mu);
   end
   
   % Check stopping conditions
   if (~any(abs(b-b0) > convcrit * max(seps, abs(b0)))), break; end
   if (iter>iterlim)
      warning('stats:glmfit:IterationLimit','Iteration limit reached.');
      break;
   end

   % Compute adjusted dependent variable for least squares fit
   deta = statglmeval('eval',dlink,mu,exponent{:});
   z = eta + (y - mu) .* deta;
   
   % Compute weight function as the inverse of the variance function
   vy = statglmeval('eval',varfunc,mu,varparams{:});
   w = pwts ./ max(eps, (deta .^ 2) .* vy);
   
   % Compute coefficient estimates for this iteration
   b0 = b;
   [b,R] = wfit(z - offset, x, w);
   
   % Form current linear combination, including offset
   eta = offset + x * b;
end

% For most distributions we may need to take a subset of the
% observations below, so expand scalar pwts to full size
if isscalar(pwts) && ~isequal(distr,'normal')
   pwts = repmat(pwts,size(y));
end

% For each distribution compute components of deviance, sum of
% squares used to estimate dispersion, the total deviance, and the
% Anscombe residual
dev = [];
switch(distr)
 case 'normal'
   di = (y - mu).^2;
   ssr = sum(pwts .* di);
   dev = ssr;
   anscresid = y - mu;
 case 'binomial'
   t = (y>0);
   di = zeros(size(y));
   Ny = N .* y;
   Nm = N .* mu;
   di(t) = 2*( Ny(t) .* log(Ny(t) ./ Nm(t)));
   Ny = N - Ny;
   Nm = N - Nm;
   t = (Ny>0);
   di(t) = di(t) + 2*(Ny(t) .* log(Ny(t) ./ Nm(t)));
   v = mu .* (1 - mu) ./ N;
   t = (v>0);
   ssr = sum(pwts(t) .* (y(t) - mu(t)).^2 ./ v(t));
   t = 2/3;
   anscresid = beta(t,t) * (betainc(y,t,t)-betainc(mu,t,t)) ./ ...
                  (max(eps,(mu.*(1-mu))).^(1/6) ./ sqrt(N));
 case 'poisson'
   di = 2*(y .* (log((y+(y==0)) ./ mu)) - (y-mu));
   t = (mu>0);
   ssr = sum(pwts(t) .* (y(t) - mu(t)).^2 ./ mu(t));
   anscresid = 1.5 * ((y.^(2/3) - mu.^(2/3)) ./ mu.^(1/6));
 case 'gamma'
   di = 2*(-log(y ./ mu) + (y - mu) ./ mu);
   t = (mu>0);
   ssr = sum(pwts(t) .* ((y(t) - mu(t)) ./ mu(t)).^2);
   anscresid = 3 * (y.^(1/3) - mu.^(1/3)) ./ mu.^(1/3);
 case 'inverse gaussian'
   di = ((y - mu).^2) ./ (mu.^2 .* y);
   t = (mu>0);
   ssr = sum(pwts(t) .* (y(t) - mu(t)).^2 ./ mu(t).^3);
   anscresid = (log(y) - log(mu)) ./ mu;
end
if (isempty(dev) & nargout>1)
   dev = sum(pwts .* di);
end

% Return additional statistics if requested
if (nargout>2)
   % Compute residuals, using original count scale for binomial
   if (isequal(distr, 'binomial'))
      resid = (y - mu) .* N;
   else
      resid  = y - mu;
   end

   vy = statglmeval('eval',varfunc,mu,varparams{:});
   dfe = n - p;
   stats.beta = b;
   stats.dfe = dfe;
   stats.sfit = sqrt(ssr / dfe);
   stats.estdisp = 1;
   if (isequal(estdisp,'off'))
      stats.s = 1;
      stats.estdisp = 0;
   elseif (dfe>0)
      stats.s = stats.sfit;
   else
      stats.s = NaN;
   end
   
   % Find coefficient standard errors and correlations
   if (~isnan(stats.s))
      RI = R\eye(p);
      C = RI * RI';
      if (isequal(estdisp,'on')), C = C * stats.s^2; end
      se = sqrt(max(eps,diag(C)));
      C = C ./ (se * se');
      stats.se = se;
      stats.coeffcorr = C;
      stats.t = b ./ se;
      if (isequal(estdisp,'on'))
         stats.p = 2 * tcdf(-abs(stats.t), dfe);
      else
         stats.p = 2 * normcdf(-abs(stats.t));
      end
   end
   
   stats.resid  = statinsertnan(wasnan, resid);
   stats.residp = statinsertnan(wasnan, (y - mu) ./ sqrt(vy + (y==mu)));
   stats.residd = statinsertnan(wasnan, sign(y - mu) .* sqrt(max(0,di)));
   stats.resida = statinsertnan(wasnan, anscresid);
end


function [b,R]=wfit(y,x,w)
% Perform a weighted least squares fit
sw = sqrt(w);
[r c] = size(x);
yw = y .* sw;
xw = x .* sw(:,ones(1,c));
[Q,R]=qr(xw,0);
b = R\(Q'*yw);


function eta=initeta(y,N,distr,link,exponent);
% Find a starting value for the linear combination, avoiding boundary values
switch(distr)
 case 'poisson'
  y = y + 0.25;
 case 'binomial'
  y = (N .* y + 0.5) ./ (N + 1);
 case {'gamma' 'inverse gaussian'}
  if (any(y(:)<=0))
     delta = min(abs(y(y~=0))) * .001;
     y = max(delta, y);
  end
end
eta = statglmeval('eval',link, y, exponent{:});

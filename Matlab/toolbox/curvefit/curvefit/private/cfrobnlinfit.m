function [p,resnorm,res,exitflag,optoutput,lam,jacob,convmsg] = ...
                cfrobnlinfit(model,p0,xdata,wtdy,lowerbnd,upperbnd,...
                 options,probparams,separargs,wts,resin,jacob,robtype,...
                 lsiter,lsfunevals)
%CFROBNLINFIT Do robust nonlinear fitting for curve fitting toolbox.
%
%   RESIN is a vector of residuals from the non-robust fit.  JACOB is
%   the Jacobian for that fit.  LSITER and LSFUNEVALS are the number of
%   iterations and the number of function evaluations used in the initial
%   least squares fit.  See cflsqcurvefit for a description of the
%   other arguments.

%   Copyright 2001-2004 The MathWorks, Inc.
%   $Revision: 1.11.2.3 $  $Date: 2004/02/01 21:43:20 $

% Global parameter, OPT_STOP is used for canceling fits
% It is initialized and set in the Curve Fitting GUI (CreateAFit.java)
global OPT_STOP 

iteroutput = isequal(lower(options.Display),'iter');

p = p0(:);
p0 = zeros(size(p));
sqrtwts = sqrt(wts);
P = numcoeffs(model);
N = length(wtdy);

% Need the real Jacobian if things are separable
if ~isempty(separargs)
   separargs{2} = wts;
   [ftemp,jacob,pfull] = ...
              feval(model,p,xdata,probparams{:},separargs{:},wts,'optimweight');
end

% Adjust residuals using leverage, as advised by DuMouchel & O'Brien
[Q,R]=qr(jacob,0);
ws = warning('off', 'all');
E = jacob/R;
h = min(.9999, sum(E.*E,2));
adjfactor = 1 ./ sqrt(1-h);
warning(ws);

dfe = N-P;
ols_s = norm(resin) / sqrt(dfe);

% Perform iteratively reweighted least squares to get coefficient estimates
D = 1e-6;
robiter = 0;

% Account for iterations and function evaluations already used
iterlim = options.MaxIter - lsiter;
maxfunevals = options.MaxFunEvals - lsfunevals;

wstr = '';
res = resin;
while((robiter==0) || any(abs(p-p0) > D*max(abs(p),abs(p0)))) && ~isequal(OPT_STOP, 1)
   robiter = robiter + 1;
   
   if iteroutput
       disp(sprintf('\nRobust fitting iteration %i:\n---------------------------',robiter));
   end
   
   % Compute residuals from previous fit, then compute scale estimate
   radj = res .* adjfactor;
   sigma = cfrobsigma(robtype,radj,P);
   if (sigma==0), sigma=1; end
   
   % Compute new weights from these residuals, then re-fit
   tune = 4.685;
   bw = cfrobwts(robtype,radj/(sigma*tune));
   p0 = p;
   if ~isempty(separargs)
       separargs{2} = wts.*bw;
   end
   options.MaxIter = iterlim;
   options.MaxFunEvals = maxfunevals;
   [p,resnorm,res,exitflag,optoutput,lam,jacob,convmsg] = ...
                cflsqcurvefit(model,p0,xdata,wtdy.*sqrt(bw),...
                              lowerbnd,upperbnd,...
                              options,probparams{:},separargs{:},wts.*bw,'optimweight');
   iterlim = iterlim - optoutput.iterations;
   maxfunevals = maxfunevals - optoutput.funcCount;
   
   if ~isempty(separargs)
       [ftemp,jacobtemp,pfull] = ...
              feval(model,p,xdata,probparams{:},separargs{:},wts.*bw,'optimweight');
   else
      pfull = p;
   end
   res = wtdy - feval(model,pfull,xdata,probparams{:},wts,'optimweight');

   if exitflag==0
      break
   end

   % After 1st iteration for lar, don't use adjusted residuals
   if robiter==1 && isequal(robtype,'lar')
      adjfactor = 1;
   end
end
if OPT_STOP
    error('curvfit:cfrobnlintfit:fittingCancelled', ...
          'Fitting computation cancelled.');
end

% To compute the res, jacob include the weights but not robust weights.
% Resnorm is computed special below.
if ~isempty(separargs) % separable, need all coefficients computed
    % Get all the coefficients and the full Jacobian and res computed with weights
    separargs{2} = wts;
    [f,jacob,ptemp] = feval(model,p,xdata,probparams{:},separargs{:},wts,'optimweight');
    p = pfull;

% Note separargs is empty in the following two feval calls
elseif isequal(category(model),'library') % library and not separable
    [f,jacob] = feval(model,p,xdata,probparams{:},separargs{:},wts,'optimweight');
else % custom
    % Finite-difference to get Jacobian without robust weights, and recompute res with weights
    f = feval(model,p,xdata,probparams{:},separargs{:},wts,'optimweight'); 
    jacob = jacobianmatrix(model,p,xdata,probparams);
    jacob = repmat(sqrtwts,1,size(jacob,2)) .* jacob;
end
res = wtdy - f;

if (nargout>1)
   % Compute robust mse according to DuMouchel & O'Brien (1989).
   % Note: mse = sse/N-P = resnorm/dfe;
   radj = res .* adjfactor;
   [mad_s,robust_s] = cfrobsigma(robtype,radj, P, tune, h);

   % Shrink robust value toward ols value if appropriate
   sigma = max(robust_s, sqrt((ols_s^2 * P^2 + robust_s^2 * N) / (P^2 + N)));
   resnorm = dfe * sigma^2; % new resnorm based on sigma
end

%---------------------------------------------------------------
function Jacob = jacobianmatrix(fun,coeffs,x,probparams)
% JACOBIANMATRIX Compute Jacobian.

n = length(coeffs);
Jacob = zeros(length(x),n);
ypred = feval(fun,coeffs,x,probparams{:},'optim');
for i = 1:n
    bi = coeffs(i);
    if (bi == 0)
        nb = sqrt(norm(coeffs));
        change = sqrt(eps) * (nb + (nb==0));
    else
        change = sqrt(eps)*bi;
    end
    coeffs(i) = bi + change;
    predplus = feval(fun,coeffs,x,probparams{:},'optim'); % Use 'optim' flag so p can be vector
    Jacob(:,i) = (predplus - ypred)/change;
    coeffs(i) = bi;
end

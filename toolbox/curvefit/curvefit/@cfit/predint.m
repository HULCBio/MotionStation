function [ci,ypred] = predint(fun,x,level,intopt,simopt)
%PREDINT  Prediction intervals for a fit result object or new observations.
%   CI = PREDINT(FITRESULT,X,LEVEL) returns prediction intervals
%   for a new Y value at the specified X value.  LEVEL is the
%   confidence level and has a default value of 0.95.
%
%   CI = PREDINT(FITRESULT,X,LEVEL,'INTOPT','SIMOPT') specifies the
%   type of interval to compute.  'INTOPT' can be either 'observation'
%   (the default) to compute bounds for a new observation, or
%   'functional' to compute bounds for the curve evaluated at X.
%   'SIMOPT' can be 'on' to compute simultaneous confidence bounds
%   or 'off' to compute non-simultaneous bounds.
%
%   If 'INTOPT' is 'functional', the bounds measure the uncertainty
%   in estimating the curve.  If 'INTOPT' is 'observation', the bounds
%   are wider to represent the addition uncertainty in predicting a
%   new Y value (the curve plus random noise).
%
%   Suppose the confidence level is 95% and 'INTOPT' is 'functional'.
%   If 'SIMOPT' is 'off' (the default), then given a single pre-determined
%   X value you have 95% confidence that the true curve lies between
%   the confidence bounds.  If 'SIMOPT' is 'on', then you have 95%
%   confidence that the entire curve (at all X values) lies between
%   the bounds.

%   Copyright 2001-2004 The MathWorks, Inc. 
%   $Revision: 1.7.2.2 $  $Date: 2004/02/01 21:39:32 $

ftype = category(fun);
if strcmpi(ftype,'spline') || strcmpi(ftype,'interpolant')
   error('curvefit:predint:cannotComputePredInts', ...
         'Cannot compute prediction intervals for %s fits.', ftype);
end
if isempty(fun.sse) || isempty(fun.dfe) || isempty(fun.rinv)
   error('curvefit:predint:missingInfo', ...
         'CFIT object is missing information for prediction intervals.');
end

if nargin<3
   level = 0.95;
elseif length(level)~=1 || ~isnumeric(level) || level<=0 || level>=1
   error('curvefit:predint:invalidConfLevel', ...
         'Confidence level must be between 0 and 1.');
end

if nargin<4
   intopt = 'observation';
else
   okval = {'observation' 'functional'};
   j = strmatch(lower(intopt),okval);
   if length(j)~=1
      error('curvefit:predint:invalidINTOPTArg', ...
            'Invalid value for INTOPT argument.');
   else
      intopt = okval{j};
   end
end

if nargin<5
   simopt = 'off';
else
   okval = {'on' 'off'};
   j = strmatch(lower(simopt),okval);
   if length(j)~=1
      error('curvefit:predint:invalidSIMOPTArg',...
            'Invalid value for SIMOPT argument.');
   else
      simopt = okval{j};
   end
end

sse = fun.sse;
dfe = fun.dfe;
Rinv = fun.rinv;
activebounds = fun.activebounds;

if dfe==0
   error('curvefit:predint:cannotComputeConfInts', ...
     'Cannot compute confidence intervals if #observations=#coefficients.');
end

% Make sure x is a column vector
x = x(:);

if isempty(x)
   ypred = zeros(0,1);
   ci = zeros(0,2);
   return
end

% Get the predicted value, and if possible compute the derivative
% w.r.t. parameters at the current parameter values and at x
jac = [];
ypred = [];
if isequal(category(fun),'library')
   try
      [ypred,jac] = feval(fun,x);
   catch
   end
end
if isempty(ypred)
   ypred = feval(fun, x);
end

% Compute the Jacobian numerically if necessary
beta = cat(1,fun.coeffValues{:})';
p = length(beta);
if isempty(jac)
   fun2 = fun;
   jac = zeros(length(x),p);
   seps = sqrt(eps);
   for i = 1:p
      bi = beta(i);
      if (bi == 0)
         nb = sqrt(norm(beta));
         change = seps * (nb + (nb==0));
      else
         change = seps * bi;
      end
      fun2.coeffValues{i} = bi + change;
      predplus = feval(fun2, x);
      fun2.coeffValues{i} = bi - change;
      predminus = feval(fun2, x);
      jac(:,i) = (predplus - predminus)/(2*change);
      fun2.coeffValues{i} = bi;
   end
end

jac = jac(:,~activebounds);
E = jac*Rinv;

if isequal(intopt,'observation')
   delta = sqrt(1 + sum(E.*E,2));
else
   delta = sqrt(sum(E.*E,2));
end   

rmse = sqrt(sse/dfe);

% Calculate confidence interval
if isequal(simopt,'on')
   crit = sqrt(p * cffinv(level, p, dfe));
else
   crit = -cftinv((1-level)/2,dfe);
end

delta = delta .* rmse * crit;
ci = [ypred-delta ypred+delta];
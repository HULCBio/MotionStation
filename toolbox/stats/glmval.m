function [yhat,dylo,dyhi]=glmval(beta,x,link,stats,clev,N,offset,const)
%GLMVAL   Compute fitted values for generalized linear model
%   YHAT=GLMVAL(BETA,X,LINK) computes the fitted values for the
%   generalized linear model with link function LINK and predictor
%   values X.  BETA is a vector of coefficient estimates as
%   returned by the GLMFIT function.  LINK can be any of the link
%   function specifications acceptable to the GLMFIT function.
%
%   [YHAT,DYLO,DYHI] = GLMVAL(BETA,X,LINK,STATS,CLEV) also computes
%   confidence bounds on the predicted Y values.  STATS is the stats
%   structure returned by GLMFIT.  DYLO and DYHI define a lower
%   confidence bound of YHAT-DYLO and an upper confidence bounds of
%   YHAT+DYHI.  CLEV is the confidence level (default 0.95 for 95%
%   confidence bounds).  Confidence bounds are non-simultaneous and
%   they apply to the fitted curve, not to a new observation.
%
%   [YHAT,DYLO,DYHI] = GLMVAL(BETA,X,LINK,STATS,CLEV,N,OFFSET,CONST)
%   specifies additional options through optional arguments.  N is the
%   value of the binomial N parameter if the distribution used with
%   GLMFIT was binomial, or an empty array for other distributions.
%   OFFSET is a vector of offset values if you supplied an offset
%   argument to GLMFIT, or an empty array if no offset was used.
%   CONST is 'on' if the fit included a constant term or 'off' if it
%   did not.
%
%   See also GLMFIT.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.5.4.2 $  $Date: 2004/01/16 20:09:24 $

% Supply default values for missing inputs
if (nargin<3)
   error('stats:glmval:TooFewInputs','At least two arguments are required');
end
if (nargout>1 & nargin<4)
   error('stats:glmval:TooFewInputs',...
         'Must supply 4 arguments to compute confidence bounds');
end

if (nargin<4 | isempty(stats)),    stats = []; end
if (nargin<5 | isempty(clev)),     clev = 0.95; end
if (nargin<6 | isempty(N)),        N = 1; end
if (nargin<7 | isempty(offset)),   offset = 0; end
if (nargin<8 | isempty(const)),    const = 'on'; end
isconst = isequal(const,'on');

% Make sure link function is valid
[emsg,link,dlink,ilink,exponent] = stattestlink(link);
if ~isempty(emsg)
   error('stats:glmval:BadLink',emsg);
end

% Should X be changed to a column vector?
if (size(x,1)==1)
   if (length(beta)==2 & isconst) | (length(beta)==1 & ~isconst)
      x = x';
   end
end

% Add constant column to X matrix, compute linear combination, and
% use the inverse link function to get a predicted value
if (isconst), x = [ones(size(x,1),1) x]; end
eta = x*beta + offset;
yhat = N .* statglmeval('eval',ilink,eta,exponent{:});

% Return bounds if requested
if (nargout>1)
   se = stats.se(:);
   cc = stats.coeffcorr;
   p = length(se);
   V = se * se' .* cc;
   [R,z] = chol(V);
   vxb = sum((R * x').^2);
   if (stats.estdisp)
      crit = tinv((1+clev)/2, stats.dfe);
   else
      crit = norminv((1+clev)/2);
   end
   dxb = crit * sqrt(vxb(:));
   if (length(N)==1), N = repmat(N, size(eta)); end
   tmp = [N N] .* statglmeval('eval',ilink,[eta-dxb eta+dxb],exponent{:});
   dylo = yhat - min(tmp,[],2);
   dyhi = max(tmp,[],2) - yhat;
end

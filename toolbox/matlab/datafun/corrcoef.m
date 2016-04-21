function [r,p,rlo,rup] = corrcoef(x,varargin)
%CORRCOEF Correlation coefficients.
%   R=CORRCOEF(X) calculates a matrix R of correlation coefficients for
%   an array X, in which each row is an observation and each column is a
%   variable.
%
%   R=CORRCOEF(X,Y), where X and Y are column vectors, is the same as
%   R=CORRCOEF([X Y]).
%   
%   If C is the covariance matrix, C = COV(X), then CORRCOEF(X) is
%   the matrix whose (i,j)'th element is
%
%          C(i,j)/SQRT(C(i,i)*C(j,j)).
%
%   [R,P]=CORRCOEF(...) also returns P, a matrix of p-values for testing
%   the hypothesis of no correlation.  Each p-value is the probability
%   of getting a correlation as large as the observed value by random
%   chance, when the true correlation is zero.  If P(i,j) is small, say
%   less than 0.05, then the correlation R(i,j) is significant.
%
%   [R,P,RLO,RUP]=CORRCOEF(...) also returns matrices RLO and RUP, of
%   the same size as R, containing lower and upper bounds for a 95%
%   confidence interval for each coefficient.
%
%   [...]=CORRCOEF(...,'PARAM1',VAL1,'PARAM2',VAL2,...) specifies additional
%   parameters and their values.  Valid parameters are the following:
% 
%       Parameter  Value
%       'alpha'    A number between 0 and 1 to specify a confidence
%                  level of 100*(1-ALPHA)%.  Default is 0.05 for 95%
%                  confidence intervals.
%       'rows'     Either 'all' (default) to use all rows, 'complete' to
%                  use rows with no NaN values, or 'pairwise' to compute
%                  R(i,j) using rows with no NaN values in column i or j.
%
%   The p-value is computed by transforming the correlation to create a t
%   statistic having N-2 degrees of freedom, where N is the number of rows
%   of X.  The confidence bounds are based on an asymptotic normal
%   distribution of 0.5*log((1+R)/(1-R)), with an approximate variance equal
%   to 1/(N-3).  These bounds are accurate for large samples when X has a
%   multivariate normal distribution.  The 'pairwise' option can produce
%   an R matrix that is not positive definite.
%
%   Example:  Generate random data having correlation between column 4
%             and the other columns.
%       x = randn(30,4);       % uncorrelated data
%       x(:,4) = sum(x,2);     % introduce correlation
%       [r,p] = corrcoef(x)    % compute sample correlation and p-values
%       [i,j] = find(p<0.05);  % find significant correlations
%       [i,j]                  % display their (row,col) indices
%
%   Class support for inputs X,Y:
%      float: double, single
%
%   See also COV, STD.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.11.4.4 $  $Date: 2004/03/09 16:16:11 $

if nargin<1
   error('MATLAB:corrcoef:NotEnoughInputs', 'Not enough input arguments.');
end
if length(varargin)>0 && isnumeric(varargin{1})
   y = varargin{1};
   varargin(1) = [];

   % Two inputs, convert to equivalent single input
   x = x(:);
   y = y(:);
   if length(x)~=length(y)
      error('MATLAB:corrcoef:XYmismatch', 'The lengths of X and Y must match.');
   end
   x = [x y];
elseif ndims(x)>2
   error('MATLAB:corrcoef:InputDim', 'Inputs must be 2-D.');
end

% Quickly dispose of most common case
if nargout<=1 && isempty(varargin) && (size(x,2)>0 || size(x,1)<=1)
   r = correl(x);
   return
end

if ~isreal(x) && nargout>1
   error('MATLAB:corrcoef:ComplexInputs',...
         'Cannot compute p-values for complex inputs.');
end

% Process parameter name/value inputs
[alpha,userows,emsg] = getparams(varargin{:});
error(emsg);

% Deal with degenerate inputs
[n,m] = size(x);
if m<=1 || n<=1
   if n==1, x=x'; [n,m] = size(x); end
   if n<=1 || m==0
      r = NaN(m,m,class(x));
      p = r; rlo = r; rup = r;
   else
      r = ones(m,class(x));
      p = r; rlo = r; rup = r;
   end
   return
end

% Compute covariance matrix
t = isnan(x);
if isequal(userows,'all')
   somenan = 0;
else
   somenan = any(any(t));
end
if ~somenan || ~isequal(userows,'pairwise')
   % Remove observations with any missing values
   if somenan && isequal(userows,'complete')
      t = ~any(t,2);
      x = x(t,:);
   end
   
   % Subfunction computes correlation
   [r,n] = correl(x);
else
   % Compute correlation for each pair
   r = eye(m,class(x));
   n = diag(sum(t,1));
   kj = 1:2;
   for j = 2:m
      kj(2) = j;
      for k=1:j-1
         kj(1) = k;
         tjk = ~any(t(:,kj),2);
         njk = sum(tjk);
         if njk<=1
            rjk = NaN;
         else
            rjk = correl(x(tjk,kj));
            rjk = rjk(1,2);
         end
         r(j,k) = rjk;
         r(k,j) = rjk;
         n(j,k) = njk;
         n(k,j) = njk;
      end
   end
end

% Compute p-value if requested
if nargout>=2
   % Operate on half of symmetric matrix
   lowerhalf = (tril(ones(m),-1)>0);
   rv = r(lowerhalf)';
   lhsize = size(rv);
   nv = n;
   if length(n)>1, nv = nv(lowerhalf)'; end

   % Tstat=Inf and p=0 if abs(r)==1
   denom = (1 - rv.^2);
   Tstat = Inf + zeros(size(rv));
   Tstat(rv<0) = -Inf;
   
   t = denom>0;
   rv = rv(t);
   if length(n)>1
      nvt = nv(t);
   else
      nvt = nv;
   end
   Tstat(t) = rv .* sqrt((nvt-2) ./ denom(t));
   p = zeros(m,class(x));
   
   p(lowerhalf) = 2*tpvalue(-abs(Tstat),nv-2);
   p = p + p' + eye(m,class(x));
   risnan = isnan(r);
   p(risnan) = NaN;
   if nargout>=3
      % Compute confidence bound if requested
      z = NaN(lhsize,class(x));
      z(t) = 0.5 * log((1+rv)./(1-rv));
      zalpha = NaN(size(nv),class(x));
      if any(nv>3)
         zalpha(nv>3) = (-erfinv(alpha - 1)) .* sqrt(2) ./ sqrt(nv(nv>3)-3);
      end
      rlo = zeros(m,class(x));
      rlo(lowerhalf) = tanh(z-zalpha);
      rlo = rlo + rlo' + eye(m,class(x));
      rup = zeros(m,class(x));
      rup(lowerhalf) = tanh(z+zalpha);
      rup = rup + rup' + eye(m,class(x));
      
      rlo(risnan) = NaN;
      rup(risnan) = NaN;
   end
end


% ------------------------------------------------
function [r,n] = correl(x)
%CORREL Compute correlation matrix without error checking.

n = size(x,1);
c = cov(x);
d = diag(c);
r = c./sqrt(d*d');

% ------------------------------------------------
function p = tpvalue(x,v)
%TPVALUE Compute p-value for t statistic

normcutoff = 1e7;
if length(x)~=1 && length(v)==1
   v = repmat(v,size(x));
end

% Initialize P to zero.
p=zeros(size(x));

% use special cases for some specific values of v
k = find(v==1);
if any(k)
    p(k) = .5 + atan(x(k))/pi;
end
k = find(v>=normcutoff);
if any(k)
    p(k) = 0.5 * erfc(-x(k) ./ sqrt(2));
end

% See Abramowitz and Stegun, formulas 26.5.27 and 26.7.1
k = find(x ~= 0 & v ~= 1 & v > 0 & v < normcutoff);
if any(k),                            % first compute F(-|x|)
    xx = v(k) ./ (v(k) + x(k).^2);
    p(k) = betainc(xx, v(k)/2, 0.5)/2;
end

% Adjust for x>0.  Right now p<0.5, so this is numerically safe.
k = find(x > 0 & v ~= 1 & v > 0 & v < normcutoff);
if any(k), p(k) = 1 - p(k); end

p(x == 0 & v ~= 1 & v > 0) = 0.5;

% Return NaN for invalid inputs.
p(v <= 0 | isnan(x) | isnan(v)) = NaN;

% -----------------------------------------------
function [alpha,userows,emsg] = getparams(varargin)
%GETPARAMS Process input parameters for CORRCOEF
alpha = 0.05;
userows = 'all';
emsg = '';
while(length(varargin)>0)
   if length(varargin)==1
      emsg = 'Unmatched parameter name/value pair.';
      return
   end
   pname = varargin{1};
   if ~ischar(pname)
      emsg = 'Invalid argument name.';
      return
   end
   pval = varargin{2};
   j = strmatch(pname, {'alpha' 'rows'});
   if isempty(j)
      emsg = sprintf('Invalid argument name ''%s''.',pname);
      return
   end
   if j==1
      alpha = pval;
   else
      userows = pval;
   end
   varargin(1:2) = [];
end

% Check for valid inputs
if ~isnumeric(alpha) || ~isscalar(alpha) || alpha<=0 || alpha>=1
   emsg = 'The ''alpha'' parameter must be a scalar between 0 and 1.';
end
oktypes = {'all' 'complete' 'pairwise'};
if isempty(userows) || ~ischar(userows)
   i = [];
else
   i = strmatch(lower(userows), oktypes);
end
if isempty(i)
   emsg = 'Valid row choices are ''all'', ''complete'', and ''pairwise''.';
end
userows = oktypes{i};

function [p, h, stats] = signtest(x,y,varargin)
%SIGNTEST Sign test for zero median.
%   P = SIGNTEST(X) performs a two-sided sign test of the hypothesis that
%   the data in the vector X come from a distribution whose median is zero,
%   and returns the p-value from the test.  P is the probability of
%   observing the given result, or one more extreme, by chance if the null
%   hypothesis ("median is zero") is true.  Small values of P cast doubt
%   on the validity of the null hypothesis.  The data are assumed to come
%   from an arbitrary continuous distribution.
%
%   P = SIGNTEST(X,M) performs a two-sided test of the hypothesis that the
%   data in the vector X come from a distribution whose median is M.  M
%   must be a scalar.
%
%   P = SIGNTEST(X,Y) performs a paired, two-sided test of the hypothesis
%   that the difference between the matched samples in the vectors X and
%   Y comes from a distribution whose median is zero.  The differences X-Y
%   are assumed to come from an arbitrary continuous distribution.  X and Y
%   must be the same length.  The two-sided p-value is computed by doubling
%   the most significant one-sided value.
%
%   [P,H] = SIGNTEST(...) returns the result of the hypothesis test,
%   performed at the 0.05 significance level, in H.  H==0 indicates that
%   the null hypothesis ("median is zero") cannot be rejected at the 5%
%   level. H==1 indicates that the null hypothesis can be rejected at the
%   5% level.
%
%   [P,H] = SIGNTEST(...,'alpha',ALPHA) returns the result of the hypothesis
%   test performed at the significance level ALPHA.
%
%   [P,H] = SIGNTEST(...,'method',METHOD) computes the p-value using an
%   exact algorithm if METHOD is 'exact', or a normal approximation if
%   METHOD is 'approximate'.  The default is to use an exact method for
%   small samples.
%
%   [P,H,STATS] = SIGNTEST(...) returns STATS, a structure with one or two
%   fields.  The field 'sign' contains the value of the sign statistic.
%   If P is calculated using a normal approximation, then the field 'zval'
%   contains the value of the normal (Z) statistic.
%
%   See also SIGNRANK, RANKSUM, TTEST, ZTEST.

%   References:
%      [1] Hollander, M. and D. A. Wolfe.  Nonparametric Statistical
%          Methods. Wiley, 1973.
%      [2] Gibbons, J.D.  Nonparametric Statistical Inference,
%          2nd ed.  M. Dekker, 1985.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.14.4.3 $  $Date: 2003/11/24 23:24:44 $

% Check most of the inputs now
alpha = 0.05;
if nargin>2 && isnumeric(varargin{1})
   % Grandfathered syntax:  signtest(x,y,alpha)
   alpha = varargin{1};
   varargin(1) = [];
end
oknames = {'alpha' 'method'};
dflts   = {alpha   ''};
[eid,emsg,alpha,method] = statgetargs(oknames,dflts,varargin{:});
if ~isempty(eid)
   error(sprintf('stats:signtest:%s',eid),emsg);
end

if ~isscalar(alpha)
   error('stats:signtest:BadAlpha','SIGNRANK requires a scalar ALPHA value.');
end
if ~isnumeric(alpha) || isnan(alpha) || (alpha <= 0) || (alpha >= 1)
   error('stats:signtest:BadAlpha','SIGNRANK requires 0 < ALPHA < 1.');
end

if nargin < 2 || isempty(y)
    y = zeros(size(x));
elseif isscalar(y)
    y = repmat(y, size(x));
end

if ~isvector(x) || ~isvector(y)
    error('stats:signtest:InvalidData',...
          'SIGNTEST requires vector rather than matrix data.');
elseif numel(x) ~= numel(y)
    error('stats:signtest:InputSizeMismatch',...
    'SIGNTEST requires the data vectors to have the same number of elements.');
end

diffxy = x(:) - y(:);
nodiff = find(diffxy == 0);
diffxy(nodiff) = [];
n = numel(diffxy);

if n == 0 % this means the two vectors are identical
    p = 1;
    if nargout == 2
        h = (p<alpha);
    end
    return
end

% Now deal with the method argument
if isempty(method)
   if n<100
      method = 'exact';
   else
      method = 'approximate';
   end
elseif ischar(method)
   okmethods = {'exact' 'approximate'};
   j = strmatch(lower(method),okmethods);
   if isempty(j)
      error('stats:signrank:BadMethod',...
            'METHOD must be ''exact'' or ''approximate''.');
   end
   method = okmethods{j};
else
   error('stats:signrank:BadMethod',...
         'METHOD must be ''exact'' or ''approximate''.');
end

npos = length(find(diffxy>0));
nneg = n-npos;
sgn = min(nneg,npos);

if isequal(method,'exact')
    p = min(1, 2*binocdf(sgn,n,0.5));  % p>1 means center value double-counted
else
    % Do a continuity correction, keeping in mind the right direction
    z = (npos-nneg - sign(npos-nneg))/sqrt(n);
    p = 2*normcdf(-abs(z),0,1);
    if (nargout > 2)
        stats.zval = z;
    end
end

if nargout > 1
    h = (p<=alpha);
    if (nargout > 2)
        stats.sign = sgn;
    end
end

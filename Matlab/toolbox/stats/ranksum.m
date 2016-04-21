function [p, h, stats] = ranksum(x,y,varargin)
%RANKSUM Wilcoxon rank sum test for equal medians.
%   P = RANKSUM(X,Y) performs a two-sided rank sum test of the hypothesis
%   that two independent samples, in the vectors X and Y, come from
%   distributions with equal medians, and returns the p-value from the
%   test.  P is the probability of observing the given result, or one more
%   extreme, by chance if the null hypothesis ("medians are equal") is
%   true.  Small values of P cast doubt on the validity of the null
%   hypothesis.  The two sets of data are assumed to come from continuous
%   distributions that are identical except possibly for a location shift,
%   but are otherwise arbitrary.  X and Y can be different lengths.
%   The two-sided p-value is computed by doubling the most significant
%   one-sided value.
%
%   The Wilcoxon rank sum test is equivalent to the Mann-Whitney U test.
%
%   [P,H] = RANKSUM(...) returns the result of the hypothesis test,
%   performed at the 0.05 significance level, in H.  H==0 indicates that
%   the null hypothesis ("medians are equal") cannot be rejected at the 5%
%   level. H==1 indicates that the null hypothesis can be rejected at the
%   5% level.
%
%   [P,H] = RANKSUM(...,'alpha',ALPHA) returns the result of the hypothesis
%   test performed at the significance level ALPHA.
%
%   [P,H] = RANKSUM(...,'method',M) computes the p-value exactly if M is
%   'exact', or uses a normal approximation if M is 'approximate'.  If you
%   omit this argument, RANKSUM uses the exact method for small samples and
%   the approximate method for larger samples.
%
%   [P,H,STATS] = RANKSUM(...) returns STATS, a structure with one or two
%   fields.  The field 'ranksum' contains the value of the rank sum
%   statistic.  For the 'approximate' method, the field 'zval' contains the
%   value of the normal (Z) statistic.
%
%   See also SIGNTEST, SIGNRANK, KRUSKALWALLIS, TTEST2.

%   References:
%      [1] Hollander, M. and D. A. Wolfe.  Nonparametric Statistical
%          Methods. Wiley, 1973.
%      [2] Gibbons, J.D.  Nonparametric Statistical Inference,
%          2nd ed.  M. Dekker, 1985.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.14.4.3 $

% Check most of the inputs now
alpha = 0.05;
if nargin>2 && isnumeric(varargin{1})
   % Grandfathered syntax:  ranksum(x,y,alpha)
   alpha = varargin{1};
   varargin(1) = [];
end
oknames = {'alpha' 'method'};
dflts   = {alpha   ''};
[eid,emsg,alpha,method] = statgetargs(oknames,dflts,varargin{:});
if ~isempty(eid)
   error(sprintf('stats:ranksum:%s',eid),emsg);
end

if ~isscalar(alpha)
   error('stats:ranksum:BadAlpha','RANKSUM requires a scalar ALPHA value.');
end
if ~isnumeric(alpha) || isnan(alpha) || (alpha <= 0) || (alpha >= 1)
   error('stats:ranksum:BadAlpha','RANKSUM requires 0 < ALPHA < 1.');
end

% Get the samples and their sizes, find the larger sample
if ~isvector(x) || ~isvector(y)
   error('stats:ranksum:InvalidData',...
         'RANKSUM requires vector rather than matrix data.');
end
x = x(:);
y = y(:);
nx = numel(x);
ny = numel(y);
if nx <= ny
   smsample = x;
   lgsample = y;
   ns = nx;
else
   smsample = y;
   lgsample = x;
   ns = ny;
end

% Now deal with the method argument
if isempty(method)
   if ns<10 && (nx+ny)<20
      method = 'exact';
   else
      method = 'approximate';
   end
elseif ischar(method)
   okmethods = {'exact' 'approximate' 'oldexact'};
   j = strmatch(lower(method),okmethods);
   if isempty(j)
      error('stats:ranksum:BadMethod',...
            'METHOD must be ''exact'' or ''approximate''.');
   end
   method = okmethods{j};
else
   error('stats:ranksum:BadMethod',...
         'METHOD must be ''exact'' or ''approximate''.');
end

% Compute the rank sum statistic based on the smaller sample
[ranks, tieadj] = tiedrank([smsample; lgsample]);
xrank = ranks(1:ns);
w = sum(xrank);

wmean = ns*(nx + ny + 1)/2;
if ~isequal(method,'approximate')    % use the sampling distribution of W
   if nx+ny<=10 || isequal(method,'oldexact')
      % For small samples, enumerate all possibilities, find smaller tail prob
      allpos = nchoosek(ranks,ns);
      sumranks = sum(allpos,2);
      np = length(sumranks);
      plo = sum(sumranks<=w)/np;
      phi = sum(sumranks>=w)/np;
      p = min(plo,phi);
   else
      % Use a network algorithm for larger samples
      p = exactprob(smsample,lgsample,w);
   end
   
   p = min(2*p, 1);           % 2-sided, p>1 means the middle is double-counted
   
else                          % use the normal approximation
   tiescor = 2 * tieadj / ((nx+ny) * (nx+ny-1));
   wvar  = nx*ny*((nx + ny + 1) - tiescor)/12;
   wc = w - wmean;
   z = (wc - 0.5 * sign(wc))/sqrt(wvar);
   p = normcdf(z,0,1);
   p = 2*min(p,1-p);
   if (nargout > 2)
      stats.zval = z;
   end
end

if nargout > 1,
   h = (p<=alpha);
   if (nargout > 2)
      stats.ranksum = w;
   end
end

% --------------------------------------------------------------
function p = exactprob(x,y,w)
%EXACTPROB Exact P-values for Wilcoxon Mann Whitney nonparametric test
%   P=EXACTPROB(X,Y,W) computes the p-value P for the test statistic W
%   in a Wilcoxon-Mann-Whitney nonparametric test of the hypothesis that
%   X and Y come from distributions with equal medians.

% Create a contingency table with element (i,j) indicating how many
% times u(j) appears in sample i
u = unique([x(:); y(:)]);
t = zeros(2,length(u));
t(1,:) = histc(x,u)';
t(2,:) = histc(y,u)';

% Compute weights for wmw test
colsum = sum(t,1);
tmp = cumsum(colsum);
wts = [0 tmp(1:end-1)] + .5*(1+diff([0 tmp]));

% Compute p-value using network algorithm for contingency tables
p = statctexact(t,wts,w);

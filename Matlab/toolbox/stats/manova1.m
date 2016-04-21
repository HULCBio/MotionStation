function [d, p, stats] = manova1(x,group,alpha)
%MANOVA1 One-way multivariate analysis of variance (MANOVA).
%   D = MANOVA1(X,GROUP,ALPHA) performs a one-way MANOVA for comparing
%   the mean vectors of two or more groups of multivariate data.
%
%   X is a matrix with each row representing a multivariate
%   observation, and each column representing a variable.
%
%   GROUP is a vector of the same length as X, or a string array or
%   cell array of strings with the same number of rows as X.  X values
%   are in the same group if they correspond to the same value of GROUP.
%
%   ALPHA is the scalar significance level and is 0.05 by default.
%
%   D is an estimate of the dimension of the group means.  It is the
%   smallest dimension such that a test of the hypothesis that the
%   means lie on a space of that dimension is not rejected.  If D=0
%   for example, we cannot reject the hypothesis that the means are
%   the same.  If D=1, we reject the hypothesis that the means are the
%   same but we cannot reject the hypothesis that they lie on a line.
%
%   [D,P] = MANOVA1(...) returns P, a vector of p-values for testing
%   the null hypothesis that the mean vectors of the groups lie on
%   various dimensions.  P(1) is the p-value for a test of dimension
%   0, p(2) for dimension 1, etc.
%
%   [D,P,STATS] = MANOVA1(...) returns a STATS structure with the
%   following fields:
%       W        within-group sum of squares and cross-products
%       B        between-group sum of squares and cross-products
%       T        total sum of squares and cross-products
%       dfW      degrees of freedom for W
%       dfB      degrees of freedom for B
%       dfT      degrees of freedom for T
%       lambda   value of Wilk's lambda (the test statistic)
%       chisq    transformation of lambda to a chi-square distribution
%       chisqdf  degrees of freedom for chisq
%       eigenval eigenvalues of (W^-1)*B
%       eigenvec eigenvectors of (W^-1)*B; these are the coefficients
%                for canonical variables, and they are scaled
%                so the within-group variance of C is 1
%       canon    canonical variables, equal to XC*eigenvec, where XC is
%                X with columns centered by subtracting their means
%       mdist    Mahalanobis distance from each point to its group mean
%       gmdist   Mahalanobis distances between each pair of group means
%
%   The canonical variables C have the property that C(:,1) is the
%   linear combination of the X columns that has the maximum
%   separation between groups, C(:,2) has the maximum separation
%   subject to it being orthogonal to C(:,1), and so on.
%
%   See also ANOVA1, GPLOTMATRIX, GSCATTER.

% References:
%    Krzanowski, W.J. (1988), "Prinicples of Multivariate Analysis," 
%       Oxford University Press, Oxford.
%    Manly, B.F.J. (1990), "Multivariate Statistical Methods:
%       A Primer," Wiley, London
%    Mardia, K.V., J.T. Kent, and J.M. Bibby (1979), "Multivariate
%       Analysis," Academic Press, London.
%    Morrison, D.F. (1976), "Multivariate Statistical Methods,"
%       McGraw-Hill, New York.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.7.2.2 $  $Date: 2004/01/16 20:09:37 $

error(nargchk(2,3,nargin,'struct'));
if (nargin < 3)
   alpha = 0.05;
end
if (length(alpha) > 1)
   error('stats:manova1:BadAlpha','ALPHA must be a scalar.');
end
if ((alpha <= 0) | (alpha >= 1))
   error('stats:manova1:BadAlpha',...
         'Significance level must satisfy 0 < ALPHA < 1.')
end

% Convert group to cell array from character array, make it a column
if (ischar(group)), group = cellstr(group); end
if (size(group, 1) == 1), group = group'; end

% Make sure inputs have the correct size
n = size(x,1);
if (size(group,1) ~= n)
   error('stats:manova1:InputSizeMismatch',...
         'Dimensions of X and GROUP must match.');
end

% Remove missing X columns first in case this eliminates a group
nonan = (sum(isnan(x), 2) == 0);
x = x(nonan,:);
group = group(nonan,:);
wasnan = ~nonan;

% Convert group to indices 1,...,g and separate names
[groupnum, gnames] = grp2idx(group);
g = max(groupnum);

% Remove NaN values again
nonan = ~isnan(groupnum);
if (~all(nonan))
   groupnum = groupnum(nonan);
   x = x(nonan,:);
   wasnan(~wasnan) = ~nonan;
end
[n,m] = size(x);

% Start by computing the Total sum of squares matrix
xm = mean(x);
x = x - xm(ones(n,1),:);       % done with the original x
T = x'*x;

% Now compute the Within sum of squares matrix
W = zeros(size(T));
for j=1:g
   r = find(groupnum == j);
   nr = length(r);
   if (nr > 1)
      z = x(r,:);
      xm = mean(z);
      z = z - xm(ones(nr,1),:);
      W = W + z'*z;
   end
end

% The Between sum of squares matrix is the difference
B = T - W;

% Compute the eigenvalues and eigenvectors of (W^-1)B
% We would like to do something like:
%    [v,ed] = eig(B,W);
% but in order to insure the condition v'*W*v=I we need:
[R,p] = chol(W);
if (p > 0)
   error('stats:manova1:SingularSumSquares',...
         ['The within-group sum of squares and cross products matrix' ...
          ' is singular.']);
end
S = R' \ B / R;
S = (S+S')/2;     % remove asymmetry caused by roundoff
[vv,ed] = eig(S);
v = R\vv;

[e,ei] = sort(diag(ed));            % put in descending order

% Compute Barlett's statistic for each dimension
if (min(e) <= -1)             % should not happen
   error('stats:manova1:SingularSumSquares',...
         'Error computing Bartlett''s statistic.');
end
dims = 0:(min(g-1, m)-1);     % testable dimensions
lambda = flipud(1 ./ cumprod(e+1));
lambda = lambda(1+dims);
chistat = -(n-1-(g+m)/2) .* log(lambda);
chisqdf = ((m - dims) .* (g - 1 - dims))';
pp = 1-chi2cdf(chistat, chisqdf);

% Pick off the first acceptable dimension
d = dims(pp>alpha);
if (length(d) > 0)
   d = d(1);
else
   d = max(dims) + 1;
end

% If required, create extra outputs
if (nargout > 1), p = pp; end
if (nargout > 2)
   stats.W = W;
   stats.B = B;
   stats.T = T;
   stats.dfW = n-g;
   stats.dfB = g-1;
   stats.dfT = n-1;
   stats.lambda = lambda;
   stats.chisq = chistat;
   stats.chisqdf = chisqdf;
   stats.eigenval = flipud(e);         % order is now increasing
   
   % Need to re-scale eigenvectors so the within-group variance is 1
   v = v(:,flipud(ei));                % in order of increasing e
   vs = diag((v' * W * v))' ./ (n-g);
   vs(vs<=0) = 1;
   v = v ./ repmat(sqrt(vs), size(v,1), 1);
   
   % Flip sign so that the average element is positive
   j = (sum(v) < 0);
   v(:,j) = -v(:,j);
   stats.eigenvec = v;
   canon = x*v;
   if (any(wasnan))
      tmp(~wasnan,:) = canon;
      tmp(wasnan,:) = NaN;
      stats.canon = tmp;
   else
      stats.canon = canon;
   end
   
   % Compute Mahalanobis distances from points to group means
   gmean = grpstats(canon, groupnum);
   mdist = sum((canon - gmean(groupnum,:)).^2, 2);
   if (any(wasnan))
      stats.mdist(~wasnan) = mdist;
      stats.mdist(wasnan) = NaN;
   else
      stats.mdist = mdist;
   end
   
   % Compute Mahalanobis distances between group means
   stats.gmdist = squareform(pdist(gmean)).^2;
   stats.gnames = gnames;
end


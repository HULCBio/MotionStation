function [coef, pval] = corr(x, varargin)
%CORR Linear or rank correlation.
%   RHO = CORR(X) returns a P-by-P matrix containing the pairwise linear
%   correlation coefficient between each pair of columns in the N-by-P
%   matrix X.
%
%   RHO = CORR(X,Y,...) returns a P1-by-P2 matrix containing the pairwise
%   correlation coefficient between each pair of columns in the N-by-P1 and
%   N-by-P2 matrices X and Y.
%
%   [RHO,PVAL] = CORR(...) also returns PVAL, a matrix of p-values for
%   testing the hypothesis of no correlation against the alternative that
%   there is a non-zero correlation.  Each element of PVAL is the p-value
%   for the corresponding element of RHO.  If PVAL(i,j) is small, say less
%   than 0.05, then the correlation RHO(i,j) is significantly different
%   from zero.
%
%   [...] = CORR(...,'PARAM1',VAL1,'PARAM2',VAL2,...) specifies additional
%   parameters and their values.  Valid parameters are the following:
%
%        Parameter  Value
%         'type'    'Pearson' (the default) to compute Pearson's linear
%                   correlation coefficient, 'Kendall' to compute Kendall's
%                   tau, or 'Spearman' to compute Spearman's rho.
%         'rows'    'all' (default) to use all rows regardless of missing
%                   values (NaNs), 'complete' to use only rows with no
%                   missing values, or 'pairwise' to compute RHO(i,j) using
%                   rows with no missing values in column i or j.
%         'tail'    The alternative hypothesis against which to compute
%                   p-values for testing the hypothesis of no correlation.
%                   Choices are:
%                      TAIL         Alternative Hypothesis
%                   ---------------------------------------------------
%                      'ne'       correlation is not zero (the default)
%                      'gt'       correlation is greater than zero
%                      'lt'       correlation is less than zero
%
%   The 'pairwise' option for the 'rows' parameter can produce CORR(X) that
%   is not positive definite.  The 'complete' option always produces a
%   positive definite CORR(X), but in general the estimates will be based
%   on fewer observations.
%
%   CORR computes p-values for Pearson's correlation using a Student's t
%   distribution for a transformation of the correlation.  This is exact
%   when X and Y are normal.  CORR computes p-values for Kendall's tau and
%   Spearman's rho using either the exact permutation distributions (for
%   small sample sizes), or large-sample approximations.
%
%   CORR computes p-values for the two-tailed test by doubling the more
%   significant of the two one-tailed p-values.
%
%   See also CORRCOEF, TIEDRANK.

%   References:
%      [1] Gibbons, J.D. (1985) Nonparametric Statistical Inference,
%          2nd ed., M. Dekker.
%      [2] Hollander, M. and D.A. Wolfe (1973) Nonparametric Statistical
%          Methods, Wiley.
%      [3] Kendall, M.G. (1970) Rank Correlation Methods, Griffin.
%      [4] Best, D.J. and D.E. Roberts (1975) "Algorithm AS 89: The Upper
%          Tail Probabilities of Spearman's rho", Applied Statistics,
%          24:377-379.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/03/02 21:49:06 $

%   Spearman's rho is equivalent to the linear (Pearson's) correlation
%   between ranks.  Kendall's tau is equivalent to the linear correlation
%   between the "concordances" sign(x(i)-x(j))*sign(y(i)-y(j)), i<j, with
%   an adjustment for ties.  This is often referred to as tau-b.
%
%   Kendall's tau-b is identical to the standard tau (or tau-a) when there
%   are no ties.  However, tau-b includes an adjustment for ties in the
%   normalizing constant.

%   Spearman's rho and Kendall's tau are discrete-valued statistics, and
%   their distributions have positive probability at 1 and -1.  For small
%   sample sizes, CORR uses the exact permutation distributions, and thus,
%   the on-diagonal p-values from CORR(X,X) or CORR(X) are not zero.

%   When there are ties in the data, the null distribution of Spearman's
%   rho and Kendall's tau may not be symmetric.  Computing a two-tailed
%   p-value in such cases is not well-defined.  CORR computes p-values for
%   the two-tailed test by doubling the smaller of the one-tailed p-values.

if nargin < 1 || isempty(x)
    error('stats:corr:TooFewInputs', ...
          'Requires a data matrix X.');
end
[n,p1] = size(x);

% Only x given, compute pairwise rank correlations
if (nargin < 2) || ischar(varargin{1})
    corrXX = true;
    y = x;
    p2 = p1;

% Both x and y given, compute the pairwise rank cross correlations
else
    y = varargin{1};
    varargin = varargin(2:end);
    if size(y,1) ~= n
        error('stats:corr:InputSizeMismatch', ...
              'X and Y must have the same number of rows.');
    end
    corrXX = false;
    p2 = size(y,2);
end
if isa(x,'single') | isa(y,'single')
    outClass = 'single';
else
    outClass = 'double';
end

pnames = {'type'  'rows' 'tail'};
dflts  = {'p'     'a'    'ne'};
[errid,errmsg,type,rows,tail] = statgetargs(pnames,dflts,varargin{:});
if ~isempty(errid)
    error(sprintf('stats:corr:%s',errid),errmsg);
end

% Validate the rows parameter, and do some missing data pre-processing.
rowsChoices = {'all' 'complete' 'pairwise'};
if ischar(rows)
    i = strmatch(lower(rows),rowsChoices);
    if isscalar(i)
        rows = rowsChoices{i}(1);
    end
end
switch rows
case 'a' % 'all'
    % Missing values are left in, so all cols have the same length.
    anyRowsRemoved = false;
case 'c' % 'complete'
    ok = ~(any(isnan(x),2) | any(isnan(y),2));
    if ~all(ok)
        x = x(ok,:);
        y = y(ok,:);
        n = sum(ok);
    end
    % Complete rows with missing values are removed, so all cols have the
    % same length.
    anyRowsRemoved = false;
case 'p' % 'pairwise'
    % Missing values are removed pairwise, so each column pair may have a
    % different length, we'll have to see.
otherwise
    error('stats:corr:UnknownRows', ...
          'The ''rows'' parameter value must be ''all'', ''complete'', or ''pairwise''.');
end

% Can't do anything without at least two observations.
if n < 2
    coef = NaN(p1,p2,outClass);
    pval = NaN(p1,p2,outClass);
    return
end
n2const = n*(n-1) ./ 2;
n3const = (n+1)*n*(n-1) ./ 3;

% Validate the type parameter, and set a handle to the cdf function.
typeChoices = {'pearson' 'kendall' 'spearman'};
if ischar(type)
    i = strmatch(lower(type),typeChoices);
    if isscalar(i)
        type = typeChoices{i}(1);
    end
end
switch type
case 'p'
    pvalFun = @pvalPearson;
    pvalArgs = {n};
case 'k'
    stdNoTies = sqrt(n2const * (2*n+5) ./ 9);
    pvalFun = @pvalKendall;
    pvalArgs = {stdNoTies, n};
case 's'
    meanNoTies = n3const ./ 2;
    stdNoTies = n3const ./ (2*sqrt(n-1));
    pvalFun = @pvalSpearman;
    pvalArgs = {meanNoTies, stdNoTies, n};
otherwise
    error('stats:corr:UnknownType', ...
          'The ''type'' parameter value must be ''Pearson'', ''Kendall'', or ''Spearman''.');
end

% Validate the tail parameter.
switch tail
case {'ne' 'gt' 'lt'}
    % these are ok
otherwise
    error('stats:corr:UnknownTail', ...
          'The ''tail'' parameter value must be ''ne'', ''gt'', or ''lt''.');
end

% Preallocate the outputs.
coef = zeros(p1,p2,outClass);
if nargout > 1
    pval = zeros(p1,p2,outClass);
    stat = zeros(p1,p2,outClass); % save the obs. stat. for p-value computation
    if corrXX
         % Do the upper triangle and diagonal only, we'll reflect into
         % the lower.  Need to do the diagonal explicitly because those
         % p-values will not be zero for Spearman and Kendall when we use
         % the exact dist'n.
         needPVal = triu(true(p1,p2));
    else
         needPVal = true(p1,p2);
    end
end

for i = 1:p1
    % loop from 1:p2 for corr(x,y), from i:p2 for corr(x)
    j0 = 1*(1-corrXX) + i*corrXX;
    for j = j0:p2
        xi = x(:,i);
        yj = y(:,j);

        % Handle missing data.
        switch rows
        case 'a' % all rows
            % missing values create NaN result
            ok = ~(isnan(xi) | isnan(yj));
            % Can't do anything with missing values.
            if ~all(ok)
                coef(i,j) = NaN;
                pval(i,j) = NaN;
                needPVal(i,j) = false;
                continue
            end
        case 'c' % complete rows only
            % x and y have already had missing values removed
        case 'p' % remove missing values pairwise
            ok = ~(isnan(xi) | isnan(yj));
            if ~all(ok)
                xi = xi(ok);
                yj = yj(ok);
                n = sum(ok);
                % Can't do anything without at least two observations.
                if n < 2
                    coef(i,j) = NaN;
                    pval(i,j) = NaN;
                    needPVal(i,j) = false;
                    continue
                end
                n2const = n*(n-1) ./ 2;
                n3const = (n+1)*n*(n-1) ./ 3;
                anyRowsRemoved = true;
            else
                n = numel(ok);
                n2const = n*(n-1) ./ 2;
                n3const = (n+1)*n*(n-1) ./ 3;
                anyRowsRemoved = false;
            end
        end

        % Compute the correlation coefficient.
        switch type
        case 'p' % Pearson's linear correlation
            x0 = xi - mean(xi);
            y0 = yj - mean(yj);
            coef(i,j) = sum(x0.*y0) ./ sqrt(sum(x0.^2) .*sum(y0.^2));

            if nargout > 1
                % Ties in the data are irrelevant for linear correlation.
                % But if there has been pairwise removal of missing data,
                % we'll compute the p-value separately here.  Otherwise,
                % we'll compute it with the rest, later.
                if anyRowsRemoved
                    pval(i,j) = pvalPearson(tail, coef(i,j), n);
                    needPVal(i,j) = false; % this one's done
                else
                    stat(i,j) = coef(i,j);
                end
            end

        case 'k' % Kendall's tau
            [xrank, xadj] = tiedrank(xi,1);
            [yrank, yadj] = tiedrank(yj,1);
            K = 0;
            for k = 1:n-1
                K = K + sum(sign(xi(k)-xi(k+1:n)).*sign(yj(k)-yj(k+1:n)));
            end
            coef(i,j) = K ./ sqrt((n2const - xadj(1)).*(n2const - yadj(1)));
            if nargout > 1
                % If there are ties, or if there has been pairwise removal
                % of missing data, we'll compute the p-value separately here.
                % Otherwise, we'll compute it with the rest, later.
                ties = ((xadj(1)>0) || (yadj(1)>0));
                if ties
                    % The tied case is sufficiently slower that we don't
                    % want to do it if not necessary.
                    stdK = sqrt(n2const*(2*n+5)./9 ...
                                - (xadj(3) + yadj(3))./18 ...
                                + xadj(2)*yadj(2)./(18*n2const*(n-2)) ...
                                + xadj(1)*yadj(1)./n2const);
                    pval(i,j) = pvalKendall(tail, K, stdK, xrank, yrank);
                    needPVal(i,j) = false; % this one's done
                elseif anyRowsRemoved
                    stdK = sqrt(n2const*(2*n+5)./9);
                    pval(i,j) = pvalKendall(tail, K, stdK, n);
                    needPVal(i,j) = false; % this one's done
                else
                    stat(i,j) = K;
                end
            end

        case 's' % Spearman's rank correlation
            [xrank, xadj] = tiedrank(xi,0);
            [yrank, yadj] = tiedrank(yj,0);
            D = sum((xrank - yrank).^2);
            meanD = (n3const - (xadj+yadj)./3) ./ 2;
            stdD = sqrt((n3const./2 - xadj./3)*(n3const./2 - yadj./3)./(n-1));
            coef(i,j) = (meanD - D) ./ (sqrt(n-1)*stdD);
            if nargout > 1
                % If there are ties, or if there has been pairwise removal
                % of missing data, we'll compute the p-value separately here.
                % Otherwise, we'll compute it with the rest, later.
                ties = ((xadj>0) || (yadj>0));
                if (anyRowsRemoved || ties)
                    pval(i,j) = pvalSpearman(tail, D, meanD, stdD, xrank, yrank);
                    needPVal(i,j) = false; % this one's done
                else
                    stat(i,j) = D;
                end
            end
        end
    end
end

% Calculate the p-values of the observed correlations, for the requested
% alternative hypothesis.  Any cases with ties (Kendall's tau and
% Spearman's rho) or pairwise removal of missing data have already been
% computed.  The remaining p-values can be computed based on a single null
% distribution.
if nargout > 1 && any(needPVal(:))
    pval(needPVal) = feval(pvalFun, tail, stat(needPVal), pvalArgs{:});
end

% If this is an autocorrelation, reflect the upper correlations and
% p-values into the lower triangle.  Leave the diagonal alone.
if corrXX
    coef = triu(coef) + triu(coef,1)';
    if nargout > 1
        pval = triu(pval) + triu(pval,1)';
    end
end


%--------------------------------------------------------------------------

function p = pvalPearson(tail, rho, n)
%PVALPEARSON Tail probability for Pearson's linear correlation.
t = sign(rho) .* Inf;
k = (abs(rho) < 1);
t(k) = rho(k).*sqrt((n-2)./(1-rho(k).^2));
switch tail
case 'ne'
    p = 2*tcdf(-abs(t),n-2);
case 'gt'
    p = tcdf(-t,n-2);
case 'lt'
    p = tcdf(t,n-2);
end


%--------------------------------------------------------------------------

function p = pvalKendall(tail, K, stdK, arg1, arg2)
%PVALKENDALL Tail probability for Kendall's K statistic.

% Without ties, K is symmetric about zero, taking on values in
% -n(n-1)/2:2:n(n-1)/2.  With ties, it's still in that range, but not
% symmetric, and can take on adjacent integer values.

if nargin < 5 % pvalKendall(tail, K, stdK, n)
    noties = true;
    n = arg1;
    exact = (n < 50);
else          % pvalKendall(tail, K, stdK, xrank, yrank)
    noties = false;
    xrank = arg1;
    yrank = arg2;
    n = length(xrank);
    exact = (n < 10);
end
nfact = factorial(n);
n2const = n*(n-1)./2;

if exact
    if noties
        % No ties, use recursion to get the cumulative distribution of
        % the number, C, of positive (xi-xj)*(yi-yj), i<j.
        %
        % K = #pos-#neg = C-Q, and C+Q = n(n-1)/2 => C = (K + n(n-1)/2)/2
        freq = [1 1];
        for i = 3:n
            freq = conv(freq,ones(1,i));
        end
        freq = [freq; zeros(1,n2const+1)]; freq = freq(1:end-1)';

    else
        % Ties, take permutations of the midranks.
        %
        % With ties, we could consider only distinguishable permutations
        % (those for which equal ranks (ties) are not simply interchanged),
        % but generating only those is a bit of work.  Generating all
        % permutations uses more memory, but gives the same result.
        xrank = repmat(xrank,nfact,1);
        yrank = perms(yrank);
        Kperm = zeros(nfact,1);
        for k = 1:n-1
            U = sign(repmat(xrank(:,k),1,n-k)-xrank(:,k+1:n));
            V = sign(repmat(yrank(:,k),1,n-k)-yrank(:,k+1:n));
            Kperm = Kperm + sum(U .* V, 2);
        end
        freq = histc(Kperm,-(n2const+.5):(n2const+.5)); freq = freq(1:end-1);
    end

    % Get the tail probabilities.  Reflect as necessary to get the correct
    % tail.
    switch tail
    case 'ne'
        % Use twice the smaller of the tail area above and below the
        % observed value.
        tailProb = min(cumsum(freq), rcumsum(freq,nfact)) ./ nfact;
        tailProb = min(2*tailProb, 1); % don't count the center bin twice
    case 'gt'
        tailProb = rcumsum(freq,nfact) ./ nfact;
    case 'lt'
        tailProb = cumsum(freq) ./ nfact;
    end
    p = tailProb(K + n2const+1); % bins at integers, starting at -n2const

else
    switch tail
    case 'ne'
        p = normcdf(-(abs(K)-1) ./ stdK);
        p = min(2*p, 1); % Don't count continuity correction at center twice
    case 'gt' %
        p = normcdf(-(K-1) ./ stdK);
    case 'lt'
        p = normcdf((K+1) ./ stdK);
    end
end


%--------------------------------------------------------------------------

function p = pvalSpearman(tail, D, meanD, stdD, arg1, arg2)
%PVALSPEARMAN Tail probability for Spearman's D statistic.

% Without ties, D is symmetric about (n^3-n)/6, taking on values
% 0:2:(n^3-n)/3.  With ties, it's still in (but not on) that range, but
% not symmetric, and can take on odd and half-integer values.

if nargin < 6 % pvalSpearman(tail, D, meanD, stdD, n)
    noties = true;
    n = arg1;
else          % pvalSpearman(tail, D, meanD, stdD, xrank, yrank)
    noties = false;
    xrank = arg1;
    yrank = arg2;
    n = length(xrank);
end
exact = (n < 10);
nfact = factorial(n);
n3const = (n^3 - n)./3;
if exact
    if noties
        % No ties, take permutations of 1:n
        Dperm = sum((repmat(1:n,nfact,1) - perms(1:n)).^2, 2);
    else
        % Ties, take permutations of the midranks.
        %
        % With ties, we could consider only distinguishable permutations
        % (those for which equal ranks (ties) are not simply interchanged),
        % but generating only those is a bit of work.  Generating all
        % permutations uses more memory, but gives the same result.
        Dperm = sum((repmat(xrank,nfact,1) - perms(yrank)).^2, 2);
    end
    freq = histc(Dperm,(-.25):.5:(n3const+.25)); freq = freq(1:end-1);

    % Get the tail probabilities.  Reflect as necessary to get the correct
    % tail: the left tail of D corresponds to right tail of rho.
    switch tail
    case 'ne'
        % Use twice the smaller of the tail area above and below the
        % observed value.
        tailProb = min(cumsum(freq), rcumsum(freq,nfact)) ./ nfact;
        tailProb = min(2*tailProb, 1); % don't count the center bin twice
    case 'gt'
        tailProb = cumsum(freq) ./ nfact;
    case 'lt'
        tailProb = rcumsum(freq,nfact) ./ nfact;
    end
    p = tailProb(2*D+1); % bins at half integers, starting at zero

else
    if noties
        % Use AS89, an Edgeworth expansion for upper tail prob of D.
        switch tail
        case 'ne'
            p = AS89(max(D, n3const-D), n, n3const);
            p = min(2*p, 1); % Don't count continuity correction at center twice
        case 'gt'
            p = AS89(n3const - D, n, n3const);
        case 'lt'
            p = AS89(D, n, n3const);
        end
    else
        % Use a t approximation.
        r = (meanD - D) ./ (sqrt(n-1)*stdD);
        t = Inf*sign(r);
        ok = (abs(r) < 1);
        t(ok) = r(ok) .* sqrt((n-2)./(1-r(ok).^2));
        switch tail
        case 'ne'
            p = tcdf(-abs(t),n-2);
            p = min(2*p, 1);
        case 'gt'
            p = tcdf(-t,n-2);
        case 'lt'
            p = tcdf(t,n-2);
        end
    end
end


%--------------------------------------------------------------------------

function p = AS89(D, n, n3const)
%AS89 Upper tail probability for Spearman's D statistic.
%   Edgeworth expansion for the upper tail probability of D in the no ties
%   case, with continuity correction, adapted from Applied Statistics
%   algorithm AS89.
c = [.2274 .2531 .1745 .0758 .1033 .3932 .0879 .0151 .0072 .0831 .0131 .00046];
x = (2*(D-1)./n3const - 1) * sqrt(n - 1);
y = x .* x;
u = x .* (c(1) + (c(2) + c(3)/n)/n + ...
    y .* (-c(4) + (c(5) + c(6)/n)/n - ...
    y .* (c(7) + c(8)/n - y .* (c(9) - c(10)/n + ...
    y .* (c(11) - c(12) * y)/n))/n))/n;
p = u ./ exp(.5*y) + 0.5 * erfc(x./sqrt(2));
p = max(min(p, ones(size(p),class(D))), zeros(size(p),class(D)));


%--------------------------------------------------------------------------

function y = rcumsum(x,sumx)
%RCUMSUM Cumulative sum in reverse direction.
if nargin < 2
    sumx = sum(x);
end
y = repmat(sumx,size(x));
y(2:end) = sumx - cumsum(x(1:end-1));

function [p,Table,stats] = friedman(X, reps, displayopt)
%FRIEDMAN Nonparametric two-way analysis of variance.
%   P = FRIEDMAN(X,REPS,DISPLAYOPT) performs Friedman's test, a
%   nonparametric version of balanced two-way ANOVA.  FRIEDMAN compares
%   columns of data in X, adjusting for possible row effects, and returns
%   the p-value for the null hypothesis that there are no column effects.
%   The data are assumed to be independent samples from continuous
%   distributions that are identical except possibly for location shifts
%   due to row and column effects, but are otherwise arbitrary.  If there
%   is more than one observation per row-column "cell", use the scalar
%   argument REPS to indicate the number of observations per cell.  Each
%   cell corresponds to REPS consecutive rows in one column of X.
%   DISPLAYOPT can be 'on' (the default) to display the table, or 'off' to
%   skip the display.
%
%   In typical use the columns represent different levels of a treatment
%   factor to be tested, and the rows represent different blocks.  If both
%   rows and columns represent effects of a factor to be tested, run
%   FRIEDMAN twice, once using X and again using the transpose X'.
%
%   [P,TABLE] = FRIEDMAN(...) returns a cell array containing the ANOVA
%   table values.
%
%   [P,TABLE,STATS] = FRIEDMAN(...) returns an additional structure of
%   statistics useful for performing a multiple comparison of cell medians
%   with the MULTCOMPARE function.

%   See also ANOVA2, KRUSKALWALLIS, MULTCOMPARE.

%   References:
%      [1] Hogg, R. V. and J. Ledolter.  Engineering Statistics.  MacMillan
%          Publishing Company, 1987.
%      [2] Hollander, M. and D. A. Wolfe.  Nonparametric Statistical
%          Methods.  Wiley, 1973.
%      [3] Gibbons, J.D.  Nonparametric Statistical Inference,
%          2nd ed.  M. Dekker, 1985.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.7.4.3 $  $Date: 2004/01/24 09:33:47 $

[r,c] = size(X);

if (nargin<2), reps = 1; end
if (nargin<3), displayopt = 'on'; end
if (any(isnan(X(:))))
   error('stats:friedman:NanNotAllowed','NaN values in input not allowed.');
end
if (reps>1)
   r = r/reps;
   if (floor(r) ~= r), 
       error('stats:friedman:BadSize',...
             'The number of rows must be a multiple of REPS.');
   end
end   
if (r<=1 | c <=1)
   error('stats:friedman:BadSize','Must have at least two rows and columns.');
end
if ~(isequal(displayopt,'on') | isequal(displayopt,'off'))
   error('stats:friedman:BadDisplayOpt',...
         'DISPLAYOPT must be ''on'' or ''off''.');
end

% Get a matrix of ranks.  For the unusual case of replicated
% measurements, rank together all replicates in the same row.  This
% is the advice given by Zar (1996), "Biostatistical Analysis."
m = X;
sumta = 0;
for j=1:r
   jrows = reps * (j-1) + (1:reps);
   v = X(jrows,:);
   [a,tieadj] = tiedrank(v(:));
   m(jrows,:) = reshape(a, reps, c);;
   sumta = sumta + 2*tieadj;
end

% Perform anova but don't display the table
[p0,Table] = anova2(m, reps, 'off');

% Compute Friedman test statistic and p-value
chistat = Table{2,2};
sigmasq = c*reps*(reps*c+1) / 12;
if (sumta > 0)
   sigmasq = sigmasq - sumta / (12 * r * (reps*c-1));
end
if (chistat > 0)
   chistat = chistat / sigmasq;
end
p = 1 - chi2cdf(chistat, c-1);

Table(3,:) = [];                    % remove row info
if (reps>1), Table{3,5} = []; Table{3,6} = []; end % remove interaction test
Table{1,5} = 'Chi-sq';              % fix test statistic name
Table{2,5} = chistat;               % fix test statistic value
Table{1,6} = 'Prob>Chi-sq';         % fix p-value name
Table{2,6} = p;                     % fix p-value value

if (isequal(displayopt, 'on'))
   digits = [-1 -1 0 -1 2 4];
   statdisptable(Table, 'Friedman''s Test', 'Friedman''s ANOVA Table', ...
              'Test for column effects after row effects are removed', digits);
end

if (nargout > 2)
   stats.source = 'friedman';
   stats.n = r;
   stats.meanranks = mean(m);
   stats.sigma = sqrt(sigmasq);
end

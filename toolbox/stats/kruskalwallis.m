function [p,anovatab,stats] = kruskalwallis(varargin)
%KRUSKALWALLIS Nonparametric one-way analysis of variance (ANOVA).
%   P = KRUSKALWALLIS(X,GROUP,DISPLAYOPT) performs a non-parametric one-way
%   ANOVA to test the null hypothesis that independent samples from two or
%   more groups come from distributions with equal medians, and returns the
%   p-value for that test.  The data are assumed to come from continuous
%   distributions that are identical except possibly for location shifts
%   due to group effects, but are otherwise arbitrary.
%
%   If X is a matrix, KRUSKALWALLIS treats each column as coming from a
%     separate group.  This form of input is appropriate when each sample
%     has the same number of elements (balanced).  GROUP can be a character
%     array or a cell array of strings, with one row per column of X,
%     containing the group names.  Enter an empty array ([]) or omit this
%     argument if you do not want to specify group names.
%   If X is a vector, GROUP must be a vector of the same length, or a
%     string array or cell array of strings with one row for each element
%     of X.  X values corresponding to the same value of GROUP are placed
%     in the same group.
%
%   DISPLAYOPT can be 'on' (the default) to display figures containing a
%   boxplot and the Kruskal-Wallis version of a one-way ANOVA table, or
%   'off' to omit these displays.
%
%   [P,ANOVATAB] = KRUSKALWALLIS(...) returns the ANOVA table values as the
%   cell array ANOVATAB.
%
%   [P,ANOVATAB,STATS] = KRUSKALWALLIS(...) returns an additional structure
%   of statistics useful for performing a multiple comparison of group
%   medians with the MULTCOMPARE function.
%
%   See also ANOVA1, BOXPLOT, FRIEDMAN, MULTCOMPARE, RANKSUM.

%   References:
%      [1] Hollander, M. and D. A. Wolfe.  Nonparametric Statistical
%          Methods. Wiley, 1973.
%      [2] Gibbons, J.D.  Nonparametric Statistical Inference,
%          2nd ed.  M. Dekker, 1985.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.5.4.2 $  $Date: 2004/01/24 09:34:15 $

error(nargchk(1,3,nargin,'struct'));
[p,anovatab,stats] = anova1('kruskalwallis', varargin{:});

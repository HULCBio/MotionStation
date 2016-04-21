function [comparison,means,h] = multcompare(stats,varargin)
%MULTCOMPARE Perform a multiple comparison of means or other estimates
%   MULTCOMPARE performs a multiple comparison using one-way anova or
%   anocova results to determine which estimates (such as means,
%   slopes, or intercepts) are significantly different.
%
%   COMPARISON = MULTCOMPARE(STATS) performs a multiple comparison
%   using a STATS structure that is obtained as output from any of
%   the following functions:  anova1, anova2, anovan, aoctool,
%   kruskalwallis, friedman.  The return value COMPARISON is a matrix
%   with one row per comparison and five columns.  Columns 1-2 are the
%   indices of the two samples being compared.  Columns 3-5 are a lower
%   bound, estimate, and upper bound for their difference.
%
%   COMPARISON = MULTCOMPARE(STATS, 'PARAM1',val1, 'PARAM2',val2,...)
%   specifies one or more of the following name/value pairs:
%   
%     'alpha'       Specifies the confidence level as 100*(1-ALPHA)%
%                   (default 0.05).
%     'displayopt'  Either 'on' (the default) to display a graph of the
%                   estimates with comparison intervals around them, or
%                   'off' to omit the graph.
%     'ctype'       The type of critical value to use.  Choices are
%                   'tukey-kramer' (default), 'dunn-sidak', 'bonferroni',
%                   'scheffe'.  Enter two or more choices separated by
%                   spaces, to use the minimum of those critical values.
%     'dimension'   A vector specifying the dimension or dimensions over
%                   which the population marginal means are to be
%                   calculated.  Used only if STATS comes from anovan.
%                   The default is 1 to compute over the first dimension.
%                   The value [1 3], for example, computes the population
%                   marginal mean for each combination of the first and
%                   third predictor values.
%     'estimate'    Estimate to compare.  Choices depend on the source of
%                   the stats structure:
%         anova1:  ignored, compare group means
%         anova2:  'column' (default) or 'row' means
%         anovan:  ignored, compare population marginal means
%         aoctool:  'slope', 'intercept', or 'pmm' (default is 'slope'
%                   for separate-slopes models, 'intercept' otherwise)
%         kruskalwallis:  ignored, compare average ranks of columns
%         friedman:  ignored, compare average ranks of columns
%
%   [COMPARISON,MEANS,H] = MULTCOMPARE(...) also returns MEANS, a matrix
%   with columns equal to the estimated quantities and their standard
%   errors, and H, a handle to the figure containing the graph.
%
%   The intervals shown in the graph are computed so that to a very close
%   approximation, two estimates being compared are significantly different
%   if their intervals are disjoint, and are not significantly different if
%   their intervals overlap.  (This is exact for multiple comparison
%   of means from anova1, if all means are based on the same sample size.)
%   You can click on any estimate to see which means are significantly
%   different from it.
%
%   Two additional CTYPE choices are available.  The 'hsd' option stands
%   for "honestly significant differences" and is the same as the
%   'tukey-kramer' option.  The 'lsd' option stands for "least significant
%   difference" and uses plain t-tests; it provides no protection against
%   the multiple comparison problem unless it follows a preliminary overall
%   test such as an F test.
%
%   See also ANOVA1, ANOVA2, ANOVAN, AOCTOOL, FRIEDMAN, KRUSKALWALLIS.

%   Also supports older calling sequence:
%      [...] = MULTCOMPARE(STATS,ALPHA,DISPLAYOPT,CTYPE,ESTIMATE,DIM)
%
%   Reference: Y. Hochberg and A.C. Tamhane, "Multiple Comparison
%   Procedures," Wiley, New York, 1987.
%
%   The Tukey-Kramer critical value is the default.  This is known
%   to be the best choice for one-way anova comparisons, but the
%   conjecture that this is best for other comparisons is
%   unproven.  The Bonferroni and Scheffe critical values are
%   conservative in all cases.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.9.4.3 $  $Date: 2004/01/16 20:09:40 $

% Check inputs and assign default values
if (nargin < 1)
   error('stats:multcompare:TooFewInputs',...
         'At least one argument is required.');
end
if isempty(varargin) || (~isempty(varargin{1}) && ischar(varargin{1}))
   okargs =   {'alpha' 'display' 'ctype' 'estimate' 'dimension'};
   defaults = {0.05    'on'      ''      ''         1};
   [eid,emsg,alpha,displayopt,ctype,estimate,dim] = ...
                statgetargs(okargs,defaults,varargin{:});
   if ~isempty(emsg)
      error(sprintf('stats:multcompare:%s',eid),emsg);
   end
else
   % Old-style calling sequence with fixed argument positions
   if (nargin >= 2) && ~isempty(varargin{1})
      alpha = varargin{1};
   else
      alpha = 0.05;
   end
   if (nargin >= 3) && ~isempty(varargin{2})
      displayopt = varargin{2};
   else
      displayopt = 'on';
   end
   if (nargin>=4) && ~isempty(varargin{3})
      ctype = varargin{3};
   else
      ctype = '';
   end
   if (nargin>=5) && ~isempty(varargin{4})
      estimate = varargin{4};
   else
      estimate = '';
   end
   if (nargin>=6) && ~isempty(varargin{5})
      dim = varargin{5};
   else
      dim = 1;
   end
end

if (~isstruct(stats))
   error('stats:multcompare:BadStats','STATS must be a structure.');
end
if (~isfield(stats,'source'))
   error('stats:multcompare:BadStats',...
         'The first argument is not a STATS output structure from ANOVA1.');
end
if (length(alpha)~=1 || ~isfinite(alpha) || alpha<=0 || alpha>=1)
   error('stats:multcompare:BadAlpha',...
         'ALPHA must be a scalar between 0 and 1, exclusive.');
end
if ~(isequal(displayopt, 'on') || isequal(displayopt, 'off'))
   error('stats:multcompare:BadDisplayOpt',...
         'DISPLAYOPT must be ''on'' or ''off''.');
end
dodisp = isequal(displayopt, 'on');

source = stats.source;

switch(source)
 case 'anova1'
   mname = 'means';
   gmeans = stats.means(:);
   gnames = stats.gnames;
   n = stats.n(:);
   df = stats.df;
   s = stats.s;
   ng = length(n);
   if (df < 1)
      error('stats:multcompare:NotEnoughData',...
            'Cannot compare means with 0 degrees of freedom for error.');
   end
   
   % Get Tukey-Kramer critical value
   if (isempty(ctype)), ctype = 'tukey-kramer'; end
   crit = getcrit(ctype, alpha, df, ng);
   
   gcov = diag((s^2)./n);

 case 'anova2'
   docols = logical(1);
   if (~isempty(estimate))
      if ~(   isequal(estimate,'row') || isequal(estimate,'column')...
           || isequal(estimate,'r')   || isequal(estimate,'c'))
         error('stats:multcompare:BadEstimate',...
               'ESTIMATE must be ''column'' or ''row''.');
      end
      docols = isequal(estimate, 'column') || isequal(estimate, 'c');
   end
   if (docols)
      gmeans = stats.colmeans(:);
      n = stats.coln(:);
      mname = 'column means';
   else
      gmeans = stats.rowmeans(:);
      n = stats.rown(:);
      mname = 'row means';
   end
   ng = length(gmeans);
   sigma = sqrt(stats.sigmasq);
   gnames = strjust(num2str((1:ng)'), 'left');
   df = stats.df;
   if (df < 1)
      error('stats:multcompare:NotEnoughData',...
            'Cannot compare means with 0 degrees of freedom for error.');
   end
   
   % Get Tukey-Kramer critical value
   if (isempty(ctype)), ctype = 'tukey-kramer'; end
   crit = getcrit(ctype, alpha, df, ng);
   
   gcov = ((sigma^2)/n) * eye(ng);

   % This whole activity is a little strange if the model includes
   % interactions, especially if they are important.
   if (stats.inter && dodisp)     % model included an interaction term
      if (stats.pval < alpha)
         disp(sprintf(...
['Note:  Your model includes an interaction term that is significant\n'...
 'at the level you specified.  Testing main effects under these\n'...
 'conditions is questionable.']));
      else
         disp(sprintf(...
['Note:  Your model includes an interaction term.  A test of main\n'...
 'effects can be difficult to interpret when the model includes\n'...
 'interactions.']));
      end
   end

 case 'anovan'
   mname = 'population marginal means';

   % Our calculations treat all effects as fixed
   if ~isempty(stats.ems)
      warning('stats:multcompare:IgnoringRandomEffects',...
              'Ignoring random effects (all effects treated as fixed).')
   end
   
   nvars = length(stats.nlevels);
   P0 = stats.nullproject;
   
   % Make sure DIM is a scalar or vector of factor numbers.
   dim = dim(:);
   if any(dim<1 | dim>nvars | dim~=round(dim))
      error('stats:multcompare:BadDim',...
            'Values of DIM must be integers between 1 and %d.',nvars);
   end
   dim = sort(dim);
   dim(diff(dim)==0) = [];
   
   % Create all combinations of the specified factors
   ffdesign = fullfact(stats.nlevels(dim));
   nrows = size(ffdesign,1);
   
   % Create a design matrix for these combinations
   dums = cell(nvars, 1);
   for j=1:length(dim)
      dj = dim(j);
      dums{dj} = idummy(ffdesign(:,j),3);  % dummy variables for each factor
   end
   
   % Create a vector of average values for remaining factors
   for j=1:nvars
      if isempty(dums{j});
         dums{j} = repmat(1/stats.nlevels(j),nrows,stats.nlevels(j));
      end
   end

   % Fill in x columns for each term
   termcols = stats.termcols(:);
   termstart = cumsum([1; termcols]);
   terms = [zeros(1,nvars); stats.terms];
   ncols = sum(termcols);
   x = zeros(size(ffdesign,1), ncols);
   x(:,1) = 1;
   for j=1:length(termcols)
      tm = terms(j,:);
      t0 = termstart(j);
      t1 = termstart(j) + termcols(j) - 1;
      if all(tm==0)
         x(:,t0:t1) = 1;
      else
         x0 = [];
         for k=nvars:-1:1
            if tm(k)
               x0 = termcross(x0,dums{k});
            end
         end
         x(:,t0:t1) = x0;
      end
   end

   % Compute estimates and their standard errors
   gmeans = x * stats.coeffs;
   xproj = (x*P0)';
   tmp = stats.Rtr \ xproj;
   if (stats.dfe == 0)
      mse = NaN;
   else
      mse = max(stats.mse,0);
   end
   gcov = mse * tmp' * tmp;
   
   % Find non-estimable means and set them to NaN
   Xrows = stats.rowbasis';           % row basis of original X matrix
   bb = Xrows \ (x');                 % fit rows of x to row basis
   xres = Xrows * bb - x';            % get residuals
   xres = sum(abs(xres));             % sum of absolute residuals
   cutoff = sqrt(eps(class(xres))) * size(xres,2); % cutoff for large residuals
   gmeans(xres > cutoff) = NaN;       % not in row space of original X
   
   % Get Tukey-Kramer critical value
   if (isempty(ctype)), ctype = 'tukey-kramer'; end
   crit = getcrit(ctype, alpha, stats.dfe, length(gmeans));


   % Get names for each group
   ngroups = size(ffdesign,1);
   gnames = cell(ngroups,1);
   allnames = stats.grpnames;
   varnames = stats.varnames;
   for j=1:ngroups
      v1 = dim(1);
      vals1 = allnames{v1};
      nm = sprintf('%s=%s',varnames{v1},vals1{ffdesign(j,1)});
      for i=2:size(ffdesign,2)
         v2 = dim(i);
         vals2 = allnames{v2};
         nm = sprintf('%s,%s=%s',nm,varnames{v2},vals2{ffdesign(j,i)});
      end
      gnames{j} = nm;
   end

 case 'aoctool'
   model = stats.model;
   if (model==1 || model==3)
      error('stats:multcompare:NoMultipleParameters',...
            'No multiple comparisons possible from this aoctool fit.');
   end
   gnames = stats.gnames;
   n = stats.n(:);
   ng = length(n);
   df = stats.df;
   if (df < 1)
      error('stats:multcompare:NotEnoughData',...
            'Cannot do multiple comparison with 0 d.f. for error.');
   end

   % Get either slope or intercept estimates and covariances
   if (isempty(estimate))
      if (model == 5)
         estimate = 'slope';
      else
         estimate = 'intercept';
      end
   end
   
   if (isequal(estimate,'s')), estimate = 'slope'; end
   if (isequal(estimate,'i')), estimate = 'intercept'; end
   if (isequal(estimate,'p')), estimate = 'pmm'; end
   if (~isempty(estimate))
      if ~(   isequal(estimate,'slope') || isequal(estimate,'pmm')...
           || isequal(estimate,'intercept'))
         error('stats:multcompare:BadEstimate',...
               'ESTIMATE must be ''slope'', ''intercept'', or ''pmm''.');
      end
   end
   switch(estimate)
    case 'slope'
      if (~isfield(stats, 'slopes'))
         error('stats:multcompare:BadStats',...
               'No slope estimates available in STATS argument.');
      end
      gmeans = stats.slopes;
      gcov = stats.slopecov;
      mname = 'slopes';
    case 'intercept'
      if (~isfield(stats, 'intercepts'))
         error('stats:multcompare:BadStats',...
               'No intercept estimates available in STATS argument.');
      end
      gmeans = stats.intercepts;
      gcov = stats.intercov;
      mname = 'intercepts';
    case 'pmm'
      gmeans = stats.pmm;
      gcov = stats.pmmcov;
      mname = 'population marginal means';
   end

   if (any(any(isinf(gcov))))
      error('stats:multcompare:InfiniteVariance',...
            'Cannot do comparisons.  Some %s have infinite variance.', mname);
   end
   
   % Get Tukey-Kramer critical value
   if (isempty(ctype)), ctype = 'tukey-kramer'; end
   crit = getcrit(ctype, alpha, df, ng);

 case 'kruskalwallis'
   gmeans = stats.meanranks(:);
   gnames = stats.gnames;
   n = stats.n(:);
   sumt = stats.sumt;
   ng = length(n);
   N = sum(n);
   mname = 'mean ranks';

   % Get critical value; H&T recommend the Tukey-Kramer value
   if (isempty(ctype)), ctype = 'tukey-kramer'; end
   crit = getcrit(ctype, alpha, Inf, ng);
   
   gcov = diag(((N*(N+1)/12) - (sumt/(12*(N-1)))) ./ n);
   
   % Note that the intervals in M can be used for testing but not
   % for simultaneous confidence intervals.  See H&T, p. 249.
   if (dodisp)
      disp(['Note:  Intervals can be used for testing but are not ' ...
            'simultaneous confidence intervals.']);
   end

 case 'friedman'
   gmeans = stats.meanranks(:);
   n = stats.n;
   ng = length(gmeans);
   sigma = stats.sigma;
   mname = 'mean column ranks';
   gnames = strjust(num2str((1:ng)'), 'left');

   % Get critical value; H&T recommend the Tukey-Kramer value
   if (isempty(ctype)), ctype = 'tukey-kramer'; end
   crit = getcrit(ctype, alpha, Inf, ng);

   gcov = ((sigma^2) / n) * eye(ng);

   % Note that the intervals in M can be used for testing but not
   % for simultaneous confidence intervals.  See H&T, p. 249.
   if (dodisp)
      disp(['Note:  Intervals can be used for testing but are not ' ...
            'simultaneous confidence intervals.']);
   end

 otherwise
  error('stats:multcompare:BadStats','Bad SOURCE field in STATS structure');
end


% Create output matrix showing tests for all pairwise comparisons
% and graph that approximates these tests.
[M,MM,hh] = makeM(gmeans, gcov, crit, gnames, mname, dodisp);

comparison = M;
if (nargout>1), means = MM; end
if (nargout>2), h = hh; end

% -----------------------------------------------
function crit = getcrit(ctype, alpha, df, ng)
% Get the minimum of the specified critical values
crit = Inf;
[onetype,ctype] = strtok(ctype);

while(~isempty(onetype))
   if (length(onetype) == 1)
      switch onetype
       case 't', onetype = 'tukey-kramer';
       case 'd', onetype = 'dunn-sidak';
       case 'b', onetype = 'bonferroni';
       case 's', onetype = 'scheffe';
       case 'h', onetype = 'tukey-kramer';
       case 'l', onetype = 'lsd';
      end
   end
   if (isequal(onetype, 'hsd')), onetype = 'tukey-kramer'; end
   
   switch onetype
    case 'tukey-kramer' % or hsd
     crit1 = stdrinv(1-alpha, df, ng) / sqrt(2);
     
     % The T-K algorithm is inaccurate for small alpha, so compute
     % an upper bound for it and make sure it's in range.
     ub = getcrit('dunn-sidak', alpha, df, ng);
     if (crit1 > ub), crit1 = ub; end

    case 'dunn-sidak'
     kstar = nchoosek(ng, 2);
     alf = 1-(1-alpha).^(1/kstar);
     if (isinf(df))
        crit1 = norminv(1-alf/2);
     else
        crit1 = tinv(1-alf/2, df);
     end

    case 'bonferroni'
     kstar = nchoosek(ng, 2);
     if (isinf(df))
        crit1 = norminv(1 - alpha / (2*kstar));
     else
        crit1 = tinv(1 - alpha / (2*kstar), df);
     end

    case 'lsd'
     if (isinf(df))
        crit1 = norminv(1 - alpha / 2);
     else
        crit1 = tinv(1 - alpha / 2, df);
     end

    case 'scheffe'
     if (isinf(df))
        tmp = chi2inv(1-alpha, ng-1) / (ng-1);
     else
        tmp = finv(1-alpha, ng-1, df);
     end
     crit1 = sqrt((ng-1) * tmp);
     
    otherwise
     error('stats:multcompare:BadCType',...
           'Unknown CTYPE (critical value type) %s.', ctype);
   end

   if (~isnan(crit1)), crit = min(crit, crit1); end
   [onetype,ctype] = strtok(ctype);
end

% -----------------------------------------------
function [M,MM,hh] = makeM(gmeans, gcov, crit, gnames, mname, dodisp)
% Create matrix to test differences, matrix of means, graph to display test
   
ng = length(gmeans);
MM = zeros(ng,2);
MM(:,1) = gmeans(:);
MM(:,2) = sqrt(diag(gcov));
MM(isnan(MM(:,1)),2) = NaN;

M = nchoosek(1:ng, 2);      % all pairs of group numbers
M(1,5) = 0;                 % expand M to proper size
g1 = M(:,1);
g2 = M(:,2);
M(:,4) = gmeans(g1) - gmeans(g2);
i12 = sub2ind(size(gcov), g1, g2);
gvar = diag(gcov);
d12 = sqrt(gvar(g1) + gvar(g2) - 2 * gcov(i12));
delta = crit * d12;
M(:,3) = M(:,4) - delta;
M(:,5) = M(:,4) + delta;

% If requested, make a graph that approximates these tests
if (dodisp)
   % Find W values according to H&T (3.32, p. 98)
   d = zeros(ng, ng);
   d(i12) = d12;
   sum1 = sum(sum(d));
   d = d + d';
   sum2 = sum(d);
   if (ng > 2)
      w = ((ng-1) * sum2 - sum1) ./ ((ng-1)*(ng-2));
   else
      w = repmat(sum1, 2, 1) / 2;
   end
   halfwidth = crit * w(:);
   hh = meansgraph(gmeans, gmeans-halfwidth, gmeans+halfwidth, ...
                   gnames, mname);
   set(hh, 'Name', sprintf('Multiple comparison of %s',mname));
else
   hh = [];
end

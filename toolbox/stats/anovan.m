function [p,t,stats,terms] = anovan(y,group,varargin)
%ANOVAN N-way analysis of variance (ANOVA).
%   P=ANOVAN(Y,GROUP) performs multi-way (n-way) anova on the vector Y
%   grouped by entries in the cell array GROUP.  Each cell of GROUP
%   must contain a grouping variable that can be a numeric vector, a
%   character matrix, or a single-column cell array of strings.  Each
%   grouping variable must have the same number of items as Y.  The
%   fitted anova model includes the main effects of each grouping
%   variable.  All grouping variables are treated as fixed effects by
%   default.  The result P is a vector of p-values, one per term.
%
%   P=ANOVAN(Y,GROUP,'PARAM1',val1,'PARAM2',val2,...) specifies one or
%   more of the following name/value pairs:
%
%     'sstype'   The type of sum of squares (1-3, default=3)
%     'varnames' Grouping variables names in a character matrix or
%                a cell array of strings, one per grouping variable
%                (default names are 'X1', X2', ...)
%     'display'  Either 'on' (the default) to display an anova table
%                or 'off' to omit the display
%     'random'   A vector of indices indicating which grouping variables
%                are random effects (all are fixed by default)
%     'alpha'    A value between 0 and 1 requesting 100*(1-alpha)%
%                confidence bounds (default 0.05 for 95% confidence)
%     'model'    The model to use, specified as one of the following:
%
%        'linear' to use only main effects of all factors (default)
%        'interaction' for main effects plus two-factor interactions
%        'full' to include interactions of all levels
%        an integer representing the maximum interaction order, for example
%           3 means main effects plus two- and three-factor interactions
%        a matrix of term definitions as accepted by the X2FX function,
%           but all entries must be 0 or 1 (no higher powers)
%
%   [P,T,STATS,TERMS]=ANOVAN(...) also returns a cell array T containing
%   the anova table, a structure STATS containing a variety of statistics,
%   and a matrix TERMS describing the terms used (suitable for use as the
%   MODEL input argument if you run ANOVAN again).
%
%   For models without random effects, the anova table T contains columns
%   for terms, sum of squares, degrees of freedom, an indication of whether
%   the term is singular, mean square, F statistic, and P value.  For models
%   with random effects there are additional columns showing the term type
%   (fixed or random), expected mean square, denominator mean square for F,
%   denominator degrees of freedom for F, denominator definition, variance
%   component estimate, lower bound for variance, and upper bound for
%   variance.
%
%   The STATS structure contains the fields listed below, in addition
%   to a number of other fields required for doing multiple comparisons
%   using the MULTCOMPARE function:
%      coeffs      estimated coefficients
%      coeffnames  name of term for each coefficient
%      vars        matrix of grouping variable values for each term
%      resid       residuals from the fitted model
%
%   These fields exist if there are random effects:
%      ems         expected mean squares
%      denom       denominator definition
%      rtnames     names of random terms
%      varest      variance component estimates (one per random term)
%      varci       confidence intervals for variance components
%
%   Example:
%    load carbig
%    [p, atab] = anovan(MPG, {Cylinders Origin Model_Year}, ...
%                       'model',2, 'sstype',2, ...
%                       'varnames',strvcat('Cyl', 'Org', 'Yr'))
%    This example performs three-way anova on MPG using the factors
%    Cylinders, Origin, and Year.  The model will have all two-factor
%    interactions but not the three-factor interaction.  Sum of
%    squares are Type 2.
%
%   See also MULTCOMPARE, ANOVA1, ANOVA2, MANOVA1.

%   Also supports older calling sequence:
%      P=ANOVAN(Y,GROUP,MODEL,SSTYPE,VARNAME,DISPLAYOPT)
%   In addition to the matrix form of the model specification, the function
%   allows MODEL to be a vector V of integers.  In this compressed form
%   each element describes a term, so the Ith term includes the Jth grouping
%   variable if BITGET(V(I),J)==1
%
%
%   References:
%      Dunn, O.J., and V.A. Clark (1974), "Applied Statistics:
%         Analysis of Variance and Regression," Wiley, New York.
%      Goodnight, J.H., and F.M. Speed (1978), "Computing Expected Mean
%         Squares," SAS Institute, Cary, NC.
%      Milliken, G.A., and D.E. Johnson, "Analysis of Messy Data,"
%         Chapman & Hall, New York.
%      Seber, G.A.F. (1977), "Linear Regression Analysis," Wiley,
%         New York.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.9.2.4 $  $Date: 2004/01/16 20:08:52 $

% First:  argument checking and selection of defaults
error(nargchk(2,Inf,nargin,'struct'));
if (numel(y)~=length(y))
   error('stats:anovan:VectorRequired','Y must be a vector.');
end
if (size(y,1)==1), y=y(:); end
n = length(y);
dostats = (nargout>=3);      % true to compute output stats structure

if (~iscell(group))
   error('stats:anovan:BadGroup',...
         'GROUP must be a cell array of grouping variables.')
end
group = group(:);
ng = length(group);

% Which style of calling sequence are we using?
newstyle = true;
if ~isempty(varargin) && nargin<=6
   va1 = varargin{1};
   if ~ischar(va1) || isempty(va1)
      newstyle = false;
   elseif ~isempty(strmatch(va1,{'l' 'i' 'f' 'linear' 'interaction' 'full'},...
                            'exact'))
      newstyle = false;
   end
end

if newstyle
   % Calling sequence with named arguments
   okargs =   {'model' 'sstype' 'varnames' 'display' 'alpha' 'random'};
   defaults = {1       3        ''         'on'      0.05    false(ng,1)};
   [eid emsg model sstype varnames displayopt alpha randomvar] = ...
                statgetargs(okargs,defaults,varargin{:});
   if ~isempty(eid)
      error(sprintf('stats:anovan:%s',eid),emsg);
   end
else
   % Old-style calling sequence with fixed argument positions
   model = 1;
   sstype = 3;
   varnames = '';
   displayopt = 'on';
   if nargin>=3, model = varargin{1}; end
   if nargin>=4, sstype = varargin{2}; end
   if nargin>=5, varnames = varargin{3}; end
   if nargin>=6, displayopt = varargin{4}; end
   alpha = 0.05;
   randomvar = false(ng,1);
end

% Check optional arguments
if isempty(varnames)
   varnames = cellstr([repmat('X',ng,1) strjust(num2str((1:ng)'),'left')]);
else
   if (iscell(varnames)), varnames = varnames(:); end
   if (size(varnames,1) ~= ng)
      error('stats:anovan:InputSizeMismatch','VARNAMES must have %d rows', ng);
   elseif (~(ischar(varnames) || iscellstr(varnames)))
      error('stats:anovan:BadVarNames',...
            'VARNAMES must be a character matrix or cell array of strings.');
   elseif (ischar(varnames))
      varnames = cellstr(varnames);
   end
end

if isempty(sstype)
   sstype = 3;
elseif (sstype ~= 1 && sstype ~= 2 && sstype ~=  3)
   error('stats:anovan:BadSumSquares','SSTYPE must be 1, 2, or 3.');
end

if isempty(model)
   model = 1;
elseif ~isnumeric(model)
   if strcmp(model, 'linear') || strcmp(model, 'l')
      model = 1;
   elseif strcmp(model, 'interaction') || strcmp(model, 'i')
      model = 2;
   elseif strcmp(model, 'full') || strcmp(model, 'f')
      model = ng;
   else
      error('stats:anovan:BadModel','MODEL is invalid.');
   end
elseif min(size(model))>1 || ...
       (isequal(size(model),[1 ng]) && all(ismember(model,0:1)))
   % Matrix form of input
   if ~all(ismember(model(:),0:1))
      error('stats:anovan:BadModel',...
            'MODEL matrix entries must be all 0 or 1.');
   elseif size(model,2)~=ng
      error('stats:anovan:InputSizeMismatch',...
            'MODEL matrix must have %d columns.',ng);
   end
else
   if (any(model~=floor(model)|model<=0))
      % Original vector form, no longer advertized
      error('stats:anovan:BadModel','MODEL is invalid.');
   end
   model = model(:);
end
if (length(model)==1) || (any(size(model)==1) & any(model(:)>1))
   % Convert from scalar or coded integer to matrix form
   termlist = makemodel(model, ng);
else
   termlist = model;
end

if ~isnumeric(alpha) || numel(alpha)~=1 || alpha<=0 || alpha>=1
   error('stats:anovan:BadAlpha','ALPHA must be a scalar between 0 and 1.');
end

% Randomvar may be a logical vector indicating the random variables
if islogical(randomvar) && length(randomvar)==ng && numel(randomvar)==ng
   randomvar = randomvar(:);
elseif isnumeric(randomvar) && all(ismember(randomvar(:),1:ng))
   % or it may be an index vector -- convert to logical
   randomvar = ismember((1:ng)', randomvar(:));
else
   error('stats:anovan:BadRandomVar',...
         'RANDOMVAR must be a vector of indices between 1 and %d.', ng);
end
doems = any(randomvar);        % true to compute expected mean squares


% STEP 1:  Remove NaN's and prepare grouping variables.
% First pass, make sure all groups are rows and find NaNs.
nanrow = isnan(y);
for j=1:ng
   gj = group{j};
   if (size(gj,1) == 1), gj = gj(:); end
   if (size(gj,1) ~= n)
      error('stats:anovan:InputSizeMismatch',...
            'Group variable %d must have %d elements.',j,n);
   end
   if (ischar(gj)), gj = cellstr(gj); end
   group{j} = gj;
   if (isnumeric(gj))
      nanrow = (nanrow | isnan(gj));
   else
      nanrow = (nanrow | strcmp(gj,''));
   end
end

% Second pass, remove NaNs and create group index and name arrays.
y(nanrow) = [];
n = length(y);
gdum = cell(ng,1);
dfvar = zeros(ng,1);
if sstype==3
   vconstr = cell(ng,1);
   vmean = cell(ng,1);
end
if dostats
   allgrps = zeros(n, ng);
   allnames = cell(ng,1);
end
for j=1:ng
   gj = group{j};
   gj(nanrow,:) = [];
   [gij,gnj] = grp2idx(gj);
   nlevels = size(gnj,1);
   dfvar(j) = nlevels - 1;
   if dostats
      allgrps(:,j) = gij;
      allnames{j} = gnj;
   end

% STEP 2:  Create dummy variable arrays for each grouping variable.
   gdum{j} = idummy(gij, 3);
   
% STEP 2a: For type 3 ss, create constraints for each grouping variable.
   if sstype==3
      vconstr{j} = idummy(1:nlevels)';
      vmean{j} = ones(1,nlevels) / nlevels;
   end
end

% STEP 3:  Create dummy variable arrays for each term in the model.
nterms = size(termlist,1);
[sterms,sindex] = sortrows(termlist);
ncols = 1;
nconstr = 0;

termdum = cell(nterms, 1);      % dummy variable = design matrix cols
termconstr = cell(nterms,1);    % constraints to make each term well defined
levelcodes = cell(nterms, 1);   % codes for levels of each M row
tnames = cell(nterms, 1);       % name for entire term, e.g. A*B
dfterm0 = zeros(nterms, 1);     % nominal d.f. for each term
termvars = cell(nterms, 1);     % list of vars in each term
termlength = zeros(size(sindex));% length of each term (number of columns)
randomterm = find(termlist*randomvar > 0);  % indices of random terms

% For each term,
for j=1:nterms
   % Loop over elements of the term
   df0 = 1;
   tm = sterms(j,:);
   tdum = [];         % empty term so far
   tconstr = 1;       % empty constraints so far
   tn = '';           % blank name so far
   vars = find(tm);
   for varidx = 1:length(vars)
      % Process each variable participating in this term
      varnum = vars(varidx);          % variable name
      tm(varnum) = 0;                 % term without this variable
      df0 = df0 * dfvar(varnum);      % d.f. so var

      % Combine its dummy variable with the part computed so far
      G = gdum{varnum};           % dummy vars for this grouping var
      nlevterm = size(tdum,2);    % levels for term so far
      nlevgrp  = size(G,2);       % levels for this grouping var
      tdum = termcross(G,tdum);   % combine G into term dummy vars

      % Construct the term name and constraints matrix
      if (isempty(tn))
         tn = varnames{varnum};
         tconstr = ones(1,nlevgrp);
      else
         tn = [varnames{varnum} '*' tn];
         tconstr = [kron(ones(1,nlevgrp),eye(size(tconstr,2)));
                    kron(eye(nlevgrp),tconstr)];
      end

      % If the rest of this term is computed, take advantage of that
      prevterms = sterms(1:j-1,:);
      oldtm = find((prevterms * tm') == sum(tm));      % same vars in old term
      oldtm = oldtm((prevterms(oldtm,:) * ~tm') == 0); % and no others
      if (length(oldtm) > 0)
         k = sindex(oldtm(1));
         tdum = termcross(termdum{k}, tdum);
         oconstr = termconstr{k};
         tconstr = [kron(tconstr,              eye(size(oconstr,2)));
                    kron(eye(size(tconstr,2)), oconstr)];
         tn = [tn '*' tnames{k}];
         df0 = df0 * dfterm0(k);
         break;
      end
   end

   % Store this term's dummy variables and name
   k = size(tdum, 2);
   termlength(sindex(j),1) = k;
   ncols = ncols + k;
   sj = sindex(j);
   termdum{sj} = tdum;
   termconstr{sj} = tconstr;
   termvars{sj} = vars;
   levelcodes{sj} = fullfact(dfvar(vars)+1);
   if (isempty(tn)), tn = 'Constant'; end
   tnames{sj,1} = tn;
   dfterm0(sj) = df0;
   nconstr = nconstr + size(tconstr,1);
end
tnames{length(tnames)+1,1} = 'Error';

% STEP 4:  Create the full design matrix
dmat = ones(n, ncols);        % to hold design matrix
cmat = zeros(nconstr,ncols);  % to hold constraints matrix
cbase = 0;                    % base from which to fill in cmat
termname = zeros(ncols,1);
termstart = cumsum([2; termlength(1:end-1)]);
termend = termstart + termlength - 1;
for j=1:nterms
   clist = termstart(j):termend(j);
   dmat(:, clist) = termdum{j};
   C = termconstr{j};
   nC = size(C,1);
   cmat(cbase+1:cbase+nC,clist) = C;
   termname(clist) = j;
   cbase = cbase + nC;
end

% STEP 5:  Fit the full model and compute the residual sum of squares
mu =  mean(y);
y = y - mu;                   % two passes to improve accuracy
mu2 = mean(y);
mu = mu + mu2;
y = y - mu2;
sst = sum(y.^2);
if ~dostats
   [ssx,dfx,dmat2,y] = dofit(dmat, y, cmat, sst, mu);
else
   % Do initial fit requesting stats structure, then convert from full-rank
   % to overdetermined form, then find a label for each coefficient
   [ssx,dfx,dmat2,y,stats] = dofit(dmat,y,cmat,sst,mu);
   fullcoef = stats.coeffs;
   codes = zeros(length(fullcoef), ng);
   names = cell(length(fullcoef),1);
   base = 1;
   names{1} = 'Constant';
   % compute names
   for j=1:length(levelcodes)
      M = levelcodes{j};
      varlist = termvars{j};
      v1 = varlist(1);
      vals1 = allnames{v1};
      nrows = size(M,1);
      codes(base+(1:nrows),varlist) = M;
      for k=1:nrows
         vals1 = allnames{v1};
         nm = sprintf('%s=%s',varnames{v1},vals1{M(k,1)});
         for i=2:length(varlist)
            v2 = varlist(i);
            vals2 = allnames{v2};
            nm = sprintf('%s * %s=%s',nm,varnames{v2},vals2{M(k,i)});
         end
         names{base+k} = nm;
      end
      base = base+nrows;
   end
end
   
sse = sst - ssx;
dfe = n - dfx;

% STEP 6:  Determine which models to compare for testing each term
ssw  = -ones(nterms, 1);      % sum of squares with this term
sswo = ssw;                   % sum of squares without this term
dfw  = ssw;                   % residual d.f. with this term
dfwo = ssw;                   % residual d.f. without this term

switch sstype
 case 1
   modw = tril(ones(nterms)); % get model with this term
   k = nterms;                % locations of model with all terms
 case 2
   modw = termsnotcontained(termlist);
   k = (sum(modw,2) == nterms);
   TnotC = modw;
 case 3
   modw = ones(nterms);
   k = 1:nterms;
   TnotC = termsnotcontained(termlist);
end
modw = logical(modw);
modwo = logical(modw - eye(nterms));   % get model without this term

% STEP 7:  Fit each model, get its residual SS and d.f.
ssw(k) = ssx;        % for full model we already know the results
dfw(k) = dfx;

% Fit each model separately
dfboth = [dfw; dfwo];
if doems
   Llist = cell(nterms,1);
end

% Consider interactions before their components for type 3 ss, so
% examine the terms in decreasing order of the number factors in the term
if sstype==3
   termsize = sum(termlist,2)';
   [stermsize,sindices] = sort(termsize);
   sindices = [sindices(:); sindices(:)];
else
   sindices = [(1:size(termlist,1)), (1:size(termlist,1))]';
end

for j=length(sindices):-1:1
   % Find the next model index to fit
   k = sindices(j);
   
   % Look in unsorted arrays to see if we have already fit this model
   if j>nterms
      k0 = k+nterms;
   else
      k0 = k;
   end
   if dfboth(k0)~=-1
      continue
   end
   
   % Find the model with this index
   if (j > nterms)
      thismod = modwo(k, :);
   else
      thismod = modw(k, :);
   end
   
   % Get the design matrix for this model
   keepterms = find(thismod);
   clist = ismember(termname, [0 keepterms]);
   X = dmat2(:,clist);
   C = cmat(:,clist);

   % Fit this model
   [ssx0,dfx0] = dofit(X, y, C);
   
   % If this model is the "without" model for a term, compute L for that term
   if doems && j>nterms
      if sstype==1
         prevterms = (1:nterms)<k;
      else
         prevterms = TnotC(k,:);
      end
      termscontained = ~prevterms;
      prevterms(k) = false;
      prevcols = ismember(termname, [0 find(prevterms)]);
      curcols = (termname == k);
      if sstype==3
         prevL = cat(1,Llist{termscontained});
      else
         prevL = [];
      end
      Llist{k} = getL(dmat, curcols, prevcols, prevL);
   end
   
   % Use these results for each term that requires them
   mod0 = repmat(thismod, nterms, 1);
   k = find(all(modw == mod0, 2));
   ssw(k) = ssx0;
   dfw(k) = dfx0;
   dfboth(k) = 0;
   k = find(all(modwo == mod0, 2));
   sswo(k) = ssx0;
   dfwo(k) = dfx0;
   dfboth(nterms+k) = 0;
end
clear mod0

% STEP 7A:  Compute expected means squares if requested
if doems
   % Factor the design matrix X appended with the constraints matrix C,
   % getting a full-rank R factor.
   xc = [dmat; cmat];
   [Qxc,Rxc,Exc] = qr(xc,0);
   tol = sqrt(eps(class(Rxc)));
   rankRxc = Rrank(Rxc,tol);
   Rxc0 = zeros(rankRxc,size(Rxc,2));
   Rxc0(:,Exc) = Rxc(1:rankRxc,:);
   
   % Compute expected mean squares for each term.
   emsMat = zeros(nterms,0);
   for k=1:nterms
      termems = getems(Llist{k},Rxc0,termname);
      emsMat(k,1:length(termems)) = termems;
   end
   emsMat(nterms+1,end) = 1;       % for error term
end

% STEP 8:  Compute the sum of squares attributed to each term
ssterm = ssw - sswo;
dfterm = dfw - dfwo;
ssterm(dfterm==0) = 0;    % make this exact

% STEP 9:  Compute the mean square for each term
msterm = ssterm ./ max(1, dfterm);
mse = sse * (dfe>0) / max(1, dfe);

% STEP 9a:  Equated computed and expected mean squares, then solve for
%           variance component estimates

if isempty(randomterm)
   msdenom = repmat(mse, size(msterm));
   dfdenom = repmat(dfe, size(msterm));
else
   RandomInfo = getRandomInfo(msterm,dfterm,mse,dfe,emsMat,randomterm,...
                              tnames,alpha);
   msdenom = RandomInfo.msdenom;
   dfdenom = RandomInfo.dfdenom;
   varest = RandomInfo.varest;
   varci = RandomInfo.varci;
   txtdenom = RandomInfo.txtdenom;
   txtems = RandomInfo.txtems;
   denommat = RandomInfo.denommat;
   rtnames = RandomInfo.rtnames;
end

% STEP 10:  Compute an F statistic for each term
fstat = repmat(Inf, size(msterm));
t = (msdenom>0);
fstat(t) = msterm(t) ./ msdenom(t);

% STEP 11:  Compute the p-value for each term
pval = repmat(NaN, size(fstat));
t = (dfdenom>0 & dfterm>0);
pval(t) = 1 - fcdf(fstat(t), dfterm(t), dfdenom(t));
p = pval;

% Create anova table as a cell array
sing = (dfterm < dfterm0);
tbl = [ssterm dfterm sing msterm fstat pval; sse dfe 0 mse NaN NaN];
tbl = num2cell(tbl);
tbl(end,end-1:end) = {[]};
tbl = [{'Source' 'Sum Sq.' 'd.f.' 'Singular?' 'Mean Sq.' 'F' 'Prob>F'}; ...
       tnames tbl];

% Add random effects information if required
if ~isempty(randomterm)
   rterms = [randomterm; nterms+1];
   C = size(tbl,2);
   tbl(1,end+1:end+8) = {'Type' 'Expected MS' 'MS denom' 'd.f. denom' 'Denom. defn.' ...
                         'Var. est.' 'Var. lower bnd' 'Var. upper bnd'};
   tbl(1+(1:nterms),C+1)          = {'fixed'};
   tbl(1+rterms,C+1)              = {'random'};
   tbl(1+(1:length(txtems)),C+2)  = txtems;
   tbl(1+(1:length(msdenom)),C+3) = num2cell(msdenom(:));
   tbl(1+(1:length(dfdenom)),C+4) = num2cell(dfdenom(:));
   tbl(1+(1:length(txtdenom)),C+5)= txtdenom;
   tbl(1+rterms,C+6)              = num2cell(varest);
   tbl(1+rterms,C+7)              = num2cell(varci(:,1));
   tbl(1+rterms,C+8)              = num2cell(varci(:,2));
end

% Add total information
tbl{end+1,1} = 'Total';
tbl{end,2} = sst;
tbl{end,3} = n-1;
tbl{end,4} = 0;

if (nargout > 1), t = tbl; end
if (nargout > 3), terms = termlist; end

% For display, mark terms that are rank deficient
tbl{1,1} = ['  ' tbl{1,1}];
for r=2:size(tbl,1)
   x = tbl{r,1};
   if (tbl{r,4})
      x = ['# ' x];
   else
      x = ['  ' x];
   end
   tbl{r,1} = x;
end
tbl = tbl(:,[1 2 3 5 6 7]);

if (isequal(displayopt,'on'))
   switch(sstype)
    case 1,    cap = 'Sequential (Type I) sums of squares.';
    case 2,    cap = 'Hierarchical (Type II) sums of squares.';
    otherwise, cap = 'Constrained (Type III) sums of squares.';
   end
   if (any(sing)), cap = [cap '  Terms marked with # are not full rank.']; end
   digits = [-1 -1 -1 -1 2 4];
   figh = statdisptable(tbl, 'N-Way ANOVA', 'Analysis of Variance', cap, digits);
   set(figh,'HandleVisibility','callback');
end

% Store additional information for multiple comparisons
if dostats
   stats.terms = termlist;
   stats.nlevels = dfvar+1;
   stats.termcols = [1; termlength];
   stats.coeffnames = names;
   stats.vars = codes;
   stats.varnames = varnames;       % names of grouping variables
   stats.grpnames = allnames;       % names of levels of these variables
   if length(stats.resid)<length(nanrow)
      r(~nanrow) = stats.resid;
      r(nanrow) = NaN;
      stats.resid = r;
   end
   

   % Extra info for models with random effects
   if doems
      stats.ems = emsMat;
      stats.denom = denommat;
      stats.dfdenom = dfdenom;
      stats.msdenom = msdenom;
      stats.varest = varest;
      stats.varci = varci;
      stats.txtdenom = txtdenom;
      stats.txtems = txtems;
      stats.rtnames = rtnames;
   else
      stats.ems = [];
      stats.denom = [];
      stats.dfdenom = [];
      stats.msdenom = [];
      stats.varest = [];
      stats.varci = [];
      stats.txtdenom = [];
      stats.txtems = [];
      stats.rtnames = [];
   end
end

% --------------------------
function m = termsnotcontained(t)
%TERMSNOTCONTAINED Creates a logical matrix indicating term containment
%   m(i,j)==1  iff  t(i) is not contained by t(j)
%   set diagonals to 1 because we want proper containment

m = (t*~t') > 0;
m(1:(size(t,1)+1):end) = 1;

% --------------------------
function v = makemodel(p,ng)
%MAKEMODEL Helper function to make model matrix
%    P = max model term size, NG = number of grouping variables
% or
%    P = vector of term codes

% We want a matrix with one row per term.  Each row has a 1 for
% the variables participating in the term.  There will be rows
% summing up to 1, 2, ..., p.

if numel(p)==1
   % Create model matrix from a scalar max order value
   vgen = 1:ng;
   v = eye(ng);                      % linear terms
   for j=2:min(p,ng)
      c = nchoosek(vgen,j);          % generate column #'s with 1's
      nrows = size(c,1);             % generate row #'s
      r = repmat((1:nrows)',1,j);    %    and make it conform with c
      m = zeros(nrows,ng);           % create a matrix to get new rows
      m(r(:)+nrows*(c(:)-1)) = 1;    % fill in 1's
      v = [v; m];                    % append rows
   end
else
   % Create model matrix from terms encoded as bit patterms
   nterms = length(p);
   v = zeros(nterms,ng);
   for j=1:nterms
      tm = p(j);
      while(tm)
         % Get last-numbered effect remaining
         lne = 1 + floor(log2(tm));
         tm = bitset(tm, lne, 0);
         v(j,lne) = 1;
      end
   end
end

% --------------------------
function [ssx,dfx,dmat2,y2,stats] = dofit(dmat,y,cmat,sst,mu)
%DOFIT Do constrained least squares fit and reduce data for subsequent fits

% Tolerance for computing rank from diag(R) after QR decomposition
[nrows,ncols] = size(dmat);

% Find the null space of the constraints matrix
[Qc,Rc,Ec] = qr(cmat');
pc = Rrank(Rc);
Qc0 = Qc(:,pc+1:end);



% Do qr decomposition on design matrix projected to null space
Dproj = dmat*Qc0;
[Qd,Rd,Ed] = qr(Dproj,0);
dfx = Rrank(Rd);
Qd = Qd(:,1:dfx);
Rd = Rd(1:dfx,1:dfx);

% Fit y to design matrix in null space
y2 = Qd' * y;            % rotate y into that space
zq = Rd \ y2;            % fit rotated y to projected design matrix

z = zeros(length(Ed),1); % coefficent vector extend to full size ...
z(Ed(1:dfx)) = zq;       % ... and in correct order for null space

b = Qc0 * z;             % coefficients back in full space
ssx = norm(y2)^2;        % sum of squares explained by fit

% Return reduced design matrix if requested
if nargout>2
   dmat2 = Qd' * dmat;
end

% Prepare for multiple comparisons if requested
if (nargout >= 3)
   stats.source = 'anovan';
   
   % Get residuals
   yhat = Dproj * z;
   stats.resid = y - yhat;
   
   % Calculate coefficients, then adjust for previously removed mean
   t = b;
   t(1) = t(1) + mu;            % undo mean adjustment before storing
   stats.coeffs = t;

   RR = zeros(dfx,size(Dproj,2));
   RR(:,Ed(1:dfx)) = Rd;
   stats.Rtr = RR';
   [qq,rr,ee] = qr(dmat,0);
   pp = Rrank(rr);
   rowbasis = zeros(pp,size(rr,2));
   rowbasis(:,ee) = rr(1:pp,:);
   stats.rowbasis = rowbasis;
   stats.dfe = length(y) - dfx;
   stats.mse = (sst - ssx) / max(1, stats.dfe);
   stats.nullproject = Qc0;
end


% ---------------------
function p = Rrank(R,tol)
%RRANK Compute rank of R factor after qr decomposition
if (min(size(R))==1)
   d = abs(R(1,1));
else
   d = abs(diag(R));
end
if nargin<2
   tol = 100 * eps(class(d)) * max(size(R));
end
p = sum(d > tol*max(d));

% ----------------------
function ems = getems(L,R,termnums)
%GETEMS Final step in expected mean square computation
%   The L array is an array of constraints on the coefficients,
%   R is the R factor in a QR decomposition X, and termnums is a
%   vector mapping R column numbers to term numbers.  The output is
%   a vector of expected mean square coefficients with one element
%   per term.  The first element is for the constant term, and
%   the last is for the error term.  See "Computing Expected Mean
%   Squares" by Goodnight and Speed, 1978.

% In G&S notation, form the matrix L*pinv(X'*X)*L'.
dfL = size(L,1);
temp = L/R;
LML = temp*temp';

% Create the Cholesky decomposition U and then compute U\L.
U = statchol(LML);
C = U'\L;

% Sum the squared values of the columns other than the column for
% the constant term, and assign the sums to terms.
sumsq = sum(C(:,2:end).^2,1);
cols = termnums(2:end);
rows = ones(size(cols));
ems = accumarray([rows(:),cols(:)], sumsq) / dfL;
ems(:,end+1) = 1;  % add entry for error term


% -----------------------------
function L = getL(X, curcols, incols, L2);
%GETL Get L hypothesis matrix for the current term after adjusting for
%     terms that remain "in" for this test, making the whole thing
%     orthogonal to the matrix L2 containing hypotheses for terms that
%     contain the current term.
%
%        Type   incols                  L2
%        ----   --------------------    ----------------
%        1      lower-numbered terms    empty
%        2      non-containing terms    empty
%        3      non-containing terms    containing terms

x1 = X(:,curcols);     % the current term
x0 = X(:,incols);      % terms that remain "in" when testing x1

% Find hypothesis for the current term.  First remove effects of terms it does
% not contain (these terms remain in the model when testing the current term).
[Q0,R,E] = qr(x0,0);
tol = 100 * max(size(x0)) * eps(R(1,1));
if min(size(R))>1
   p = sum(abs(diag(R)) > tol);
else
   p = 1;
end

Q0 = Q0(:,1:p);
adjx1 = x1 - Q0 * (Q0' * x1);

% Now find a full-rank basis for the adjusted effect.
[Q2,R,E] = qr(adjx1,0);
tol = 100 * max(size(R)) * eps(R(1,1));
if min(size(R))>1
   p = sum(abs(diag(R)) > tol);
else
   p = 1;
end
Q2 = Q2(:,1:p);
L = Q2' * X;

% Make L rows orthogonal to the L rows for containing terms.
if ~isempty(L2)
   L2tr = L2';
   [Q,R,E] = qr(L2tr,0);
   tol = 100 * max(size(L2tr)) * eps(R(1,1));
   if min(size(R))>1
      p = sum(abs(diag(R)) > tol);
   else
      p = 1;
   end
   L = (L' - Q * (Q' * L'))';

   % Make L full rank
   [Q,R,E] = qr(L,0);
   tol = 100 * max(size(L)) * eps(R(1,1));
   if min(size(R))>1
      p = sum(abs(diag(R)) > tol);
   else
      p = 1;
   end
   if p<size(L,1)
      L = L(1:p,:);
   end
end


% -----------------------------
function RandomInfo = getRandomInfo(msTerm,dfTerm,msErr,dfErr,ems,...
                                    randomterms,tnames,alpha)
%GETRANDOMINFO Get info for random effects, such as denominator for F tests

nterms = length(msTerm);
msDenom = repmat(NaN,nterms,1);
dfDenom = repmat(NaN,nterms,1);
txtdenom = cell(nterms,1);
txtems = cell(nterms+1,1);
txtems{end} = 'V(Error)';

% For convenience, combine error info with term info
msTerm = [msTerm(:); msErr];
dfTerm = [dfTerm(:); dfErr];
randomterms = [randomterms(:); length(msTerm)];

% Find the matrix giving expected mean squares for random rows, and
% compute the coefficients of these expected values.
randrows = ems(randomterms,:);
emsmat = ems(1:end-1,:);
emsmat(1:size(emsmat,1)+1:end) = 0;
[q,r,e] = qr(randrows',0);
p = Rrank(r);
e = e(1:p);
B = r(1:p,:)\(q(:,1:p)'*emsmat');

% Loop over all terms
for j=1:nterms
   % First compute F statistic denominator information
   % See which terms are involved in this combination
   b = B(:,j);
   tol = sqrt(eps(class(b))) * max(abs(b));
   nonzeroterms = find(abs(b) >= tol);
   indices = e(nonzeroterms);
   tnums = randomterms(indices);
   if length(nonzeroterms) == 1
      % If it's a single term, use it exactly
      msDenom(j) = msTerm(tnums);
      dfDenom(j) = dfTerm(tnums);
      txtdenom{j} = sprintf('MS(%s)',tnames{tnums});
   else
      % Otherwise use the linear combination and Satterthwaite's approximation
      linprod = b(indices) .* msTerm(tnums);
      msDenom(j) = sum(linprod);
      dfDenom(j) = msDenom(j)^2 / sum((linprod.^2) ./ dfTerm(tnums));
      txtdenom{j} = linprodtxt(b(indices),tnames(tnums),'MS');
   end
   
   % Next get an expression for the expected mean square
   prefix = repmat('Q',nterms+1,1); % quadratic form for fixed effects
   prefix(randomterms,1) = 'V';     % variance for random effects
   txtems{j} = linprodtxt(ems(j,:),tnames,prefix);
end

% Get the variance component estimates
[varest,varci] = varcompest(ems,randomterms,msTerm,dfTerm,alpha);

% Package up the results
RandomInfo.msdenom = msDenom;
RandomInfo.dfdenom = dfDenom;
RandomInfo.varest = varest;
RandomInfo.varci = varci;
RandomInfo.txtdenom = txtdenom;
RandomInfo.txtems = txtems;
RandomInfo.denommat = B';
RandomInfo.rtnames = tnames(randomterms);


% -----------------------------------------
function [varest,varci] = varcompest(ems,Rterms,msTerm,dfTerm,alpha);
%VARCOMPEST Estimate variance components from obs. & exp. mean squares

nterms = length(msTerm) - 1;          % not including error term

Fterms = find(~ismember(1:nterms, Rterms));
Fterms = Fterms(:);

% Get A and B so that expected means square is Av+Bq
% where v is the variances and q is quadratic forms in the fixed effects
B = ems(Rterms, Fterms);
A = ems(Rterms, Rterms);
const = msTerm(Rterms) - B*msTerm(Fterms);
Ainv = pinv(A);          % should be well-conditioned and easily invertible
varest = Ainv * const;

% Get confidence bounds for the variance components
varci = repmat(NaN,length(varest),2);
if all(dfTerm>0)
   L = msTerm .* dfTerm ./ chi2inv(1-alpha/2,dfTerm);
   U = msTerm .* dfTerm ./ chi2inv(alpha/2,dfTerm);
   AinvB = Ainv * B;
   for j=find(varest'>0)
      Rcoeffs = Ainv(j,:);
      Fcoeffs = AinvB(j,:);
      t = (Rcoeffs>0);
      s = (Fcoeffs>0);
      cL = 0;
      cU = 0;
      if any(t)
         cL = cL + dot(Rcoeffs(t),  L(Rterms(t)));
         cU = cU + dot(Rcoeffs(t),  U(Rterms(t)));
      end
      if any(~t)
         cL = cL + dot(Rcoeffs(~t), U(Rterms(~t)));
         cU = cU + dot(Rcoeffs(~t), L(Rterms(~t)));
      end
      if any(s)
         cL = cL + dot(Fcoeffs(s),  L(Fterms(s)));
         cU = cU + dot(Fcoeffs(s),  U(Fterms(s)));
      end
      if any(~s)
         cL = cL + dot(Fcoeffs(~s), U(Fterms(~s)));
         cU = cU + dot(Fcoeffs(~s), L(Fterms(~s)));
      end
      varci(j,1) = max(0,cL);
      varci(j,2) = max(0,cU);
   end   
end

% ------------------------------------------------
function txt=linprodtxt(coeffs,names,prefix)
%LINPRODTXT Create a text representing a linear combination of some things

txt = '';
plustxt = '';

% If things will display as 0 or 1, make them exact
tol = sqrt(eps(class(coeffs))) * max(abs(coeffs));
coeffs(abs(coeffs)<tol) = 0;
coeffs(abs(coeffs-1)<tol) = 1;
coeffs(abs(coeffs+1)<tol) = -1;

% Add each component of the linear combination
preftxt = prefix;
for i=1:length(coeffs)
   bi = coeffs(i);
   if bi~=0
      % Get the sign
      if bi<0
         signtxt = '-';
      else
         signtxt = plustxt;
      end
      
      % Get the coefficient and multiplication symbol, unless it's one
      if abs(bi)==1
         coefftxt = '';
      else
         coefftxt = sprintf('%g*',abs(bi));
      end
      
      % If each row has its own prefix, get this one
      if size(prefix,1)>1
         preftxt = deblank(prefix(i,:));
      end
      
      txt = sprintf('%s%s%s%s(%s)',txt,signtxt,coefftxt,preftxt,names{i});
      plustxt = '+';
   end
end

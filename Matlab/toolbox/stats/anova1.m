function [p,anovatab,stats] = anova1(x,group,displayopt,extra)
%ANOVA1 One-way analysis of variance (ANOVA).
%   ANOVA1 performs a one-way ANOVA for comparing the means of two or more 
%   groups of data. It returns the p-value for the null hypothesis that the
%   means of the groups are equal.
%
%   P = ANOVA1(X,GROUP,DISPLAYOPT)
%   If X is a matrix, ANOVA1 treats each column as a separate group, and
%     determines whether the population means of the columns are equal.
%     This form of ANOVA1 is appropriate when each group has the same
%     number of elements (balanced ANOVA).  GROUP can be a character
%     array or a cell array of strings, with one row per column of
%     X, containing the group names.  Enter an empty array ([]) or
%     omit this argument if you do not want to specify group names.
%   If X is a vector, GROUP must be a vector of the same length, or a
%     string array or cell array of strings with one row for each
%     element of X.  X values corresponding to the same value of
%     GROUP are placed in the same group.
%
%   DISPLAYOPT can be 'on' (the default) to display figures
%   containing a standard one-way anova table and a boxplot, or
%   'off' to omit these displays.  Note that the notches in the
%   boxplot provide a test of group medians (see HELP BOXPLOT),
%   and this is not the same as the F test for different means
%   in the anova table.
%
%   [P,ANOVATAB] = ANOVA1(...) returns the ANOVA table values as the
%   cell array ANOVATAB.
%
%   [P,ANOVATAB,STATS] = ANOVA1(...) returns an additional structure
%   of statistics useful for performing a multiple comparison of means
%   with the MULTCOMPARE function.
%
%   See also ANOVA2, ANOVAN, BOXPLOT, MANOVA1, MULTCOMPARE.

%   Reference: Robert V. Hogg, and Johannes Ledolter, Engineering Statistics
%   Macmillan 1987 pp. 205-206.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.19.2.3 $  $Date: 2004/01/16 20:08:51 $

classical = 1;
nargs = nargin;
if (nargin>0 & strcmp(x,'kruskalwallis'))
   % Called via kruskalwallis function, adjust inputs
   classical = 0;
   if (nargin >= 2), x = group; group = []; end
   if (nargin >= 3), group = displayopt; displayopt = []; end
   if (nargin >= 4), displayopt = extra; end
   nargs = nargs-1;
end

error(nargchk(1,3,nargs,'struct'));

if (nargs < 2), group = []; end
if (nargs < 3), displayopt = 'on'; end
% Note: for backwards compatibility, accept 'nodisplay' for 'off'
willdisplay = ~(strcmp(displayopt,'nodisplay') | strcmp(displayopt,'n') ...
                | strcmp(displayopt,'off'));

% Convert group to cell array from character array, make it a column
if (ischar(group) & ~isempty(group)), group = cellstr(group); end
if (size(group, 1) == 1), group = group'; end

% If X is a matrix with NaNs, convert to vector form.
if (length(x) < prod(size(x)))
   if (any(isnan(x(:))))
      [n,m] = size(x);
      x = x(:);
      gi = reshape(repmat((1:m), n, 1), n*m, 1);
      if (length(group) == 0)     % no group names
         group = gi;
      elseif (size(group,1) == m)
         group = group(gi,:);
      else
         error('stats:anova1:InputSizeMismatch',...
               'X and GROUP must have the same length.');
      end
   end
end

% If X is a matrix and GROUP is strings, use GROUPs as names
if (iscell(group) & (length(x) < prod(size(x))) ...
                  & (size(x,2) == size(group,1)))
   named = 1;
   gnames = group;
   grouped = 0;
else
   named = 0;
   gnames = [];
   grouped = (length(group) > 0);
end

if (grouped)
   % Single data vector and a separate grouping variable
   x = x(:);
   lx = length(x);
   if (lx ~= prod(size(x)))
      error('stats:anova1:VectorRequired','First argument has to be a vector.')
   end
   nonan = ~isnan(x);
   x = x(nonan);

   % Convert group to indices 1,...,g and separate names
   group = group(nonan,:);
   [groupnum, gnames] = grp2idx(group);
   named = 1;

   % Remove NaN values
   nonan = ~isnan(groupnum);
   if (~all(nonan))
      groupnum = groupnum(nonan);
      x = x(nonan);
   end

   lx = length(x);
   xorig = x;                    % use uncentered version to make M
   groupnum = groupnum(:);
   maxi = size(gnames, 1);
   if isa(x,'single')
      xm = zeros(1,maxi,'single');
   else
      xm = zeros(1,maxi);
   end
   countx = xm;
   if (willdisplay), M = []; end
   if (classical)
      mu = mean(x);
      x = x - mu;                % center to improve accuracy
      xr = x;
   else
      [xr,tieadj] = tiedrank(x);
   end
   
   for j = 1:maxi
      % Get group sizes and means
      k = find(groupnum == j);
      lk = length(k);
      countx(j) = lk;
      xm(j) = mean(xr(k));       % column means

      if (willdisplay)           % create matrix for boxplot    
         [r, c] = size(M);
         if lk > r
            tmp = NaN;
            M(r+1:lk,:) = tmp(ones(lk - r,c));
            tmp = xorig(k);
            M = [M tmp];
         else
            tmp = xorig(k);
            tmp1 = NaN;
            tmp((lk + 1):r,1) = tmp1(ones(r - lk,1));
            M = [M tmp];
         end
      end
   
   end

   gm = mean(xr);                      % grand mean
   df1 = length(xm) - 1;               % Column degrees of freedom
   df2 = lx - df1 - 1;                 % Error degrees of freedom
   RSS = countx .* (xm - gm)*(xm-gm)'; % Regression Sum of Squares
else
   % Data in matrix form, no separate grouping variable
   [r,c] = size(x);
   lx = r * c;
   if (classical)
      xr = x;
      mu = mean(xr(:));
      xr = xr - mu;           % center to improve accuracy
   else
      [xr,tieadj] = tiedrank(x(:));
      xr = reshape(xr, size(x));
   end
   countx = repmat(r, 1, c);
   xorig = x;                 % save uncentered version for boxplot
   xm = mean(xr);             % column means
   gm = mean(xm);             % grand mean
   df1 = c-1;                 % Column degrees of freedom
   df2 = c*(r-1);             % Error degrees of freedom
   RSS = r*(xm - gm)*(xm-gm)';        % Regression Sum of Squares
end

TSS = (xr(:) - gm)'*(xr(:) - gm);  % Total Sum of Squares
SSE = TSS - RSS;                   % Error Sum of Squares

if (df2 > 0)
   mse = SSE/df2;
else
   mse = NaN;
end

if (classical)
   if (SSE~=0)
      F = (RSS/df1) / mse;
      p = 1 - fcdf(F,df1,df2);     % Probability of F given equal means.
   elseif (RSS==0)                 % Constant Matrix case.
      F = 0;
      p = 1;
   else                            % Perfect fit case.
      F = Inf;
      p = 0;
   end
else
   F = (12 * RSS) / (lx * (lx+1));
   if (tieadj > 0)
      F = F / (1 - 2 * tieadj/(lx^3-lx));
   end
   p = 1 - chi2cdf(F, df1);
end


Table=zeros(3,5);               %Formatting for ANOVA Table printout
Table(:,1)=[ RSS SSE TSS]';
Table(:,2)=[df1 df2 df1+df2]';
Table(:,3)=[ RSS/df1 mse Inf ]';
Table(:,4)=[ F Inf Inf ]';
Table(:,5)=[ p Inf Inf ]';

colheads = ['Source       ';'         SS  ';'          df ';...
            '       MS    ';'          F  ';'     Prob>F  '];
if (~classical)
   colheads(5,:) = '     Chi-sq  ';
   colheads(6,:) = '  Prob>Chi-sq';
end
rowheads = ['Columns    ';'Error      ';'Total      '];
if (grouped)
   rowheads(1,:) = 'Groups     ';
end

% Create cell array version of table
atab = num2cell(Table);
for i=1:size(atab,1)
   for j=1:size(atab,2)
      if (isinf(atab{i,j}))
         atab{i,j} = [];
      end
   end
end
atab = [cellstr(strjust(rowheads, 'left')), atab];
atab = [cellstr(strjust(colheads, 'left'))'; atab];
if (nargout > 1)
   anovatab = atab;
end

% Create output stats structure if requested, used by MULTCOMPARE
if (nargout > 2)
   if (length(gnames) > 0)
      stats.gnames = gnames;
   else
      stats.gnames = strjust(num2str((1:length(xm))'),'left');
   end
   stats.n = countx;
   if (classical)
      stats.source = 'anova1';
      stats.means = xm + mu;
      stats.df = df2;
      stats.s = sqrt(mse);
   else
      stats.source = 'kruskalwallis';
      stats.meanranks = xm;
      stats.sumt = 2 * tieadj;
   end
end

if (~willdisplay), return; end

digits = [-1 -1 0 -1 2 4];
if (classical)
   wtitle = 'One-way ANOVA';
   ttitle = 'ANOVA Table';
else
   wtitle = 'Kruskal-Wallis One-way ANOVA';
   ttitle = 'Kruskal-Wallis ANOVA Table';
end
statdisptable(atab, wtitle, ttitle, '', digits);

fig2 = figure('pos',get(gcf,'pos') + [0,-200,0,0]);

if (~grouped)
   boxplot(xorig,1);
else
   boxplot(M,1);
   h = get(gca,'XLabel');
   set(h,'String','Group Number');
end

% If there are group names, use them after removing blanks
if (length(gnames) > 0)
   gnames = strrep(gnames, '|', '_');
   gstr = gnames{1};
   for j=2:size(gnames,1)
      gstr = [gstr, '|', gnames{j}];
   end
   h = get(gca,'XLabel');
   if (named)
      set(h,'String','');
   end
   set(gca, 'xtick', (1:df1+1), 'xticklabel', gstr);
end

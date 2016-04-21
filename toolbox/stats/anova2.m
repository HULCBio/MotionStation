function [p,Table,stats] = anova2(X,reps,displayopt)
%ANOVA2 Two-way analysis of variance.
%   ANOVA2(X,REPS,DISPLAYOPT) performs a balanced two-way ANOVA for
%   comparing the means of two or more columns and two or more rows of the
%   sample in X.  The data in different columns represent changes in one
%   factor. The data in different rows represent changes in the other
%   factor. If there is more than one observation per row-column pair, then
%   then the argument REPS indicates the number of observations per "cell".
%   A cell contains REPS number of rows.  DISPLAYOPT can be 'on' (the
%   default) to display the table, or 'off' to skip the display. 
%
%   For example, if REPS = 3, then each cell contains 3 rows and the total
%   number of rows must be a multiple of 3. If X has 12 rows, and REPS = 3,
%   then the "row" factor has 4 levels (3*4 = 12). The second level of the 
%   row factor goes from rows 4 to 6.
%
%   [P,TABLE] = ANOVA2(...) returns two items.  P is a vector of p-values
%   for testing row, column, and if possible interaction effects.  TABLE
%   is a cell array containing the contents of the anova table.
%
%   [P,TABLE,STATS] = ANOVA2(...) returns an additional structure
%   of statistics useful for performing multiple comparisons with the
%   MULTCOMPARE function.
%
%   To perform unbalanced two-way ANOVA, use ANOVAN.
%
%   See also ANOVA1, ANOVAN.

%   Reference: Robert V. Hogg, and Johannes Ledolter, Engineering Statistics
%   Macmillan 1987 pp. 227-231. 

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.14.4.1 $  $Date: 2003/11/01 04:24:56 $

if (nargin<3), displayopt = 'on'; end
if (nargin < 1)
   error('stats:anova2:TooFewInputs','At least one input is required.');
end
if (any(isnan(X(:))))
   error('stats:anova2:DataNotBalanced',...
         'NaN values in input not allowed.  Use anovan instead.');
end
[r,c] = size(X);
if nargin == 1,
  reps = 1;
  m=r;
  Y = X;
elseif reps == 1
  m=r;
  Y = X;
else
  m = r/reps;
  if (floor(m) ~= r/reps), 
      error('stats:anova2:BadSize',...
            'The number of rows must be a multiple of reps.');
  end
  Y = zeros(m,c);
  for i=1:m,
      j = (i-1)*reps;
      Y(i,:) = mean(X(j+1:j+reps,:));
  end
end
colmean = mean(Y);          % column means
rowmean = mean(Y');         % row means
gm = mean(colmean);         % grand mean
df1 = c-1;                  % Column degrees of freedom
df2 = m-1;                  % Row degrees of freedom
if reps == 1,
  edf = (c-1)*(r-1);% Error degrees of freedom. No replication. This assumes an additive model.
else
  edf = (c*m*(reps-1));     % Error degrees of freedom with replicates
  idf = (c-1)*(m-1);        % Interaction degrees of freedom
end
CSS = m*reps*(colmean - gm)*(colmean-gm)';              % Column Sum of Squares
RSS = c*reps*(rowmean - gm)*(rowmean-gm)';              % Row Sum of Squares
correction = (c*m*reps)*gm^2;
TSS = sum(sum(X .* X)) - correction;                    % Total Sum of Squares
ISS = reps*sum(sum(Y .* Y)) - correction - CSS - RSS;   % Interaction Sum of Squares
if reps == 1,
  SSE = ISS;
else
  SSE = TSS - CSS - RSS - ISS;          % Error Sum of Squares
end

ip = NaN;
if (SSE~=0)
    MSE  = SSE/edf;
    colf = (CSS/df1) / MSE;
    rowf = (RSS/df2) / MSE;
    colp = 1 - fcdf(colf,df1,edf);  % Probability of F given equal column means.
    rowp = 1 - fcdf(rowf,df2,edf);  % Probability of F given equal row means.
    p    = [colp rowp];

    if (reps > 1),
       intf = (ISS/idf)/MSE;
       ip   = 1 - fcdf(intf,idf,edf);
       p   = [p ip];
    end
    
else                    % Dealing with special cases around no error.
    if (edf > 0)
       MSE = 0;
    else
       MSE = NaN;
    end
    if CSS==0,          % No between column variability.            
      colf = 0;
      colp = 1;
    else                % Between column variability.
      colf = Inf;
      colp = 0;
    end

    if RSS==0,          % No between row variability.
      rowf = 0;
      rowp = 1;
    else                % Between row variability.
      rowf = Inf;
      rowp = 0;
    end
    
    p = [colp rowp];

    if (reps>1) & (ISS==0)  % Replication but no interactions.
      intf = 0;
      p = [p 1];
    elseif (reps>1)         % Replication with interactions.
      intf = Inf;
      p = [p 0];
    end 
end

if (reps > 1),
  Table{6,6} = [];   %Formatting for ANOVA Table printout with interactions.
  Table(2:6,1)={'Columns';'Rows';'Interaction';'Error';'Total'};
  Table(2:6,2)={CSS; RSS; ISS; SSE; TSS};
  Table(2:6,3)={df1; df2; idf; edf; r*c-1};
  Table(2:5,4)={CSS/df1; RSS/df2; ISS/idf; SSE/edf;};
  Table(2:4,5)={colf; rowf; intf};
else
  Table{5,6} = [];   %Formatting for ANOVA Table printout no interactions.
  Table(2:5,1)={'Columns';'Rows';'Error';'Total'};
  Table(2:5,2)={CSS; RSS; SSE; TSS};
  Table(2:5,3)={df1; df2; edf; r*c-1};
  Table(2:4,4)={CSS/df1; RSS/df2; SSE/edf;};
  Table(2:3,5)={colf; rowf};
end

Table(1,1:6) = {'Source' 'SS' 'df' 'MS' 'F' 'Prob>F'};
Table(2:(1+length(p)),6) = num2cell(p);

if (isequal(displayopt, 'on'))
   digits = [-1 -1 0 -1 2 4];
   statdisptable(Table, 'Two-way ANOVA', 'ANOVA Table', '', digits);
end

if (nargout > 2)
   stats.source = 'anova2';
   stats.sigmasq = MSE;
   stats.colmeans = colmean;   % mean of columns
   stats.coln = m*reps;        % n for estimating column means
   stats.rowmeans = rowmean;
   stats.rown = c*reps;
   stats.inter = (reps>1);     % was an interaction term included?
   stats.pval = ip;            % p-value for interactions
   stats.df = edf;
end
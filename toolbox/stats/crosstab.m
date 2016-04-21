function [table, chi2, p, labels] = crosstab(varargin)
%CROSSTAB Cross-tabulation of column vectors.
%   CROSSTAB(COL1,COL2,...) takes vectors, string arrays, or cell
%   arrays of strings, and returns an array, TABLE, of crosstabs.
%   Element (i,j,...) of TABLE contains the count of all instances
%   where COL1 = i, COL2 = j, and so on.
%
%   [TABLE, CHI2, P] = CROSSTAB(...) also returns the chisquare
%   statistic, CHI2, for testing independence of each dimension of
%   TABLE. (That is, that the proportion of items falling in any
%   cell is equal to the product of the proportion in that row,
%   times the proportion in that column, and so on.)  The scalar,
%   P, is the significance level of the test.  Values of P near
%   zero cast doubt on the assumption of independence.
%
%   [TABLE, CHI2, P, LABELS] = CROSSTAB(...) also returns a cell
%   array of labels for TABLE.  The entries in the first column of
%   LABELS are labels for the rows of TABLE, the entries in the
%   second column are labels for the columns, and so on.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.12.2.1 $  $Date: 2003/11/01 04:25:38 $

sz = zeros(1,nargin);
if (nargout > 3), labels = cell(0, nargin); end
nonan = [];
M = [];
for j=1:nargin
   [g1,g2] = grp2idx(varargin{j});
   ng = size(g2,1);
   if (nargout > 3), labels(1:ng,j) = g2; end
   sz(j) = ng;
   n = length(g1);
   if (j == 1)
      n1 = n;
      nonan = ~isnan(g1);
      M = zeros(n,nargin);
      M(:,1) = g1;
   elseif (n ~= n1)
      error('stats:crosstab:InputSizeMismatch',...
            'All arguments must have the same length');
   else
      nonan = nonan & ~isnan(g1);
      M(:,j) = g1;
   end
end

M = M(nonan,:);
n = size(M,1);

if (length(sz) > 1)
   table = zeros(sz);
else
   table = zeros(sz, 1);
end

for k = 1:n
   N = num2cell(M(k,:));
   table(N{:}) = table(N{:}) + 1;
end
 
if (nargout > 1) & (sum(sz>1) > 1)
   % Remove degenerate dimensions
   if any(sz==1)
      sz = sz(sz>1);
      T = reshape(table,sz);
   else
      T = table;
   end
      
   expected = zeros(sz);
   expected(:) = n;
   szv = sz;
   permv = [(2:length(sz)) 1];
   for j = 1:nargin
      sz1 = szv(1);
      sz2 = prod(szv(2:end));
      frac = sum(reshape(T, sz1, sz2), 2) / n;
      frac = reshape(repmat(frac,1,sz2),szv);
      expected = expected .* frac;
      expected = shiftdim(expected, 1);
      szv = szv(permv);
      T = shiftdim(T, 1);
   end

   chi2 = (T - expected).^ 2 ./ expected;
   chi2 = sum(chi2(:));
   df = prod(sz) - (1 + sum(sz - 1));
   p = 1 - chi2cdf(chi2,df);

elseif (nargout > 1)      % nargin <= 1
   chi2 = NaN;
   p = NaN;
end
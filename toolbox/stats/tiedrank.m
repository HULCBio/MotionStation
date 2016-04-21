function [r, tieadj] = tiedrank(x, flag)
%TIEDRANK Compute the ranks of a sample, adjusting for ties.
%   [R, TIEADJ] = TIEDRANK(X) computes the ranks of the values in the
%   vector X.  If any X values are tied, TIEDRANK computes their average
%   rank.  The return value TIEADJ is an adjustment for ties required by
%   the nonparametric tests SIGNRANK and RANKSUM, and for the computation
%   of Spearman's rank correlation.
%
%   [R, TIEADJ] = TIEDRANK(X,1) computes the ranks of the values in the
%   vector X.  TIEADJ is a vector of three adjustments for ties required
%   in the computation of Kendall's tau.
%
%   See also CORR, RANKSUM, SIGNRANK.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.5.2.2 $  $Date: 2004/01/16 20:10:34 $

if ~isvector(x)
   error('stats:tiedrank:InvalidData','TIEDRANK requires a vector.');
end

if nargin < 2
    flag = false;
end
[sx, rowidx] = sort(x(:));
ranks = 1:numel(x);
if isa(x,'single')
   ranks = single(ranks);
end

% Adjust for ties
tieloc = find(~diff(sx));
if flag
    tieadj = [0 0 0];
else
    tieadj = 0;
end
while (length(tieloc) > 0)
    tiestart = tieloc(1);
    ntied = 1 + sum(sx(tiestart) == sx(tiestart+1:end));
    if ntied > 1
        if flag
            n2minusn = ntied*(ntied-1);
            tieadj = tieadj + [n2minusn/2 n2minusn*(ntied-2) n2minusn*(2*ntied+5)];
        else
            tieadj = tieadj + ntied*(ntied-1)*(ntied+1)/2;
        end
    end
    ranks(tiestart:tiestart+ntied-1) = tiestart + (ntied-1)/2;
    tieloc(1:ntied-1) = [];
end

r(rowidx) = ranks;

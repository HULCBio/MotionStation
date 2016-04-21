function h = iscatter(x,y,i,c,m,msize)
%ISCATTER Scatter plot grouped by index vector.
%   ISCATTER(X,Y,I,C,M,msize) displays a scatter plot of X vs. Y grouped
%   by the index vector I.  
%
%   No error checking.  Use GSCATTER instead.
%
%   See also GSCATTER, GPLOTMATRIX.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.4.2.2 $  $Date: 2004/01/24 09:34:12 $

ni = max(i);
if (isempty(ni))
   i = ones(size(x,1),1);
   ni = 1;
end

nm = length(m);
nc = length(c);
ns = length(msize);

% Now draw the plot
hh = [];
for j=1:ni
   ii = (i == j);
   hhh = line(x(ii,:), y(ii,:), ...
              'LineStyle','none', 'Color', c(1+mod(j-1,nc)), ...
              'Marker', m(1+mod(j-1,nm)), 'MarkerSize', msize(1+mod(j-1,ns)));
   hh = [hh; hhh'];
end

% Return the handles if desired.  They are arranged so that even if X
% or Y is a matrix, the first ni elements of hh(:) represent different
% groups, so they are suitable for use in drawing a legend.
if (nargout>0)
   h = hh(:);
end


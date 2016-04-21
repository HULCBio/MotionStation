function h = manovacluster(stats,method)
%MANOVACLUSTER Cluster group means using manova1 output
%   MANOVACLUSTER(STATS) draws a dendrogram showing the clustering
%   of group means, calculated using the output STATS structure
%   from MANOVA1 and applying the single linkage algorithm.
%   See the DENDROGRAM function for more information about the figure.
%
%   MANOVACLUSTER(STATS,METHOD) uses the METHOD algorithm in place
%   of single linkage. The available methods are:
%
%      'single'   --- nearest distance
%      'complete' --- furthest distance
%      'average'  --- average distance
%      'centroid' --- center of mass distance
%      'ward'     --- inner squared distance
%
%   H = MANOVACLUSTER(...) returns a vector of line handles.
%
%   See also MANOVA1, DENDROGRAM, LINKAGE, PDIST, CLUSTER,
%   CLUSTERDATA, INCONSISTENT.

%   Tom Lane, 12-17-99
%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.4.2.1 $

% Draw dendrogram of multivariate group means
d = stats.gmdist;
gn = stats.gnames;
[a,b] = meshgrid(1:length(d));
if (nargin<2 | isempty(method)), method = 'single'; end
hh = dendrogram(linkage(d(a<b)', method), 0);

% Fix up X axis tick labels
oldlab = get(gca, 'XTickLabel');
maxlen = max(cellfun('length', gn));
newlab = repmat(' ', size(oldlab,1), maxlen);
ng = size(gn,1);
for j=1:size(oldlab,1)
   k = str2num(oldlab(j,:));
   if (~isempty(k) & k>0 & k<=ng)
      x = gn{k,:};
      newlab(j,1:length(x)) = x;
   end
end
set(gca, 'XtickLabel', newlab);

% Return handles if requested
if (nargout>0), h = hh; end

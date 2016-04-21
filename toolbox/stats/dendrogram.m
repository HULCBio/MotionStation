function [h,T,perm] = dendrogram(Z,varargin)
%DENDROGRAM Generate dendrogram plot.
%   DENDROGRAM(Z) generates a dendrogram plot of the hierarchical
%   binary cluster tree Z.  Z is an (M-1)-by-3 matrix, generated
%   by the LINKAGE function, where M is the number of objects in the
%   original dataset.
%
%   A dendrogram consists of many U-shaped lines connecting objects 
%   in a hierarchical tree.  Except for the Ward linkage (see LINKAGE), 
%   the height of each U represents the distance between the two 
%   objects being connected.
%
%   DENDROGRAM(Z,P) generates a dendrogram with only the top P nodes.
%   By default, DENDROGRAM uses 30 as the value of P.  When there are
%   more than 30 initial nodes, a dendrogram may look crowded.  To
%   display every node, set P = 0.
%
%   H = DENDROGRAM(...) returns a vector of line handles.
%
%   [H,T] = DENDROGRAM(...) generates a dendrogram and returns T, a vector of 
%   size M that contains the leaf node number for each object in the original 
%   dataset.  T is useful when P is less than the total number of objects, so 
%   some leaf nodes in the display correspond to multiple objects.  For 
%   example, to find out which objects are contained in leaf node k of the 
%   dendrogram, use find(T==k). When there are fewer than P objects in the 
%   original data, all objects are displayed in the dendrogram.  In this case, 
%   T is the identity map, i.e., T = (1:M)', where each node contains only itself.
%
%   [H,T,PERM] = DENDROGRAM(...) generates a dendrogram and returns 
%   the permutation vector of the node labels of the leaves of the 
%   dendrogram. PERM is ordered from left to right on a horizontal dendrogram 
%   and bottom to top for a vertical dendrogram.
%
%   [...] = DENDROGRAM(...,'COLORTHRESHOLD',T) assigns a unique color 
%   to each group of nodes within the dendrogram whose linkage is less than 
%   the scalar value T where T is in the range 0 < T < max(Z(:,3)). If T is 
%   less than or equal to zero or if T is greater than the maximum linkage then
%   the dendrogram will be drawn using only one color. T can also be set to 
%   'default' in which case the threshold will be set to 70% of the maximum 
%   linkage i.e. 0.7 * max(Z(:,3)).
%
%   [...] = DENDROGRAM(...,'ORIENTATION',ORIENT) will orient the dendrogram 
%   within the figure window. Options are:
%
%      'top'      --- top to bottom (default)
%      'bottom'   --- bottom to top
%      'left'     --- left to right
%      'right'    --- right to left
%
%   [...] = DENDROGRAM(...,'LABELS',S) accepts a character array or cell array
%   of strings S with one label for each observation.  Any leaves in the tree
%   containing a single observation are labeled with that observation's label.
%
%   Example:
%
%      rand('seed',12); 
%      X = rand(100,2); 
%      Y = pdist(X,'cityblock'); 
%      Z = linkage(Y,'average'); 
%      [H, T] = dendrogram(Z);
%
%   See also LINKAGE, PDIST, CLUSTER, CLUSTERDATA, INCONSISTENT.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 1.15.4.4 $


m = size(Z,1)+1;
if nargin < 2
    p = 30;
end

if nargin == 2
    p = varargin{1};
end

orientation = 't';
horz = false;
color = false;
obslabels = [];
threshold = 0.7 * max(Z(:,3));

if nargin > 2
    if isnumeric(varargin{1})
        p = varargin{1};
        offset = 1;
    else
        p = 30;
        offset = 0;
    end
    
    if rem(nargin - offset,2)== 0
        error('stats:dendrogram:BadNumArgs',...
              'Incorrect number of arguments to DENDROGRAM.');
    end
    okargs = {'orientation' 'colorthreshold' 'labels'};
    for j=(1 + offset):2:nargin-2
        pname = varargin{j};
        pval = varargin{j+1};
        k = strmatch(lower(pname), okargs);
        if isempty(k)
            error('stats:dendrogram:BadParameter',...
                  'Unknown parameter name:  %s.',pname);
        elseif length(k)>1
            error('stats:dendrogram:BadParameter',...
                  'Ambiguous parameter name:  %s.',pname);
        else
            switch(k)
            case 1  % orientation
                if ~isempty(pval)
                    if ischar(pval)
                        orientation = lower(pval(1));
                    else
                        orientation = 0;    % bad value
                    end
                end
                if ~ismember(orientation,{'t','b','r','l'})
                    orientation = 't';
                    warning('stats:dendrogram:BadOrientation',...
                            'Unknown orientation specified, using ''top''.');
                end
                if ismember(orientation,{'r','l'})
                    horz = true;
                else
                    horz = false;
                end
            case 2  % colorthreshold
                color = true;
                if ischar(pval) 
                    if ~strncmp(lower(pval),'default',length(pval))
                        warning('stats:dendrogram:BadThreshold',...
                                'Unknown threshold specified, using default');
                    end
                end
                if isnumeric(pval)
                    threshold = pval;
                end
             case 3 % labels
                if ischar(pval)
                   pval = cellstr(pval);
                end
                if ~iscellstr(pval)
                   error('stats:dendrogram:BadLabels',...
                         'Value of ''labels'' parameter is invalid');
                end
                if ~isvector(pval) || numel(pval)~=m
                   error('stats:dendrogram:InputSizeMismatch',...
                         'Must supply a label for each observation.');
                end
                obslabels = pval(:);
            end
        end
    end
end

% For each node currently labeled m+k, replace its index by
% min(i,j) where i and j are the nodes under node m+k.
Z = transz(Z);
T = (1:m)';

% If there are more than p nodes, the dendrogram looks crowded.
% The following code will make the last p link nodes into leaf nodes,
% and only these p nodes will be visible.
if (m > p) & (p ~= 0)
    
    Y = Z((m-p+1):end,:);         % get the last nodes
    
    R = unique(Y(:,1:2)); 
    Rlp = R(R<=p);
    Rgp = R(R>p);
    W(Rlp) = Rlp;                 % use current node number if <=p
    W(Rgp) = setdiff(1:p, Rlp);   % otherwise get unused numbers <=p
    W = W(:);
    T(R) = W(R);

    % Assign each leaf in the original tree to one of the new node numbers
    for i = 1:p
        c = R(i);
        T = clusternum(Z,T,W(c),c,m-p+1,0); % assign to its leaves.
    end

    % Create new, smaller tree Z with new node numbering
    Y(:,1) = W(Y(:,1));
    Y(:,2) = W(Y(:,2));
    Z = Y;
    
    m = p; % reset the number of node to be 30 (row number = 29).
end

A = zeros(4,m-1);
B = A;
n = m;
X = 1:n;
Y = zeros(n,1);
r = Y;

% arrange Z into W so that there will be no crossing in the dendrogram.
W = zeros(size(Z));
W(1,:) = Z(1,:);

nsw = zeros(n,1); rsw = nsw;
nsw(Z(1,1:2)) = 1; rsw(1) = 1;
k = 2; s = 2;

while (k < n)
    i = s;
    while rsw(i) | ~any(nsw(Z(i,1:2)))
        if rsw(i) & i == s, s = s+1; end
        i = i+1;
    end
    
    W(k,:) = Z(i,:);
    nsw(Z(i,1:2)) = 1;
    rsw(i) = 1;
    if s == i, s = s+1; end
    k = k+1;
end

g = 1;
for k = 1:m-1 % initialize X
    i = W(k,1);
    if ~r(i),
        X(i) = g;
        g = g+1;
        r(i) = 1;
    end
    i = W(k,2);
    if ~r(i),
        X(i) = g;
        g = g+1;
        r(i) = 1;
    end
end
[u,perm]=sort(X);   % perm is the third output value
label = num2str(perm');
if ~isempty(obslabels)
   label = cellstr(label);
   % label(:) = {''};   % to make sure non-singletons get an empty label
   singletons = find(histc(T,1:m)==1);
   for j=1:length(singletons)
      sj = singletons(j);
      label(perm==sj) = obslabels(T==sj);
   end
end

% set up the color

numColors = 1;theGroups = 1;
groups = 0;
cmap = [0 0 1];

if color
    groups = sum(Z(:,3)< threshold);
    if groups > 1 & groups < (m-1)
        theGroups = zeros(m-1,1);
        numColors = 0;
        for count = groups:-1:1
            if (theGroups(count) == 0)
                P = zeros(m-1,1);
                P(count) = 1;
                P = colorcluster(Z,P,Z(count,1),count);
                P = colorcluster(Z,P,Z(count,2),count);
                numColors = numColors + 1;
                theGroups(logical(P)) = numColors;
            end
        end 
        cmap = hsv(numColors);
        cmap(end+1,:) = [0 0 0]; 
    else
        groups = 1;
    end
    
end  


if  isempty(get(0,'CurrentFigure')) | ishold
    figure;
    set(gcf,'Position', [50, 50, 800, 500]);
else
    newplot;
end

col = zeros(m-1,3);
h = zeros(m-1,1);

for n = 1:(m-1)
    i = Z(n,1); j = Z(n,2); w = Z(n,3);
    A(:,n) = [X(i) X(i) X(j) X(j)]';
    B(:,n) = [Y(i) w w Y(j)]';
    X(i) = (X(i)+X(j))/2; Y(i)  = w;
    if n <= groups
        col(n,:) = cmap(theGroups(n),:);
    else
        col(n,:) = cmap(end,:);
    end
end


ymin = min(Z(:,3));
ymax = max(Z(:,3));
margin = (ymax - ymin) * 0.05;
n = size(label,1);

if(~horz)
    for count = 1:(m-1)
        h(count) = line(A(:,count),B(:,count),'color',col(count,:));
    end
    lims = [0 m+1 max(0,ymin-margin) (ymax+margin)];
    set(gca, 'Xlim', [.5 ,(n +.5)], 'XTick', 1:n, 'XTickLabel', label, ...
        'Box', 'off');
    mask = logical([0 0 1 1]); 
    if strcmp(orientation,'b')
        set(gca,'XAxisLocation','top','Ydir','reverse');
    end 
else
    for count = 1:(m-1)
        h(count) = line(B(:,count),A(:,count),'color',col(count,:));
    end
    lims = [max(0,ymin-margin) (ymax+margin) 0 m+1 ];
    set(gca, 'Ylim', [.5 ,(n +.5)], 'YTick', 1:n, 'YTickLabel', label, ...
        'Box', 'off');
    mask = logical([1 1 0 0]);
    if strcmp(orientation, 'l')
        set(gca,'YAxisLocation','right','Xdir','reverse');
    end
end

if margin==0
    if ymax~=0
        lims(mask) = ymax * [0 1.25];
    else
        lims(mask) = [0 1];
    end
end
axis(lims);

% ---------------------------------------
function T = clusternum(X, T, c, k, m, d)
% assign leaves under cluster c to c.

d = d+1;
n = m; flag = 0;
while n > 1
    n = n-1;
    if X(n,1) == k % node k is not a leave, it has subtrees
        T = clusternum(X, T, c, k, n,d); % trace back left subtree
        T = clusternum(X, T, c, X(n,2), n,d);
        flag = 1; break;
    end
end

n = size(X,1);
if flag == 0 & d ~= 1 % row m is leaf node.
    T(X(m,1)) = c;
    T(X(m,2)) = c;
end
% ---------------------------------------
function T = colorcluster(X, T, k, m)
% find local clustering

n = m; 
while n > 1
    n = n-1;
    if X(n,1) == k % node k is not a leave, it has subtrees
        T = colorcluster(X, T, k, n); % trace back left subtree
        T = colorcluster(X, T, X(n,2), n);
        break;
    end
end
T(m) = 1;
% ---------------------------------------
function Z = transz(Z)
%TRANSZ Translate output of LINKAGE into another format.
%   This is a helper function used by DENDROGRAM and COPHENET.  

%   In LINKAGE, when a new cluster is formed from cluster i & j, it is
%   easier for the latter computation to name the newly formed cluster
%   min(i,j). However, this definition makes it hard to understand
%   the linkage information. We choose to give the newly formed
%   cluster a cluster index M+k, where M is the number of original
%   observation, and k means that this new cluster is the kth cluster
%   to be formmed. This helper function converts the M+k indexing into
%   min(i,j) indexing.

m = size(Z,1)+1;

for i = 1:(m-1)
    if Z(i,1) > m
        Z(i,1) = traceback(Z,Z(i,1));
    end
    if Z(i,2) > m
        Z(i,2) = traceback(Z,Z(i,2));
    end
    if Z(i,1) > Z(i,2)
        Z(i,1:2) = Z(i,[2 1]);
    end
end


function a = traceback(Z,b)

m = size(Z,1)+1;

if Z(b-m,1) > m
    a = traceback(Z,Z(b-m,1));
else
    a = Z(b-m,1);
end
if Z(b-m,2) > m
    c = traceback(Z,Z(b-m,2));
else
    c = Z(b-m,2);
end

a = min(a,c);

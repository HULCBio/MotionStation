function sepplot(A,xy,lname,sname)
%SEPPLOT Used by SEPDEMO to show the separators.
% sepplot(A,xy,lname,sname): plot a mesh, a matrix, a tree, a factor,
% highlighting the top-level separator.
%     A:  the matrix
%    xy: the xy coordinates of the mesh
% lname: the text of the name of the permutation (long)
% sname: the text of the name of the permutation (short)

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.8 $  $Date: 2002/04/15 03:37:22 $

if nargin<3
   lname = 'Some Ordering';
end;
if nargin<4
   sname = lname;
end;

subplot(2,2,1);

[n,n] = size(A);
[t,q] = etree(A);
A = A(q,q);
xy = xy(q,:);
[t,q] = etree(A);
[x,y,h,s] = treelayout(t,q);

% identify the top-level separator
sepvtx = n-s+1;
sep = sepvtx:n;

% identify the partitions (subtrees)
parts = find (t == sepvtx);
parts = [1 parts+1 n+1];  % identify them by their first vertices


highlight(A,xy,sep);
title('Finite Element Mesh')

subplot(2,2,2);
if s < n
   spypart(A,parts);
else
   spy(A);
end
title(lname)


subplot(2,2,3)
etreeplot(A);
title(['Elim Tree with ' sname])


subplot(2,2,4)
if s < n
   spypart(chol(A),parts);
else
   spy(chol(A));
end
title(['Factor with ' sname]);

%===============================================================================
function highlight(A,xy,sep)
%HIGHLIGHT Plot a mesh with subgraph highlighted.
%   highlight(A,xy,sep) plots a picture of the mesh A with
%   coordinates xy, highlighting the subgraph induced
%   by the vertices in sep.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.8 $  $Date: 2002/04/15 03:37:22 $

[n,n] = size(A);
[i,j] = find(A);

% Plot main graph with vertices before edges.

[ignore, p] = sort(max(i,j));
i = i(p);
j = j(p);
X = [ xy(i,1) xy(j,1) NaN*ones(size(i))]';
Y = [ xy(i,2) xy(j,2) NaN*ones(size(i))]';
xymin = min(xy);
xymax = max(xy);
range = max(xymax-xymin);
plot(X(:), Y(:), 'b-');
axis([xymin(1) xymin(1)+range xymin(2) xymin(2)+range]);
axis('square');
hold on;

% Highlight sep set.

B = A(sep,sep);
xB = xy(sep,1);
yB = xy(sep,2);
[i,j] = find(B);
X = [xB(i) xB(j) NaN*ones(size(i))]';
Y = [yB(i) yB(j) NaN*ones(size(i))]';
plot (X(:), Y(:), 'r-');
if n < 1200
   plot(xB,yB,'ro');
else
   plot(xB,yB,'r.');
end

hold off;

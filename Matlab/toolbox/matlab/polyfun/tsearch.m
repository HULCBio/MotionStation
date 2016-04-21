function k = tsearch(x,y,tri,xi,yi)
%TSEARCH Closest triangle search.
%   T = TSEARCH(X,Y,TRI,XI,YI) returns the index of the enclosing Delaunay
%   triangle for each point in XI,YI so that the enclosing triangle for
%   point (XI(k),YI(k)) is TRI(T(k),:).  TSEARCH returns NaN for all
%   points outside the convex hull.  Requires a triangulation TRI of the
%   points X,Y obtained from DELAUNAY.
%
%   See also DELAUNAY, DSEARCH, QHULL, TSEARCHN, DELAUNAYN.

%   Relies on the MEX file tsrchmx to do most of the work.

%   Clay M. Thompson 8-15-95
%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.17.4.1 $  $Date: 2004/01/24 09:22:48 $

if numel(xi) == 1
   x1 = x(tri(:,1))-xi; y1 = y(tri(:,1))-yi; 
   x2 = x(tri(:,2))-xi; y2 = y(tri(:,2))-yi; 
   x3 = x(tri(:,3))-xi; y3 = y(tri(:,3))-yi; 
   
   t =  (x1.*y2 > x2.*y1) + (x2.*y3 > x3.*y2) + (x3.*y1 > x1.*y3);
   k = min(find(t==3|t==0));
   if isempty(k) 
       k=nan; 
   end
   
else
    % Create TriangleGraph which is a sparse connectivity matrix
    ntri = size(tri,1);
    nxy = length(x);
    triangle_graph = sparse( repmat((1:ntri)',1,3), tri, 1, ntri, nxy);
    
    % call tsrchmx to do the work
    k = tsrchmx(x,y,tri,xi,yi,triangle_graph);

end

function [t, p] = tsearchn(x,tes,xi)
%TSEARCHN N-D closest simplex search.
%   T = TSEARCHN(X,TES,XI) returns the indices T of the enclosing simplex
%   of the Delaunay tessellation TES for each point in XI. X is 
%   an m-by-n matrix, representing m points in n-D space. XI is 
%   a p-by-n matrix, representing p points in n-D space.  TSEARCHN returns 
%   NaN for all points outside the convex hull of X. TSEARCHN requires a 
%   tessellation TES of the points X obtained from DELAUNAYN.
% 
%   [T,P] = TSEARCHN(X,TES,XI) also returns the barycentric coordinate P
%   of XI in the simplex TES. P is an p-by-n+1 matrix. Each row of P is the
%   barycentric coordinate of the corresponding point in XI. It is useful
%   for interpolation.
%
%   See also DSEARCHN, TSEARCH, QHULL, GRIDDATAN, DELAUNAYN.

%   Relies on the MEX file tsrchnmx to do most of the work.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.13.4.2 $  $Date: 2004/04/16 22:08:16 $


if size(xi,1) == 1
   myeps = -sqrt(eps);
   [m,n] = size(tes);
   v = ones(1,n);
   for i = 1:m
     p = [v; x(tes(i,:),:)'] \ [1; xi'];
     p = p';
     if all(p > myeps);
       t = i; return;
     end
   end
   t = nan; 
   p = nan*ones(1,n);
else
  if nargout == 2
    [t,p] = tsrchnmx(x',tes,xi',0);
    p = p';
  else
    t = tsrchnmx(x',tes,xi',2);
  end
end

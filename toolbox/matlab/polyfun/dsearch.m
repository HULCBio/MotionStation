function k = dsearch(varargin)
%DSEARCH Search Delaunay triangulation for nearest point.
%   K = DSEARCH(X,Y,TRI,XI,YI) returns the index of the nearest (x,y)
%   point to the point (xi,yi). Requires a triangulation TRI of
%   the points X,Y obtained from DELAUNAY.
%
%   K = DSEARCH(X,Y,TRI,XI,YI,S) uses the sparse matrix S instead of
%   computing it each time:
%   
%     S = sparse(tri(:,[1 1 2 2 3 3]),tri(:,[2 3 1 3 1 2]),1,nxy,nxy) 
%
%   where nxy = prod(size(x)).
%
%   See also TSEARCH, DELAUNAY, VORONOI.

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.11 $  $Date: 2002/04/15 04:24:45 $

%   This calls a MATLAB mex file.
k = dsrchmx(varargin{:});

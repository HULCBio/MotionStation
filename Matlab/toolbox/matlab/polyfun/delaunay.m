function tri = delaunay(x,y,options)
%DELAUNAY Delaunay triangulation.
%   TRI = DELAUNAY(X,Y) returns a set of triangles such that no data points
%   are contained in any triangle's circumcircle. Each row of the numt-by-3
%   matrix TRI defines one such triangle and contains indices into the
%   vectors X and Y. When the triangles cannot be computed (such as when the
%   original data is collinear, or X is empty), an empty matrix is returned.
%
%   DELAUNAY uses Qhull.
%
%   TRI = DELAUNAY(X,Y,OPTIONS) specifies a cell array of strings OPTIONS to
%   be used in Qhull via DELAUNAYN. The default options are {'Qt','Qbb','Qc'}.
%   If OPTIONS is [], the default options will be used.
%   If OPTIONS is {''}, no options will be used, not even the default.
%   For more information on Qhull and its options, see http://www.qhull.org.
%
%   Example:
%      x = [-0.5 -0.5 0.5 0.5];
%      y = [-0.5 0.5 0.5 -0.5];
%      tri = delaunay(x,y,{'Qt','Qbb','Qc','Qz'})
%
%   The Delaunay triangulation is used with: GRIDDATA (to interpolate scattered
%   data), CONVHULL, VORONOI (to compute the VORONOI diagram), and is useful by
%   itself to create a triangular grid for scattered data points.
%
%   The functions DSEARCH and TSEARCH search the triangulation to
%   find nearest neighbor points or enclosing triangles, respectively.
%   
%   See also VORONOI, TRIMESH, TRISURF, TRIPLOT, GRIDDATA, CONVHULL
%            DSEARCH, TSEARCH, DELAUNAY3, DELAUNAYN, QHULL.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.25.4.3 $  $Date: 2004/01/16 20:04:51 $

if nargin < 2
    error('MATLAB:delaunay:NotEnoughInputs','Needs at least 2 inputs.');
end
if ~isequal(size(x),size(y))
    error('MATLAB:delaunay:InputSizeMismatch',...
          'X and Y must be the same size.');
end
if nargin == 3
    if ( ~iscellstr(options) && ~isempty(options) )
        error('MATLAB:delaunay:OptsNotStringCell',...
              'OPTIONS should be cell array of strings.');
    end
    tri = delaunayn([x(:) y(:)],options);
else
    tri = delaunayn([x(:) y(:)]);
end

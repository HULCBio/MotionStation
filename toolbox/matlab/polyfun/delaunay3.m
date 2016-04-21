function t = delaunay3(x,y,z,options)
%DELAUNAY3  3-D Delaunay tessellation.
%   T = DELAUNAY3(X,Y,Z) returns a set of tetrahedrons such that no data
%   points of X are contained in any circumspheres of the tetrahedrons. T is
%   a numt-by-4 array. The entries in each row of T are indices of the
%   points in (X,Y,Z) forming a tetrahedron in the tessellation of (X,Y,Z).
%   When the triangles cannot be computed (such as when the original data is
%   collinear, or X is empty), an empty matrix is returned.
%
%   DELAUNAY3 uses Qhull. 
%
%   T = DELAUNAY3(X,Y,Z,OPTIONS) specifies a cell array of strings OPTIONS
%   to be used in Qhull via DELAUNAY3. The default options are
%   {'Qt','Qbb','Qc'}.
%   If OPTIONS is [], the default options will be used.
%   If OPTIONS is {''}, no options will be used, not even the default.
%   For more information on Qhull options, see http://www.qhull.org.
%
%   Example:
%      X = [-0.5 -0.5 -0.5 -0.5 0.5 0.5 0.5 0.5];
%      Y = [-0.5 -0.5 0.5 0.5 -0.5 -0.5 0.5 0.5];
%      Z = [-0.5 0.5 -0.5 0.5 -0.5 0.5 -0.5 0.5];
%      T = delaunay3( X, Y, Z, {'Qt', 'Qbb', 'Qc', 'Qz'} )
%
%   See also QHULL, DELAUNAY, DELAUNAYN, GRIDDATA3, GRIDDATAN,
%            VORONOIN, TETRAMESH.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.3 $ $Date: 2004/01/16 20:04:52 $

if nargin < 3
    error('MATLAB:delaunay3:NotEnoughInputs','Needs at least 3 inputs.');
end

if numel(x) ~= numel(y) || numel(x) ~= numel(z)
    error('MATLAB:delaunay3:InputSizeMismatch',...
          'X,Y,Z have to be the same size.');
end

if nargin > 3
    if ( ~iscellstr(options) && ~isempty(options) )
        error('MATLAB:delaunay:OptsNotStringCell',...
              'OPTIONS should be cell array of strings.');
    end
    t = delaunayn([x(:) y(:) z(:)],options);
else
    t = delaunayn([x(:) y(:) z(:)]);
end

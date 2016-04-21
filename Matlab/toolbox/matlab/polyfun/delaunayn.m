function t = delaunayn(x,options)
%DELAUNAYN  N-D Delaunay tessellation.
%   T = DELAUNAYN(X) returns a set of simplices such that no data points of
%   X are contained in any circumspheres of the simplices. The set of
%   simplices forms the Delaunay tessellation. X is an m-by-n array
%   representing m points in n-D space. T is a numt-by-(n+1) array where
%   each row is the indices into X of the vertices of the corresponding
%   simplex. When the simplices cannot be computed (such as when X is
%   degenerate, or X is empty), an empty matrix is returned.
%
%   DELAUNAYN uses Qhull. 
%
%   T = DELAUNAYN(X,OPTIONS) specifies a cell array of strings OPTIONS to
%   be used as options in Qhull. The default options are:
%                                 {'Qt','Qbb','Qc'} for 2D and 3D input,
%                                 {'Qt','Qbb','Qc','Qx'} for 4D and higher.  
%   If OPTIONS is [], the default options will be used.
%   If OPTIONS is {''}, no options will be used, not even the default.
%   For more information on Qhull options, see http://www.qhull.org.
%
%   Example:
%      X = [-0.5 -0.5  -0.5;
%           -0.5 -0.5   0.5;
%           -0.5  0.5  -0.5;
%           -0.5  0.5   0.5;
%            0.5 -0.5  -0.5;
%            0.5 -0.5   0.5;
%            0.5  0.5  -0.5;
%            0.5  0.5   0.5];
%      T = delaunayn(X);
%   errors, but hints that adding 'Qz' to the default options might help.
%      T = delaunayn(X,{'Qt','Qbb','Qc','Qz'});
%   To visualize this answer you can use the TETRAMESH function:
%      tetramesh(T,X)
%
%   See also QHULL, VORONOIN, CONVHULLN, DELAUNAY, DELAUNAY3, TETRAMESH.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.20.4.5 $ $Date: 2004/01/16 20:04:53 $

if nargin < 1
    error('MATLAB:delaunayn:NotEnoughInputs', 'Needs at least 1 input.');
end
if isempty(x), t = []; return; end
[x,idx,jdx] = unique(x,'rows');
idx = idx';

[m,n] = size(x);

if m < n+1,
  error('MATLAB:delaunayn:NotEnoughPtsForTessel',...
        'Not enough unique points to do tessellation.');
end
if any(isinf(x(:)) | isnan(x(:)))
  error('MATLAB:delaunayn:CannotTessellateInfOrNaN',...
        'Data containing Inf or NaN cannot be tessellated.');
end
if m == n+1
    t = 1:n+1;
    t = idx(1:n+1);
  return;
end

%default options
if n >= 4
    opt = 'Qt Qbb Qc Qx';
else 
    opt = 'Qt Qbb Qc';
end

if ( nargin > 1 && ~isempty(options) )
    if ~iscellstr(options)
        error('MATLAB:delaunayn:OptsNotStringCell',...
              'OPTIONS should be cell array of strings.');
    end
    sp = {' '};
    c = strcat(options,sp);
    opt = cat(2,c{:});   
end

t = qhullmx(x', 'd ', opt);

% try to get rid of zero volume simplices. They are generated
% because of the fuzzy jiggling.

[mt, nt] = size(t);
v = true(mt,1);

seps = eps^(4/5)*max(abs(x(:)));
try
    for i=1:mt
        val = abs(det(x(t(i,1:nt-1),:)-x(t(i,nt)*ones([nt-1, 1]),:))); 
        if val < seps
           v(i) = false;
        end
    end
catch
    error('MATLAB:delaunayn:InvalidOpts',...
          'Bad options choice. Try using different options.');
end

t = t(v,:);
t = idx(t);

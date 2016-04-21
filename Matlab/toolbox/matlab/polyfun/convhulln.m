function [k,v] = convhulln(x,options)
%CONVHULLN N-D Convex hull.
%   K = CONVHULLN(X) returns the indices K of the points in X that 
%   comprise the facets of the convex hull of X. 
%   X is an m-by-n array representing m points in n-D space. 
%   If the convex hull has p facets then K is p-by-n. 
%
%   CONVHULLN uses Qhull.
%
%   K = CONVHULLN(X,OPTIONS) specifies a cell array of strings OPTIONS to be
%   used as options in Qhull. The default options are:
%                                 {'Qt'} for 2D, 3D and 4D input,
%                                 {'Qt','Qx'} for 5D and higher. 
%   If OPTIONS is [], the default options will be used.
%   If OPTIONS is {''}, no options will be used, not even the default.
%   For more information on Qhull and its options, see http://www.qhull.org.
%
%   [K,V] = CONVHULLN(...) also returns the volume of the convex hull
%   in V. 
%
%   Example:
%      X = [0 0; 0 1e-10; 0 0; 1 1];
%      K = convhulln(X)
%   gives a warning that is suppresed by the additional option 'Pp':
%      K = convhulln(X,{'Qt','Pp'})
%
%   See also CONVHULL, QHULL, DELAUNAYN, VORONOIN, TSEARCHN, DSEARCHN.

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.14.4.3 $ $Date: 2004/01/16 20:04:50 $

if nargin < 1
    error('MATLAB:convhulln:NotEnoughInputs', 'Needs at least 1 input.');
end
[m,n] = size(x);
if m < n+1,
    error('MATLAB:convhulln:NotEnoughPtsForTessel',...
          'Not enough points to do tessellation.');
end

if any(isnan(x(:)) | isinf(x(:)))
    error('MATLAB:convhulln:CannotTessellateInfOrNaN',...
          'Data containing Inf or NaN, cannot be tessellated.');
end

%default options
if n >= 5
    opt = 'Qt Qx';
else 
    opt = 'Qt';
end

if ( nargin > 1 && ~isempty(options) )
    if ~iscellstr(options)
        error('MATLAB:convhulln:OptsNotStringCell',...
              'OPTIONS should be cell array of strings.');
    end
    sp = {' '};
    c = strcat(options,sp);
    opt = cat(2,c{:});
end

[k,vv] = qhullmx(x', opt);

if nargout > 1
    v = vv;
end

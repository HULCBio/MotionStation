function [k,v] = convhull(x,y,options)
%CONVHULL Convex hull.
%   K = CONVHULL(X,Y) returns indices into the X and Y vectors of the points on
%   the convex hull.  
%
%   CONVHULL uses Qhull.
%
%   K = CONVHULL(X,Y,OPTIONS) specifies a cell array of strings OPTIONS to
%   be used as options in Qhull via CONVHULLN. The default option is {'Qt'}.
%   If OPTIONS is [], the default options will be used.
%   If OPTIONS is {''}, no options will be used, not even the default.
%   For more information on Qhull and its options, see http://www.qhull.org.
%
%   [K,A] = CONVHULL(...) also returns the area of the convex hull in A.
%
%   Example:
%      X = [0 0 0 1];
%      Y = [0 1e-10 0 1];
%      K = convhull(X,Y,{'Qt','Pp'}) 
%
%   See also CONVHULLN, DELAUNAY, VORONOI, POLYAREA, QHULL.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.20.4.3 $  $Date: 2004/01/16 20:04:49 $

if nargin < 2
    error('MATLAB:convhull:NotEnoughInputs', 'Needs at least 2 inputs.');
end
if isempty(x) || isempty(y),
    k = [];
    return
end
if ~isequal(size(x),size(y))
    error('MATLAB:convhull:InputSizeMismatch',...
          'X and Y must be the same size.');
end
if nargin == 3
    if ( ~iscellstr(options) && ~isempty(options) )
        error('MATLAB:convhull:OptsNotStringCell',...
              'OPTIONS should be cell array of strings.');           
    end
    [k,v] = convhulln([x(:) y(:)],options);
else
    [k,v] = convhulln([x(:) y(:)]);   
end
% Sort the points
k = k(:);
xc = x(k); yc = y(k);
xm = mean(xc); ym = mean(yc);
phi = angle((xc-xm) + (yc-ym)*sqrt(-1));
[dum,ind] = unique(phi);
k = k(ind);
k = [k; k(1)];

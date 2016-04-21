function h = pcolor(varargin)
%PCOLOR Pseudocolor (checkerboard) plot.
%   PCOLOR(C) is a pseudocolor or "checkerboard" plot of matrix C.
%   The values of the elements of C specify the color in each
%   cell of the plot. In the default shading mode, 'faceted',
%   each cell has a constant color and the last row and column of
%   C are not used. With shading('interp'), each cell has color
%   resulting from bilinear interpolation of the color at its 
%   four vertices and all elements of C are used. 
%   The smallest and largest elements of C are assigned the first and
%   last colors given in the color table; colors for the remainder of the 
%   elements in C are determined by table-lookup within the remainder of 
%   the color table.
%
%   PCOLOR(X,Y,C), where X and Y are vectors or matrices, makes a
%   pseudocolor plot on the grid defined by X and Y.  X and Y could 
%   define the grid for a "disk", for example.
%
%   PCOLOR(AX,..) plots into AX instead of GCA.
%
%   H = PCOLOR(...) returns a handle to a SURFACE object.
%
%   PCOLOR is really a SURF with its view set to directly above.
%
%   See also CAXIS, SURF, MESH, IMAGE, SHADING.

%-------------------------------
%   Additional details:
%
%
%   PCOLOR sets the View property of the SURFACE object to directly 
%   overhead.
%
%   If the NextPlot axis property is REPLACE (HOLD is off), PCOLOR resets 
%   all axis properties, except Position, to their default values
%   and deletes all axis children (line, patch, surf, image, and 
%   text objects).  View is set to [0 90].

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.9.4.1 $  $Date: 2002/10/24 02:14:11 $

%   J.N. Little 1-5-92

% Parse possible Axes input
[cax,args,nargs] = axescheck(varargin{:});
error(nargchk(1,4,nargs))

cax = newplot(cax);
hold_state = ishold(cax);

if nargs == 1
    x = args{1};
    hh = surface(zeros(size(x)),x,'parent',cax);
    [m,n] = size(x);
    lims = [ 1 n 1 m];
elseif nargs == 3
    [x,y,c] = deal(args{1:3});
    hh = surface(x,y,zeros(size(c)),c,'parent',cax);
    lims = [min(min(x)) max(max(x)) min(min(y)) max(max(y))];
else
    error('Must have one or three input data arguments.')
end
if ~hold_state
    set(cax,'View',[0 90]);
    set(cax,'Box','on');
    axis(cax,lims);
end
if nargout == 1
    h = hh;
end

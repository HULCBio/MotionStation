function varargout = mapoutline(varargin)
%MAPOUTLINE Compute outline of a georeferenced image or data grid.
%
%   [X,Y] = MAPOUTLINE(R, HEIGHT, WIDTH) computes the outline of a
%   georeferenced image or regular gridded data set in map coordinates.  R
%   is a 3-by-2 affine referencing matrix.  HEIGHT and WIDTH are the image
%   dimensions.  X and Y are 4-by-1 column vectors containing the map
%   coordinates of the outer corners of the corner pixels, in the following
%   order:
%             (1,1), (HEIGHT,1), (HEIGHT, WIDTH), (1, WIDTH).
%
%   [X,Y] = MAPOUTLINE(R, SIZEA) accepts SIZEA = [HEIGHT, WIDTH, ...]
%   instead of HEIGHT and WIDTH.
%
%   [X,Y] = MAPOUTLINE(INFO) accepts a scalar struct array with the fields:
%
%                'RefMatrix'   A 3-by-2 referencing matrix
%                'Height'      A scalar number
%                'Width'       A scalar number
%
%   [X, Y] = MAPOUTLINE(...,'close') returns X and Y as 5-by-1 vectors,
%   appending the coordinates of the first of the four corners to the end.
%
%   [LON,LAT] = MAPOUTLINE(R,...), where R georeferences pixels to
%   longitude and latitude rather than map coordinates, returns the outline
%   in geographic coordinates.  Longitude must precede latitude in the
%   output argument list.
%
%   OUTLINE = MAPOUTLINE(...) returns the corner coordinates in a 4-by-2 or
%   5-by-2 array.
%
%   Examples
%   --------
%   % Draw an outline delineating a TIFF image with a world file
%   R = worldfileread('concord_ortho_w.tfw');
%   info = imfinfo('concord_ortho_w.tif');
%   [x,y] = mapoutline(R, info.Height, info.Width);
%   plot(x,y)
% 
%   % Draw an outline delineating a GeoTIFF image
%   info = geotiffinfo('boston.tif');
%   [x,y] = mapoutline(info, 'close');
%   plot(x,y)
%
%   See also MAKEREFMAT, MAPBBOX, PIXCENTERS, PIX2MAP.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 21:57:30 $ 

error(nargoutchk(0,2,nargout));

% Obtain R, height, width, and close logical
[R, h, w, closeOutline] = parsePixMapInputs('MAPOUTLINE', 'close', varargin{:});

% Get the outline values
if closeOutline
    outline = [(0.5 + [0  0;...
                       h  0;...
                       h  w;...
                       0  w;...
                       0  0]), ones(5,1)] * R;
else
    outline = [(0.5 + [0  0;...
                       h  0;...
                       h  w;...
                       0  w]), ones(4,1)] * R;
end

% Setup the return arguments 
if nargout <= 1
   varargout{1} = outline;
else
    varargout{1} = outline(:,1);
    varargout{2} = outline(:,2);
end

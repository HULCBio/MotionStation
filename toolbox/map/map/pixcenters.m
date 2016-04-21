function [x,y] = pixcenters(varargin)
%PIXCENTERS Compute pixel centers for georeferenced image or data grid.
%
%   [X,Y] = PIXCENTERS(R, HEIGHT, WIDTH) computes the center coordinates
%   for each pixel in a georeferenced image or regular gridded data set.  R
%   is a 3-by-2 affine referencing matrix.  HEIGHT and WIDTH are the image
%   dimensions.  If R does not include a rotation (R(1,1) = R(2,2) = 0),
%   then X is a 1-by-WIDTH vector and Y is a HEIGHT-by-1 vector. In this
%   case, the map coordinates of the pixel in row ROW and column COL are
%   given by X(COL), Y(ROW).  Otherwise, X and Y are each a HEIGHT-by-WIDTH
%   matrix such that X(COL,ROW), Y(COL,ROW) are the map coordinates of the
%   center of the pixel with subscripts (ROW, COL).
%
%   [X,Y] = PIXCENTERS(R, SIZEA) accepts the size vector
%   SIZEA = [HEIGHT, WIDTH, ...] instead of HEIGHT and WIDTH.
%
%   [X,Y] = PIXCENTERS(INFO) accepts a scalar struct array with the fields:
%
%              'RefMatrix'   A 3-by-2 referencing matrix
%              'Height'      A scalar number
%              'Width'       A scalar number
%
%   [X,Y] = PIXCENTERS(..., 'makegrid') returns X and Y as HEIGHT-by-WIDTH
%   matrices even if R (or INFO.RefMatrix) is irrotational. This can be
%   helpful when calling PIXCENTERS from within a function or script.
%
%   Notes
%   -----
%   For more information on referencing matrices, see the help for
%   MAKEREFMAT.
%
%   PIXCENTERS is useful for working with SURF, MESH, or SURFACE, or for
%   coordinate transformations.
%
%   The help for MAPSHOW provides an alternative version of the following
%   example.
%
%   Example
%   -------
%   [Z,R] = arcgridread('MtWashington-ft.grd');
%   [x,y] = pixcenters(R, size(Z));
%   h = surf(x,y,Z); axis equal; colormap(demcmap(Z))
%   set(h,'EdgeColor','none')
%   xlabel('x (easting in meters)'); ylabel('y (northing in meters')
%   zlabel('elevation in feet')
%
%   See also ARCGRIDREAD, MAKEREFMAT, MAPBBOX, MAPOUTLINE,
%            PIX2MAP, WORLDFILEREAD.

%   Copyright 1996-2003 The MathWorks, Inc.  
%   $Revision: 1.1.6.2 $  $Date: 2003/12/13 02:50:32 $

[R, height, width, gridrequest] ...
    = parsePixMapInputs('PIXCENTERS', 'makegrid', varargin{:});

if (gridrequest || (R(1,1) ~= 0) || (R(2,2) ~= 0))
    [r,c] = ndgrid(1:height,1:width);
    [x,y] = pix2map(R,r,c);
else
    [x,j] = pix2map(R,ones(1,width),1:width);
    [j,y] = pix2map(R,1:height,ones(1,height));
end

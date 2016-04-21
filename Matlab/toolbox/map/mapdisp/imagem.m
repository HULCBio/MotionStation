function hndl = imagem(varargin)
%IMAGEM  Display a regular matrix map as an image.
%
%  IMAGEM is obsolete; use GRID2IMAGE.
%
%  IMAGEM(MAP,R) displays a regular matrix map as an image. MAP can be a
%  matrix of dimension MxN or MxNx3, and can contain double, uint8, or
%  uint16 data. R is a 1x3 referencing vector defined as [cells/angleunit
%  north-latitude west-longitude], or a 3-by-2 referencing matrix, defining
%  a 2-dimensional affine transformation from pixel coordinates to spatial
%  coordinates.   The displayed map is a Platte Carre projection, treating
%  X as longitude and Y as latitude. This projection produces significant
%  distortion at the poles.
%
%  IMAGEM(MAP,R,'PropertyName',PropertyValue,...) uses the specified image
%  properties to display the map.  See the IMAGE function reference for a
%  list of properties that can be changed.
%
%  h = IMAGEM(...) returns the handle of the image object displayed.
%
%  See also GRI2IMAGE, IMAGE, MAPSHOW, MAPVIEW, MESHM, SURFACEM, SURFM.

%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.11.4.2 $  $Date: 2003/12/13 02:52:50 $

%warnobsolete(upper(mfilename));
h = grid2image(varargin{:});
% Return the handle, if requested
if nargout == 1
  hndl = h;
end

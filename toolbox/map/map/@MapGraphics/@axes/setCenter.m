function setCenter(this,center)
%SETCENTER Set axis center
%
%   SETCENTER(CENTER) sets the center of the map to be CENTER. CENTER is a 2
%   element array [X Y], the x and y coordinates, in map units, of the center of
%   the axes.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:12:59 $

if isempty(this.mapUnitInCM)
  error('MapUnitInCM must be set before changing the center.');
  % or no error and return an empty value?
  % or what?
else
  units = this.Units;
  this.Units = 'Centimeters';
  p = this.Position;
  xLim = center(1) + p(3) * [-1/2 1/2] / (this.getScale * this.mapUnitInCM);
  yLim = center(2) + p(4) * [-1/2 1/2] / (this.getScale * this.mapUnitInCM);
  this.XLim = xLim;
  this.YLim = yLim;
  this.Units = units;
end
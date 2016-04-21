function setScale(this,scale)
%SETSCALE set map scale
%
%   SETSCALE(DISPLAYSCALE) sets the absolute map scale to be the value of
%   DISPLAYSCALE. Typically this number is small. For example, setting the
%   DISPLAYSCALE to be 0.00001 means that 1 mile on the ground covers 0.0001
%   miles on the map.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2003/12/13 02:49:00 $

if isempty(this.MapUnitInCM)
  error('MapUnitInCM must be set before changing the scale.');
  % or no error and return an empty value?
else
  this.InverseScale = 1/scale;
  units = this.Units;
  this.Units = 'Centimeters';

  xCenterInMapUnits = sum(this.XLim) / 2;
  yCenterInMapUnits = sum(this.YLim) / 2;
  p = this.Position;

  xLim = xCenterInMapUnits + p(3) * [-1/2 1/2] / (scale * this.MapUnitInCM);
  yLim = yCenterInMapUnits + p(4) * [-1/2 1/2] / (scale * this.MapUnitInCM);
  this.XLim = xLim;
  this.YLim = yLim;
  this.Units = units;
  this.updateOriginalAxis;
end

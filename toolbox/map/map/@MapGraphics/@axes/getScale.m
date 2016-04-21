function scale = getScale(this)
%GETSCALE Returns the absolute map scale.  

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:12:55 $

if this.MapUnitInCM == 0
  scale = [];
else
  units = this.Units;
  this.Units = 'Centimeters';
  p = this.Position;
  this.Units = units;
  xScale = p(3) / (diff(this.XLim) * this.MapUnitInCM);
  yScale = p(4) / (diff(this.YLim) * this.MapUnitInCM);
  scale = min([xScale, yScale]);
end
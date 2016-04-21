function setMapUnits(this,viewer, mapUnitsTag)
% SETMAPUNITS

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 21:56:32 $

switch mapUnitsTag
 case 'none'
  viewer.Axis.setMapUnitInCM(0);
  viewer.ScaleDisplay.Enable = 'inactive';
  viewer.ScaleDisplay.String = 'Units Not Set';
  viewer.ScaleDisplay.BackgroundColor = [0.7020 0.7020 0.7020]; 
 case 'km'
  viewer.Axis.setMapUnitInCM(100000);
  viewer.ScaleDisplay.Enable = 'on';
  viewer.ScaleDisplay.BackgroundColor = 'w'; 
 case 'm'
  viewer.Axis.setMapUnitInCM(100);
  viewer.ScaleDisplay.Enable = 'on';
  viewer.ScaleDisplay.BackgroundColor = 'w'; 
 case 'cm'
  viewer.Axis.setMapUnitInCM(1);
  viewer.ScaleDisplay.Enable = 'on';
  viewer.ScaleDisplay.BackgroundColor = 'w'; 
 case 'mm'
  viewer.Axis.setMapUnitInCM(0.1);
  viewer.ScaleDisplay.Enable = 'on';
  viewer.ScaleDisplay.BackgroundColor = 'w'; 
 case 'u'
  viewer.Axis.setMapUnitInCM(0.0001);
  viewer.ScaleDisplay.Enable = 'on';
  viewer.ScaleDisplay.BackgroundColor = 'w'; 
 case 'nm'
  viewer.Axis.setMapUnitInCM(185200);
  viewer.ScaleDisplay.Enable = 'on';
  viewer.ScaleDisplay.BackgroundColor = 'w'; 
 case 'ft'
  viewer.Axis.setMapUnitInCM(30.48);
  viewer.ScaleDisplay.Enable = 'on';
  viewer.ScaleDisplay.BackgroundColor = 'w'; 
 case 'in'
  viewer.Axis.setMapUnitInCM(2.54);
  viewer.ScaleDisplay.Enable = 'on';
  viewer.ScaleDisplay.BackgroundColor = 'w'; 
 case 'yd'
  viewer.Axis.setMapUnitInCM(91.44);
  viewer.ScaleDisplay.Enable = 'on';
  viewer.ScaleDisplay.BackgroundColor = 'w';
 case 'mi'
  viewer.Axis.setMapUnitInCM(160934.4);
  viewer.ScaleDisplay.Enable = 'on';
  viewer.ScaleDisplay.BackgroundColor = 'w';
 case 'sf'
  viewer.Axis.setMapUnitInCM(30.4801);
  viewer.ScaleDisplay.Enable = 'on';
  viewer.ScaleDisplay.BackgroundColor = 'w'; 
 case 'sm'
  viewer.Axis.setMapUnitInCM(160934.7218694437);
  viewer.ScaleDisplay.Enable = 'on';
  viewer.ScaleDisplay.BackgroundColor = 'w'; 
end
% Force the listener to be called 
% and update the scale display 
viewer.Axis.XLim = viewer.Axis.XLim;
viewer.Axis.YLim = viewer.Axis.YLim;

% setMapUnits
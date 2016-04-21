function fitToWindow(this)
%FITTOWINDOW 
% 
%   fitToWindow sets the axis limits to view all data in the map.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/02/01 21:56:56 $

this.Axis.setAxesLimits(this.map.getBoundingBox.getBoxCorners);
this.Axis.refitAxisLimits; 
this.Axis.updateOriginalAxis;
vEvent = MapViewer.ViewChanged(this);
this.send('ViewChanged',vEvent);


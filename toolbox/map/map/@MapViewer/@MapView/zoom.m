function out = zoom(this,varargin)
%ZOOM   Zoom in and out on a map.
%   This method simply acts as a wrapper to call the HG zoom tool
%   and it ensures that all the layers are considered for when 
%   determining the default/reset plot view.

%   Copyright 1996-2003 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 21:57:10 $

KEY = 'matlab_graphics_resetplotview';
viewInfo = getappdata(this.Axis,KEY);
if (isempty(viewInfo))
  viewInfo = localCreateViewInfo(this.Axis,this);
  setappdata(this.Axis,KEY,viewInfo);
end

% Call the HG zoom
zoom(varargin{:});

function [viewinfo] = localCreateViewInfo(hAxes, this)  
% Same as the resetplotview localCreateViewInfo except that
% the XLim and YLim are from the largest layers on the map
% axis

% Turn of the listeners 
scribefiglisten(this.Figure,'off');

% Create a temporary Map axis for obtaining the maximum
% axis limits for the layers currently on the map.
tmpAxes = MapGraphics.axes('Parent',this.Axis.Parent,...
                           'Visible','off');
tmpAxes.setAxesLimits(this.map.getBoundingBox.getBoxCorners);
tmpAxes.refitAxisLimits; 

viewinfo.XLim = tmpAxes.XLim;
viewinfo.YLim = tmpAxes.YLim;

% Store axes view state
viewinfo.DataAspectRatio = get(hAxes,'DataAspectRatio');
viewinfo.DataAspectRatioMode = get(hAxes,'DataAspectRatioMode');
viewinfo.PlotBoxAspectRatio = get(hAxes,'PlotBoxAspectRatio');
viewinfo.PlotBoxAspectRatioMode = get(hAxes,'PlotBoxAspectRatioMode');
viewinfo.XLimMode = get(hAxes,'XLimMode');
viewinfo.YLimMode = get(hAxes,'YLimMode');
viewinfo.ZLim = get(hAxes,'zLim');
viewinfo.ZLimMode = get(hAxes,'ZLimMode');
viewinfo.CameraPosition = get(hAxes,'CameraPosition');
viewinfo.CameraViewAngleMode = get(hAxes,'CameraViewAngleMode');
viewinfo.CameraTarget = get(hAxes,'CameraTarget');
viewinfo.CameraPositionMode = get(hAxes,'CameraPositionMode');
viewinfo.CameraUpVector = get(hAxes,'CameraUpVector');
viewinfo.CameraTargetMode = get(hAxes,'CameraTargetMode');
viewinfo.CameraViewAngle = get(hAxes,'CameraViewAngle');
viewinfo.CameraUpVectorMode = get(hAxes,'CameraUpVectorMode');

delete(tmpAxes)
% Turn listeners back on 
scribefiglisten(this.Figure,'on');




function NewLims = setlims(Editor,XlimData,YlimData,AxisNumber)
%SETLIMS  Set axes limits & editor limmodes
 
%   Author(s): A. DiVergilio
%   Copyright 1986-2001 The MathWorks, Inc. 
%   $Revision: 1.7 $  $Date: 2001/08/18 22:43:46 $

PlotAxes = Editor.hgget_axeshandle;

%---Default y-axis is #1
if nargin<4, 
	AxisNumber = 1; 
end

%---Apply new x-axis limits
if ~isempty(XlimData)
	if ischar(XlimData)
		set(Editor.Axes,'XlimMode',XlimData);
	else
		set(Editor.Axes,'XlimMode','manual');
		set(PlotAxes,'XLim',XlimData);
	end
end

%---Apply new y-axis limits
if ~isempty(YlimData)
	if ischar(YlimData)
        set(Editor.Axes(AxisNumber),'YlimMode',YlimData);
	else
        set(Editor.Axes(AxisNumber),'YlimMode','manual');
		set(PlotAxes(AxisNumber),'YLim',YlimData);
	end
end

%---Update
Editor.updatelims;

%---Get new limits (updatelims may adjust limits if AxesEqual is on)
Lims = get(PlotAxes(AxisNumber),{'XLim','YLim'});
NewLims = [Lims{:}];

function load(Editor,SavedData,Version)
%LOAD  Restores saved Root Locus Editor settings.
%
%   See also SISOTOOL.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.12 $  $Date: 2002/04/10 04:57:59 $

% RE: 1) Editor should be made invisible prior to calling this
%        function to avoid multiple updates
%     2) Only set properties that may differ from tool prefs
Axes = Editor.Axes;
SavedData = loadconvert(Editor,SavedData,Version);

% Style properties
Editor.AxisEqual = SavedData.AxisEqual;

% Labels
Axes.Title = SavedData.Title;
Axes.Xlabel = SavedData.Xlabel;
Axes.Ylabel = SavedData.Ylabel;
set(Axes.TitleStyle,SavedData.TitleStyle);
set(Axes.XlabelStyle,SavedData.XlabelStyle);
set(Axes.YlabelStyle,SavedData.YlabelStyle);

% Limits
if strcmp(SavedData.Visible,'on')
   % Beware of reloading stale units (see geck 113670)
   set(getaxes(Axes),'Xlim',SavedData.Xlim,'Ylim',SavedData.Ylim)
   Axes.XlimMode = SavedData.XlimMode;
   Axes.YlimMode = SavedData.YlimMode;
end
Axes.LimitStack = SavedData.LimitStack;

% Grid 
Editor.GridOptions = SavedData.GridOptions;
Axes.Grid = SavedData.Grid;

% Set editor visibility (will trigger full update)
Editor.Visible = SavedData.Visible;

% Constraints
Editor.loadconstr(SavedData.Constraints);



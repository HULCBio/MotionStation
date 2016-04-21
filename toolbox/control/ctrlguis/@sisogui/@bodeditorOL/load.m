function load(Editor,SavedData,Version)
%LOAD  Restores saved Bode Editor settings.
%
%   See also SISOTOOL.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/10 05:02:45 $

% RE: 1) Editor should be made invisible prior to calling this
%        function to avoid multiple updates
%     2) Only set properties that may differ from tool prefs
Axes = Editor.Axes;
SavedData = loadconvert(Editor,SavedData,Version);

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
   set(getaxes(Axes),'Xlim',SavedData.Xlim,{'Ylim'},SavedData.Ylim)
   Axes.XlimMode = SavedData.XlimMode;
   Axes.YlimMode = SavedData.YlimMode;
end

% Grid 
Axes.Grid = SavedData.Grid;

% Plot visibility
Editor.MagVisible = SavedData.MagVisible;
Editor.PhaseVisible = SavedData.PhaseVisible;
Editor.MarginVisible = SavedData.MarginVisible;

% Set editor visibility (will trigger full update)
Editor.Visible = SavedData.Visible;

% Constraints
Editor.loadconstr(SavedData.Constraints);


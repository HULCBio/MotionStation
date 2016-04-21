function h = viewprefs(Target)
%VIEWPREFS  LTI Viewer preferences object contructor

%   Author(s): A. DiVergilio
%    Revised : Kamesh Subbarao 
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:16:12 $

%---Create class instance
h = cstprefs.viewprefs;

%---Get a copy of the toolbox preferences
h.ToolboxPreferences    = cstprefs.tbxprefs;

%---Copy relevent toolbox preferences to viewer
h.FrequencyUnits        = h.ToolboxPreferences.FrequencyUnits;
h.FrequencyScale        = h.ToolboxPreferences.FrequencyScale;
h.MagnitudeUnits        = h.ToolboxPreferences.MagnitudeUnits;
h.MagnitudeScale        = h.ToolboxPreferences.MagnitudeScale;
h.PhaseUnits            = h.ToolboxPreferences.PhaseUnits;
h.Grid                  = h.ToolboxPreferences.Grid;
h.TitleFontSize         = h.ToolboxPreferences.TitleFontSize;
h.TitleFontWeight       = h.ToolboxPreferences.TitleFontWeight;
h.TitleFontAngle        = h.ToolboxPreferences.TitleFontAngle;
h.XYLabelsFontSize      = h.ToolboxPreferences.XYLabelsFontSize;
h.XYLabelsFontWeight    = h.ToolboxPreferences.XYLabelsFontWeight;
h.XYLabelsFontAngle     = h.ToolboxPreferences.XYLabelsFontAngle;
h.AxesFontSize          = h.ToolboxPreferences.AxesFontSize;
h.AxesFontWeight        = h.ToolboxPreferences.AxesFontWeight;
h.AxesFontAngle         = h.ToolboxPreferences.AxesFontAngle;
h.IOLabelsFontSize      = h.ToolboxPreferences.IOLabelsFontSize;
h.IOLabelsFontWeight    = h.ToolboxPreferences.IOLabelsFontWeight;
h.IOLabelsFontAngle     = h.ToolboxPreferences.IOLabelsFontAngle;
h.AxesForegroundColor   = h.ToolboxPreferences.AxesForegroundColor;
h.SettlingTimeThreshold = h.ToolboxPreferences.SettlingTimeThreshold;
h.RiseTimeLimits        = h.ToolboxPreferences.RiseTimeLimits;
h.UnwrapPhase           = h.ToolboxPreferences.UnwrapPhase;
h.TimeVector            = []; % auto range
h.FrequencyVector       = []; % auto range
h.Target                = Target;
h.EditorFrame           = [];
h.Version               = h.ToolboxPreferences.Version;
function schema
%SCHEMA SISO Tool preferences schema

%   Author(s): A. DiVergilio
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5 $  $Date: 2002/04/10 05:07:05 $

%---Register class
c = schema.class(findpackage('sisogui'),'sisoprefs');

%---Define properties

%---Units/Scales
schema.prop(c,'FrequencyUnits',        'string');
schema.prop(c,'FrequencyScale',        'string');
schema.prop(c,'MagnitudeUnits',        'string');
schema.prop(c,'MagnitudeScale',        'string');
schema.prop(c,'PhaseUnits',            'string');

%---Grids
schema.prop(c,'Grid',                  'string');

%---Fonts
schema.prop(c,'TitleFontSize',         'MATLAB array');
schema.prop(c,'TitleFontWeight',       'string');
schema.prop(c,'TitleFontAngle',        'string');
schema.prop(c,'XYLabelsFontSize',      'MATLAB array');
schema.prop(c,'XYLabelsFontWeight',    'string');
schema.prop(c,'XYLabelsFontAngle',     'string');
schema.prop(c,'AxesFontSize',          'MATLAB array');
schema.prop(c,'AxesFontWeight',        'string');
schema.prop(c,'AxesFontAngle',         'string');

%---Colors
schema.prop(c,'AxesForegroundColor',   'MATLAB array');

%---Siso Tool Options
schema.prop(c,'CompensatorFormat',     'string');
schema.prop(c,'ShowSystemPZ',          'string');
schema.prop(c,'LineStyle',             'MATLAB array');

%---Phase Wrapping
schema.prop(c,'UnwrapPhase',           'string');

%---Handle to Figure containing target SISO Tool
schema.prop(c,'Target',                'MATLAB array');

%---UI Preferences
schema.prop(c,'UIFontSize',            'MATLAB array');

%---Handle to Toolbox Preferences
schema.prop(c,'ToolboxPreferences',    'handle');

%---Handle to Frame used to edit these preferences
schema.prop(c,'EditorFrame',           'MATLAB array');

%---Listeners
schema.prop(c,'Listeners',             'MATLAB array');


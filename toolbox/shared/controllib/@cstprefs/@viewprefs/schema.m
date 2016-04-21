function schema
%SCHEMA  LTI Viewer preferences schema

%   Author(s): A. DiVergilio
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:16:07 $

a = findpackage('cstprefs');

%---Register class
c = schema.class(a,'viewprefs');

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
schema.prop(c,'IOLabelsFontSize',      'MATLAB array');
schema.prop(c,'IOLabelsFontWeight',    'string');
schema.prop(c,'IOLabelsFontAngle',     'string');

%---Colors
schema.prop(c,'AxesForegroundColor',   'MATLAB array');

%---Response Characteristics
schema.prop(c,'SettlingTimeThreshold', 'MATLAB array');
schema.prop(c,'RiseTimeLimits',        'MATLAB array');

%---Phase Wrapping
schema.prop(c,'UnwrapPhase',           'string');

%---Parameters
schema.prop(c,'TimeVector',            'MATLAB array');
schema.prop(c,'FrequencyVector',       'MATLAB array');

%---Handle to Figure containing target viewer
schema.prop(c,'Target',                'MATLAB array');

%---Handle to Toolbox Preferences
schema.prop(c,'ToolboxPreferences',    'handle');

%---Handle to Frame used to edit these preferences
schema.prop(c,'EditorFrame',           'MATLAB array');

%---Listeners
schema.prop(c,'Listeners',             'MATLAB array');

%---Preference file version control
schema.prop(c,'Version',               'MATLAB array');


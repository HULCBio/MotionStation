function schema
%SCHEMA  Toolbox preferences schema

%   Author(s): A. DiVergilio
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:15:54 $

a = findpackage('cstprefs');

%---Register class
c = schema.class(a,'tbxprefs');

%---Default FontSizes are system-dependent
if isunix
    SysFontSize  = 10;
    UIFontSize   = 10;
    JavaFontSize = 12;
else
    SysFontSize  = 8;
    UIFontSize   = 8;
    JavaFontSize = 11;
end

%---Define properties

%---Units/Scales
localCreateProp(c, 'FrequencyUnits',        'string',  'rad/sec'     );
localCreateProp(c, 'FrequencyScale',        'string',  'log'         );
localCreateProp(c, 'MagnitudeUnits',        'string',  'dB'          );
localCreateProp(c, 'MagnitudeScale',        'string',  'linear'      );
localCreateProp(c, 'PhaseUnits',            'string',  'deg'         );

%---Grids
localCreateProp(c, 'Grid',                  'string',  'off'         );

%---Fonts
localCreateProp(c, 'TitleFontSize',         'MATLAB array', SysFontSize   );
localCreateProp(c, 'TitleFontWeight',       'string',  'normal'      );
localCreateProp(c, 'TitleFontAngle',        'string',  'normal'      );
localCreateProp(c, 'XYLabelsFontSize',      'MATLAB array', SysFontSize   );
localCreateProp(c, 'XYLabelsFontWeight',    'string',  'normal'      );
localCreateProp(c, 'XYLabelsFontAngle',     'string',  'normal'      );
localCreateProp(c, 'AxesFontSize',          'MATLAB array', SysFontSize   );
localCreateProp(c, 'AxesFontWeight',        'string',  'normal'      );
localCreateProp(c, 'AxesFontAngle',         'string',  'normal'      );
localCreateProp(c, 'IOLabelsFontSize',      'MATLAB array', SysFontSize   );
localCreateProp(c, 'IOLabelsFontWeight',    'string',  'normal'      );
localCreateProp(c, 'IOLabelsFontAngle',     'string',  'normal'      );

%---Colors
localCreateProp(c, 'AxesForegroundColor',   'MATLAB array', [0.4 0.4 0.4] );

%---Response Characteristics
localCreateProp(c, 'SettlingTimeThreshold', 'MATLAB array', 0.02          );
localCreateProp(c, 'RiseTimeLimits',        'MATLAB array', [0.1 0.9]     );

%---Phase Wrapping
localCreateProp(c, 'UnwrapPhase',           'string',  'on'          );

%---Siso Tool Options
localCreateProp(c, 'CompensatorFormat',     'string',  'TimeConstant1');
% Options are: [{TimeConstant1}|TimeConstant2|ZeroPoleGain]
localCreateProp(c, 'ShowSystemPZ',          'string',  'on'          );
localCreateProp(c, 'SISOToolStyle',         'MATLAB array', localSISOToolStyle);

%---UI Preferences
localCreateProp(c, 'UIFontSize',            'MATLAB array', UIFontSize    );
localCreateProp(c, 'JavaFontSize',          'MATLAB array', JavaFontSize  );
%---Only define java fonts if the system supports Java
if usejava('AWT')
    localCreateProp(c, 'JavaFontP','MATLAB array', java.awt.Font('Dialog',java.awt.Font.PLAIN,JavaFontSize));
    localCreateProp(c, 'JavaFontB','MATLAB array', java.awt.Font('Dialog',java.awt.Font.BOLD,JavaFontSize));
    localCreateProp(c, 'JavaFontI','MATLAB array', java.awt.Font('Dialog',java.awt.Font.ITALIC,JavaFontSize));
end

%---Preference file version control
localCreateProp(c,'Version','MATLAB array',1.1);

%---Show start up help message box
msgstr = struct( ...
    'SISOtool','on', ...
    'LTIviewer', 'on');
localCreateProp(c,'StartUpMsgBox','MATLAB array', msgstr);


%%%%%%%%%%%%%%%%%%%
% localCreateProp %
%%%%%%%%%%%%%%%%%%%
function localCreateProp(Class,PropName,DataType,FactoryValue)
% Add property to class and install default value
%---Add property to class
 p = schema.prop(Class,PropName,DataType);
%---Set Factory Value for property and use it upon initialization
 p.set('AccessFlags.Init','on','FactoryValue',FactoryValue);


%%%%%%%%%%%%%%%%%%%%%%
% localSISOToolStyle %
%%%%%%%%%%%%%%%%%%%%%%
function s = localSISOToolStyle
% Create the default SISO Tool style structure
s = struct(...
   'Color',[],...
   'Marker',[]);
s.Color = struct(...
   'ClosedLoop',[1 0 0.8],...
   'Compensator',[1 0 0],...
   'Margin',[.8 .5 0],...
   'PreFilter',[0 0.7 0],...
   'Response',[0 0 1],...
   'System',[0 0 1]);
s.Marker = struct(...
   'ClosedLoop','s');

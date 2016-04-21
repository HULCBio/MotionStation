function slinstallprefs

% Copyright 2004 The MathWorks, Inc.

% The classes below (as defined in info.xml) return the neccessary 
% set_params that need to be done to install Simulink preferences. 
prefClasses = {...
    'com.mathworks.toolbox.simulink.preferences.EditingConfig',...
    'com.mathworks.toolbox.simulink.preferences.FontConfig',...
    'com.mathworks.toolbox.simulink.preferences.ExecutionConfig'};

for i = 1:length(prefClasses)
    eval(['obj = ' prefClasses{i} ';']);
    obj.installPrefs;
end
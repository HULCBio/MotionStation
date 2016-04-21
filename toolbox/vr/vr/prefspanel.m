function prefspanel
%PREFSPANEL Registers a preferences control panel.
%   PREFSPANEL registers a Preferences Control panel with the MATLAB IDE.
%   The registration is accomplished by calling the IDE preferences dialog
%   registerPanel method.

%   Copyright 1998-2004 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2004/03/02 03:08:03 $ $Author: batserve $

% only if we have the desktop
if ~usejava('desktop')
  return;
end

% register the Virtual  preferences panel
com.mathworks.ide.prefs.PrefsDialog.registerPanel( ...
    'Virtual Reality Toolbox', ...
    'com.mathworks.toolbox.vr.preferences.GeneralConfig' ...
    );

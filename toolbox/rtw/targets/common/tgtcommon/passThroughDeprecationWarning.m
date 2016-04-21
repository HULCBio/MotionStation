function passThroughDeprecationWarning(varargin)
% passThroughDeprecationWarning
%
% m-file to display a warning message the first 
% time a pass through enabled driver block is detected,
% during a MATLAB session.

%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $
%   $Date: 2004/04/19 01:22:01 $

% warning message stating that old style pass through is being
% deprecated in future releases
warning_title = 'Driver block based pass through is deprecated.';
warning_string = [warning_title ...
                  ' This feature will be removed in a future release.'...
                  ' Your model contains driver blocks that are using the ''Enable pass through'' feature.'...
                  ' Please use the replacement mechanism as shown in the demonstration model, mpc555_fuelsys_project.'];
              
% we only need to show the warning once per session
persistent show_warning;

% provide a warning that the old style
% passthrough is being deprecated
if (isempty(show_warning))
    warndlg(warning_string, warning_title);
    show_warning = 0;
end;
return;

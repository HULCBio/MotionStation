function commandwindow
%COMMANDWINDOW Open the Command Window or bring it to the front.
%   COMMANDWINDOW Opens the Command Window or brings the Command Window
%   to the front if it is already open.
%
%   See also DESKTOP.

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $

try
    % Launch Java Command Window
    if usejava('desktop') %desktop mode
        % This means we're either running the new desktop, or no desktop,
        % so bring up MDE Java Command Window
        com.mathworks.mde.desk.MLDesktop.getInstance.showCommandWindow;
    else
        % In nodesktop or nojvm mode this will raise the windows command
        % window if it is open.  The following command has no impact on
        % unix.
        uimenufcn(0,'WindowCommandWindow')
    end
catch
    % Failed. Bail
    error('Failed to open the Command Window');
end
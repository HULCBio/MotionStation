function commandhistory
%COMMANDHISTORY Open the Command History window or bring it to the front.
%   COMMANDHISTORY Opens the Command History window or brings the Command
%   History window to the front if it is already open.

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $

% Make sure that we can support the Command History window on this platform.
errormsg = javachk('mwt', 'The Command History window');
if ~isempty(errormsg)
	error('MATLAB:cmdhist:UnsupportedPlatform', errormsg.message);
end

try
    % Launch Command History window
    com.mathworks.mde.cmdhist.CmdHistoryWindow.invoke;
catch
    error('MATLAB:cmdhist:CmdHistFailed', 'Failed to open the Command History window');
end

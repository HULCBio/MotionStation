function workspace
%WORKSPACE View the contents of a workspace.
%   WORKSPACE Opens the Workspace browser with a view of the variables
%   in the current Workspace.  Displayed variables may be viewed,
%   manipulated, saved, and cleared.
%
%   See also WHOS, OPENVAR, SAVE.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $

% Check for required level of Java support
err = javachk('mwt', 'The Workspace browser');
if (~isempty(err))
    error('MATLAB:workspace:UnsupportedPlatform', err.message);
end

%Launch the Workspace
try
    com.mathworks.mlservices.MLWorkspaceServices.invoke;
catch
    error('MATLAB:workspace:workspaceFailed', ...
    'Failed to open the Workspace browser');
end

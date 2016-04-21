function h = WorkspaceWrapper(wrapped)
    % Workspace Class constructor function
    % Wraps calls to the workspaces

    % Instantiate object
    h = DAStudio.WorkspaceWrapper;

    if nargin == 1
        h.wrappedWorkspace = wrapped;
    end


%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:31:31 $

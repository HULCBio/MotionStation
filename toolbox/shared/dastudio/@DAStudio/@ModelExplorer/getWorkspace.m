function ws = getWorkspace(h, hand)

    ws = [];

    if (hand.isa('Simulink.Root'))
        ws = DAStudio.Workspace;
    else
        try
            %if (hand.doesWorkspaceExist)
                ws = DAStudio.Workspace(hand.getWorkspace);
            %end
        catch
            % no workspaces for this type
        end
    end

%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:31:02 $

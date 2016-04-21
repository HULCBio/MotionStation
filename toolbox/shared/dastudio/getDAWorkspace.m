function daw = getDAWorkspace

    persistent theWorkspace;

    if isempty(theWorkspace)
        theWorkspace = dastudio.Workspace;
        theWorkspace.Name = 'MATLAB Workspace';
    end

    daw = theWorkspace;
                                            

%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:32:12 $

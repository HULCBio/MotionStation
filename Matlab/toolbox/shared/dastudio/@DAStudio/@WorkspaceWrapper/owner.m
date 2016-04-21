function response = owner(h)

    if (isempty(h.wrappedWorkspace))
        response = Simulink.Root;
    else
        response = h.wrappedWorkspace.owner;
    end


%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:31:38 $

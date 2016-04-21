function assignin(h, name, value)

    if (isempty(h.wrappedWorkspace))
        ws = 'base';
    else
        ws = h.wrappedWorkspace;
    end

    assignin(ws, name, value);


%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:31:33 $

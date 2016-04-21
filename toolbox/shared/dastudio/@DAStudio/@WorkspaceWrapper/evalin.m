function response = evalin(h, expr)

    if (isempty(h.wrappedWorkspace))
        ws = 'base';
    else
        ws = h.wrappedWorkspace;
    end

    response = evalin(ws, expr);


%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:31:35 $

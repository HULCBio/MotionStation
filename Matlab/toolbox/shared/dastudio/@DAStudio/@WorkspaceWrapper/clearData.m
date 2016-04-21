function clearData(h, names)

    nameList = [' '];
    for i=1:length ( names ),
      nameList = [ nameList names{i} ' '];
    end,

    if (isempty(h.wrappedWorkspace))
        ws = 'base';
    else
        ws = h.wrappedWorkspace;
    end

    evalin(ws, ['clear', nameList]);


%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:31:34 $

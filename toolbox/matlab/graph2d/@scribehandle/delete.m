function delete(hndl)
%SCRIBEHANDLE/DELETE Delete scribehandle object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.11.4.1 $  $Date: 2004/01/15 21:12:59 $

h=hndl.HGHandle;
if ishandle(h)
    ud = getscribeobjectdata(h);
    MLObj = ud.ObjectStore;
    delete(MLObj);
    delete(hndl.HGHandle);
end

    


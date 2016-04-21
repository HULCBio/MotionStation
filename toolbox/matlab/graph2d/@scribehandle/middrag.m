function middrag(hndl)
%SCRIBEHANDLE/MIDDRAG Drag scribehandle object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.10.4.1 $  $Date: 2004/01/15 21:13:10 $

ud = getscribeobjectdata(hndl.HGHandle);
MLObj = ud.ObjectStore;
MLObj = middrag(MLObj);

% writeback
ud.ObjectStore = MLObj;
setscribeobjectdata(hndl.HGHandle,ud);


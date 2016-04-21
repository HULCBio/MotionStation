function doclick(hndl)
%SCRIBEHANDLE/DOCLICK Click method for scribhandle object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.11.4.1 $  $Date: 2004/01/15 21:13:01 $

ud = getscribeobjectdata(hndl.HGHandle);
MLObj = ud.ObjectStore;
MLObj = doclick(MLObj);

% writeback
if ~isempty(MLObj) & ishandle(hndl.HGHandle)
   ud.ObjectStore = MLObj;
   setscribeobjectdata(hndl.HGHandle,ud);
end

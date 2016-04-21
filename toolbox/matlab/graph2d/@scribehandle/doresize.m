function doresize(hndl,varargin)
%SCRIBEHANDLE/DORESIZE Resize scribehandle object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.10.4.1 $  $Date: 2004/01/15 21:13:05 $

ud = getscribeobjectdata(hndl.HGHandle);
MLObj = ud.ObjectStore;
MLObj = doresize(MLObj, varargin{:});

% writeback
ud.ObjectStore = MLObj;
setscribeobjectdata(hndl.HGHandle,ud);

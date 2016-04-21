function set(hndl,varargin)
%SCRIBEHANDLE/SET Set scribehandle property
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.12.4.1 $  $Date: 2004/01/15 21:13:17 $

% get the object
ud = getscribeobjectdata(hndl.HGHandle);

% call object methods
MyObject = set(ud.ObjectStore,varargin{:});
ud.ObjectStore = MyObject;

% writeback
setscribeobjectdata(hndl.HGHandle,ud);




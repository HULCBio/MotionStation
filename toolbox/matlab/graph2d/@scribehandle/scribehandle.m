function h = scribehandle(MLObj)
%SCRIBEHANDLE/HANDLE   Wrapper class for Scribe HG Objects
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.18.4.1 $  $Date: 2004/01/15 21:13:15 $

if nargin==0
   h.HGHandle = [];
   h = class(h,'scribehandle');
   return
end

if isempty(MLObj)
   % create a 0x0 struct
   h = struct('HGHandle',{});
   h = class(h,'scribehandle');
   return
end

if isa(MLObj,'figobj')
   figHGHandle = MLObj.HGHandle;
   HGHandle = uimenu(...
           'Parent',figHGHandle,...
           'Tag','ScribeFigObjStorage',...
           'Visible','off',...
           'HandleVisibility','off');
   figUD = fighandle(HGHandle);
   % object to redirect deferencing...
   setscribeobjectdata(figHGHandle,figUD);
   
else
   HGHandle = MLObj.HGHandle;
end

h.HGHandle = HGHandle;

ud = getscribeobjectdata(HGHandle);
ud.ObjectStore = MLObj;

h = class(h,'scribehandle');

ud.HandleStore = h;
setscribeobjectdata(HGHandle,ud)


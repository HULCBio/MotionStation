function [xpcObj] = unload(xpcObj)
% UNLOAD Unloads the currently loaded application from the target.
%
%   UNLOAD(XPCOBJ) unloads the currently loaded application from the target
%   represented by XPCOBJ.
%
%   See also LOAD, REBOOT.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.5 $ $Date: 2002/03/25 04:17:36 $

try
  xpcObj = set(xpcObj, 'Command', 'Remove');
catch
  error(xpcgate('xpcerrorhandler'));
end
  
if (nargout == 0)
  if ~isempty(inputname(1)), assignin('caller', inputname(1), xpcObj); end
end

%% EOF unload.m

function [xpcObj] = stop(xpcObj)
% STOP stop exectution of the target application
%
%   STOP(XPCOBJ) stops the execution of the target application which is
%   pointed to by XPCOBJ.
%
%   See also START, LOAD, UNLOAD, XPC.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.5 $ $Date: 2002/03/25 04:16:41 $

if (prod(size(xpcObj)) > 1)
  error(sprintf('%s: Not a scalar', inputname(1)));
end

if strcmp(xpcObj.Application, 'loader') % No model loaded
  disp('No application to terminate');
  return;
end

try
  xpcObj = set(xpcObj, 'Command', 'Stop');
catch
  error(xpcgate('xpcerrorhandler'));
end

if (nargout == 0)
   if ~isempty(inputname(1)), assignin('caller', inputname(1), xpcObj); end
end

%% EOF stop.m
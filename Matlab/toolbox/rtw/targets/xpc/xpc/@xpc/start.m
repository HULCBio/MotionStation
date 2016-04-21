function [xpcObj] = start(xpcObj)
% START start target application execution
%
%   start(XPCOBJ) starts execution of the target application represented by
%   the xPC object XPCOBJ. XPCOBJ must have previously been created using
%   XPC and loaded onto the target using LOAD.
%
%   See also STOP, LOAD, UNLOAD, XPC.
%

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.9 $ $Date: 2002/03/25 04:17:24 $

if (prod(size(xpcObj)) > 1)
  error('xPC objects must be scalars');
end

try, modelname = xpcgate('getname');
catch, error(xpcgate('xpcerrorhandler')); end
  
if strcmp(modelname, 'loader') % No model loaded
  error('You must load a model first');
end

stopTime = str2num(xpcObj.StopTime);
try
  if (stopTime > 0.5) | (stopTime < 0)
    xpcObj = set(xpcObj, 'Command', 'Start');
  else                                  % to eliminate sync problems
    xpcgate('rlstart');
    for i = 1 : 5
      pause(stopTime);                  % Wait for simulation to finish.
      if ~xpcgate('isrun'), break; end  % stopped (not running)
    end
    sync(xpcObj);
  end
catch
  error(xpcgate('xpcerrorhandler'));
end

if (nargout == 0)
  if ~isempty(inputname(1)), assignin('caller', inputname(1), xpcObj); end
end

%% EOF start.m

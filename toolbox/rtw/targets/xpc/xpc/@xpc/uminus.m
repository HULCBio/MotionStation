function [xpcObj] = uminus(xpcObj)
% UMINUS synonym for the STOP command
%   -XPCOBJ is the same as saying STOP(XPCOBJ): both these forms stop the
%   target simulation represented by XPCOBJ.
%
%   See also UPLUS.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.6 $ $Date: 2002/03/25 04:17:33 $

try
  xpcObj = stop(xpcObj);
catch
  error(xpcgate('xpcerrorhandler'));
end

if (nargout == 0)
  if ~isempty(inputname(1)), assignin('caller', inputname(1), xpcObj); end
end

%% EOF uminus.m

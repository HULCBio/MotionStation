function [xpcObj] = uplus(xpcObj)
% UPLUS synonym for the START command
%   +XPCOBJ is the same as saying START(XPCOBJ): both these forms start the
%   target simulation represented by XPCOBJ.
%
%   See also UMINUS.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.6 $ $Date: 2002/03/25 04:17:39 $

try
  xpcObj = start(xpcObj);               % Use the start method in case
                                        % StopTime is less than 1 second.
catch
  error(xpcgate('xpcerrorhandler'));
end                                     

if (nargout == 0)
  if ~isempty(inputname(1)), assignin('caller', inputname(1), xpcObj); end
end

%% EOF uplus.m

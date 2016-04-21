function [xpcScopeObj] = uminus(xpcScopeObj)
% UMINUS synonym for the STOP command
%
%   -XPCSCOPEOBJ is the same as saying STOP(XPCSCOPEOBJ): both these forms
%   stop the scope represented by XPCSCOPEOBJ.
%
%   This is a private function and is not to be called directly.
%
%   See also UPLUS.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.7 $ $Date: 2002/03/25 04:24:55 $

try 
  xpcScopeObj = stop(xpcScopeObj);
catch
  error(xpcgate('xpcerrorhandler'));
end

% Vectorization of set will take care of vector xpcScopeObj
if (nargout == 0)
  if ~isempty(inputname(1))
    assignin('caller', inputname(1), xpcScopeObj);
  end    
end

%% EOF uminus.m

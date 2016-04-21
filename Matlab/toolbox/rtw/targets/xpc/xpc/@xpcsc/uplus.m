function [xpcScopeObj] = uplus(xpcScopeObj)
% UPLUS synonym for the START command
%
%   +XPCSCOPEOBJ is the same as saying START(XPCSCOPEOBJ): both these forms
%   start the scope represented by XPCSCOPEOBJ.
%
%   This is a private function and is not to be called directly.
% 
%   See also UMINUS.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.7 $ $Date: 2002/03/25 04:24:58 $

try
  xpcScopeObj = start(xpcScopeObj);
catch
  error(xpcgate('xpcerrorhandler'));
end
  
% Vectorization of set will take care of vector xpcScopeObj
if (nargout == 0)
  if ~isempty(inputname(1))
    assignin('caller', inputname(1), xpcScopeObj);
  end    
end

%% EOF uplus.m

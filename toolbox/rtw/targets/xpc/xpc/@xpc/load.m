function [xpcObj] = load(xpcObj, appname)
% LOAD  Loads an application onto the target.
%
%   LOAD(XPCOBJ, APPNAME) loads the application with name APPNAME onto the
%   target represented by XPCOBJ. The string APPNAME is the name of the
%   application (without extension), which must have been built in the current
%   directory. For example, use LOAD(XPCOBJ, 'F14'), where XPCOBJ is an xPC
%   object.
%
%   See also UNLOAD.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.11.2.2 $ $Date: 2004/04/08 21:03:36 $

tmpappname=appname;
if tmpappname(1)=='-', tmpappname(1)=[]; end;
if ~exist([tmpappname, '.dlm'], 'file')
  error(sprintf('%s: Application not found: perhaps you have to build?',...
                tmpappname));
end

try
  if ~exist(xpcenvdata, 'file')
    error('xPC setup file not found: run xpcsetup first');
  end
  load(xpcenvdata);
  if strcmp(xpctargetping, 'failed')
    error('Unable to find target');
  end
  xpcgate('xpcload',appname);
  xpcObj = sync(xpcObj);
catch
  error(xpcgate('xpcerrorhandler'));
end

if (nargout == 0)
   if ~isempty(inputname(1)), assignin('caller', inputname(1), xpcObj); end
end

%% EOF load.m

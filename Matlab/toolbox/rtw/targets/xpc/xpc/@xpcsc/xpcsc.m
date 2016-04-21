function [xpcScopeObj] = xpcsc(id, application)
% XPCSC Construct a xpcsc object
%
%   XPCSC(ID, APPLICATION) constructs the scope object which represents the
%   scope of id ID for the target application APPLICATION. This is usually not
%   called by the user; use GETSCOPE instead.
%
%   See also XPC/GETSCOPE.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.10 $ $Date: 2002/03/25 04:25:01 $

prop                  = initprop;

propname              = prop.propname;
propval               = prop.propval;

xpcScopeObj.prop      = prop;
xpcScopeObj.execqueue = [];

for i = 1 : length(propname)
   eval(['xpcScopeObj.', propname{i}, '=''', propval{i}, ''';'], ...
         'error(xpcgate(''xpcerrorhandler''))');
end

xpcScopeObj.ScopeId     = num2str(id);
xpcScopeObj.Application = application;

xpcScopeObj = class(xpcScopeObj, 'xpcsc');
xpcScopeObj = sync(xpcScopeObj);

%% EOF xpcscope.m
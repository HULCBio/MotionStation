function [xpcObj] = xpc
% XPC Construct xPC target object
%
%   XPC is the basic target object constructor. This object is created by the
%   syntax TG = XPC, where TG is the variable used to reference the target
%   object. This object represents the target machine, and changes made to the
%   target simulation, such as starting, stopping, adding/removing scopes,
%   etc., should be made via this object's methods. For a complete list of
%   methods, use METHODS XPC. However, some of the methods are private and
%   not meant to be used directly.
%
%   See also GET, SET, ADDSCOPE, REMSCOPE.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.10 $ $Date: 2002/11/14 21:33:34 $

prop             = initprop;

propname         = prop.propname;
propval          = prop.propval;

xpcObj.prop      = prop;
xpcObj.execqueue = [];

for i = 1 : length(propname)
  try
    xpcObj.(propname{i}) = propval{i};
  catch
    error(xpcgate('xpcerrorhandler'));
  end
end

xpcObj = class(xpcObj, 'xpc');
xpcObj.TunParamIndex  = [];             % Needed to ensure
xpcObj.ParameterValue = {};             % setting parameters works properly.
sync(xpcObj);

%% EOF xPC.m

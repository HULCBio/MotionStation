function [xpcObj] = xpc(varargin)
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

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2003/11/13 06:24:02 $

xpcObj=xpctarget.xpc(varargin{:});

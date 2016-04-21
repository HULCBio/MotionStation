function schema
%SCHEMA  Defines properties for @timeplot class

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:24:09 $

% Register class (subclass)
pkg = findpackage('resppack');
c = schema.class(pkg, 'timeplot', findclass(pkg, 'respplot'));

% Private properties
% Global time focus (sec, default = []). 
% Controls time range shown in auto-X mode
p = schema.prop(c, 'TimeFocus', 'MATLAB array');  
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
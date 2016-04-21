function schema

%SCHEMA Schema for DataTipState class

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/13 02:49:35 $

pkg = findpackage('MapViewer');
c = schema.class(pkg,'InfoToolState');

p = schema.prop(c,'InfoBoxHandles','MATLAB array');
p.AccessFlags.PrivateGet = 'on';
p.AccessFlags.PrivateSet = 'on';
p.AccessFlags.PublicGet  = 'on';
p.AccessFlags.PublicSet  = 'on';

p = schema.prop(c,'Viewer','MATLAB array');
p.AccessFlags.PrivateGet = 'on';
p.AccessFlags.PrivateSet = 'on';
p.AccessFlags.PublicGet  = 'on';
p.AccessFlags.PublicSet  = 'off';

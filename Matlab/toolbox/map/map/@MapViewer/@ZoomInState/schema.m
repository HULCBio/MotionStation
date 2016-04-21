function schema

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date $

pkg = findpackage('MapViewer');
c = schema.class(pkg,'ZoomInState');

p = schema.prop(c,'MapViewer','MATLAB array');
p.AccessFlags.PrivateGet = 'on';
p.AccessFlags.PrivateSet = 'on';
p.AccessFlags.PublicGet  = 'on';
p.AccessFlags.PublicSet  = 'off';

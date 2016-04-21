function schema

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 21:57:18 $

pkg = findpackage('MapViewer');
c = schema.class(pkg,'SelectAreaState');

p = schema.prop(c,'MapViewer','MATLAB array');
p.AccessFlags.PrivateGet = 'on';
p.AccessFlags.PrivateSet = 'on';
p.AccessFlags.PublicGet  = 'on';
p.AccessFlags.PublicSet  = 'off';

p = schema.prop(c,'NewViewAreaMenu','MATLAB array');
p.AccessFlags.PrivateGet = 'on';
p.AccessFlags.PrivateSet = 'on';
p.AccessFlags.PublicGet  = 'on';
p.AccessFlags.PublicSet  = 'off';

p = schema.prop(c,'ExportAreaMenu','MATLAB array');
p.AccessFlags.PrivateGet = 'on';
p.AccessFlags.PrivateSet = 'on';
p.AccessFlags.PublicGet  = 'on';
p.AccessFlags.PublicSet  = 'off';

p = schema.prop(c,'Box','MATLAB array');
p.AccessFlags.PrivateGet = 'on';
p.AccessFlags.PrivateSet = 'on';
p.AccessFlags.PublicGet  = 'on';
p.AccessFlags.PublicSet  = 'on';

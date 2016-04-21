function schema
%SCHEMA Definition for Arrow class

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/08/01 18:12:25 $

pkg = findpackage('MapGraphics');
hgpkg = findpackage('hg');
c = schema.class(pkg,'ArrowHead',hgpkg.findclass('patch'));

p = schema.prop(c,'line','MATLAB array');
p.AccessFlags.PrivateGet = 'on';
p.AccessFlags.PrivateSet = 'on';
p.AccessFlags.PublicGet  = 'on';
p.AccessFlags.PublicSet  = 'on';

p = schema.prop(c,'ArrowHead','MATLAB array');
p.AccessFlags.PrivateGet = 'on';
p.AccessFlags.PrivateSet = 'on';
p.AccessFlags.PublicGet  = 'on';
p.AccessFlags.PublicSet  = 'on';

p = schema.prop(c,'listeners','MATLAB array');
p.AccessFlags.PrivateGet = 'on';
p.AccessFlags.PrivateSet = 'on';
p.AccessFlags.PublicGet  = 'on';
p.AccessFlags.PublicSet  = 'on';

p = schema.prop(c,'ArrowWidth','double');
p.AccessFlags.PrivateGet = 'on';
p.AccessFlags.PrivateSet = 'on';
p.AccessFlags.PublicGet  = 'on';
p.AccessFlags.PublicSet  = 'on';
p.FactoryValue = 16/3;

p = schema.prop(c,'ArrowHeight','double');
p.AccessFlags.PrivateGet = 'on';
p.AccessFlags.PrivateSet = 'on';
p.AccessFlags.PublicGet  = 'on';
p.AccessFlags.PublicSet  = 'on';
p.FactoryValue = 24;

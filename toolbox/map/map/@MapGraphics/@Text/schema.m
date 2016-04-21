function schema
%SCHEMA Definition for Text class

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:12:49 $

pkg = findpackage('MapGraphics');
hgpkg = findpackage('hg');
c = schema.class(pkg,'Text',hgpkg.findclass('text'));

p = schema.prop(c,'LayerName','string');
p.AccessFlags.PrivateGet = 'on';
p.AccessFlags.PrivateSet = 'on';
p.AccessFlags.PublicGet  = 'on';
p.AccessFlags.PublicSet  = 'off';

p = schema.prop(c,'OldWindowButtonMotionFcn','MATLAB array');
p.AccessFlags.PrivateGet = 'on';
p.AccessFlags.PrivateSet = 'on';
p.AccessFlags.PublicGet  = 'on';
p.AccessFlags.PublicSet  = 'on';

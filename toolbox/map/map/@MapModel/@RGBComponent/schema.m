function schema
%SCHEMA Define the RGBComponent class.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:13:55 $

pkg = findpackage('MapModel');
c = schema.class(pkg,'RGBComponent',findclass(pkg,'RasterComponent'));

p = schema.prop(c,'Attributes','MATLAB array');
p.AccessFlags.PrivateGet = 'on';
p.AccessFlags.PrivateSet = 'on';
p.AccessFlags.PublicGet  = 'on';
p.AccessFlags.PublicSet  = 'off';

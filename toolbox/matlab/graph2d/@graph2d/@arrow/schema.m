function schema
%SCHEMA defines the GRAPH2D.ARROW schema
%
%  See also PLOTEDIT

%   Copyright 1984-2002 The MathWorks, Inc.  
%   $Revision: 1.3 $  $Date: 2002/04/15 03:59:34 $ 

pkg   = findpackage('graph2d');
pkgHG = findpackage('hg');

h = schema.class(pkg, 'arrow' , pkgHG.findclass('line'));

p = schema.prop(h,'DisplayLineStyle','string');
p = schema.prop(h,'DisplayLineColor','color');
p = schema.prop(h,'DisplayLineWidth','MATLAB array'); %should be 'double'

p = schema.prop(h,'LineHandle','handle');
p = schema.prop(h,'HeadHandle','handle');

p = schema.prop(h,'StartPoint', 'NReals'); %should be 1x2 array
p = schema.prop(h,'EndPoint'  , 'NReals'); %should be 1x2 array

%could also create ArrowStyle, ArrowSize, StartPoint, EndPoint

pl = schema.prop(h, 'PropertyListeners', 'handle vector');
pl.AccessFlags.Serialize = 'off';
pl.AccessFlags.PublicGet = 'off';
pl.AccessFlags.PublicSet = 'off';

pl = schema.prop(h, 'ArrowListeners', 'handle vector');
pl.AccessFlags.Serialize = 'off';
pl.AccessFlags.PublicGet = 'off';
    

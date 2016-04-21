function schema
%SCHEMA defines the COLORBAR's properties

%   Copyright 1984-2002 The MathWorks, Inc.  
%   $Revision: 1.3 $  $Date: 2002/04/15 04:26:47 $ 

a=findpackage('graph3d');
hgA=findpackage('hg');

c = schema.class(a, 'colorbar', hgA.findclass('axes'));

%schema.EnumType('graph3d_colorbar_orientation',{'horiz','vert',''});
%p = schema.prop(c,'Orientation','graph3d_colorbar_orientation');
%p.AccessFlags.Init='on';
%p.AccessFlags.Reset='off';
%p.FactoryValue='';

p = schema.prop(c,'Orientation','String');


p = schema.prop(c,'TickMode','String');
p.AccessFlags.Serialize = 'off';

p = schema.prop(c,'Tick','NReals');
p.AccessFlags.Serialize = 'off';

p = schema.prop(c,'TickLabelMode','String');
p.AccessFlags.Serialize = 'off';

p = schema.prop(c,'TickLabel','NStrings');
p.AccessFlags.Serialize = 'off';

p = schema.prop(c,'Dir','String');
p.AccessFlags.Serialize = 'off';

pl = schema.prop(c, 'SinglePropertyListener',    'handle vector');
pl.AccessFlags.Serialize = 'off';
pl.AccessFlags.PublicGet = 'off';
pl.AccessFlags.PublicSet = 'off';

pl = schema.prop(c, 'VirtualPropertyListeners',  'handle vector');
pl.AccessFlags.Serialize = 'off';
pl.AccessFlags.PublicGet = 'off';
pl.AccessFlags.PublicSet = 'off';

pl = schema.prop(c, 'ShadowedPropertyListeners', 'handle vector');
pl.AccessFlags.Serialize = 'off';
pl.AccessFlags.PublicGet = 'off';
pl.AccessFlags.PublicSet = 'off';



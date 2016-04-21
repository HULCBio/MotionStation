function schema
%SCHEMA Define the legendchangedevent class

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:12:17 $

pkg = findpackage('LayerEvent');
cEventData = findclass(findpackage('handle'),'EventData');
c = schema.class(pkg,'LegendChanged',cEventData);

p = schema.prop(c,'layer','MATLAB array');
p.AccessFlags.PrivateGet = 'on';
p.AccessFlags.PrivateSet = 'on';
p.AccessFlags.PublicGet  = 'on';
p.AccessFlags.PublicSet  = 'off';




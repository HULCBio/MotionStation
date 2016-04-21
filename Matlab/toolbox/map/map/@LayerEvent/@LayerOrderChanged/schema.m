function schema
% Define the LayerOrderChangedEvent

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:12:13 $

pkg = findpackage('LayerEvent');
cEventData = findclass(findpackage('handle'),'EventData');

c = schema.class(pkg,'LayerOrderChanged',cEventData);

p = schema.prop(c,'layerorder','MATLAB array');
p.AccessFlags.PrivateGet = 'on';
p.AccessFlags.PrivateSet = 'on';
p.AccessFlags.PublicGet  = 'on';
p.AccessFlags.PublicSet  = 'off';

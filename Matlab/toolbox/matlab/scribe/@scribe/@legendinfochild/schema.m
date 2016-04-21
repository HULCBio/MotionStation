function schema
%SCHEMA defines the scribe.LEGENDINFOCHILD schema
%

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $  $  $  $

pkg   = findpackage('scribe');
h = schema.class(pkg, 'legendinfochild');

% constructor name
p = schema.prop(h,'ConstructorName','MATLAB array');
p.AccessFlags.Init = 'off';
p.AccessFlags.Serialize = 'on';
p.AccessFlags.PublicGet = 'on';
p.AccessFlags.PublicSet = 'on';
% property value pairs
p = schema.prop(h,'PVPairs','MATLAB array');
p.AccessFlags.Init = 'off';
p.AccessFlags.Serialize = 'on';
p.AccessFlags.PublicGet = 'on';
p.AccessFlags.PublicSet = 'on';
% children (of type legendinfochild)
p = schema.prop(h,'GlyphChildren','handle vector');
p.AccessFlags.Init = 'off';
p.AccessFlags.Serialize = 'on';
p.AccessFlags.PublicGet = 'on';
p.AccessFlags.PublicSet = 'on';
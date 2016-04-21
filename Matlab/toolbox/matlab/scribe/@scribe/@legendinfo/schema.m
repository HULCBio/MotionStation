function schema
%SCHEMA defines the scribe.LEGENDINFO schema
%

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $  $  $  $

pkg   = findpackage('scribe');
h = schema.class(pkg, 'legendinfo');

% object associated with the legendinfo
p = schema.prop(h,'GObject','handle');
p.AccessFlags.Serialize = 'on';
p.AccessFlags.PublicGet = 'on';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Init = 'off';
% glyph size
p = schema.prop(h,'GlyphWidth','MATLAB array');
p.AccessFlags.Init = 'off';
p.AccessFlags.Serialize = 'on';
p.AccessFlags.PublicGet = 'on';
p.AccessFlags.PublicSet = 'on';
p = schema.prop(h,'GlyphHeight','MATLAB array');
p.AccessFlags.Init = 'off';
p.AccessFlags.Serialize = 'on';
p.AccessFlags.PublicGet = 'on';
p.AccessFlags.PublicSet = 'on';
% children (of type legendinfochild)
p = schema.prop(h,'GlyphChildren','handle vector');
p.AccessFlags.Serialize = 'on';
p.AccessFlags.PublicGet = 'on';
p.AccessFlags.PublicSet = 'on';
p.AccessFlags.Init = 'off';
% listeners
pl = schema.prop(h, 'PropertyListeners', 'handle vector');
pl.AccessFlags.Serialize = 'off';
pl.AccessFlags.PublicGet = 'off';
pl.AccessFlags.PublicSet = 'off';
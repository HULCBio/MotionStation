function schema
% SCHEMA defines the SCRIBE.COPYBUFFER schema
%
%  See also PLOTEDIT

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $  $

pkg   = findpackage('scribe');

h = schema.class(pkg,'copybuffer');

p = schema.prop(h,'figure','handle');
p = schema.prop(h,'axes','handle');
p = schema.prop(h,'copies','handle vector');

pl = schema.prop(h, 'PropertyListeners', 'handle vector');
pl.AccessFlags.Serialize = 'off';
pl.AccessFlags.PublicGet = 'off';
pl.AccessFlags.PublicSet = 'off';
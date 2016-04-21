function schema
%SCHEMA  Class definition for @datasource (abstract data source).

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:26:56 $

% Register class
pkg = findpackage('wrfc');
c = schema.class(pkg, 'datasource');

% Class attributes
schema.prop(c, 'Name', 'string');        % Source name

% Private attributes
p = schema.prop(c, 'Listeners', 'handle vector');
set(p, 'AccessFlags.PublicGet', 'off', 'AccessFlags.PublicSet', 'off');

% Class events
schema.event(c, 'SourceChanged');

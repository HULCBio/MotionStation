function schema
%SCHEMA  Class definition of @waveform (time or frequency wave).

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:26:20 $

% Register class (subclass)
superclass = findclass(findpackage('wrfc'), 'dataview');
c = schema.class(findpackage('wavepack'), 'waveform', superclass);

% Public attributes
schema.prop(c, 'Characteristics','handle vector'); % Response char. (@dataview)
schema.prop(c, 'ColumnIndex','MATLAB array');  % Input channels
schema.prop(c, 'Context',        'MATLAB array');  % Context info (plot type, x0,...)
schema.prop(c, 'DataSrc',        'handle');        % Data source (@respsource)
schema.prop(c, 'Name',           'string');        % Response array name
schema.prop(c, 'RowIndex',   'MATLAB array');  % Output channels
schema.prop(c, 'Style',          'handle');        % Style

% Private attributes
p(1) = schema.prop(c, 'DataChangedListener', 'handle vector');
p(2) = schema.prop(c, 'DataSrcListener', 'handle');
p(3) = schema.prop(c, 'StyleListener', 'handle');
% REVISIT: make it private when local function limitation is gone
% set(p, 'AccessFlags.PublicGet', 'off', 'AccessFlags.PublicSet', 'off');

% Event
schema.event(c, 'DataChanged');

function schema
%SCHEMA  Definition of @waveplot base class.

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:26:42 $

% Extension of @wrfc/@plot interface
cplot = findclass(findpackage('wrfc'), 'plot');

% Register class 
c = schema.class(findpackage('wavepack'), 'waveplot', cplot);

% Class attributes
schema.prop(c, 'ChannelName',    'string vector');  % Channel names (cell array)
schema.prop(c, 'ChannelVisible', 'string vector');  % Visibility of individual input channels
p = schema.prop(c, 'ChannelGrouping', 'string');    % Axes grouping [{none}|all]
p.FactoryValue = 'none';
schema.prop(c, 'Waves',  'handle vector');          % Waves (@waveform handles)
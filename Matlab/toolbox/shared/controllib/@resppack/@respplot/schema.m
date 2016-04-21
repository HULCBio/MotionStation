function schema
%SCHEMA  Class definition for @respplot (response plot)

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:22:45 $

% Extends @wrfc/@plot interface
cplot = findclass(findpackage('wrfc'), 'plot');

% Register class 
c = schema.class(findpackage('resppack'), 'respplot', cplot);

% Class attributes
schema.prop(c, 'InputName',    'string vector');  % Input names (cell array)
schema.prop(c, 'InputVisible', 'string vector');  % Visibility of individual input channels
p = schema.prop(c, 'IOGrouping', 'string');       % [{none}|all|inputs|outputs]
p.FactoryValue = 'none';
schema.prop(c, 'OutputName',    'string vector'); % Output names (cell array)
schema.prop(c, 'OutputVisible', 'string vector'); % Visibility of individual output channels
schema.prop(c, 'Responses',  'handle vector');    % Response arrays (@waveform)

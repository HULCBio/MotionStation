function schema
%SCHEMA  Schema for the Nichols Plot Editor.

%   Author(s): Bora Eryilmaz
%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.6 $ $Date: 2002/04/10 05:05:37 $

% Find parent package
sisopack = findpackage('sisogui');

% Find parent class (superclass)
sisoclass = findclass(sisopack, 'grapheditor');

% Register class (subclass)
c = schema.class(sisopack, 'nicholseditor', sisoclass);

% Editor data and units
schema.prop(c, 'Frequency', 'MATLAB array');      % Frequency vector (always in rad/sec)
schema.prop(c, 'FrequencyUnits', 'string');       % Frequency units (in use by editor)
schema.prop(c, 'Magnitude', 'MATLAB array');      % Magnitude vector
schema.prop(c, 'Phase', 'MATLAB array');          % Phase vector 

% Plot attributes
schema.prop(c, 'ShowSystemPZ', 'on/off');         % Visibility of poles/zeros
p = schema.prop(c, 'MarginVisible', 'on/off');          % Stability margin
set(p, 'AccessFlags.Init', 'on', 'FactoryValue', 'on'); % visibility

% Frequency focus (private)
p = schema.prop(c,'FreqFocus','MATLAB array');  % Optimal frequency focus (rad/sec)
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
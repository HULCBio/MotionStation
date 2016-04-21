function schema
%SCHEMA  Schema for the PreFilter Bode Editor.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $ $Date: 2002/04/10 05:04:20 $

% Register class 
sisopack = findpackage('sisogui');
c = schema.class(sisopack,'bodeditorF',findclass(sisopack,'bodeditor'));

% Editor data and units
schema.prop(c,'ClosedLoopFrequency','MATLAB array');  % Frequency vector for closed-loop model
schema.prop(c,'ClosedLoopMagnitude','MATLAB array');  % Closed-loop mag vector
% Magnitude is for the normalized closed loop for configs 1,2
schema.prop(c,'ClosedLoopPhase','MATLAB array');      % Closed-loop phase vector 

% Plot attributes
p = schema.prop(c,'ClosedLoopVisible','on/off');  % Visibility of closed loop
set(p,'AccessFlags.Init','on','FactoryValue','on');



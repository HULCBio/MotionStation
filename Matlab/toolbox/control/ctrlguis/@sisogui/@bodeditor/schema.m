function schema
%SCHEMA  Schema for the generic Bode Editor.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $ $Date: 2002/04/10 04:56:49 $

% Register class 
sisopack = findpackage('sisogui');
c = schema.class(sisopack,'bodeditor',findclass(sisopack,'grapheditor'));

% Editor data and units
schema.prop(c,'Frequency','MATLAB array');      % Frequency vector (always in rad/sec)
schema.prop(c,'Magnitude','MATLAB array');      % Magnitude vector 
% RE: Normalized magnitude (after replacing model zpk gain by its sign)
schema.prop(c,'Phase','MATLAB array');          % Phase vector 

% Plot attributes
p(1) = schema.prop(c,'MagVisible','on/off');    % Mag. plot visibility
p(2) = schema.prop(c,'PhaseVisible','on/off');  % Phase plot visibility
set(p,'AccessFlags.Init','on','FactoryValue','on');
    
% Frequency focus (private)
p = schema.prop(c,'FreqFocus','MATLAB array');  % Optimal frequency focus (rad/sec)
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
function schema
%SCHEMA  Schema for the Root Locus Editor.

%   Authors: P. Gahinet
%   Revised: A. DiVergilio
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $ $Date: 2002/04/10 04:58:20 $

% Register class 
sisopack = findpackage('sisogui');
c = schema.class(sisopack,'rleditor',findclass(sisopack,'grapheditor'));

% Editor data
schema.prop(c,'ClosedPoles','MATLAB array');      % Closed-loop poles for current gain
schema.prop(c,'FrequencyUnits','string');    % Frequency units
schema.prop(c,'LocusGains','MATLAB array');       % Locus gains 
% Relative to normalized open loop, see loopdata/getopenloop
schema.prop(c,'LocusRoots','MATLAB array');       % Locus roots    

% Plot attributes
schema.prop(c,'AxisEqual','on/off');              % Equal aspect ratio
schema.prop(c,'GridOptions','MATLAB array');      % Grid options



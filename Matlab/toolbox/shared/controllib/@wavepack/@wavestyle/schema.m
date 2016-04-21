function schema
%SCHEMA  Defines properties for @wavestyle class

%   Author(s): John Glass
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:26:45 $

% Register class
c = schema.class(findpackage('wavepack'), 'wavestyle');

% Public attributes
schema.prop(c, 'Colors', 'MATLAB array'); 
schema.prop(c, 'LineStyles', 'MATLAB array');    
p = schema.prop(c, 'LineWidth', 'double');    
p.FactoryValue = 0.5;
schema.prop(c, 'Markers', 'MATLAB array');    
schema.prop(c, 'Legend', 'string'); 

% Event
schema.event(c,'StyleChanged');   % Notifies of change in style attributes
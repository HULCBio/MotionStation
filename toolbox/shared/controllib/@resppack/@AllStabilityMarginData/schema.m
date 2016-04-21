function schema
%  SCHEMA  Defines properties for @AllStabilityMarginData class

%  Author(s): John Glass
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:18:40 $

% Register class
superclass = findclass(findpackage('wrfc'), 'data');
c = schema.class(findpackage('resppack'),'AllStabilityMarginData',superclass);

% Public attributes
schema.prop(c, 'Stable',      'MATLAB array'); 
schema.prop(c, 'GainMargin',  'MATLAB array'); 
schema.prop(c, 'PhaseMargin', 'MATLAB array'); 
schema.prop(c, 'GMFrequency', 'MATLAB array'); 
schema.prop(c, 'PMFrequency', 'MATLAB array');  
schema.prop(c, 'DelayMargin', 'MATLAB array'); 
schema.prop(c, 'DMFrequency', 'MATLAB array'); 
schema.prop(c, 'Ts', 'MATLAB array'); 

% RE: data units are 
%     frequency: rad/sec 
%     magnitude: abs
%     phase: degrees

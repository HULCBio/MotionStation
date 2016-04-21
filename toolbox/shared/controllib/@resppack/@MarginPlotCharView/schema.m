%  SCHEMA  Defines properties for @MarginPlotCharView class

%  Author(s): John Glass
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:18:54 $

function schema

% Find parent package
pkg = findpackage('wrfc');

% Register class
c = schema.class(findpackage('resppack'), 'MarginPlotCharView', pkg.findclass('view'));

% Public attributes
% Line connecting the 0DB line at the gain margin frequency the gain margin point
schema.prop(c, 'MagVLine', 'MATLAB array');
% Line connecting the 0DB line at the gain margin frequency to the lower y limit
schema.prop(c, 'MagAxVLine', 'MATLAB array');
% Line connecting the 0DB line at the phase margin frequency to the lower y limit
schema.prop(c, 'Mag180VLine', 'MATLAB array');
% Line connecting the phase cross over at the phase margin frequency to the phase margin point
schema.prop(c, 'PhaseVLine', 'MATLAB array'); 
% Line connecting the phase cross over at the phase margin frequency to the upper y limit
schema.prop(c, 'PhaseAxVLine', 'MATLAB array');    
% Line connecting the phase cross over at the gain margin frequency to the upper y limit
schema.prop(c, 'Phase0DBVLine', 'MATLAB array');     
% 0DB Line
schema.prop(c, 'ZeroDBLine', 'MATLAB array');    
% Phase cross over line
schema.prop(c, 'PhaseCrossLine', 'MATLAB array');
function schema
%SCHEMA  Defines properties for @stylemanager class

%  Author(s): John Glass
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:25:38 $

% Register class
c = schema.class(findpackage('wavepack'), 'WaveStyleManager');

% Public attributes
p = schema.prop(c, 'ColorList', 'MATLAB array');   
p.FactoryValue = {...
         [0 0 1],'blue';...
         [0 0.65 0],'green';...
         [1 0 0],'red';...
         [0 0.75 0.75],'cyan';...
         [0.75 0 0.75],'magenta';...
         [0.8 0.8 0],'yellow';...
         [0 0 0],'black'};
 
p = schema.prop(c, 'LineStyleList', 'MATLAB array'); 
p.FactoryValue = {'-';'--';'-.';':'};

p = schema.prop(c, 'MarkerList', 'MATLAB array');   
p.FactoryValue = {'none';'x';'o';'+';'*';'s';'d';'p'};

p = schema.prop(c, 'Styles', 'MATLAB array');      

p = schema.prop(c, 'SortByColor', 'string');      
p.FactoryValue = 'response';
p = schema.prop(c, 'SortByLineStyle', 'string');     
p.FactoryValue = 'none';
p = schema.prop(c, 'SortByMarker', 'string');     
p.FactoryValue = 'none';
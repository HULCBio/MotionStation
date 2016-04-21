function schema
%SCHEMA  Defines properties for @SisoToolViewer class

%  Author(s): P. Gahinet
%  Copyright 1986-2002 The MathWorks, Inc. 
%  $Revision: 1.3 $  $Date: 2002/04/04 15:19:26 $

% Register class
pkg = findpackage('viewgui');
c = schema.class(pkg, 'SisoToolViewer', findclass(pkg, 'ltiviewer'));

% Class attributes
%%%%%%%%%%%%%%%%%%%
schema.prop(c, 'RealTimeData', 'MATLAB array');
p = schema.prop(c, 'RealTimeEnable', 'on/off');
p.Description = 'Enables dynamic response update during mouse edits of the compensators.';
p.FactoryValue = 'on';
p = schema.prop(c, 'Parent', 'handle');
p.Description = 'Handle of SISO Tool datbase.';


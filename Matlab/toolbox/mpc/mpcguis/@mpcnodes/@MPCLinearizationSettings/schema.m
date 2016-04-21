function schema
%  SCHEMA  Defines properties for MPCLinearizationSettings class

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2004/04/10 23:36:33 $

% Find parent package
% pkg = findpackage('GenericLinearizationNodes');

% % Find parent class (superclass)
% supclass = findclass(pkg, 'AbstractLinearizationSettings');

% Register class (subclass) in package
inpkg = findpackage('mpcnodes');
c = schema.class(inpkg, 'MPCLinearizationSettings');

% Properties
schema.prop(c, 'Model', 'string');
schema.prop(c, 'IOData', 'MATLAB array');
schema.prop(c, 'OPPoint', 'MATLAB array');
schema.prop(c, 'OPReport', 'MATLAB array');
p = schema.prop(c, 'AnalysisIOTableModelUDD', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'LinearizationDialog', ...
    'com.mathworks.toolbox.mpc.MPCLinearizationPanel');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'IOPanel', 'MATLAB array');
p.AccessFlags.Serialize = 'off';

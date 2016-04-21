function schema
%  SCHEMA  Defines properties for ModelLinearizationSettings class

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.7 $ $Date: 2004/04/11 00:36:23 $

% Find parent package
pkg = findpackage('GenericLinearizationNodes');

% Find parent class (superclass)
supclass = findclass(pkg, 'AbstractLinearizationSettings');

% Register class (subclass) in package
inpkg = findpackage('ModelLinearizationNodes');
c = schema.class(inpkg, 'ModelLinearizationSettings', supclass);

% Properties
schema.prop(c, 'Model', 'string');
schema.prop(c, 'IOData', 'MATLAB array');
p = schema.prop(c, 'LinearizeButtonUDD', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'AnalysisIOTableModelUDD', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'LTIViewer', 'MATLAB array');
p.AccessFlags.Serialize = 'off';

function schema
%  SCHEMA  Defines properties for BlockLinearizationSettings class

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.7 $ $Date: 2004/04/11 00:35:23 $

% Find parent package
pkg = findpackage('GenericLinearizationNodes');

% Find parent class (superclass)
supclass = findclass(pkg, 'AbstractLinearizationSettings');

% Register class (subclass) in package
inpkg = findpackage('BlockLinearizationNodes');
c = schema.class(inpkg, 'BlockLinearizationSettings', supclass);

% Properties
schema.prop(c, 'Model', 'string');
schema.prop(c, 'Block', 'MATLAB array');
schema.prop(c, 'IOData', 'MATLAB array');
p = schema.prop(c, 'LTIViewer', 'MATLAB array');
p.AccessFlags.Serialize = 'off';

% Java Handles
p = schema.prop(c, 'LinearizeButtonUDD', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'AnalysisIOTableModelUDD', 'MATLAB array');
p.AccessFlags.Serialize = 'off';

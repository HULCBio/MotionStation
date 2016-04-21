function schema
%%  SCHEMA  Defines properties for SISODesignSettings class

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2004/04/11 00:37:13 $

% Find parent package
pkg = findpackage('GenericLinearizationNodes');

% Find parent class (superclass)
supclass = findclass(pkg, 'AbstractLinearizationSettings');

%% Register class (subclass) in package
inpkg = findpackage('SISODesignNodes');
c = schema.class(inpkg, 'SISODesignSettings', supclass);

%% Properties
schema.prop(c, 'Model', 'string');
schema.prop(c, 'SISODesignGUI', 'handle');
schema.prop(c, 'IOData', 'MATLAB array');
schema.prop(c, 'ValidBlocks', 'MATLAB array');
schema.prop(c, 'NumberResponses', 'MATLAB array');

%% Listener storage
p = schema.prop(c, 'SISOToolListeners', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'CompensatorListeners', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'NodeListeners', 'MATLAB array');

%% Properties to store the UDD handles to the JAVA objects
p = schema.prop(c, 'AnalysisIOTableModelUDD', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'ValidElementsTableModelUDD', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'DesignToolButtonUDD', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'ClosedLoopRespButtonUDD', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'UpdateSimulinkModelButtonUDD', 'MATLAB array');
p.AccessFlags.Serialize = 'off';

function schema
%  SCHEMA  Defines properties for OperatingConditionSelectionPanel class

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:37:21 $

% Find parent package
pkg = findpackage('jOperatingConditionSpecificationPanels');

% Register class (subclass) in package
c = schema.class(pkg, 'OperatingConditionSelectionPanel');

% Properties
p = schema.prop(c, 'OpCondTableModelUDD', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'JavaPanel', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
schema.prop(c, 'OpCondNode', 'MATLAB array');

% Listeners
schema.prop(c, 'OperatingConditionsListeners', 'MATLAB array');

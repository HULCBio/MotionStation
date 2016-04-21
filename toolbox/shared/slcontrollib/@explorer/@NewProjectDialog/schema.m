function schema
% SCHEMA  Class definition 

% Author(s): John Glass
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:30:10 $

%% Get handles of associated packages and classes
pkg   = findpackage('explorer');

%% Construct class
c = schema.class(pkg, 'NewProjectDialog');

%% Define properties
p = schema.prop(c, 'Task', 'MATLAB array');
p = schema.prop(c, 'Workspace', 'MATLAB array');
p = schema.prop(c, 'JavaHandles', 'MATLAB array');
p = schema.prop(c, 'Dialog', 'MATLAB array');

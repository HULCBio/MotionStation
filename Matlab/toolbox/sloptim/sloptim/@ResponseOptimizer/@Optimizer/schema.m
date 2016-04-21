function schema
% @Optimizer base class.

% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2004/04/11 00:45:33 $

% Construct class
c = schema.class(findpackage('ResponseOptimizer'), 'Optimizer');

% Optimization info 
schema.prop(c, 'Info', 'MATLAB array');

% Optimization options (OPTIMSET structure)
schema.prop(c, 'Options', 'MATLAB array');

% Optimization project
schema.prop(c, 'Project', 'handle');

% Gradient computation engine (@GradientModel)
schema.prop(c, 'Gradient',  'handle');


function schema
% Definition of @SignalConstraint class.

%   Author(s): Kamesh Subbarao, P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.

c = schema.class(findpackage('ResponseOptimizer'),'SignalConstraint');
c.Description = 'Transient Signal Constraint';

% Is constraint contribution active?
p = schema.prop(c,'ConstrEnable','on/off');  
p.FactoryValue = 'on';

% Is cost contribution active?
schema.prop(c,'CostEnable','on/off');  

% Is overall spec enabled?
p = schema.prop(c,'Enable','on/off');  
p.FactoryValue = 'on';

% Source for signal data (@Source)
schema.prop(c,'SignalSource','handle');

% Signal size (size of y(t))
p = schema.prop(c,'SignalSize','MATLAB array');
p.FactoryValue = [1 1];

% Lower bounds
% j-th segment described by j-th rows of X/Y arrays
schema.prop(c,'LowerBoundX','MATLAB array');       % Nx2 array if N lower bound segments
schema.prop(c,'LowerBoundY','MATLAB array');       % Nx2 array
% weight encoding: 0=no constraint, 1=hard constraint
schema.prop(c,'LowerBoundWeight','MATLAB array');  % Nx1 vector

% Upper bounds
schema.prop(c,'UpperBoundX','MATLAB array');  
schema.prop(c,'UpperBoundY','MATLAB array');  
schema.prop(c,'UpperBoundWeight','MATLAB array');

% Reference
schema.prop(c,'ReferenceX','MATLAB array');  
schema.prop(c,'ReferenceY','MATLAB array');  
schema.prop(c,'ReferenceWeight','MATLAB array');  



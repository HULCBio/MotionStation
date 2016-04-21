function schema
% Simulink Response Optimizer project

%   Author(s): Pascal Gahinet
%   $Revision: 1.1.6.4 $ $Date: 2004/04/11 00:46:20 $
%   Copyright 1986-2003 The MathWorks, Inc.
pk = findpackage('ResponseOptimizer');
c = schema.class(pk,'SimProject',findclass(pk,'Project'));
c.Description = 'Simulink Response Optimizer Project';

% Model name
p = schema.prop(c,'Model','string');
p.Description = 'Simulink model name';

%%%%%%%%%%%%%%%%%%%%%%%%%%
%--- Private Properties
%%%%%%%%%%%%%%%%%%%%%%%%%%
p = schema.prop(c,'DataLoggingSettings','MATLAB array');
p.Description = 'Initial data logging settings';
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';

function schema
% Literal specification of Simulink Response Optimizer project.

%   Author(s): Pascal Gahinet
%   $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:45:07 $
%   Copyright 1986-2004 The MathWorks, Inc.
pk = findpackage('srogui');
c = schema.class(pk,'SimProjectForm',findclass(pk,'ProjectForm'));
c.Description = 'Literal specification of Simulink Response Optimizer Project';

% Model name
p = schema.prop(c,'Model','string');
p.Description = 'Simulink model name';

% Dialog for specifying tuned parameters
p = schema.prop(c,'ParDialog','handle');
p.Description = 'Parameter dialog';
p.AccessFlags.Serialize = 'off';
p.Visible = 'off';

% Dialog for specifying uncertaint
p = schema.prop(c,'UncDialog','handle');
p.Description = 'Uncertainty dialog';
p.AccessFlags.Serialize = 'off';
p.Visible = 'off';


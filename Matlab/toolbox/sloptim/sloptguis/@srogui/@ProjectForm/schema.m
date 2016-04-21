function schema
% Literal SRO project specifications. Used by the SRO GUI

%   Author(s): P. Gahinet
%   $Revision: 1.1.6.2 $ $Date: 2004/02/06 00:40:48 $
%   Copyright 1986-2004 The MathWorks, Inc. 

% Register class 
c = schema.class(findpackage('srogui'),'ProjectForm');
c.Description = 'Literal specifications for Simulink Response Optimization Project';

%%%%%%%%%%%%%%%%%%%%%%
%-- Public Properties
%%%%%%%%%%%%%%%%%%%%%%
p = schema.prop(c,'Dirty','bool');
p.Description = 'Tracks whether project specification has changed and needs to be resaved';
p.Visible = 'off';
p.AccessFlags.Serialize = 'off';

p = schema.prop(c,'Name','string');
p.Description = 'Project name';

p = schema.prop(c,'Parameters','handle vector');  % vector of @ParameterForm objects
p.Description = 'Specifications for tuned parameters';

p = schema.prop(c,'OptimOptions','handle');  % @OptimOptionForm
p.Description = 'Optimizer settings (literal specs)';

p = schema.prop(c,'Tests','handle vector');
p.Description = 'Specifications for tests/simulations to be conducted as part of optimization';


%%%%%%%%%%%%
%--- Dialogs
%%%%%%%%%%%%

% Options dialog
p = schema.prop(c,'OptDialog','handle');
p.Description = 'Options dialog';
p.AccessFlags.Serialize = 'off';
p.Visible = 'off';

% Display for optimization iterations
p = schema.prop(c,'IterDisplay','MATLAB array');
p.Description = 'Iteration display';
p.AccessFlags.Serialize = 'off';
p.Visible = 'off';

%%%%%%%%%%%%%%%%%%%%%%%%%%
%--- Private Properties
%%%%%%%%%%%%%%%%%%%%%%%%%%
% Version
p = schema.prop(c,'Version','double');
p.FactoryValue = 1.0;
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

% Listeners
p = schema.prop(c,'Listeners','handle vector');
p.Description = 'Listeners';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.Serialize = 'off';

% Events
% Issued when creating runtime project (data source)
schema.event(c,'SourceCreated');
% Issued when undoing optimization (clean up)
schema.event(c,'OptimUndo');

%------------------ local functions --------------------

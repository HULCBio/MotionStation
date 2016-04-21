function machine = model2machine(model)

% Copyright 2004 The MathWorks, Inc.

    % Given a simulink model (block diagram),
    % returns the Stateflow machine, if it exists


    % Does a simple find.  If we remove the machine from 
    % the hierarchy, we'll need to be more clever.
    machine = find(model, '-isa', 'Stateflow.Machine');

function parentName = ddg_get_parent_name(parent)

% Copyright 2002-2004 The MathWorks, Inc.

switch parent.class
    case 'Stateflow.Machine'
        parentName = '(machine) ';
    case 'Stateflow.Chart'
        parentName = '(chart) ';
    case 'Stateflow.EMChart'
        parentName = '(Embedded MATLAB) ';
    case 'Stateflow.State'
        parentName = '(state) ';
    case 'Stateflow.Function'
        parentName = '(function) ';
    case 'Stateflow.EMFunction'
        parentName = '(Embedded MATLAB function) ';
    case 'Stateflow.TruthTable'
        parentName = '(truthtable) ';
    case 'Stateflow.Box'
        parentName = '(box) ';
    case 'Simulink.BlockDiagram'
        parentName = '(machine) ';
    otherwise
        parentName = sprintf('(#%s) ',parent.Name);
        warning('Bad parent type.');
end

parentName = [parentName parent.getFullName];
  
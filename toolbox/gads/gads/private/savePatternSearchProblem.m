function savePatternSearchProblem(problem)
% private to psearchtool, psguiimportproblem


%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.2 $  $Date: 2004/01/16 16:51:10 $

%Create a temporary structure to save in appdata
if validrandstates(problem)
    tempstruct.randstate = problem.randstate;
    tempstruct.randnstate = problem.randnstate;
else
    tempstruct.randstate = [];
    tempstruct.randnstate = [];
end

if isfield(problem,'objective') 
    tempstruct.objective = problem.objective;
else
    tempstruct.objective = [];
end
if isfield(problem,'X0')
    tempstruct.X0 = problem.X0;
else
    tempstruct.X0 = [];
end
if isfield(problem,'Aineq')
    tempstruct.Aineq = problem.Aineq;    
else
    tempstruct.Aineq = [];    
end
if isfield(problem,'Bineq')
    tempstruct.Bineq = problem.Bineq;        
else
    tempstruct.Bineq = [];        
end
if isfield(problem,'Aeq')
    tempstruct.Aeq = problem.Aeq;   
else
    tempstruct.Aeq = [];    
end
if isfield(problem,'Beq')
    tempstruct.Beq = problem.Beq;    
else
    tempstruct.Beq = [];
end
if isfield(problem,'LB')
    tempstruct.LB = problem.LB;    
else
    tempstruct.LB = [];    
end
if isfield(problem,'UB')
    tempstruct.UB = problem.UB;    
else
    tempstruct.UB = [];    
end
setappdata(0,'gads_psearchtool_problem_data',tempstruct);
%Save options;
if isfield(problem, 'options')
    setappdata(0,'gads_psearchtool_options_data',problem.options);
end
%-------------------------------------------------------------------------
function valid = validrandstates(problem)
    valid = false;
    if isfield(problem, 'randstate') && isfield(problem, 'randnstate') && ...
       isa(problem.randstate, 'double') && isequal(size(problem.randstate),[35, 1]) && ...
       isa(problem.randnstate, 'double') && isequal(size(problem.randnstate),[2, 1])
        valid = true;
    end

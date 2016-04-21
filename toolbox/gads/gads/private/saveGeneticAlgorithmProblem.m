function saveGeneticAlgorithmProblem(problem)
%private to gatool, gaguiimportproblem

%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.2 $  $Date: 2004/01/16 16:51:11 $

%Create a temporary structure to save in appdata
if validrandstates(problem)
    tempstruct.randstate = problem.randstate;
    tempstruct.randnstate = problem.randnstate;
else
    tempstruct.randstate = [];
    tempstruct.randnstate = [];
end

if isfield(problem,'fitnessfcn') 
    tempstruct.fitnessfcn = problem.fitnessfcn;
else
    tempstruct.fitnessfcn = [];
end
if isfield(problem,'nvars')
    tempstruct.nvars = problem.nvars;
else
    tempstruct.nvars = [];
end
setappdata(0,'gads_gatool_problem_data',tempstruct);
%Save options;
if isfield(problem, 'options')
    setappdata(0,'gads_gatool_options_data',problem.options);
end
%------------------------------------------------------------------------
function valid = validrandstates(problem)
    valid = false;
    if isfield(problem, 'randstate') && isfield(problem, 'randnstate') && ...
       isa(problem.randstate, 'double') && isequal(size(problem.randstate),[35, 1]) && ...
       isa(problem.randnstate, 'double') && isequal(size(problem.randnstate),[2, 1])
        valid = true;
    end

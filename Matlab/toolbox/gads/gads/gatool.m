function gatool(optstruct)
%GATOOL  Genetic Algorithm Tool.
%   GATOOL starts a graphical user interface window for editing the default 
%   Genetic Algorithm options and running the Genetic Algorithm solver. 
%
%   GATOOL(OPTSTRUCT) starts the Genetic Algorithm tool with OPTSTRUCT.
%   OPTSTRUCT can be either a Genetic Algorithm options structure or Genetic 
%   Algorithm problem structure. An options structure can be created using 
%   GAOPTIMSET. See GAOPTIMSET for a detailed description on creating options. 
%   You can import a GA options structure from MATLAB workspace and modify it in
%   GATOOL. You can export an options structure to MATLAB workspace from GATOOL.
%
%   A Genetic Algorithm problem structure can be created in GATOOL. You can 
%   import a problem structure from MATLAB workspace to GATOOL. You can also 
%   export a problem structure to MATLAB workspace from GATOOL. See GA for 
%   a detailed description of fields in a problem structure.
%
%   GATOOL can run Genetic Algorithm solver (GA) and it allows you to modify 
%   several GA options at run time, while you watch your results. You can
%   export the solution and the current state of the solver i.e. population
%   and scores of the last generation. You can also export the best 
%   individual (X) and score of the best individual (FVAL). GATOOL can export 
%   restart information (population and scores) in the problem structure. 
%   You can start GATOOL (or GA) with the saved problem structure.
%
%   See also GA, GAOPTIMSET, PATTERNSEARCH, PSEARCHTOOL.

%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.21.4.1 $  $Date: 2004/03/09 16:15:37 $

errmsg = nargchk(0,1,nargin);
if ~isempty(errmsg)
    error('gads:GATOOL:inputArg','GATOOL requires at most one input argument.');
end
fitnessFcn = '';
nvars = '';
randchoice = false;

gaGUI = com.mathworks.toolbox.gads.GeneticAlgorithm.getGeneticAlgorithm;

tempstruct = gaoptimset;
gafieldnames = fieldnames(tempstruct);
% make up some options if none were passed in
if(nargin < 1)
    if isempty(gaGUI)
        options = gaoptimset('Display', 'off');
        optstruct = options;
    else
        gaGUI.toFront;
        return;
    end
elseif isstruct(optstruct)
    if ~isempty(gaGUI)
        button = questdlg('The GA Tool is already open. Do you want to replace the current values?', ...
            'Genetic Algorithm Tool', 'Yes', 'No', 'Yes');
        if ~strcmp(button, 'Yes')
            gaGUI.toFront;
            return;
        end
    end
          
    if isfield(optstruct, 'fitnessfcn') && isfield(optstruct, 'nvars') ...
            && isfield(optstruct, 'options')
        fitnessFcn = value2RHS(optstruct.fitnessfcn);
        nvars = value2RHS(optstruct.nvars);
        if validrandstates(optstruct)
             randchoice = true;
             randstate = optstruct.randstate;
             randnstate = optstruct.randnstate;
        end
        isproblem = true;
        options = optstruct.options;
    else
        isproblem = false;
        options = optstruct;
    end
    optionfieldnames = fieldnames(options);
    if ~all(ismember(gafieldnames, optionfieldnames))
        if isproblem
            if ~isempty(inputname(1))
               msg = sprintf('The options field of ''%s'' does not contain a valid Genetic Algorithm options structure.', inputname(1));
           else
               msg = sprintf('The options field of the input argument does not contain a valid Genetic Algorithm options structure.');
           end
        else
            if ~isempty(inputname(1))
               msg = sprintf('''%s'' is not a valid Genetic Algorithm options structure.', inputname(1));
           else
               msg = sprintf('Input argument is not a valid Genetic Algorithm options structure.');
           end
        end
        errordlg(msg,'Genetic Algorithm Tool');
        return;
    end
else
  error('gads:GATOOL:invalidInput','Input argument must be a valid structure for GATOOL.');   
end
%Save problem and options to appdata
saveGeneticAlgorithmProblem(optstruct);
setappdata(0,'gads_gatool_options_data',options);
%stuff all the fields into the hashtable.
s = struct(options);
f = fieldnames(s);
h = java.util.Hashtable;
for i = 1:length(f);
    n = f{i};
    if ismember(n, gafieldnames)
        rhs = value2RHS(s.(n));
        % remove string quotes
        q = find(rhs == '''');
        rhs(q) = [];
        h.put(n,rhs);
    end
end

if isempty(gaGUI)
    if isappdata(0,'gads_gatool_results_121677')
        rmappdata(0,'gads_gatool_results_121677');
    end
    com.mathworks.toolbox.gads.GeneticAlgorithm.showGeneticAlgorithm(fitnessFcn, nvars, h);
else
    gaGUI.updateGeneticAlgorithm(fitnessFcn, nvars, randchoice, h);
end


%--------------------------------------------------------------------------
function valid = validrandstates(problem)
    valid = false;
    if isfield(problem, 'randstate') && isfield(problem, 'randnstate') && ...
       isa(problem.randstate, 'double') && isequal(size(problem.randstate),[35, 1]) && ...
       isa(problem.randnstate, 'double') && isequal(size(problem.randnstate),[2, 1])
        valid = true;
    end

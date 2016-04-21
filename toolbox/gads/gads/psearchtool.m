function psearchtool(optstruct)
%PSEARCHTOOL  Pattern Search Tool.
%   PSEARCHTOOL starts a graphical user interface window for editing the default 
%   Pattern Search options and running the Pattern Search solver. 
%
%   PSEARCHTOOL(OPTSTRUCT) starts the Pattern Search tool with OPTSTRUCT.
%   OPTSTRUCT can be either a Pattern Search options structure or Pattern 
%   Search problem structure. An options structure can be created using 
%   PSOPTIMSET. See PSOPTIMSET for a detailed description on creating options. 
%   You can import a PATTERNSEARCH options structure from MATLAB workspace 
%   and modify it in PSEARCHTOOL. You can export an options structure to 
%   MATLAB workspace from PSEARCHTOOL.
%
%   A Pattern Search problem structure can be created in PSEARCHTOOL. You also
%   can import a problem structure from MATLAB workspace to PSEARCHTOOL. You can  
%   export a problem structure to MATLAB workspace from PSEARCHTOOL. 
%   See PATTERNSEARCH for a detailed description of fields in a problem 
%   structure.
%
%   PSEARCHTOOL can run Pattern Search solver (PATTERNSEARCH) and it allows you
%   to modify several PATTERNSEARCH options at run time, while you watch your 
%   results. You can export the solution and the current state of the solver
%   i.e. X and FVAL from the last iteration. PSEARCHTOOL can export restart 
%   information (X) in the problem structure. You can start PSEARCHTOOL 
%   (or PATTERNSEARCH) with the saved problem structure.
%
%   See also PATTERNSEARCH, PSOPTIMSET, GA, PSEARCHTOOL.

%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.17 $  $Date: 2004/01/16 16:52:13 $

errmsg = nargchk(0,1,nargin);
if ~isempty(errmsg)
    error('gads:PSEARCHTOOL:inputArg','PSEARCHTOOL requires at most 1 input argument.');
end

objectiveFcn = '';
X0 = '';
lb = '';
ub = '';
aineq = '';
bineq = '';
aeq = '';
beq = '';
randchoice = false;

psGUI = com.mathworks.toolbox.gads.DirectSearch.getDirectSearch;

tempstruct = psoptimset;
psfieldnames = fieldnames(tempstruct);
% make up some options if none were passed in
if(nargin < 1)
    if isempty(psGUI)
        options = psoptimset('Display', 'off');
        optstruct = options;
    else
        psGUI.toFront;
        return;
    end
elseif isstruct(optstruct)
   if ~isempty(psGUI)
        button = questdlg('The Pattern Search Tool is already open. Do you want to replace the current values?', ...
            'Pattern Search Tool', 'Yes', 'No', 'Yes');
        if ~strcmp(button, 'Yes')
            psGUI.toFront;
            return;
        end
    end

    if isfield(optstruct, 'objective') && isfield(optstruct, 'X0') ...
        && isfield(optstruct, 'options')
        objectiveFcn = value2RHS(optstruct.objective);
        X0 = value2RHS(optstruct.X0);
        if validrandstates(optstruct)
            randchoice = true;
            randstate = optstruct.randstate;
            randnstate = optstruct.randnstate;
        end
        options = optstruct.options;
        if isfield(optstruct, 'Aineq')
            aineq = value2RHS(optstruct.Aineq);
        end
        if isfield(optstruct, 'Bineq')
            bineq = value2RHS(optstruct.Bineq);
        end
        if isfield(optstruct, 'Aeq')
            aeq = value2RHS(optstruct.Aeq);
        end
        if isfield(optstruct, 'Beq')
            beq = value2RHS(optstruct.Beq);
        end
        if isfield(optstruct, 'LB')
            lb = value2RHS(optstruct.LB);
        end
        if isfield(optstruct, 'UB')
            ub = value2RHS(optstruct.UB);
        end
        isproblem = true;
    else
        isproblem = false;
        options = optstruct;
    end
    if ~all(ismember(psfieldnames, fieldnames(options)))
        if isproblem
            if ~isempty(inputname(1))
                msg = sprintf('The options field of ''%s'' does not contain a valid Pattern Search options structure.', inputname(1));
            else
                msg = sprintf('The options field of the input argument does not contain a valid Pattern Search options structure.');
            end
        else
            if ~isempty(inputname(1))
                msg = sprintf('''%s'' is not a valid Pattern Search options structure.', inputname(1));
            else
                msg = sprintf('Input argument is not a valid Pattern Search options structure.');
            end
        end
        errordlg(msg,'Pattern Search Tool');
        return;
    end
else
  error('gads:PSEARCHTOOL:invalidInput','Input argument must be a valid structure for PSEARCHTOOL.');   
end
%save the problem and options in appdata
savePatternSearchProblem(optstruct)
setappdata(0,'gads_psearchtool_options_data',options);
%stuff all the fields into the hashtable.
s = struct(options);
f = fieldnames(s);
h = java.util.Hashtable;
for i = 1:length(f);
    n = f{i};
    if ismember(n, psfieldnames)
        rhs = value2RHS(s.(n));
        % remove string quotes
        q = find(rhs == '''');
        rhs(q) = [];
        h.put(n,rhs);
    end
end

if isempty(psGUI)
    if isappdata(0,'gads_psearchtool_results_033051')
        rmappdata(0,'gads_psearchtool_results_033051');
    end
    com.mathworks.toolbox.gads.DirectSearch.showDirectSearch(objectiveFcn, X0, aineq, bineq, aeq, beq, lb, ub, h);
else
    psGUI.updateDirectSearch(objectiveFcn, X0, aineq, bineq, aeq, beq, lb, ub, randchoice, h);
end
%--------------------------------------------------------------------------
function valid = validrandstates(problem)
    valid = false;
    if isfield(problem, 'randstate') && isfield(problem, 'randnstate') && ...
       isa(problem.randstate, 'double') && isequal(size(problem.randstate),[35, 1]) && ...
       isa(problem.randnstate, 'double') && isequal(size(problem.randnstate),[2, 1])
        valid = true;
    end

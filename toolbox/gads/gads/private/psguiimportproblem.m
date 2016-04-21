function [selection, objective, X0, Aineq, Bineq, Aeq, Beq, LB, UB, model, randchoice] = psguiimportproblem()
%PSGUIIMPORTPROBLEM GUI helper  

%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.15 $  $Date: 2004/01/16 16:50:53 $


selection = '';
objective = '';
X0 = '';
Aineq = '';
Bineq = '';
Aeq = '';
Beq = '';
LB = '';
UB = '';
model = '';
names = {};
randchoice = false;
whoslist =evalin('base','whos');

for i = 1:length(whoslist)
    if strcmp(whoslist(i).class, 'struct') && strcmp(num2str(whoslist(i).size), '1  1')
        s = evalin('base', whoslist(i).name);
        if isfield(s, 'objective') && isfield(s, 'X0') ...
            && isfield(s, 'Aineq') && isfield(s, 'Bineq') ...
            && isfield(s, 'Aeq') && isfield(s, 'Beq') ...
            && isfield(s, 'LB') && isfield(s, 'UB') ...
            && isfield(s, 'options') && validOptions(s.options)
            names{end + 1 } = whoslist(i).name;
        end
    end
end

if isempty(names)
    msgbox('There are no problem structures in the workspace.', 'Pattern Search Tool');
else
    [value, OK] = listdlg('ListString', names, 'SelectionMode', 'Single', ...
        'ListSize', [250 200], 'Name', 'Import Pattern Search Problem', ...
        'PromptString', 'Select a problem structure to import:', ...
        'OKString', 'Import');
    if OK == 1
        selection = names{value};
        %stuff all the fields into the hashtable.
        problem = evalin('base', selection);
        objective = value2RHS(problem.objective);
        X0 = value2RHS(problem.X0);
        Aineq = value2RHS(problem.Aineq);
        Bineq = value2RHS(problem.Bineq);
        Aeq = value2RHS(problem.Aeq);
        Beq = value2RHS(problem.Beq);
        LB = value2RHS(problem.LB);
        UB = value2RHS(problem.UB);
        options = problem.options;
        s = struct(options);
        f = fieldnames(s);
        if validrandstates(problem)
            randchoice = true;
        end
        model = java.util.Hashtable;
        psfieldnames = fieldnames(psoptimset);
        for i = 1:length(f);
            n = f{i};
            if ismember(n, psfieldnames)
                rhs = value2RHS(s.(n));
                % remove string quotes
                q = find(rhs == '''');
                rhs(q) = [];
                model.put(n,rhs);
            end
        end
        savePatternSearchProblem(problem);
    end
end    

%--------------------------------------------------------------------------
 function valid = validrandstates(problem)
    valid = false;
    if isfield(problem, 'randstate') && isfield(problem, 'randnstate') && ...
       isa(problem.randstate, 'double') && isequal(size(problem.randstate),[35, 1]) && ...
       isa(problem.randnstate, 'double') && isequal(size(problem.randnstate),[2, 1])
        valid = true;
    end

%--------------------------------------------------------------------------
 function valid = validOptions(options)
    valid = false;
    psfieldnames = fieldnames(psoptimset);
    ofieldnames = fieldnames(options);
    if all(ismember(psfieldnames, ofieldnames))
        valid = true;
        return;
    end
    
    

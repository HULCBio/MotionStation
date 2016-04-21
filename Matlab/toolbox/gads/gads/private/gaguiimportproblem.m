function [selection, fitnessfcn, nvars, model, randchoice] = gaguiimportproblem()
%GAGUIIMPORT GUI helper  

%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.14 $  $Date: 2004/01/16 16:50:50 $


selection = '';
fitnessfcn = '';
nvars = '';
model = '';
names = {};
whoslist =evalin('base','whos');
randchoice = false;

for i = 1:length(whoslist)
    if strcmp(whoslist(i).class, 'struct') && strcmp(num2str(whoslist(i).size), '1  1')
        s = evalin('base', whoslist(i).name);
        if isfield(s, 'fitnessfcn') && isfield(s, 'nvars') ...
            && isfield(s, 'options') && validOptions(s.options)
            names{end + 1 } = whoslist(i).name;
        end
    end
end
   
 
if isempty(names) 
    msgbox('There are no problem structures in the workspace.', 'Genetic Algorithm Tool');
else
    [value, OK] = listdlg('ListString', names, 'SelectionMode', 'Single', ...
            'ListSize', [250 200], 'Name', 'Import GA Problem', ...
            'PromptString', 'Select a problem structure to import:', ...
            'OKString', 'Import');
    if OK == 1
        selection = names{value};
        %stuff all the fields into the hashtable.
        problem = evalin('base', selection);
        fitnessfcn = value2RHS(problem.fitnessfcn);
        nvars = value2RHS(problem.nvars);
        if validrandstates(problem)
             randchoice = true;
        end
        options = problem.options;
        s = struct(options);
        f = fieldnames(s);
        model = java.util.Hashtable;
        gafieldnames = fieldnames(gaoptimset);
        for i = 1:length(f);
            n = f{i};
            if ismember(n, gafieldnames)
                rhs = value2RHS(s.(n));
                % remove string quotes
                q = find(rhs == '''');
                rhs(q) = [];
                model.put(n,rhs);
            end
        end
        saveGeneticAlgorithmProblem(problem);
     end
end    

 %--------------------------------------------------------------------------
 function valid = validOptions(options)
    valid = false;
    gafieldnames = fieldnames(gaoptimset);
    ofieldnames = fieldnames(options);
    if all(ismember(gafieldnames, ofieldnames))
        valid = true;
        return;
    end
 
 %--------------------------------------------------------------------------
 function valid = validrandstates(problem)
    valid = false;
    if isfield(problem, 'randstate') && isfield(problem, 'randnstate') && ...
       isa(problem.randstate, 'double') && isequal(size(problem.randstate),[35, 1]) && ...
       isa(problem.randnstate, 'double') && isequal(size(problem.randnstate),[2, 1])
        valid = true;
    end
     
 
    
    

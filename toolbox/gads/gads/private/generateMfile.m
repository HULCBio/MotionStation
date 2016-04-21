function [msg] = generateMfile(obj,choice)
%GENERATEMfile Generate m code to write a set of commands in a file 
% which can run GA or PATTERNSEARCH solvers.

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.10.4.1 $  $Date: 2004/03/09 16:15:49 $

% read the list of properties from another file.
% this list is shared between several m-files for consistency.

msg  = '';
code = '';
%Get a list of all the option fields
properties =  optionsList(choice);
% make a default object.
switch lower(choice)
    case 'ga'
        defaultOpt  = gaoptimset;
    case 'ps'
        defaultOpt  = psoptimset;
    otherwise
        msg = sprintf('%s','Unknown solver.');
        return;
end


% Get file name to use, remember the directory name
filespec = '*.m';
[gadsMfileName,pn] = uiputfile(filespec,'Generate M-File','untitled.m');
if isequal(gadsMfileName,0) || isequal(pn,0)
    return
end
if ~ismember('.',gadsMfileName)
    gadsMfileName = [gadsMfileName '.m'];
end
gadsMfileName = sprintf('%s%s',pn,gadsMfileName);


% Get M file name with .m suffix, and get corresponding function name
if length(gadsMfileName)<2 || ~isequal(gadsMfileName(end-1:end),'.m')
    gadsMfileName = sprintf('%s.m',gadsMfileName);
end
[dirname,fcnname] = fileparts(gadsMfileName);
   
switch lower(choice)
    case 'ga'
        code = sprintf('%s %s\n','function [X,FVAL,REASON,OUTPUT,POPULATION,SCORES] = ', fcnname);
        %Write some useful comments
        code = [code sprintf('%s\n','%%   This is an auto generated M file to do optimization with the Genetic Algorithm and')];
        code = [code sprintf('%s\n\n','%    Direct Search Toolbox. Use GAOPTIMSET for default GA options structure.')];
        
        code = [code sprintf('%s\n','%%Fitness function')];
        code = [code sprintf('fitnessFunction = %s;\n',value2RHS(obj.fitnessfcn))];
        
        code = [code sprintf('%s\n','%%Number of Variables')];
        code = [code sprintf('nvars = %s;\n',value2RHS(obj.nvars))];
        
        % start with default options
        code = [code sprintf('%s\n','%Start with default options')];
        code = [code sprintf('options = gaoptimset;\n')];
        
        % for each property
        code = [code sprintf('%s\n','%%Modify some parameters')];
        for i = 1:length(properties)
            prop = properties{i};
            if(~isempty(prop)) % the property list has blank lines, ignore them
                value = obj.options.(prop);
                if  ~isempty(value) && ~isequal(value,defaultOpt.(prop))  % don't generate code for defaults.
                    code = [code sprintf('options = gaoptimset(options,''%s'' ,%s);\n',prop,value2RHS(value))];
                end
            end
        end
      
        %Write a function call to GA
        if isfield(obj, 'randstate') && isfield(obj, 'randnstate') && ...
                isa(obj.randstate, 'double') && isequal(size(obj.randstate),[35, 1]) && ...
                isa(obj.randnstate, 'double') && isequal(size(obj.randnstate),[2, 1])
            code = [code sprintf('%%Set the states of random number generators\n') ];
            code = [code sprintf('rand(''state'',%s);\n',value2RHS(obj.randstate))];
            code = [code sprintf('randn(''state'',%s);\n',value2RHS(obj.randnstate))];
        end
        code = [code sprintf('%s\n','%%Run GA')];    
        code = [code sprintf('[X,FVAL,REASON,OUTPUT,POPULATION,SCORES] = ga(fitnessFunction,nvars,options);')];
        
    case 'ps'
        code = sprintf('%s %s\n','function [X,FVAL,EXITFLAG,OUTPUT] = ', fcnname);
        code  = [code sprintf('%s\n','%%  This is an auto generated M file to do optimization with the Genetic Algorithm and')];
        code  = [code sprintf('%s\n\n','%   Direct Search Toolbox. Use PSOPTIMSET for default PATTERNSEARCH options structure.')];
        
        code = [code sprintf('%s\n','%%Objective function')];
        code = [code sprintf('objectiveFunction = %s;\n',value2RHS(obj.objective))];
        
        code = [code sprintf('%s\n','%%Starting point')];
        code = [code sprintf('X0 = %s;\n',value2RHS(obj.X0))];
        
        code = [code sprintf('%s\n','%Inequality constraints')];
        code = [code sprintf('Aineq = %s;\n',value2RHS(obj.Aineq))];
        code = [code sprintf('Bineq = %s;\n',value2RHS(obj.Bineq))];
        
        code = [code sprintf('%s\n','%Equality Constraints')];
        code = [code sprintf('Aeq = %s;\n',value2RHS(obj.Aeq))];
        code = [code sprintf('Beq = %s;\n',value2RHS(obj.Beq))];
        
        code = [code sprintf('%s\n','%Bounds')];
        code = [code sprintf('LB = %s;\n',value2RHS(obj.LB))];
        code = [code sprintf('UB = %s;\n',value2RHS(obj.UB))];
        
        code = [code sprintf('%s\n','%Start with default options')];
        code = [code sprintf('options = psoptimset;\n')];  
        
        % for each property
        code = [code sprintf('%s\n','%%Modify some parameters')];
        for i = 1:length(properties)
            prop = properties{i};
            if(~isempty(prop)) % the property list has blank lines, ignore them
                value = obj.options.(prop);
                if ~isempty(value) && ~isequal(value,defaultOpt.(prop)) % don't generate code for defaults.
                    code = [code sprintf('options = psoptimset(options,''%s'' ,%s);\n',prop,value2RHS(value))];
                end
            end
        end
        if isfield(obj, 'randstate') && isfield(obj, 'randnstate') && ...
                isa(obj.randstate, 'double') && isequal(size(obj.randstate),[35, 1]) && ...
                isa(obj.randnstate, 'double') && isequal(size(obj.randnstate),[2, 1])
            code = [code sprintf('%%Set the states of random number generators\n') ];
            code = [code sprintf('rand(''state'',%s);\n',value2RHS(obj.randstate))];
            code = [code sprintf('randn(''state'',%s);\n',value2RHS(obj.randnstate))];
        end
        %Write a function call to patternsearch
       code = [code sprintf('%s\n','%%Run PATTERNSEARCH')];
       code = [code sprintf('[X,FVAL,EXITFLAG,OUTPUT] = patternsearch(objectiveFunction,X0,Aineq,Bineq,Aeq,Beq,LB,UB,options);')];
    otherwise
        code = '';
end


[fid,message] = fopen(gadsMfileName,'w');
if fid==-1
   msg = sprintf('Error trying to write to %s:\n%s',gadsMfileName,message);
   errordlg(msg,'Error Saving M File','modal');
   return
end

fprintf(fid,'%s\n',code);
st = fclose(fid);
if st ~= 0
    msg = sprintf('%s%s','Error closing file ',fcnname);
    return;
end
%Open the M file just created
edit(gadsMfileName)

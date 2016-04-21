function [err, existsmsg] = cftoolchecknames(varnames, dupsok)
% CFTOOLCHECKNAMES is a helper function for the java SaveToWorkspace dialog. 
%
% [ERR, EXISTSMSG] = NAMESCHECK(VARNAMES, DUPSOK)
% checks the validity of variables names in the cell array, VARNAMES. If the
% dupsok is set to 0, it will check to see that there are no duplicates names 
% in VARNAMES. The function will return an error message in ERR if a name is empty 
% or is not a valid variable name. If the variable names already exist in the MATLAB 
% Workspace, a question will be returned in EXISTSMSG asking whether or not to
% to overwrite the existing variables.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2003/01/26 05:57:55 $

varnames = deblank(varnames);
len = length(varnames);

% if any of the checked var names is empty or invalid, send back a message
% else check for duplicates and fill in vars_exist array.

err = '';
existsmsg = '';

j = 1;
for i = 1:len
	if isempty(varnames{i})
        serr = sprintf('%s\n', 'An empty string is not a valid choice for a variable name');
		err = [err serr];
		j = j+1;
	elseif  ~isvarname(varnames{i})
		serr = sprintf('%s %s %s\n','The string ', varnames{i},' is not a valid variable name.');
		err = [err serr];
		j = j+1;
	end
end

if ~isempty(err)
    return
end

if ~dupsok 	   	 %check for dups if they are not allowed
    for i = 1:len-1
        if any(strcmp(varnames{i}, varnames(i+1:len)))
            err = 'Duplicate names are not allowed.';
            return;
        end
    end
end 

%check for existing variables
existingvars = {};
j = 1;
for i = 1:len
    if evalin('base',['exist(''',varnames{i},''', ''var'');'])
        existingvars{j} = varnames{i};
        j = j+1;	
    end
end

if ~isempty(existingvars)
	uniquevars = unique(existingvars);
	len = length(uniquevars);
	if len == 1
		existsmsg = sprintf('%s%s%s\n','Do you want to replace existing variable ', uniquevars{1}, '?');
	else
		existsmsg = sprintf('%s%s','Do you want to replace existing variables ', uniquevars{1});
        msg2 = '';
        if len > 2
            msg2 = sprintf(', %s', uniquevars{2:len-1});
        end
        existsmsg = [existsmsg msg2 ' and ' uniquevars{len} '?'];
	end
end




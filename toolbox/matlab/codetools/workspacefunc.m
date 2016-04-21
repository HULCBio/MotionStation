function varargout = workspacefunc(whichcall, varargin)
%WORKSPACEFUNC  Support function for Workspace browser component.

%   Copyright 1984-2004 The MathWorks, Inc.
%   2003/12/15 23:43:50 $

switch whichcall
    case 'getcopyname',
        varargout = {getCopyName(varargin{1}, varargin{2})};
    case 'getnewname',
        varargout = {getNewName(varargin{1})};
    case 'getshortvalue',
        varargout = {getShortValue(varargin{1})};
    case 'getshortvalues',
        getShortValues(varargin{1});
    case 'getshortvalueserror',
        getShortValuesError(varargin{1});
    otherwise
        error('MATLAB:workspacefunc:unknownOption', ...
            'Unknown command option.');
end

%********************************************************************
function new = getCopyName(orig, who_output)

counter = 0;
new_base = [orig 'Copy'];
new = new_base;
while localAlreadyExists(new , who_output)
    counter = counter + 1;
    proposed_number_string = num2str(counter);
    new = [new_base proposed_number_string];
end

%********************************************************************
function new = getNewName(who_output)

counter = 0;
new_base = 'unnamed';
new = new_base;
while localAlreadyExists(new , who_output)
    counter = counter + 1;
    proposed_number_string = num2str(counter);
    new = [new_base proposed_number_string];
end

%********************************************************************
function getShortValues(vars)

fprintf(char(10));
for i=1:length(vars)
    % Escape any backslashes.
    % Do it here rather than in the getShortValue code, since the
    % fact that Java is picking them up for interpretation is a
    % function of how they're being displayed.
    val = getShortValue(vars{i});
    val = strrep(val, '\', '\\');
    val = strrep(val, '%', '%%');
    fprintf([val 13 10]);
end

%********************************************************************
function retstr = getShortValue(var)

if isempty(var)
    if builtin('isnumeric', var)
        % Insert a space for enhanced readability.
        retstr = '[ ]';
        return;
    end
    if ischar(var)
        retstr = '''''';
        return;
    end
end

try
    % Start by assuming that we won't get anything back.
    retval = '';
    if ~isempty(var)
        if builtin('isnumeric', var) && (numel(var) < 11) && ...
              (numel(size(var)) < 3)
            % Show small numeric arrays.
            if isempty(strfind(get(0, 'format'), 'long'))
                retval = mat2str(double(var), 5);
            else
                retval = mat2str(double(var));
            end
        elseif islogical(var) && (numel(var) == 1)
            if var
                retval = 'true';
            else
                retval = 'false';
            end
        end
    end

    if (ischar(var) && (size(var, 1) == 1))
        % Show "single-line" char arrays, while establishing a reasonable
        % truncation point.
        if isempty(strfind(var, char(10))) && ...
                isempty(strfind(var, char(13))) && ...
                isempty(strfind(var, char(0)))
            limit = 128;
            if numel(var) <= limit
                retval = ['''' var ''''];
            else
                retval = ['''' var(1:limit) '...'' ' ...
                    '<Preview truncated at ' num2str(limit) ' characters>'];
            end
        end
    end

    if isa(var, 'function_handle') && numel(var) == 1
        retval = strtrim(evalc('disp(var)'));
        if ~isempty(retval)
            if ~isempty(find(retval == 10, 1))
                retval = '';
            end
        end
    end

    % Don't call mat2str on an empty array, since that winds up being the
    % char array "''".  That looks wrong.
    if isempty(retval)
        s = size(var);
        D = numel(s);
        if D == 1
            % This can happen when objects that have overridden SIZE (such as
            % a javax.swing.JFrame) return another object as their "size."
            % In that case, it's a scalar.
            theSize = '1x1';
        elseif D == 2
            theSize = [num2str(s(1)), 'x', num2str(s(2))];
        elseif D == 3
            theSize = [num2str(s(1)), 'x', num2str(s(2)), 'x', ...
                num2str(s(3))];
        else
            theSize = [num2str(D) '-D'];
        end
        classinfo = [' ' class(var)];
        retstr = ['<', theSize, classinfo, '>'];
    else
        retstr = mat2str(retval);
        % Strip off a trailing cr.
        if length(retstr) > 1 && retstr(end) == char(10)
            retstr = retstr(1:end-1);
        end
    end
catch
    retstr = '<Error displaying value>';
end
%********************************************************************
function result = localAlreadyExists(name, who_output)
result = false;
counter = 1;
while ~result && counter <= length(who_output)
    result = strcmp(name, who_output{counter});
    counter = counter + 1;
end

%********************************************************************
function getShortValuesError(numberOfVars)

fprintf(char(10));
for i=1:numberOfVars
    fprintf(['<Error retrieving value>' 13 10]);
end

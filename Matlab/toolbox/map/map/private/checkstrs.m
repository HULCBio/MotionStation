function out = checkstrs(in, valid_strings, function_name, ...
                         variable_name, argument_position)
%CHECKSTRS Check validity of option string.
%   OUT = CHECKSTRS(IN,VALID_STRINGS,FUNCTION_NAME,VARIABLE_NAME, ...
%   ARGUMENT_POSITION) checks the validity of the option string IN.  It
%   returns the matching string in VALID_STRINGS in OUT.  CHECKSTRS looks
%   for a case-insensitive nonambiguous match between IN and the strings
%   in VALID_STRINGS.
%
%   VALID_STRINGS is a cell array containing strings.
%
%   FUNCTION_NAME is a string containing the function name to be used in the
%   formatted error message.
%
%   VARIABLE_NAME is a string containing the documented variable name to be
%   used in the formatted error message.
%
%   ARGUMENT_POSITION is a positive integer indicating which input argument
%   is being checked; it is also used in the formatted error message.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 21:58:05 $

% Except for IN, input arguments are not checked for validity.

try
    if ~ischar(in) || ndims(in) > 2 || size(in,1) > 1
        id = sprintf('%s:%s:nonStrInput', getcomp, function_name);
        throwerr(id,...
          'Function %s expected its %s argument, %s,\nto be a character string.',...
          upper(function_name), num2ordinal(argument_position), variable_name);
    end

    matches = strncmpi(in,valid_strings,numel(in));
    if sum(matches) == 1
        out = valid_strings{matches};
    else
        out = substringMatch(valid_strings(matches));
        if isempty(out)
            failedToMatch(valid_strings, sum(matches), function_name,...
                          argument_position,variable_name,in);
        end
    end
catch
    rethrow(lasterror);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = substringMatch(strings)
%   STR = substringMatch(STRINGS) looks at STRINGS (a cell array of
%   strings) to see whether the shortest string is a proper substring of
%   all the other strings.  If it is, then substringMatch returns the
%   shortest string; otherwise, it returns the empty string.

if isempty(strings)
    str = '';
else
    len = cellfun('prodofsize',strings);
    [tmp,sortIdx] = sort(len);
    strings = strings(sortIdx);
    
    start = regexpi(strings(2:end), ['^' strings{1}]);
    if isempty(start) || (iscell(start) && any(cellfun('isempty',start)))
        str = '';
    else
        str = strings{1};
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function failedToMatch(valid_strings, num_matches, function_name,...
                       argument_position, variable_name, in)
% Convert valid_strings to a single string containing a space-separated list
% of valid strings.

list = '';
for k = 1:length(valid_strings)
    list = [list ', ' valid_strings{k}];
end
list(1:2) = [];

msg1 = sprintf('Function %s expected its %s input argument, %s,', ...
               upper(function_name), num2ordinal(argument_position), ...
               variable_name);
msg2 = 'to match one of these strings:';

if num_matches == 0
    msg3 = sprintf('The input, ''%s'', did not match any of the valid strings.', in);
    id = sprintf('%s:%s:unrecognizedStringChoice', getcomp, function_name);

else
    msg3 = sprintf('The input, ''%s'', matched more than one valid string.', in);
    id = sprintf('%s:%s:ambiguousStringChoice', getcomp, function_name);
end

throwerr(id,'%s\n%s\n\n  %s\n\n%s', msg1, msg2, list, msg3);

function [token, remainder] = strtok(string, delimiters)
%STRTOK Find token in cell array of strings.
%   Implementation of STRTOK for cell arrays of strings.  See STRTOK for
%   more info.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $

token = cell(size(string));
remainder = cell(size(string));

if nargin == 2
    if iscell(delimiters)
        delimiters = char(delimiters);
        % call non-cell version of strtok
        [token,remainder] = strtok(string,delimiters);
        return
    end
    % tokenize the string using delimiters
    for i = 1:numel(string)
        [token{i}, remainder{i}] = strtok(string{i},delimiters);
    end
else
    % tokenize the string using default delim
    for i = 1:numel(string)
        [token{i}, remainder{i}] = strtok(string{i});
    end
end



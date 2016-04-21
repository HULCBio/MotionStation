function [predHeader, predBody, predAction, actions] = preprocess_truth_table(predicateTable, actionTable)
%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.5.4.3 $  $Date: 2004/04/15 00:59:01 $

% Trim heading/tailing white spaces
predicateTable = regexprep(predicateTable, '^\s*(.*?)\s*$', '$1');
actionTable = regexprep(actionTable, '^\s*(.*?)\s*$', '$1');

% ====================================================================

% Expand action table (desp, action) => (desp, label, action)
% Action can be referred by row number or label. label is optional.
if ~isempty(actionTable)
    [label code] = divide_label_code(actionTable(:, 2));
    actions = [actionTable(:, 1) label code];
else
    actions = cell(0,3);
end

% Process predicate table
CIDX_TABLE_START = 3;
[m n] = size(predicateTable);
[label code] = divide_label_code(predicateTable(1:m-1,2));

predHeader = [predicateTable(1:m-1, 1) label code];
predAction = predicateTable(m, CIDX_TABLE_START:n);
predBody = predicateTable(1:(m-1), CIDX_TABLE_START:n);

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [label, code] = divide_label_code(ttStrCellArr)
% Divide truth table condition/action string to couples(label String, code String)
% Input string should have no heading/tailing white space.
% Label must begin with [a-zA-Z] followed by arbitray number of [a-zA-Z_0-9], end with a ':[^=]'

numStr = length(ttStrCellArr);
label = cell(numStr, 1);
code = cell(numStr, 1);

tokens = regexp(ttStrCellArr, '^\s*([a-zA-Z]\w*)\s*:(?!=)\s*(.*)', 'tokens', 'once');

for i = 1:numStr
    if ~isempty(tokens{i})
        label{i} = tokens{i}{1};
        code{i} = tokens{i}{2};
    else
        label{i} = '';
        code{i} = ttStrCellArr{i};
    end
end

return;

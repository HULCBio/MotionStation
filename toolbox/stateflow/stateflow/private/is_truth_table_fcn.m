function isTTFcn = is_truth_table_fcn(id)

% Copyright 2003 The MathWorks, Inc.

isTTFcn = ~isempty(sf('find',id,'state.type','FUNC_STATE','state.truthTable.isTruthTable',1));
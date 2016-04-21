function isEmlFcn = is_eml_fcn(id)

% Copyright 2002 The MathWorks, Inc.

isEmlFcn = ~isempty(sf('find',id,'state.type','FUNC_STATE','state.eml.isEML',1));
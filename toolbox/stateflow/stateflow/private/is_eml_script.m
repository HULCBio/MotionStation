
% Copyright 2003 The MathWorks, Inc.

function isEmlScript = is_eml_script(id)

isEmlScript = ~isempty(sf('get',id,'script.id'));
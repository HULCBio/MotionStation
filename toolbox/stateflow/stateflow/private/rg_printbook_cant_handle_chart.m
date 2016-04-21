function result = rg_printbook_cant_handle_chart(chartId)

% Copyright 2003 The MathWorks, Inc.

result = ~isempty(sf('SubchartsIn',chartId)) || ...
         ~isempty(truth_tables_in(chartId))  || ...
         ~isempty(eml_fcns_in(chartId));
         
return;

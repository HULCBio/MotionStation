function eml_script = get_eml_script(block_handle)
% GET_EML_SCRIPT Get the script for the eML block

% Copyright 1994-2003 The MathWorks, Inc.

eml_script = '';
if(~ishandle(block_handle))
  return   
end

chartId =  sf('Private','block2chart',block_handle);
objectId = sf('find', chartId, 'chart.type',2);
if(isempty(objectId))
  return;
else
   eMLId = sf('Private','eml_fcns_in',chartId);
   eml_script =  char(sf('get',eMLId(1),'state.eml.script'));
end

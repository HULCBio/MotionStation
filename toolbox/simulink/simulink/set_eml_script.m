function set_eml_script(block_handle, val)
% SET_EML_SCRIPT Set the script for the eML block

% Copyright 1994-2003 The MathWorks, Inc.

if(~ishandle(block_handle))
  return   
end

chartId =  sf('Private','block2chart',block_handle);
objectId = sf('find', chartId, 'chart.type',2);
if(isempty(objectId))
  return;
else
   eMLId = sf('Private','eml_fcns_in',chartId);
   sf('set',eMLId(1),'state.eml.script', val);
end

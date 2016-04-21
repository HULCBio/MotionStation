function dlg_apply_bitops_to_all_charts(chartId)

% Copyright 2002 The MathWorks, Inc.
  
  r = sfroot;
  h = r.find('-isa', 'Stateflow.Chart', 'id', chartId);
  
  if isempty(h) 
    return;
  end
  
  machineId = sf('get', chartId,'.machine');
  
  sf('set',machineId, 'machine.defaultActionLanguage', ...
     h.EnableBitOps); 
  sf('set',sf('get',machineId,'machine.charts'), ...
     'chart.actionLanguage', h.EnableBitOps);
  
  
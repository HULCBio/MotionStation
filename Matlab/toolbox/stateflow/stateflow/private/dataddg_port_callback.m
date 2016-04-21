function dataddg_port_callback(dataId, newPortNum)

% Copyright 2003 The MathWorks, Inc.
  
  scope = sf('get',dataId,'data.scope');

  if any(scope==[1,2,8,9]) % INPUT or OUTPUT DATA
    
    prnt = sf('get', dataId, '.linkNode.parent');
    ios = io_data_of(prnt, scope);
    
    % Update the port numbers if needed
    dataPortNum = find(dataId==ios)-1;
 
    if ~isequal(newPortNum, dataPortNum)
      sf('ChgPortIndTo', dataId, newPortNum+1);
      sf('ClearUndoStack', dataId);
    end
    
  end
  
%----------------------------------------------------------------------------------------
function ios = io_data_of(chart,scope)
  
  switch scope
   case {1,2,8,9}
    ios = sf('find',sf('DataOf',chart),'data.scope',scope);
   otherwise
    error('Bad scope');
  end
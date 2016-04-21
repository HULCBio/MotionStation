function eventddg_port_callback(eventId, newPortNum)

% Copyright 2003 The MathWorks, Inc.
  
  scope = sf('get',eventId,'event.scope');

  if any(scope==[1,2,8]) % INPUT or OUTPUT DATA
    
    [ios,index] = io_events_of(eventId);
    
    % Update the port numbers if needed
    eventPortNum = find(eventId==ios)-1;
 
    if ~isequal(newPortNum, eventPortNum)
      sf('ChgPortIndTo', eventId, newPortNum+1);
      sf('ClearUndoStack', eventId);
    end
    
  end

%--------------------------------------------------------------
 function [ios, index] = io_events_of(eventId)
  
  chart = sf('get',eventId,'.linkNode.parent');
  scope = sf('get',eventId,'event.scope');
  
  switch scope
  case 1 % INPUT
    ios = sf('find',sf('EventsOf',chart),'event.scope',scope);
    index = [1:size(ios,2)];
  case 2 % OUTPUT
    dios = sf('find',sf('DataOf',chart),'data.scope',scope);
    ios = sf('find',sf('EventsOf',chart),'event.scope',scope);
    index = size(dios,2) + [1:size(ios,2)];
  otherwise
    error('Bad scope');
end

function sfunOutPort = blkout2sfunout(varargin)

% BLKOUT2SFUNOUT - Maps stateflow ports to simulink ports.


%   Copyright 2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/09/18 17:42:45 $


if ~isa(varargin{1}, 'double')
  error('First argument MUST be a Numeric SL Handle');
  return;
end

if ~isa(varargin{2}, 'double')
  error('Second argument MUST be a numeric Port Number');
  return;
end

if (nargin > 2)
    error('Too many Input Arguments');
    return;
end

if (nargin < 2)
    error('Too little Input Arguments');
    return;
end


blockH=varargin{1};
portNumber=varargin{2};

chart = sf('Private','block2chart',blockH);


chartData = sf('find',sf('DataOf',chart),'data.scope','OUTPUT_DATA');
chartEvents = sf('find',sf('EventsOf',chart),'event.scope','OUTPUT_EVENT');


allPorts = [chartData,chartEvents];


if(portNumber>length(allPorts))
    blkName=get_param(blockH,'Name');
    error(['PortNumber does not exist for block: ',blkName,'.']);
end


portObject = allPorts(portNumber);


if(~isempty(sf('find',portObject,'event.trigger','FUNCTION_CALL_EVENT')))
    sfunOutPort = 1;
elseif(~isempty(sf('get',portObject,'event.id')))
    triggerEvents = sf('find',chartEvents,'~event.trigger','FUNCTION_CALL_EVENT');
    indexInTriggerEvents = find(portObject==triggerEvents);
    sfunOutPort = 1+ length(chartData)+indexInTriggerEvents;
else
    indexInData = find(portObject==chartData);
    sfunOutPort = 1+indexInData;
end

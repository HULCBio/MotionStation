function status = sanity_check_chart_simulink_block(chartId)
% This function sanity-checks the IO ports of a chart block
% wrt data dictionary. For use in tests. This throws a hard-error
% in case of an error, so use it in a try-catch if you need to proceed
% further in your test.
% usage:
% try
%   status = sanity_check_chart_simulink_block(chartId)
% catch
%   error(lasterr);
% end
%
%

% Copyright 2003 The MathWorks, Inc.

status = 0;

blockH = chart2block(chartId);

outPorts = find_system(blockH,'LookUnderMasks','on','BlockType','Outport');
inPorts = find_system(blockH,'LookUnderMasks','on','BlockType','Inport');
triggerPort = find_system(blockH,'LookUnderMasks','on','BlockType','TriggerPort');

allData = sf('DataOf',chartId);
outData = sf('find',allData,'data.scope','OUTPUT_DATA');
inData = sf('find',allData,'data.scope','INPUT_DATA');

allEvents = sf('EventsOf',chartId);
outEvents = sf('find',allEvents,'event.scope','OUTPUT_EVENT');
inEvents = sf('find',allEvents,'event.scope','INPUT_EVENT');

errInfo.count = 0;
errInfo.msgs = {};

% sanity check input ports
assert_l((length(inEvents)==0)==isempty(triggerPort),'Trigger port mismatch');

assert_l(length(inPorts)==length(inData),'Input port count mismatch');
for i=1:length(inPorts)
    portName = get_param(inPorts(i),'Name');
    dataName = sf('get',inData(i),'data.name');
    assert_l(strcmp(portName,dataName),'Input port name mismatch');
end


% sanity check output ports
assert_l(length(outPorts)==(length(outData)+length(outEvents)),'Output port count mismatch');
for i=1:length(outData)
    portName = get_param(outPorts(i),'Name');
    dataName = sf('get',outData(i),'data.name');
    assert_l(strcmp(portName,dataName),'Output port name mismatch for outdata');
end

for i=1:length(outEvents)
    portName = get_param(outPorts(i+length(outData)),'Name');
    dataName = sf('get',outEvents(i),'event.name');
    assert_l(strcmp(portName,dataName),'Output port name mismatch for outdata');
end

function assert_l(yesOrNo,msg)

if(~yesOrNo)
    error(msg);
end





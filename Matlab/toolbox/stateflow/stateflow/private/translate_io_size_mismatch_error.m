function [isOurs,newMsg] = translate_io_size_mismatch_error(oldMsg,instanceId, chartId)

% Copyright 2004 The MathWorks, Inc.

    newMsg = oldMsg;
    isOurs = 0;
    
if(isempty(regexp(oldMsg,'Error in port widths or dimensions.','once')))
    return;
end

[isOurs, isExpectedStr,dataOrEvent,dataName,tailMsg] = unpack_message(oldMsg);

if(isOurs)
    chartInputData = sf('find',sf('DataOf',chartId),'data.scope','INPUT_DATA');
    chartInputEvents = sf('find',sf('EventsOf',chartId),'event.scope','INPUT_EVENT');
    switch(isExpectedStr)
    case 'actual'
        switch(dataOrEvent)
        case 'data'
            dataId = sf('find',chartInputData,'data.name',dataName);
            dataSize = sf('get',dataId,'data.parsedInfo.array.size');
            
           if(length(dataSize)==0 ||...
               (prod(dataSize)==1))
               expMsg = sprintf('Input port "%s"(#%d) expects a scalar',dataName,dataId);
           elseif (length(dataSize)==1)           
                expMsg = sprintf('Input port "%s"(#%d) expects a one dimensional vector with %d elements',...
                     dataName,dataId,dataSize(1));
           else
                expMsg = sprintf('Input port "%s"(#%d) expects a [%dx%d] matrix',...
                     dataName,dataId,dataSize(1),dataSize(2));                   
           end
           if(~isempty(tailMsg)) 
               newMsg = sprintf('Port width mismatch. %s. The signal %s.',expMsg,tailMsg);       
           else
               newMsg = sprintf('Port width mismatch. %s.',expMsg);                      
           end
        case 'event'
            newMsg = sprintf('Port width mismatch. The input events signal connected to the chart %s'...
                     ,tailMsg);
        end
    case 'expected'
       newMsg = sprintf('Port width mismatch errors occurred');
    end    
end


function [isOurs, isExpectedStr,dataOrEvent,dataName,tailMsg] = unpack_message(oldMsg)

isOurs = 0;
isExpectedStr = '';
dataOrEvent = '';
dataName = '';
tailMsg = '';
    
langSetting = lower(get(0,'language'));
if(strncmp(langSetting,'ja',2))
    isJapanese = true;
else
    isJapanese = false;
end

if(~isJapanese) 
    found = ~isempty(regexpi(oldMsg,'output\s+port\s+','once'));
else
    found = ~isempty(regexpi(oldMsg,'output','once'));
end
if(found)
    isOurs = 1;
    isExpectedStr = 'actual';
    parsedMsg=regexp(oldMsg,'/(?<dataName>[\w ]+)''\s*(?<tailMsg>.*)','once','names');
    if(~isempty(parsedMsg))
        tailMsg  = parsedMsg.tailMsg;
        if strcmp(parsedMsg.dataName, ' input events ')
            dataOrEvent = 'event';
        else
            dataOrEvent = 'data';
            dataName  = parsedMsg.dataName;
        end
    else
       isOurs = 0;
    end
    return;
end

if(~isJapanese) 
    found = ~isempty(regexpi(oldMsg,'input\s+port\s+','once'));
else
    found = ~isempty(regexpi(oldMsg,'input','once'));
end
if(found)
    isOurs = 1;
    isExpectedStr = 'expected';
    dataOrEvent = 'dataevent';
    return;
end

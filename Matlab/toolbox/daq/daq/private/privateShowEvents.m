function str = privateShowEvents(events, index)
%PRIVATESHOWEVENTS Create formatted strings for eventlog display.
%
%    STR = PRIVATESHOWEVENTS(EVENTS, INDEX) creates the formatted 
%    strings for the event structure, EVENTS.  The INDEX specifies 
%    which events will be returned to STR.
%
%    PRIVATESHOWEVENTS is a helper function for daq/showdaqevents and
%    daqdevice/showdaqevents.
% 

%    MP 3-10-99
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.5.2.4 $  $Date: 2003/08/29 04:42:23 $


% Determine the length of the maximum index - used for the spacing
% between the index and the event name.
maxLength = length(sprintf('%d',max(index)))+1;

% Determine the spacing between relative sample and Channel.
lastData = events(end).Data;
lastRelSampleLength = length(sprintf('%d',lastData.RelSample));

% Loop through the events and create the display.
for i = 1:length(events)
   
   % Extract the events data structure.
   data = events(i).Data;

   switch lower(events(i).Type)
   case {'trigger', 'start', 'stop', 'error'}
      % Convert the CLOCK time to the correctly formatted string.
      time = localConvertTime(data.AbsTime);
   end
      
   % Determine the spacing between the index and the event name.
   space = blanks(maxLength - length(sprintf('%d',index(i))));
      
   % Construct the string based on the event type.
   switch lower(events(i).Type)
   case 'trigger'
      % 2 Trigger #1          ( 10:28:19, 0 )     Channel: N/A
      channelSpace = blanks(maxLength + lastRelSampleLength - ...
         length(sprintf('%d',data.RelSample)));
      try
         % Only analog input trigger events have a channel field.
         triggerSpace = blanks(10 - (length(sprintf('%d', data.Trigger)) - 1));
         if ~isempty(data.Channel)
            dchan = repmat('%d ',1,length(data.Channel));
            dchan = dchan(1:end-1);

            str{i} = sprintf(['   %d%sTrigger#%d %s( %s, %d )    %sChannel: [' dchan ']\n'],...
               index(i), space, data.Trigger, triggerSpace, time,...
               data.RelSample, channelSpace, data.Channel); 
         else
            str{i} = sprintf('   %d%sTrigger#%d %s( %s, %d )    %sChannel: N/A\n',...
               index(i), space, data.Trigger, triggerSpace, time,...
               data.RelSample, channelSpace); 
         end
      catch
         % An analog output trigger event occurred which does not
         % have a channel field or trigger field. 
         % 2 Trigger             ( 10:28:19, 0 )   
         triggerSpace = blanks(12);
         str{i} = sprintf('   %d%sTrigger %s( %s, %d )\n', index(i), space,...
            triggerSpace, time, data.RelSample );
      end
   case 'start'
      % 1 Start               ( 10:28:19, 0 )
      str{i} = sprintf('   %d%sStart %s( %s, %d )\n', index(i), space,...
         blanks(14), time, data.RelSample );
      
   case 'stop'
      % 9 Stop                ( 10:28:20, 8000 )
      str{i} = sprintf('   %d%sStop %s( %s, %d )\n', index(i), space, ....
         blanks(15), time, data.RelSample );
      
   case 'error'
      % 3 Error               ( 10:28:20, 8000 )
      %   Message: Gap found when looking for pretrigger data. Trigger skipped.
      messageSpace = blanks(maxLength - 1);
      str{i} = sprintf('   %d%sError %s ( %s, %d )\n    %sMessage:  %s\n',...
         index(i),space,blanks(13), time, data.RelSample,...
         messageSpace, data.String); 
      
   case 'overrange'
      % 4 InputOverRange      (   N/A  , 8000 )    Channel: 1    Overrange: On
      channelSpace = blanks(maxLength + lastRelSampleLength - ...
         length(sprintf('%d', data.RelSample)));
      directionSpace = blanks(maxLength + lastRelSampleLength - ...
         length(sprintf('%d', data.Channel)));
      
      dchan = repmat('%d ',1,length(data.Channel));
      dchan = dchan(1:end-1);
      
      str{i} = sprintf(['   %d%sInputOverRange %s( %s, %d )    %sChannel: [' dchan ']%sOverrange: %s\n'],...
         index(i),space, blanks(5), '   N/A  ', data.RelSample,...
         channelSpace, data.Channel, directionSpace, data.Overrange);

   case 'datamissed'
      % 5 DataMissed          (   N/A  , 8000 )      
      channelSpace = blanks(maxLength + lastRelSampleLength - ...
          length(sprintf('%d', data.RelSample)));
      str{i} = sprintf('   %d%sDataMissed %s( %s, %d ) \n',... 
         index(i), space, blanks(9), '   N/A  ', data.RelSample );
   otherwise
      % 6 Name
      str{i} = sprintf('   %d%s%s\n', index(i), space, events(i).Type);
   end
end

% ****************************************************************
% Convert the CLOCK time to a 'hh:mm:ss' string.
function out = localConvertTime(time)

time = fix(time);
out = sprintf('%2d:%2d:%2d', time(4), time(5), time(6));

% Convert single digit to [0 digit], i.e. 1 becomes 01 for the display.
index = find(isspace(out));
out(index) = '0';
out = out(1:8);
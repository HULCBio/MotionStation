function out = showdaqevents(obj, index)
%SHOWDAQEVENTS Display summary of event log.
%
%    SHOWDAQEVENTS(OBJ) displays a summary of the event log for device object,
%    OBJ.  OBJ can only be a 1-by-1 data acquisition device object.
%
%    SHOWDAQEVENTS(OBJ, INDEX) displays a summary of the events with index, 
%    INDEX for device object, OBJ.  INDEX can be the numerical index of
%    the event.  INDEX can also be a string or a cell array of strings
%    that specify the name of the event. Valid events are Start, Trigger, 
%    Stop, Error, OverRange and DataMissed.  If multiple events are
%    specified, the events will be displayed in ascending order.
%
%    SHOWDAQEVENTS(STRUCT)
%    SHOWDAQEVENTS(STRUCT, INDEX) displays a summary of the events with 
%    index, INDEX for the event structure, STRUCT.  This allows the 
%    display of the event structure from GETDATA or DAQREAD.  STRUCT can
%    also be obtained from the device object's EventLog property.
%
%    OUT = SHOWDAQEVENTS(...) outputs the event display to a one column 
%    cell array, OUT, which contains strings corresponding to each index
%    in the event log. 
%
%    The display summary includes the number of samples acquired when 
%    the event occurred.  The Trigger, Start, Stop and Error events also 
%    include the absolute time the event occurred.
%
%    The Trigger event also includes the trigger number and the channel 
%    which caused the trigger to be issued (analog input objects only). 
%    Channel will be N/A if an immediate or manual trigger was used.  
%
%    The InputOverRange event also includes the channel that experienced
%    an input over-range condition and an overrange which indicates if the
%    over-range condition switched from 'On' to 'Off' or from 'Off' to 'On'.
%
%    Example:
%      ai = analoginput('winsound');
%      set(ai, 'TriggerRepeat', 4, 'SamplesPerTrigger', 4000);
%      addchannel(ai, 1);
%      start(ai);
%      showdaqevents(ai)
%      showdaqevents(ai, 2:6)
%      showdaqevents(ai, 'Trigger');
%      out = showdaqevents(ai, [1 3 5]);
%

%    MP 3-10-99
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.5.2.4 $  $Date: 2003/08/29 04:41:26 $

% Error checking.
if (nargin < 1)
   error('daq:showdaqevents:argcheck', 'OBJ must be defined.  Type ''daqhelp showdaqevents'' for more information.');
end

if (length(obj) > 1)
   error('daq:showdaqevents:invalidobject', 'OBJ must be a 1-by-1 device object.');
end

% Check to see if event logging is supported
if (~ismember('EventLog', fieldnames(obj)))
   error('daq:showdaqevents:notsupported', 'This object does not support event logging.');
end   


% Get the eventlog.
if isa(obj, 'daqdevice')
   if ~isvalid(obj),
      error('daq:showdaqevents:invalidobject', 'OBJ must be a valid 1-by-1 device object.');
   end
   
   try
      events = daqmex(obj, 'get', 'EventLog');
   catch
      error('daq:showdaqevents:unexpected', lasterr);
   end
else
   error('daq:showdaqevents:invalidobject', 'Invalid input OBJ.');
end

% Return if there are no events.
if isempty(events)
   out = {};
   return;
end

% Verify that the specified index does not exceed the dimensions of the 
% event structure and extract the requested events from the event structure.
if nargin == 2
   if ischar(index) 
      % Find the index of the specified event type.
      index = find(strcmp(lower(index), lower({events.Type})));
   elseif iscell(index)
      % Initialize variables.
      tempIndex = [];
      for i = 1:length(index)
         % Loop through the specified events and find their indices.
         tempIndex = [tempIndex find(strcmp(lower(index{i}), lower({events.Type})))];
      end
      index = sort(tempIndex);
   end
   
   % Verify the index values.
   if max(index) > length(events)
      error('daq:showdaqevents:invalidindex', 'INDEX exceeds event dimensions.  %s events occurred.', num2str(length(events)));
   elseif min(index) < 1
      error('daq:showdaqevents:invalidindex', 'Invalid INDEX specified.  INDEX contains zero or negative values.');
   elseif isempty(index)
      % Occurs if a user specifies an invalid event name.
      error('daq:showdaqevents:noevents', 'No events match the specified INDEX.');
   end
   
   % Extract the events.
   events = events(index);
else
   % Entire event structure is used.  Initialize the INDEX variable for 
   % the display.
   index = 1:length(events);
end

% Create the display strings.
str = daqgate('privateShowEvents', events, index);

% Either display or return the strings.
switch nargout
case 0
   fprintf('\n');
   for i = 1:length(str)
      fprintf(str{i})
   end
   fprintf('\n');      
case 1
   out = str';   
end


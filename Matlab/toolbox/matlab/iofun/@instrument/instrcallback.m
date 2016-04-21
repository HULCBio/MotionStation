function instrcallback(obj, event)
%INSTRCALLBACK Display event information for the event.
%
%   INSTRCALLBACK(OBJ, EVENT) displays a message which contains the 
%   type of the event, the time of the event and the name of the
%   object which caused the event to occur.  
%
%   If an error event occurs, the error message is also displayed.  
%   If a pin event occurs, the pin that changed value and the pin 
%   value is also displayed. 
%
%   INSTRCALLBACK is an example callback function. Use this callback 
%   function as a template for writing your own callback function.
%
%   Example:
%       s = serial('COM1');
%       set(s, 'OutputEmptyFcn', {'instrcallback'});
%       fopen(s);
%       fprintf(s, '*IDN?', 'async');
%       idn = fscanf(s);
%       fclose(s);
%       delete(s);
%

%   MP 2-24-00
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.4.4.3 $  $Date: 2004/01/16 20:03:49 $


% Define error message.
error1 = 'Type ''help instrument\instrcallback'' for an example using INSTRCALLBACK.';
error1Id = 'MATLAB:instrument:instrcallback:invalidSyntax';

switch nargin
case 0
   error(error1Id, sprintf(['This function may not be called with 0 inputs.\n',...
         'Type ''help instrument\instrcallback'' for an example using INSTRCALLBACK.']));
case 1
   error(error1Id, error1);
case 2
   if ~isa(obj, 'instrument') || ~isa(event, 'struct')
      error(error1Id, error1);
   end   
   if ~(isfield(event, 'Type') && isfield(event, 'Data'))
      error(error1Id, error1);
   end
end  

% Determine the type of event.
EventType = event.Type;

% Determine the time of the error event.
EventData = event.Data;
EventDataTime = EventData.AbsTime;
   
% Create a display indicating the type of event, the time of the event and
% the name of the object.
name = get(obj, 'Name');
fprintf([EventType ' event occurred at ' datestr(EventDataTime,13),...
	' for the object: ' name '.\n']);

% Display the error string.
if strcmp(lower(EventType), 'error')
	fprintf([EventData.Message '\n']);
end

% Display the pinstatus information.
if strcmp(lower(EventType), 'pinstatus')
    fprintf([EventData.Pin ' is ''' EventData.PinValue '''.\n']);
end

% Display the trigger line information.
if strcmp(lower(EventType), 'trigger')
    fprintf(['The trigger line is ' EventData.TriggerLine '.\n']);
end

% Display the datagram information.
if strcmp(lower(EventType), 'datagramreceived')
    fprintf([num2str(EventData.DatagramLength) ' bytes were ',...
            'received from address ' EventData.DatagramAddress,...
            ', port ' num2str(EventData.DatagramPort) '.\n']);
end

% Display the configured value information.
if strcmp(lower(EventType), 'confirmation')
    fprintf([EventData.PropertyName ' was configured to ' num2str(EventData.ConfiguredValue) '.\n']);
end

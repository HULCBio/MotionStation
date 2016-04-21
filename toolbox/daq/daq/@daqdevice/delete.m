function delete(obj,event)
%DELETE Remove data acquisition objects from the engine.
%
%    DELETE(OBJ) removes object, OBJ, from the data acquisition engine.
%    If any channels or lines are associated with OBJ, they are also 
%    deleted.  OBJ can be either a device array or a channel/line.
%
%    If OBJ is the last object accessing the identified hardware, the
%    associated hardware driver and driver specific adaptor are closed 
%    and unloaded.
%
%    Using CLEAR removes OBJ from the workspace only.
%  
%    DELETE should be used at the end of a data acquisition session.
%
%    If OBJ is running, DELETE(OBJ) will delete OBJ and a warning 
%    will be issued.  If OBJ is running and logging/sending, DELETE(OBJ)
%    will not delete OBJ and an error will be returned.
%
%    If multiple references to a data acquisition object exist in the 
%    workspace, deleting one reference will invalidate the remaining 
%    references.  These remaining references should be cleared from 
%    the workspace.
%
%    Example:
%      ai = analoginput('winsound');
%      aiCopy = ai;
%      delete(ai)  % Removes ai from the data acquisition engine.
%                  % aiCopy is now an invalid object.
%
%    See also DAQHELP, DAQRESET, DAQ/PRIVATE/CLEAR.
%

%    CP 3-30-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.12.2.4 $  $Date: 2003/08/29 04:41:08 $

% If two inputs are given, verify that the second input is the event
% structure otherwise error.
if nargin == 2
   if ~(isfield(event, 'Type') && isfield(event, 'Data'))
      error('daq:delete:argcheck', 'Too many input arguments.');
   end
end

% Initialize variables.
handles = daqgetfield(obj, 'handle');

% If the handle is valid delete the object.  The validity needs to be 
% checked for the case: delete([ai ai ai1 ai ai1]);  After deleting 
% the first element in the array, the second element is invalid and 
% calling delete on it produces an error.
for i = 1:length(obj)
   try
      if daqmex('IsValidHandle', handles(i))
         daqmex(handles(i),'delete');
      end
   catch
      error('daq:delete:unexpected', lasterr)
   end
end

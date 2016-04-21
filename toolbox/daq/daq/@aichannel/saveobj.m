function obj = saveobj(obj)
%SAVEOBJ Save filter for data acquisition objects.
%
%    B = SAVEOBJ(OBJ) is called by SAVE when a data acquisition object is
%    saved to a .MAT file. The return value B is subsequently used by SAVE  
%    to populate the .MAT file.  
%
%    SAVEOBJ will be separately invoked for each object to be saved.
% 
%    See also DAQ/PRIVATE/SAVE, ANALOGINPUT/LOADOBJ.
%

%    MP 4-17-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.11.2.4 $  $Date: 2003/08/29 04:39:19 $

% If the object is invalid store nothing, warn and return.
if ~all(isvalid(obj))
   obj.daqchild = getsetstore(obj.daqchild,[]);
   
   % Set the warning to not use a backtrace.
   s = warning('off', 'backtrace');
   warning('daq:saveobj:invalidobject', 'An invalid object is being saved.');
   % Restore the warning state.
   warning(s);
   
   return;
end

% Get the parent object.
% Then obtain the information needed for storing.
% store_info{1} - property values of the Analog Input object
%                (minus the Channel property).
% store_info{2} - property values of the AIChannel objects
%                (minus the Parent property).
% store_info{3} - Creation Time
% store_info{4} - a cell array of the adaptor and HWID.
% channel       - the actual channels saved.
try
   parent = daqmex(obj,'get','parent');
   [store_info, channel] = daqgate('privatesavecell', parent);
catch
   error('daq:saveobj:unexpected', lasterr);
end

% Get the handles to the channels that are being saved.
chan_handle = channel.handle;
if ~iscell(chan_handle)
   chan_handle = {chan_handle};
end

% Add chan_handle to the store_info cell array.
store_info{2} = chan_handle;

% Save the information to the store field of the daqchild object.
% GETSETSTORE is used to access the parent object's (daqchild object)
% store field since a parent's fields are not accessible in a child 
% object's methods.
obj.daqchild = getsetstore(obj.daqchild,store_info);



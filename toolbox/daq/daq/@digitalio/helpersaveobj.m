function obj = helpersaveobj(obj)
%HELPERSAVEOBJ Helper function to SAVEOBJ.
%
%    B = HELPERSAVEOBJ(OBJ) is a helper function for SAVEOBJ which 
%    is a save filter for data acquisition objects.
%
%    See also DAQ/PRIVATE/SAVE, ANALOGINPUT/SAVEOBJ.
%

%    MP 9-23-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.6.2.4 $  $Date: 2003/08/29 04:41:44 $

% If the object is invalid store nothing, warn and return.
if ~all(isvalid(obj))
   obj.daqdevice = getsetstore(obj.daqdevice,[]);
   
   % Set the warning to not use a backtrace.
   s = warning('off', 'backtrace');
   warning('daq:saveobj:invalidobject', 'An invalid object is being saved.');
   % Restore the warning state.
   warning(s);
   
   return;   
end

% Obtain the information needed for storing.
% store_info{1} - property values of the Analog Input object
%                (minus the Channel property).
% store_info{2} - property values of the AIChannel objects
%                (minus the Parent property).
% store_info{3} - Creation Time
% store_info{4} - a cell array of the adaptor and HWID.
try
   store_info = daqgate('privatesavecell', obj);
catch
   error('daq:saveobj:unexpected', lasterr);
end

% Store the handles so that the correct size output can be produced.
store_info = {store_info obj.handle};

% Save the information to the store field of daqdevice object.
% GETSETSTORE is used to access the parent object's (daqdevice object)
% store field since a parent's fields are not accessible in a child 
% object's methods.
obj.daqdevice = getsetstore(obj.daqdevice,store_info);


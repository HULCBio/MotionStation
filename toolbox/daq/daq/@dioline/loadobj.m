function obj = loadobj(B)
%LOADOBJ Load filter for data acquisition objects.
%
%    OBJ = LOADOBJ(B) is called by LOAD when a data acquisition object  
%    is loaded from a .MAT file. The return value, OBJ, is subsequently 
%    used by LOAD to populate the workspace.  
%
%    LOADOBJ will be separately invoked for each object in the .MAT file.
%
%    See also DAQ/PRIVATE/LOAD, ANALOGINPUT/SAVEOBJ.
%

%    MP 4-17-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.6.2.4 $  $Date: 2003/08/29 04:41:56 $

% Initialize parent variable.
parent = [];

% Get the information that was stored during SAVEOBJ in daqchild's
% store field.  
info = getsetstore(B.daqchild);

% If info is empty an invalid object was stored and an invalid
% object is created and returned.
if isempty(info)
   obj = dioline(int32(0));
   % It is possible that info will be an empty cell array.  This occurs
   % if the object saved UserData is another data acquisition object. 
   % If this is the case, a warning should not be displayed.
   if isnumeric(info)
      % Set the warning to not use a backtrace.
      s = warning('off', 'backtrace');
      warning('daq:loadobj:invalidobject', 'An invalid object is being loaded.');
      % Restore the warning state.
      warning(s);
   end
   return;
end

% Extract the CreationTime and line handles from the store variable, info.
time = info{1}{3};
chan_handle = info{2};

% Need to recreate the parent object so that the Parent field of the Line
% object being loaded is correct.  All the line objects need to be
% created initially and then the handles of the object that is being loaded
% will be compared to the parent object's line objects and the correct
% lines will be extracted.

% Obtain a cell array of AnalogInput, AnalogOutput and DigitalIO objects.
basevar = daqfind;
for i = 1:length(basevar)
   % If the object is an Digital I/O compare the creation time.
   tempobj = get(basevar, i);
   if isa(tempobj, 'digitalio')
      timebasevar = get(tempobj, 'CreationTime');
      if (timebasevar == time)
         % If the creationtime's are equal the objects are pointing to 
         % the same thing in the engine.  privateExistParent compares
         % the property values of the two objects and makes them the 
         % same as the object that is being loaded.
         try
            parent = daqgate('privateExistParent',info{1}, tempobj);
         catch
            error('daq:loadobj:unexpected', lasterr);
         end;
         % The parent object has been created.  
         break;
      end
   end
end

% Construct the parent with all its children if it does not currently exist.
if isempty(parent)
   try
      parent = daqgate('privatecreateobj', info{1});
   catch
      error('daq:loadobj:unexpected', lasterr);
   end
end

% Return those lines that were saved only.
obj = [];
for i = 1:length(B.handle)
   index = find(B.handle(i) == chan_handle{:});
   obj = [obj; parent.Line(index)];
end

% If the sizes are not equal then transpose the line array.
if size(B.handle) ~= size(obj)
   obj = obj';
end
   
   
   

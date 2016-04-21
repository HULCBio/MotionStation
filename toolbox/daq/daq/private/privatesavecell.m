function [store_info, child] = privatesavecell(objs)
%PRIVATESAVECELL Obtain information to be stored before saving object.
%
%    STORE_INFO = PRIVATESAVECELL(OBJ) obtains the information from the 
%    object, OBJ, that needs to be stored in the parent object's 
%    store field.
%

%    PRIVATESAVECELL is a helper function for @analoginput\saveobj,
%    @analogoutput\saveobj, @aichannel\saveobj, @aochannel\saveobj.
%

%    MP 6-08-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.10.2.4 $  $Date: 2003/08/29 04:42:31 $

% Initialize variables.
DataMissedFcn = 1;
InputOverRangeFcn = 2;
RuntimeErrorFcn = 3;
SamplesAcquiredFcn = 4;
SamplesOutputFcn = 5;
StartFcn = 6;
StopFcn = 7;
TimerFcn = 8;
TriggerFcn = 9;
UserData = 10;

% Determine the child object's name (Channel or Line);
handles = daqgetfield(objs, 'handle');
info = daqgetfield(objs, 'info');

for i = 1:length(objs)
   obj = handles(i);
   child_name = info(i).child;
   
   % Obtain the child objects 
   child = daqmex(obj, 'get', child_name);
   
   % Get the parent property information and remove the child field (Channel/Line).
   parent_prop = daqmex(obj, 'get');
   parent_prop = rmfield(parent_prop, child_name);
   
   % If the TriggerChannel property exists and it is set to a channel, save the
   % index of the channel rather than the actual channel.
   if isfield(parent_prop, 'TriggerChannel') && ~isempty(parent_prop.TriggerChannel)
      parent_prop.TriggerChannel = get(parent_prop.TriggerChannel, {'Index'});
   end
   
   % Get child property information and remove the Parent field.
   child_prop = get(child);
   if ~isempty(child_prop)
      child_prop = rmfield(child_prop, 'Parent');
   end
   
   % Get the CreationTime property value of the Analog Input object
   time = daqmex(obj, 'get', 'CreationTime');
   
   % Get the adaptor and ID for the object.
   hwinfo = daqmex(obj, 'daqhwinfo');
   adaptor = hwinfo.AdaptorName;
   hwid = hwinfo.ID;
   
   isSaved = daqmex(obj, 'get', 'IsSaved');
   if isempty(isSaved)
      isSaved = zeros(1,10);
      daqmex(obj, 'set', 'IsSaved', isSaved);
   end
   
   % Determine if the object's UserData is a Data Acquisition object.
   if isfield(parent_prop, 'UserData') && ~isempty(parent_prop.UserData)
      tempobj = daqmex(obj, 'get', 'UserData');
      if ~isSaved(UserData)
         if isa(tempobj, 'daqdevice') 
            isSaved(UserData) = 1;
            daqmex(obj, 'set', 'IsSaved', isSaved)
            parent_prop.UserData = helpersaveobj(tempobj);
         elseif isa(tempobj, 'daqchild')
            isSaved(UserData) = 1;
            daqmex(obj, 'set', 'IsSaved', isSaved)
            parent_prop.UserData = saveobj(tempobj);
         elseif iscell(tempobj) || isstruct(tempobj)
            isSaved(UserData) = 1;
            daqmex(obj, 'set', 'IsSaved', isSaved)
            parent_prop.UserData = daqgate('privateSaveUserData', tempobj);
		 else
			 try
				 parent_prop.UserData = saveobj(tempobj);
			 catch
				 % unhandle object, do nothing
			 end
		 end
      end
   end
   
   % Determine if any of the callback properties contain a Data Acquisition
   % object.
   parent_prop_field = fieldnames(parent_prop);
   parent_prop_value = struct2cell(parent_prop);
   for k = 1:length(parent_prop_field)
      callbackInfo = daqmex(obj, 'propinfo', parent_prop_field{k});
      %if findstr('Fcn', lower(parent_prop_field{k})) & iscell(parent_prop_value{k})
      if strcmp(callbackInfo.Type, 'callback') && iscell(parent_prop_value{k})
         tempobj = daqmex(obj, 'get', parent_prop_field{k});
         isSaved = daqmex(obj, 'get', 'IsSaved');
         if ~isSaved(eval(parent_prop_field{k}))
            isSaved(eval(parent_prop_field{k})) = 1;
            daqmex(obj, 'set', 'IsSaved', isSaved);
            parent_prop = setfield(parent_prop, parent_prop_field{k}, ...
               daqgate('privateSaveUserData', tempobj));
         end
      end
   end
   
   % Combine the information into a cell array.
   store_info{i} = {parent_prop, child_prop, time, {adaptor hwid}};
end


function obj = privateExistParent(info,engine_parent)
%PRIVATEEXISTPARENT Determine if the device object exists.
%
%    PRIVATEEXISTPARENT determines if the device object already
%    exists in the MATLAB workspace before the object is loaded
%    from the MAT-file.  If it does exist, all the properties
%    are compared to determine if they are equal.  If they are
%    not equal, the property values are changed to the loaded
%    objects property values.
%

%    PRIVATEEXISTPARENT is a helper function for @analoginput\loadobj,
%    @analogoutput\loadobj, @aichannel\loadobj, @aochannel\loadobj.

%    MP 6-10-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.14.2.5 $  $Date: 2003/12/04 18:38:38 $

% engine_parent is the Data Acquisition object that exists in the engine.  
% info is the cell array which contains property information on the
% object that is being loaded.

% Initialize variables.
obj = [];
rflag = 0;
triggerChannel = [];

% Set the warning up to use no backtrace.
s = warning('off', 'backtrace');

% Extract the child name and method for adding a child to the parent.
h = struct(engine_parent);
child_name = h.info.child;    % Channel or Line
child_fcn  = h.info.addchild; % addchannel or addline

% Extract the information from the info cell array.
% recreate_parent_prop - contains the property information of the 
%                        Parent object minus the Child object.
% recreate_child_prop  - contains the property information of the 
%                        Child object minus the Parent object.
recreate_parent_prop = info{1};
recreate_child_prop  = info{2};

% Convert the structure to a cell array of [prop name].
rvalues = struct2cell(recreate_parent_prop);
rprop = fieldnames(recreate_parent_prop);
recreate_parent_pvpair = [rprop rvalues];

% Determine if the object that is being loaded has the same property 
% values as the object that already exists in the engine (engine_parent).

% Get the parent properties (minus Channel or Line (child_name))
engine_parent_prop = daqmex(engine_parent, 'get');
engine_parent_prop = rmfield(engine_parent_prop, child_name);

% Modify the TriggerChannel property of engine_parent_prop if it is set
% to a channel.  The channels need to be converted to their index values
% so that it can be compared to recreate_parent_prop which has the index
% values and not the actual channels.  Otherwise the comparison below always
% fails and a warning is always issued when the TriggerChannel property is set.
if isfield(engine_parent_prop, 'TriggerChannel')
   if ~isempty(engine_parent_prop.TriggerChannel)
      engine_parent_prop.TriggerChannel = get(engine_parent_prop.TriggerChannel, {'Index'});
   end
end

% Convert the structure to a cell array of [prop name].
evalues = struct2cell(engine_parent_prop);
eprop = fieldnames(engine_parent_prop);
engine_parent_pvpair = [eprop evalues];

% Get the child properties (minus Parent)
% daqmex cannot be used in case there is more than one channel.
engine_child = daqmex(engine_parent, 'get', child_name);
if ~isempty(engine_child)
   engine_child_prop = get(engine_child);
   engine_child_prop = rmfield(engine_child_prop, 'Parent');
else
   engine_child_prop = [];
end

engine_parent_prop_temp = engine_parent_pvpair;
recreate_parent_prop_temp = recreate_parent_pvpair;

% Remove the UserData and determine if the engine's UserData equals
% what is being loaded.
iswarned = privateCheckUserData(engine_parent_prop.UserData,...
   recreate_parent_prop.UserData);
engine_parent_prop_temp = localRmField(engine_parent_prop_temp, {'UserData'});
recreate_parent_prop_temp = localRmField(recreate_parent_prop_temp, {'UserData'});

% Remove any callback properties which contain a cell array.  Determine
% if the engine's callback property equals what is being loaded.
for k = 1:length(rprop)
   if ~isempty(findstr('Fcn', rprop{k}))
      if iscell(rvalues{k})
         iswarned(end+1) = privateCheckUserData(evalues{k},rvalues{k});
         engine_parent_prop_temp = localRmField(engine_parent_prop_temp, rprop(k));
         recreate_parent_prop_temp = localRmField(recreate_parent_prop_temp, rprop(k));
         if iswarned(end) == 0
            % The properties are equal therefore don't want to reset
            % the property value.
            recreate_parent_pvpair = localRmField(recreate_parent_pvpair, rprop(k));
         end
      end
   end
end

% Remove the read-only properties - temporarily for comparison.
readOnly = privatereadonly(engine_parent);
engine_parent_prop_temp = localRmField(engine_parent_prop_temp, readOnly);
recreate_parent_prop_temp = localRmField(recreate_parent_prop_temp, readOnly);

% If the properties are equal, the object is returned.  Otherwise, the
% properties of the object that exists in the engine needs to be set to 
% the values of the object that is being loaded.  If the object in the 
% engine is running, a warning is given indicating that the object is stopped 
% (since the object must be stopped before the properties can be set) and that
% property values have been changed, otherwise a warning is given that
% property values have been changed.
if isequal(engine_parent_prop_temp, recreate_parent_prop_temp) &&...
      isequal(engine_child_prop, recreate_child_prop) && (sum(iswarned) == 0)
   obj = engine_parent;
   
   % Reset the read-only properties.
   daqmex(obj, 'reset');
   warning(s);
   return;
else
   if isfield(engine_parent_prop, 'Running') &&...
         strcmp(engine_parent_prop.Running, 'On')
      warning('%s\n%s', 'Loaded object has stopped the Data Acquisition session',...
            'and has updated property values.');
      stop(engine_parent);
   elseif iswarned(1) == 1 && all(iswarned)
      warning('Loaded object has updated property values.');
   elseif ~isequal(engine_parent_prop_temp, recreate_parent_prop_temp)
      warning('Loaded object has updated property values.');
   elseif ~isequal(engine_child_prop, recreate_child_prop)
      warning('Loaded object has updated property values.');
   end  
   
   % Remove the read-only properties from the recreate_parent_prop structure 
   % and set the object's (that exists in the engine) properties.
   propremove = daqgate('privatereadonly',engine_parent);
   recreate_parent_pvpair = localRmField(recreate_parent_pvpair, propremove);

   
   % Remove the ChannelSkew property if ChannelSkewMode is not Manual.
   if isfield(recreate_parent_prop, 'ChannelSkewMode') &&...
         isfield(recreate_parent_prop, 'ChannelSkew')
      if ~strcmp(recreate_parent_prop.ChannelSkewMode, 'Manual')
         recreate_parent_pvpair=localRmField(recreate_parent_pvpair, {'ChannelSkew'});
      end
   end
   
   % If the TriggerChannel property is not empty, remove it and recreate
   % its settings after the channels have been added.
   if isfield(recreate_parent_prop, 'TriggerChannel') && ...
         ~isempty(recreate_parent_prop.TriggerChannel)
      triggerChannel = recreate_parent_prop.TriggerChannel;
      recreate_parent_pvpair = localRmField(recreate_parent_pvpair, {'TriggerChannel'});
   end
   
   % Set the TriggerType and TriggerCondition properties since these properties
   % must be set in that order (non-alphabetical).
   if isfield(recreate_parent_prop, 'TriggerType') &&...
         isfield(recreate_parent_prop, 'TriggerCondition')
      set(engine_parent, 'TriggerType', recreate_parent_prop.TriggerType);
      set(engine_parent, 'TriggerCondition', recreate_parent_prop.TriggerCondition);
      recreate_parent_pvpair = localRmField(recreate_parent_pvpair, {'TriggerType', 'TriggerCondition'});
   end
   
   % If the BufferingMode property is set to Manual, then the BufferingConfig
   % property is restored only.  If the BufferingMode property is set to Auto,
   % then the BufferingMode property is restored only.
   if isfield(recreate_parent_prop, 'BufferingMode')
      if strcmp(recreate_parent_prop.BufferingMode, 'Manual')
         recreate_parent_pvpair = localRmField(recreate_parent_pvpair, {'BufferingMode'});
      elseif strcmp(recreate_parent_prop.BufferingMode, 'Auto') && ...
            isfield(recreate_parent_prop, 'BufferingConfig')
         recreate_parent_pvpair = localRmField(recreate_parent_pvpair, {'BufferingConfig'});
      end
   end
   
   % Remove InputType if it's value is the same as the engines otherwise
   % any existing channels may be deleted.
   if isfield(recreate_parent_prop, 'InputType')
      if strcmp(recreate_parent_prop.InputType, daqmex(engine_parent, 'get', 'InputType'))
         recreate_parent_pvpair = localRmField(recreate_parent_pvpair, {'InputType'});
      end
   end
   
   % Restore the read-only properties to a pre-start state.
   daqmex(engine_parent, 'reset');
   % dio objects do not have samplerate (or maxsamplerate)
   if ~isa(engine_parent,'digitalio')
       try
           maxSR = daqhwinfo(engine_parent, 'MaxSampleRate');
           if recreate_parent_prop.SampleRate > maxSR 
               recreate_parent_prop.SampleRate = maxSR;
               index = find(strcmp('SampleRate', recreate_parent_pvpair));
               if ~isempty(index)
                   recreate_parent_pvpair{index, 2} = maxSR;
               end
           end
       catch
       end
   end
   
   % Reset the existing object's parent properties to the stored values.
   for i = 1:length(recreate_parent_pvpair)
      daqmex(engine_parent, 'set', recreate_parent_pvpair{i,1}, recreate_parent_pvpair{i,2});
   end
   
   % Loop through each child object and set it's properties. 
   if ~isequal(engine_child_prop, recreate_child_prop)
      % Determine if a channel was added or deleted.
      diffchild = length(recreate_child_prop) - length(engine_child);
      
      % Modify the channel properties for those channels that exist in 
      % engine_parent and in the loaded object.
      if ~isempty(recreate_child_prop)
         % Determine the HwID's in case a channel needs to be added
         eval(['hwid = [recreate_child_prop.Hw' child_name '];'])

         % Update the properties of the channels that currently exist.
         if ~isempty(engine_child) 
            % Determine the read-only properties.
            propremove = daqgate('privatereadonly',engine_child(1));
            propremove = {propremove{:} ['Hw' child_name ]}';
            propremove(strmatch('Parent', propremove)) = [];
            rflag = 1;
            
            % Get access to the engine_child's handle array.
            engine_child_struct = struct(engine_child);
            classname = class(engine_child);
            
            % Set the channel properties.
            for j = 1:min(length(engine_child),length(recreate_child_prop))
               % Convert the structure to a cell array of [prop value].
               values = struct2cell(recreate_child_prop(j));
               prop = fieldnames(recreate_child_prop(j));
               recreate_child_pvpair = [prop values];
               
               % Remove the read-only properties.
               recreate_child_pvpair = localRmField(recreate_child_pvpair, propremove);
               
               % Create the object.
               temp = feval(classname,engine_child_struct.handle(j));
               
               % Set the new object's properties.
               for k = 1:length(recreate_child_pvpair)
                  daqmex(temp, 'set', recreate_child_pvpair{k,1}, recreate_child_pvpair{k,2});
               end
            end
         end
      end
      
      % Add or delete channels depending on diffchan.
      if diffchild >= 1 
         % A positive diffchild indicates that a channel or line was deleted  
         % from the object that already exists in the MATLAB workspace. 
         
         % Get the child structure and hwid's that still need to be added.
         recreate_child_prop = recreate_child_prop(end-diffchild+1:end);
         hwid = hwid(end-diffchild+1:end);
         
         for j = 1:diffchild
            % Add the channel or line with addchild or addline (child_fcn)
            % to the object that exists in the engine (engine_parent).
            
            switch child_name
            case 'Channel'
               addedchild = feval(child_fcn, engine_parent, hwid(j));
            case 'Line'
               addedchild = feval(child_fcn, engine_parent, hwid(j), recreate_child_prop(j).Direction);
            end
            
            % Determine the read-only properties.
            if (j == 1) && (rflag ~= 1)
               propremove = daqgate('privatereadonly',addedchild);
               propremove = {propremove{:} ['Hw' child_name ]}';
               propremove(strmatch('Parent', propremove)) = [];
            end
            
            % Remove the read only property from the [prop value] cell array.
            values = struct2cell(recreate_child_prop(j));
            prop = fieldnames(recreate_child_prop(j));
            recreate_child_pvpair = [prop values];
            recreate_child_pvpair = localRmField(recreate_child_pvpair, propremove);
            
            % Set the channel/line properties.
            for k = 1:length(recreate_child_pvpair)
               daqmex(addedchild, 'set', recreate_child_pvpair{k,1}, recreate_child_pvpair{k,2});
            end
         end
         warning(['Loaded object has added ' child_name 's.']);
      elseif diffchild <= -1
         % A negative diffchild indicates that a channel or line was added to 
         % the object in the engine.  Those additional channels or lines need 
         % to be deleted.
         
         delete(engine_child(length(engine_child)+diffchild+1:length(engine_child)));
         warning(['Loaded object has deleted ' child_name 's.']);
      end
   end
   
   % Reset the TriggerChannel property.
   if ~isempty(triggerChannel);
      child = daqmex(engine_parent, 'get', child_name);
      daqmex(engine_parent, 'set', 'TriggerChannel', child([triggerChannel{:}]));
   end
   
   % Assign engine_parent to the output variable, obj.
   obj = engine_parent;
   
   % Reset the warning to its original value.
   warning(s);
end

% ***********************************************************************
% Modified version of rmfield.
function pvpair = localRmField(pvpair, field)

for j = 1:length(field)
   i = find(strcmp(pvpair(:,1), field{j}));
   pvpair(i,:) = [];
end
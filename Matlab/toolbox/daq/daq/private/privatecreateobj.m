function parent = privatecreateobj(info) 
%PRIVATECREATEOBJ Reconstruct data acquisition object.
%
%    NEWOBJ = PRIVATECREATEOBJ(INFO) reconstructs the data acquisition
%    objects from the stored information, INFO.
%

%    PRIVATECREATEOBJ is a helper function for @analoginput\loadobj,
%    @analogoutput\loadobj, @aichannel\loadobj, @aochannel\loadobj.
%

%    MP 6-08-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.12.2.4 $  $Date: 2003/08/29 04:42:26 $

% Initialize variables.
triggerChannel = [];

% Get object information from the INFO cell array
% info{1} - property values of the Analog Input object
%                (minus the Channel property).
% info{2} - property values of the AIChannel objects
%                (minus the Parent property).
% info{3} - Creation Time
% info{4} - a cell array of the adaptor and HWID.
recreate_parent_prop = info{1}; 
recreate_child_prop  = info{2};
time                 = info{3};
hwinfo               = info{4};

% Determine what kind of object is to be created
% (analgoinput, analogoutput).
fcnname = lower(recreate_parent_prop.Type);
i = find(fcnname == ' ');
fcnname(i) = [];

% Get the hardware information.
adaptor = hwinfo{1};
hwid = hwinfo{2};

% Create the object from the hardware information.
if isempty(hwid) 
   parent = feval(fcnname, adaptor);
else
   parent = feval(fcnname, adaptor, hwid);
end

% Convert the structures to cell arrays of [prop name];
values = struct2cell(recreate_parent_prop);
prop = fieldnames(recreate_parent_prop);
recreate_parent_pvpair = [prop values];

% Remove the read-only properties from the prop structure.
recreate_parent_pvpair=localRmField(recreate_parent_pvpair,...
   daqgate('privatereadonly',parent));

% Remove the ChannelSkew property if ChannelSkewMode is not Manual.
if isfield(recreate_parent_prop, 'ChannelSkewMode') && ...
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
   daqmex(parent, 'set', 'TriggerType', recreate_parent_prop.TriggerType);
   daqmex(parent, 'set', 'TriggerCondition', recreate_parent_prop.TriggerCondition);
   recreate_parent_pvpair = localRmField(recreate_parent_pvpair, ...
      {'TriggerType', 'TriggerCondition'});
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

try
   maxSR = daqhwinfo(parent, 'MaxSampleRate');
   if recreate_parent_prop.SampleRate > maxSR 
      recreate_parent_prop.SampleRate = maxSR;
      index = find(strcmp('SampleRate', recreate_parent_pvpair));
      if ~isempty(index)
         recreate_parent_pvpair{index, 2} = maxSR;
      end
   end
catch
end

% Reset the existing object's parent properties to the stored values.
for i = 1:length(recreate_parent_pvpair)
   daqmex(parent, 'set', recreate_parent_pvpair{i,1}, recreate_parent_pvpair{i,2});
end
   
% Reset the CreationTime property.
daqmex(parent, 'set', 'CreationTime', time);

% Determine the method for adding a child to the parent object
h = struct(parent);

child_name = h.info.child;    % Channel or Line

% Create the child objects from the recreate_child_prop variable.
if ~isempty(recreate_child_prop)
   eval(['hwchan = [recreate_child_prop.Hw' child_name '];'])
   for i = 1:length(recreate_child_prop)
      % Add the child object to the parent.
      switch child_name
      case 'Channel'
         %newchild = feval(child_fcn, parent, hwchan(i));
         newchild = addchannel(parent, hwchan(i));
      case 'Line'
         newchild = daqmex(parent, 'dioline', hwchan(i), recreate_child_prop(i).Port); %call daqmex to prevent needing to set direction here
      end
      
      % Determine which properties are read-only.  This is done
      % only once rather than each time through the loop.  The parent
      % property needs to be removed since it was removed in saveobj.
      if i == 1
         readonly = daqgate('privatereadonly',newchild);
         readonly = {readonly{:} ['Hw' child_name ]}';
         readonly(strcmp('Parent', readonly)) = [];
      end
      
      % Convert the structures to cell arrays of [prop name];
      values = struct2cell(recreate_child_prop(i));
      prop = fieldnames(recreate_child_prop(i));
      child_pvpair = [prop values];
      child_pvpair = localRmField(child_pvpair, readonly);
      
      % Set the child properties.
      for j = 1:length(child_pvpair)
         daqmex(newchild, 'set', child_pvpair{j,1}, child_pvpair{j,2});
      end
   end
end

% Reset the TriggerChannel property.
if ~isempty(triggerChannel)
   child = get(parent, child_name);
   daqmex(parent, 'set', 'TriggerChannel', child([triggerChannel{:}]));
end

% ***********************************************************************
% Modified version of rmfield.
function pvpair = localRmField(pvpair, field)

for j = 1:length(field)
   i = find(strcmp(pvpair(:,1), field{j}));
   pvpair(i,:) = [];
end
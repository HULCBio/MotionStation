function getdisplay(obj, out)
%GETDISPLAY Create the display for the GET command.
%
%    GETDISPLAY  Create the display for the GET command
%    so that the InputRange displays the actual values 
%    rather than [2x1 double].

%    GETDISPLAY is a helper function for @daqdevice\get and
%    @daqchild\get.

%    MP 6-03-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.10.2.4 $  $Date: 2003/08/29 04:42:05 $

% Get the property names (names) and property values (val).
names = fieldnames(out);
val = struct2cell(out);

% Store device specific properties in DEVICEPROPS.
propinfonames = propinfo(obj);
propinfovalues = struct2cell(propinfonames);
deviceprops = {};

% Loop through each property and determine the display (dependent
% upon the class of val).
for i = 1:length(val)
   if isnumeric(val{i})
      [m,n] = size(val{i});
      if isempty(val{i})
         % Print the property name only.
         if strcmp(names{i}, 'TriggerConditionValue')
            fprintf(['        %s = [1x0 double]\n'], names{i});
         elseif any(strcmp(names{i}, {'Channel', 'Line'}))
            info = struct(obj);
            classname = lower(info.info.childconst);
            fprintf(['        %s = [0x1 %s]\n'], names{i}, classname);
         elseif strcmp(names{i}, 'TriggerChannel')
            info = struct(obj);
            classname = lower(info.info.childconst);
            fprintf(['        %s = [1x0 %s]\n'], names{i}, classname);
         elseif propinfovalues{i}.DeviceSpecific,
            deviceprops = {deviceprops{:} sprintf(['        %s = []\n'], names{i})};
         else
            fprintf(['        %s = []\n'], names{i})
         end         
      elseif (m*n == 1)
         % SamplesPerTrigger = 1024
         if propinfovalues{i}.DeviceSpecific,
            deviceprops = {deviceprops{:} sprintf(['        %s = %g\n'], names{i}, val{i})};
         else
            fprintf(['        %s = %g\n'], names{i}, val{i});
         end
      elseif ((m == 1) || (n == 1)) && (m*n <= 10)
         % The property value is a vector with a max of 10 values.
         % UserData = [1 2 3 4]
         numd = repmat('%g ',1,length(val{i}));
         numd = numd(1:end-1);
         if propinfovalues{i}.DeviceSpecific,
            deviceprops = {deviceprops{:} sprintf(['        %s = [' numd ']\n'], names{i}, val{i})};
         else
            fprintf(['        %s = [' numd ']\n'], names{i}, val{i});
         end
      else
         % The property value is a matrix or a vector with more than 10 values.
         % UserData = [10x10 double]
         if propinfovalues{i}.DeviceSpecific,
            deviceprops = {deviceprops{:} sprintf('        %s = [%dx%d %s]\n', names{i},m,n,class(val{i}))};
         else
            fprintf('        %s = [%dx%d %s]\n', names{i},m,n,class(val{i}));
         end
      end
   elseif ischar(val{i})
      % The property value is a string.
      % LogToDiskMode = Append
      if propinfovalues{i}.DeviceSpecific,
         deviceprops = {deviceprops{:} sprintf(['        %s = %s\n'], names{i}, val{i})};
      else
         fprintf(['        %s = %s\n'], names{i}, val{i});
      end
	elseif isa(val{i},'function_handle')
      % The property value is a string.
      % LogToDiskMode = Append
      if propinfovalues{i}.DeviceSpecific,
         deviceprops = {deviceprops{:} sprintf(['        %s = %s\n'], names{i}, val{i})};
      else
         fprintf(['        %s = @%s\n'], names{i}, func2str(val{i}));
      end

   else
      % The property value is a analoginput, aichannel, etc object.
      % Channel = [2x1 aichannel] 
      [m,n]=size(val{i});
      if propinfovalues{i}.DeviceSpecific,
         deviceprops = {deviceprops{:} sprintf('        %s = [%dx%d %s]\n', names{i},m,n,class(val{i}))};
      else
         fprintf('        %s = [%dx%d %s]\n', names{i},m,n,class(val{i}));
      end
   end
end

% Create a blank line after the property value listing.
fprintf('\n');

% Device specific properties are displayed if they exist.
if ~isempty(deviceprops)
   % Determine adaptor.
   if isa(obj,'daqchild'),
      parent = get(obj,'Parent');
   else
      parent = obj;
   end
   objinfo = daqhwinfo(parent);
   
   % Create device specific heading.
   fprintf(['        ' upper(objinfo.AdaptorName) ' specific properties:\n']);
   
   % Display device specific properties.
   for i=1:length(deviceprops),
      fprintf(deviceprops{i})
   end
   
   % Create a blank line after the device specific property value listing.
   fprintf('\n');
end


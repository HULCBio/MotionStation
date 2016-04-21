function out = saveobj(obj)
%SAVEOBJ Save filter for serial port objects.
%
%   B = SAVEOBJ(OBJ) is called by SAVE when a serial port object is
%   saved to a .MAT file. The return value B is subsequently used by
%   SAVE to populate the .MAT file.  
%
%   SAVEOBJ will be separately invoked for each object to be saved.
% 

%   MP 3-14-00
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.11.4.7 $  $Date: 2004/01/16 20:04:39 $

% Define a persistent variable to help with recursively linked objects.
persistent objsSaved;

% Check to see if we have previously saved this object prior.
if ~isempty(objsSaved)
	for i = 1:length(objsSaved)
		if isequal(objsSaved{i}, obj) && ~isa(obj, 'instrument')
			% Detected that object has been previously saved
			% Break the recursive link.
			out = [];
            
            % Store the state of the warning. Turn off backtrace.
            bt = warning('query', 'backtrace'); 
            warning off backtrace; 

			% Display a warning to the user.
			warning('MATLAB:serial:saveobj:recursive', ...
				'A recursive link between objects has been found during SAVE. \nAll objects have been saved, but the link has been removed.');			
            
            % Restore the warning state.
            warning(bt); 
			return;
		end
	end
end

% Object was not saved prior, add to recurssive list.
objsSaved{end+1} = obj;

% Determine the number of objects being saved.
allJObjects = igetfield(obj, 'jobject');
numJObjects = length(allJObjects);

% ***************************************************************************
% A structure will be created which contains:
% x(i).jobject  = jobject
% x(i).props    = get(jobject) % Read-only properties removed (except Type).
% x(i).location = locations of the object.
%
% The location of the object is represented as a cell of structs. The 
% structures contain the following information.
%
%  Ex. y(1).Temp = 4; y(2).Temp = s1; s.UserData = y;    
%      s1's location field contains:
%           x.ObjectIndex = 1;             % s is stored in x(1)
%           x.Property    = 'UserData';
%           x.Index       = {'()', 2, '.', 'Temp', '()', 1};
%
% Every jobject will be replaced with the index of the appropriate jobject
% in the x structure.
% ***************************************************************************

% Create an empty structure which contains the necessary information to 
% recreate all the objects.
propInfo = struct('jobject', '', 'props', '', 'location', '');

% Create a cell which contains information on the object's location in 
% the propInfo structure.
jobject = cell(1, numJObjects);

% Loop through each object and save.
for i = 1:numJObjects
    currentObj = allJObjects(i);
    
    if isempty(propInfo(1).jobject)
    	index = 1;
    else
        index = length(propInfo) +1;
    end
    
    % Determine if the object has already been saved.
    if localIsSaved(currentObj)
        % Object has been saved. Determine which object currentObj is equal to.
        jobject{i} = localFindSavedObject(currentObj, propInfo);
    elseif (isvalid(currentObj))
		% If the object is valid get it's property values.
        propInfo(index).jobject = currentObj;
        propInfo(index).props   = localFindSettableProperties(currentObj);
   		
        % Indicate that the object has been saved.
		localIndicateSaved(currentObj);
		
        % Store the location in the jobject array.
        jobject{i} = index;
        
        % Parse the object to determine if the UserData or the Fcn
        % properties contain any instrument objects.
        propInfo = localParseUserDataAndFcnProps(currentObj, propInfo);
	else
        % Invalid object - save the class type. 
        propInfo(index).jobject = currentObj;        
        propInfo(index).props   = class(java(currentObj));
        
        % Indicate that the object has been saved.
		localIndicateSaved(currentObj);
        
        % Store the location in the jobject arrays.
        jobject{i} = index;
    end
end
    
% Create the object that is going to be saved.
savedObj = obj;
savedObj = isetfield(savedObj, 'jobject', jobject);

% Remove the saved field - Can't use instrfind since invalid objects could
% have been modified..
localRemoveSavedFlag(propInfo);

% Store the table of objects in the store field - minus the UDD objects.
instrumentField = igetfield(obj, 'icinterface');
propInfo = rmfield(propInfo, 'jobject');
instrumentField = isetfield(instrumentField, 'store', propInfo);
savedObj = isetfield(savedObj, 'icinterface', instrumentField);

% Define output.
out = savedObj;

% Object saved without recurssive issue, remove from recursive list.      
objsSaved(end) = [];                                                       

% ************************************************************************
% Indicate that the object has been saved.
function localIndicateSaved(currentObj)

% Add a temporary property called Saved that cannot be accessed through
% SET or GET.
p = schema.prop(currentObj, 'Saved', 'double');
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';

% ************************************************************************
% Determine if object has been saved. Returns a logical 1 if saved,
% otherwise returns a logical 0.
function isSaved = localIsSaved(currentObj)

isSaved = ~isempty(currentObj.findprop('Saved'));

% ************************************************************************
% Remove the saved flag.
function localRemoveSavedFlag(propInfo)

% Can't use instrfind since invalid objects could have been modified.
for i = 1:length(propInfo)
    currentObj = propInfo(i).jobject;
	if ~isempty(currentObj)
		delete(currentObj.findprop('Saved'));
	end
end

% ****************************************************************************
% Find index of already saved object.
function equalIndex = localFindSavedObject(currentObj, propInfo)

% Initialize variables.
equalIndex = 1;
javaCurrentObj = java(currentObj);

% Loop through and find equivalent object.
for i = 1:length(propInfo)
	if equals(javaCurrentObj, java(propInfo(i).jobject)) == 1;
        equalIndex = i;
    	break
	end
end

% ****************************************************************************
% Save the settable properties only including the Type property.
function settable = localFindSettableProperties(currentObj)

if isa(java(currentObj), 'com.mathworks.toolbox.instrument.device.ICDevice')
    settable = localFindSettablePropertiesDevice(currentObj);
elseif isa(java(currentObj), 'com.mathworks.toolbox.instrument.device.ICDeviceChild')
    settable = localFindSettablePropertiesGroup(currentObj);
else
    settable = localFindSettablePropertiesInterface(currentObj);
end

% *************************************************************************
% Save the settable properties for an interface object.
function settable = localFindSettablePropertiesInterface(currentObj)

% Determine the property values.
allProps = get(currentObj);
propNames = fieldnames(allProps);

% Find the non-settable properties.
nonSettableProps = com.mathworks.toolbox.instrument.util.PropertyUtil.getNonSettable(java(currentObj));
nonSettableProps(cellfun('isempty', nonSettableProps)) = [];

% Remove the non-settable properties from property structure.
nonSettableProps(find(strcmp('Type', nonSettableProps))) = [];
settable = rmfield(allProps, nonSettableProps);
settable.ConstructorArgs = currentObj.constructorargs;
settable.CreationTime = currentObj.getUniqueCreationTime;

% ****************************************************************************
% Save the settable properties for a device object.
function settable = localFindSettablePropertiesDevice(currentObj)

% Determine the property values.
allProps = get(currentObj);
propNames = fieldnames(allProps);

jobj = java(currentObj);

% Find the non-settable properties.
nonSettableProps = com.mathworks.toolbox.testmeas.device.util.PropertyUtil.getNonSettable(jobj);
nonSettableProps(cellfun('isempty', nonSettableProps)) = [];

% Remove the non-settable properties from property structure.
nonSettableProps(find(strcmp('Type', nonSettableProps))) = [];
settable = rmfield(allProps, nonSettableProps);

% Save the driver name and the type of driver.
tempConstructorArgs    = getConstructorArgs(jobj);
constructorArgs.driver = char(tempConstructorArgs(1));
constructorArgs.type   = jobj.getDriverTypeDisplayName;

% If a MATLAB interface driver is being used, save the interface object.
if strcmp(jobj.getDriverTypeDisplayName, 'MATLAB interface driver')
    constructorArgs.object = saveobj(getInterface(jobj));
end

settable.Type            = 'icdevice';
settable.ConstructorArgs = constructorArgs;
settable.CreationTime    = getCreationTime(jobj);

% Get the group properties.
groups = jobj.getPropertyGroups;

% The parent group is the base icdevice object and has already been saved.
groups.removeElement('parent');

% Save the group properties.
for j = 0:groups.size-1
    groupname = groups.elementAt(j);
    jgroup = jobj.getJGroup(groupname);
    for i = 1:length(jgroup)
        % Call handle so that the default HG props don't show up in the list.
        allProps = get(handle(jgroup(i)));
        propNames = fieldnames(allProps);
        
        % Find the non-settable properties.
        nonSettableProps = com.mathworks.toolbox.testmeas.device.util.PropertyUtil.getNonSettable(jgroup(i));
        nonSettableProps(cellfun('isempty', nonSettableProps)) = [];

        childProps = rmfield(allProps, nonSettableProps);

        settable.(groupname)(i) = childProps;
    end
end

% ****************************************************************************
% Save the settable properties for a group object.
function settable = localFindSettablePropertiesGroup(currentObj)

% Get the parent.
jparent = currentObj.getJParent;

% Determine the property values.
allProps = get(handle(jparent));
propNames = fieldnames(allProps);

% Find the non-settable properties.
nonSettableProps = com.mathworks.toolbox.testmeas.device.util.PropertyUtil.getNonSettable(jparent);
nonSettableProps(cellfun('isempty', nonSettableProps)) = [];

% Remove the non-settable properties from property structure.
nonSettableProps(find(strcmp('Type', nonSettableProps))) = [];
settable = rmfield(allProps, nonSettableProps);

% Save the driver name and the type of driver.
tempConstructorArgs    = getConstructorArgs(jparent);
constructorArgs.driver = char(tempConstructorArgs(1));
constructorArgs.type   = jparent.getDriverTypeDisplayName;

% If a MATLAB interface driver is being used, save the interface object.
if strcmp(jparent.getDriverTypeDisplayName, 'MATLAB interface driver')
    constructorArgs.object = saveobj(getInterface(jparent));
end

settable.Type            = 'icgroup';
settable.ConstructorArgs = constructorArgs;
settable.CreationTime    = getCreationTime(jparent);
settable.SavedIndex      = currentObj.getHwIndex;
settable.SavedType       = char(getChildTypeName(currentObj));

% Get the group properties.
groups = jparent.getPropertyGroups;

% The parent group is the base icdevice object and has already been saved.
groups.removeElement('parent');

% Save the group properties.
for j = 0:groups.size-1
    groupname = groups.elementAt(j);
    jgroup = jparent.getJGroup(groupname);
    for i = 1:length(jgroup)
        % Call handle so that the default HG props don't show up in the list.
        allProps = get(handle(jgroup(i)));
        propNames = fieldnames(allProps);
        
        % Find the non-settable properties.
        nonSettableProps = com.mathworks.toolbox.testmeas.device.util.PropertyUtil.getNonSettable(jgroup(i));
        nonSettableProps(cellfun('isempty', nonSettableProps)) = [];

        childProps = rmfield(allProps, nonSettableProps);

        settable.(groupname)(i) = childProps;
    end
end

% ****************************************************************************
% Parse the UserData and the Fcn properties to determine if the value
% contains an instrument object.
function propInfo = localParseUserDataAndFcnProps(currentObj, propInfo)

% Initialize variables.
index = length(propInfo);
allProps = propInfo(index).props;

% Find the parseable properties - Fcn properties and UserData.
parseProps = localFindParseProps(allProps);

% Loop through each property and determine if the property value contains
% an instrument object.
for i = 1:length(parseProps)
    propValue = allProps.(parseProps{i});
    
    className = class(propValue);
    if isa(propValue, 'icgroup')
        className = 'icgroup';
    end
    
    switch className
    case {'serial', 'gpib', 'visa', 'udp', 'tcpip', 'icdevice', 'icgroup'}
    	currentObj = igetfield(propValue, 'jobject');
        propInfo = localSaveArray(currentObj, propInfo, parseProps{i}, index, 1);
    case 'instrument'
        % An array of objects.
        currentArray = igetfield(propValue, 'jobject');
        for j = 1:length(currentArray)
	        propInfo = localSaveArray(currentArray(j), propInfo, parseProps{i}, index, j);        
        end
    case 'struct'
        % Loop through each field and determine if the field contains an instrument
        % object.
        propInfo = localSaveStruct(propInfo, parseProps{i}, index, propValue, {});
    case 'cell'
        % Loop through each element of the cell array and determine if the cell
        % array element contains an instrument object.
        propInfo = localSaveCell(propInfo, parseProps{i}, index, propValue, {});
	case 'char'
	case 'double'
    case 'function_handle'
	otherwise
		propInfo = localSaveObject(propValue, propInfo, parseProps{i}, index, {});
    end
end

% ****************************************************************************
% Save other objects.
function propInfo = localSaveObject(currentObj, propInfo, prop, objectIndex, index)

propInfo(end+1).jobject = [];
try
    propInfo(end).props = saveobj(currentObj);
catch
    propInfo(end).props = currentObj;
end
savedIndex              = length(propInfo);

% Remove the instrument object and add to the location cell.
propInfo = localAddArrayLocation(propInfo, savedIndex, prop, objectIndex, index);

% ****************************************************************************
% Save an array of objects.
function propInfo = localSaveArray(currentObj, propInfo, prop, objectIndex, index)

% Determine if the object has already been saved.
if findstr(class(currentObj), 'ICGroup')
    parentObj = get(currentObj(1), 'Parent');
    parentObj = igetfield(parentObj, 'jobject');
    
    % Determine if the parent object is saved.
    propInfo = localSaveArray(parentObj, propInfo, prop, objectIndex, index);
    
    % Store information about the group object that was saved.
    hwindex = get(currentObj, {'HwIndex'});
    
    location = propInfo.location{end};
    location.ObjectIndex = {location.ObjectIndex, 'input', hwindex};
    propInfo.location{end} = location;    
elseif localIsSaved(currentObj)
    % Object has been saved. Determine which object currentObj is equal to.
    savedIndex = localFindSavedObject(currentObj, propInfo);

    % Remove the instrument object and add to the location cell.
    propInfo = localAddArrayLocation(propInfo, savedIndex, prop, objectIndex, index);
    propInfo = localRemoveArrayElement(propInfo, index, objectIndex, prop);
elseif (isvalid(currentObj))
	% If the object is valid get it's property values.
    propInfo(end+1).jobject = currentObj;
    propInfo(end).props     = localFindSettableProperties(currentObj);
    savedIndex              = length(propInfo);
	
    % Indicate that the object has been saved.
	localIndicateSaved(currentObj);

    % Remove the instrument object and add to the location cell.
    propInfo = localAddArrayLocation(propInfo, savedIndex, prop, objectIndex, index);
    propInfo = localRemoveArrayElement(propInfo, index, objectIndex, prop);

    % Parse the object to determine if the UserData or the Fcn
    % properties contain any instrument objects.
    propInfo = localParseUserDataAndFcnProps(currentObj, propInfo);
else
    % Invalid object - save the class type. 
    propInfo(end+1).jobject = currentObj;        
    propInfo(end).props     = class(java(currentObj));
    savedIndex              = length(propInfo);
    
    % Indicate that the object has been saved.
	localIndicateSaved(currentObj);

    % Remove the instrument object and add to the location cell.
    propInfo = localAddArrayLocation(propInfo, savedIndex, prop, objectIndex, index);
    propInfo = localRemoveArrayElement(propInfo, index, objectIndex, prop);
end

% ****************************************************************************
% Save a structure which may or may not contain instrument objects.
function propInfo = localSaveStruct(propInfo, prop, objectIndex, propValue, index)

% Get the fields of the property Value.
names = fieldnames(propValue);

% Loop through each field value and determine if it is set to a cell, struct or
% an instrument object.
for j = 1:length(propValue)
    for i = 1:length(names)
		value = propValue(j).(names{i});
		if isstruct(value)
            index = localUpdateIndex('struct', index, {'()' j, '.', names{i}});
            propInfo = localSaveStruct(propInfo, prop, objectIndex, value, index);
            index = index(1:end-4);
        elseif iscell(value)
            index = localUpdateIndex('struct', index, {'()' j, '.', names{i}});
            propInfo = localSaveCell(propInfo, prop, objectIndex, value, index);
            index = index(1:end-4);
        elseif isa(value, 'instrument')
            % Done - found instrument object. 
            index = localUpdateIndex('struct', index, {'()' j, '.', names{i}});
            currentObj = igetfield(value, 'jobject');
            if length(currentObj) == 1
            	propInfo = localSaveArray(currentObj, propInfo, prop, objectIndex, index);
            else
                for k = 1:length(currentObj)
                    index(end+1:end+2) = {'()', k};
            		propInfo = localSaveArray(currentObj(k), propInfo, prop, objectIndex, index);
                    index = index(1:end-2);
                end
            end
            index = index(1:end-4);
		end
	end
end

% ****************************************************************************
% Save a structure which may or may not contain instrument objects.
function propInfo = localSaveCell(propInfo, prop, objectIndex, propValue, index)


% Loop through each cell and determine if it is set to a cell, struct or
% an instrument object.
for j = 1:numel(propValue)
    value = propValue{j};
	if isstruct(value)
        index = localUpdateIndex('cell', index, {'{}', j});
        propInfo = localSaveStruct(propInfo, prop, objectIndex, value, index);
        index = index(1:end-2);
    elseif iscell(value)
        index = localUpdateIndex('cell', index, {'{}', j});
        propInfo = localSaveCell(propInfo, prop, objectIndex, value, index);
        index = index(1:end-2);
    elseif isa(value, 'instrument')
        % Done - found instrument object. 
        index = localUpdateIndex('cell', index, {'{}', j});
        currentObj = igetfield(value, 'jobject');
        if length(currentObj) == 1
        	propInfo = localSaveArray(currentObj, propInfo, prop, objectIndex, index);
        else
           	for k = 1:length(currentObj)
          	 	index(end+1:end+2) = {'()', k};
            	propInfo = localSaveArray(currentObj(k), propInfo, prop, objectIndex, index);
                index = index(1:end-2);
            end
        end
        index = index(1:end-2);
    end
end

% ****************************************************************************
% Update indices.
function index = localUpdateIndex(type, index, value)

% Can't use END on any empty matrix.

switch (type)
case 'struct'
    if (isempty(index))
        index(1:4) = value;
    else
        index(end+1:end+4) = value;
    end
case 'cell'
    if (isempty(index))
        index(1:2) = value;
    else
        index(end+1:end+2) = value;
    end
end

% ****************************************************************************
% Add an array location.
function propInfo = localAddArrayLocation(propInfo, savedIndex, prop, objectIndex, arrayIndex)

%  Ex. y(1).Temp = 4; y(2).Temp = s1; s.UserData = y;    
%      s1's location field contains:
%           x.ObjectIndex = 1;             % s is stored in x(1)
%           x.Property    = 'UserData';
%           x.Index       = {'()', 2, '.', 'Temp', '()', 1};

% Get the current location field value.
allLocations = propInfo(savedIndex).location;

% Create the structure to be stored.
temp.ObjectIndex = objectIndex;
temp.Property = prop;
temp.Index = arrayIndex;    

% Add the structure to the propInfo array - Can't use END on an empty value.
count = length(allLocations) + 1;
allLocations{count} = temp; 
propInfo(savedIndex).location = allLocations;

% ****************************************************************************
% Remove the UDD object from propInfo.
function propInfo = localRemoveArrayElement(propInfo, index, objectIndex, propName)

propValue = propInfo(objectIndex).props.(propName);

if isnumeric(index) 
    % index points to an instrument object.
    propValue = '';
    propInfo(objectIndex).props.(propName) = propValue;
    return;
end

if length(index) >= 2 && (isnumeric(index{end}) && strcmp(index{end-1}, '()'))
    index = index(1:end-2);
end

% Build up the string to access the UDD object.
stringToAccessUDD = '';
for i = 1:2:length(index)
    currentDelimiter = index{i};
    switch (currentDelimiter)
    case '()'
        stringToAccessUDD = [stringToAccessUDD '(' num2str(index{i+1}) ')'];
    case '{}'
        stringToAccessUDD = [stringToAccessUDD '{' num2str(index{i+1}) '}'];
    case '.'
        stringToAccessUDD = [stringToAccessUDD '.' index{i+1}];
    end
end

% Set the UDD object to empty.
eval(['propValue' stringToAccessUDD ' = '''';']);

% Update the propInfo structure to contain property value minus UDD object.
propInfo(objectIndex).props.(propName) = propValue;

% ****************************************************************************
% Determine which properties need to be parsed including the Fcn properties
% and UserData.
function parseProps = localFindParseProps(allProps)

% Initialize variables.
count = 1;

% Get a list of all properties.
propNames = fieldnames(allProps);

% Find the properties which contain the string 'Fcn'.
for i = 1:length(propNames)
    if findstr('Fcn', propNames{i})
        parseProps{count} = propNames{i};
        count = count+1;
    end
end

% Add UserData.
parseProps{count} = 'UserData';


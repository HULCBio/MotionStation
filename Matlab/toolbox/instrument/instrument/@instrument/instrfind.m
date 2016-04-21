function output = instrfind(obj, varargin)
%INSTRFIND Find instrument or device group objects with specified property values.
%
%   OUT = INSTRFIND returns all instrument objects that exist in memory.
%   The instrument objects are returned as an array to OUT.
%
%   OUT = INSTRFIND('P1', V1, 'P2', V2,...) returns an array, OUT, of
%   instrument objects or device group objects whose property names and
%   property values match those passed as param-value pairs, P1, V1, P2,
%   V2,... The param-value pairs can be specified as a cell array. 
%
%   OUT = INSTRFIND(S) returns an array, OUT, of instrument objects or
%   device group objects whose property values match those defined in
%   structure S whose field names are object property names and the field
%   values are the requested property values.
%   
%   OUT = INSTRFIND(OBJ, 'P1', V1, 'P2', V2,...) restricts the search for 
%   matching param-value pairs to the objects listed in OBJ. OBJ can be an
%   array of instrument objects or an array of device group objects.
%
%   Note that it is permissible to use param-value string pairs, structures,
%   and param-value cell array pairs in the same call to INSTRFIND.
%
%   When a property value is specified, it must use the same format as
%   GET returns. For example, if GET returns the Name as 'MyObject',
%   INSTRFIND will not find an object with a Name property value of
%   'myobject'. However, properties which have an enumerated list data type
%   will not be case sensitive when searching for property values. For
%   example, INSTRFIND will find an object with a RecordDetail property value
%   of 'Verbose' or 'verbose'. The data type of a property can be determined 
%   with PROPINFO's Constraint field.
%
%   Example:
%       g1 = gpib('ni', 0, 1, 'Tag', 'Oscilloscope');
%       g2 = gpib('ni', 0, 2, 'Tag', 'FunctionGenerator');
%       out1 = instrfind('Type', 'gpib')
%       out2 = instrfind('Tag', 'Oscilloscope')
%       out3 = instrfind({'Type', 'Tag'}, {'gpib', 'FunctionGenerator'})
%
%   See also INSTRUMENT/PROPINFO, INSTRUMENT/GET, ICGROUP/PROPINFO,
%   ICGROUP/GET, INSTRFINDALL, INSTRHELP.
%

%   MP 7-13-99
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.11.2.7 $  $Date: 2004/01/16 20:01:00 $

% If in this function, then either OBJ is an instrument object or one of the property
% values specified is an instrument object.
if ~isa(obj, 'instrument')
    % Then one of the property values must be an instrument object.
    allObj = instrfind;
    pvpairs = {obj varargin{:}};
    obj = allObj;
    varargin = pvpairs;
end

% Error checking.
if ~isa(obj, 'instrument')    
    error('instrument:instrfind:invalidOBJ', 'OBJ must be an instrument object.');
end

% Error if invalid.
if ~all(isvalid(obj))
   error('instrument:instrfind:invalidOBJ', 'Instrument object OBJ is an invalid object.');
end

switch nargin
case 1
    output = obj;
    return;
otherwise
    % Get the java objects.
    jobject = igetfield(obj, 'jobject');
   
	% Determine if a structure property was specifeid.
    [allPropOut, allValOut, errflag] = createArrayOfAllProps(varargin{:});
	if (errflag)
        rethrow(lasterror);
	end

    % Find a unique list of properties.
    [allPropOut, i]    = sort(allPropOut);
    allValOut          = allValOut(i);
    [allPropOut, i, j] = unique(allPropOut);
    allValOut          = allValOut(i);
    
    [propToSearch, valToSearch, propsIndex] = findNonUDDProps(jobject, allPropOut, allValOut);
    
    if (length(propToSearch) == length(allPropOut))
        % No struct properties were specified.
		try
	        out = find(jobject, varargin{:});
		catch
            rethrow(lasterror);
		end
        
        % Search for icgroup objects.
        out2 = localICGroupFind(jobject, varargin{:});
        
        % If no instrument objects or icgroup objects were found return empty.
        if isempty(out) && isempty(out2)
            output = [];
            return;
        else
            % Convert the instrument objects and/or icgroup objects to output.
            output = javaToMATLAB(out, out2);
        end
    else
        % Search on the non-struct properties.
        if ~isempty(propToSearch)
	        out = find(jobject, propToSearch, valToSearch);
        else
            out = find(jobject);
        end

        % Search for icgroup objects.
        if ~isempty(propToSearch)
            out2 = localICGroupFind(jobject, propToSearch, valToSearch);
        else 
            out2 = find(jobject);
        end
        
        % Search objects for non-UDD props.
        if (isempty(out) && isempty(out2))
            output = [];
            return;
        else
            % Search instrument objects for non-UDD props. 
            out = checkNonUDDProps(out, propsIndex, allPropOut, allValOut);
            
            % Convert non-UDD props into pvpairs for searching.
            propsToCheck = localConvertToPVPairs(propsIndex, allPropOut, allValOut);
            
            % Determine if icgroup objects match the non-udd properties.
            if isempty(propToSearch)
                out2 = localICGroupFind(out2, propsToCheck{:});
            elseif ~isempty(out2) 
                out2 = instrfind(out2{:}, propsToCheck{:});
            end
            
            % Convert to MATLAB objects.
            output = javaToMATLAB(out, out2);
        end
    end
end

% ************************************************************************
% Create a cell of properties and property values that are being searched.
function [allProps, allValues, errflag] = createArrayOfAllProps(varargin)

% Create a cell array of properties that are being searched.
index = 1;
allProps = {};
allValues = {};
errflag = 0;

try
	while index <= nargin
		switch class(varargin{index})
		case 'char'
			% Concatenate properties.
			prop = varargin{index};
			allProps = {allProps{:} prop};
			
			% Concatenate values.
			value = varargin{index+1};
			allValues = {allValues{:} value}; 
			
			% Update index.
			index = index+2;        
		case 'cell'
			% Concatenate properties.
			prop = varargin{index};
			if (iscell([prop{:}]))
				errflag = 1;
				lasterr('Invalid param-value pairs specified.', 'instrument:instrfind:invalidPVPair');
				return;
			end
			allProps = {allProps{:} prop{:}};
			
			% Concatenate values.
			value = varargin{index+1};
			allValues = {allValues{:} value{:}};
			
			% Update index.
			index = index+2;        
		case 'struct'
			% Concatenate properties.
			propStruct = varargin{index};
			prop = fieldnames(propStruct);
			allProps = {allProps{:} prop{:}};
			
			% Concatenate values.  
			value = struct2cell(propStruct);
			allValues = {allValues{:} value{:}};
			
			% Update index.
			index = index+1;    
		otherwise
			errflag = 1;
			lasterr('Invalid param-value pairs specified.', 'instrument:instrfind:invalidPVPair');
			return;
		end
	end
catch	
	errflag = 1;
	lasterr('Invalid param-value pairs specified.', 'instrument:instrfind:invalidPVPair');
	return;
end	

% ************************************************************************
% Get the PV pairs minus the non-UDD properties.
function [propOut, valOut, propsIndex] = findNonUDDProps(jobject, props, vals)

% Determine the non-UDD properties.
nonUDDProps = lower(com.mathworks.toolbox.instrument.util.PropertyUtil.findStructProps);
nonUDDProps = {nonUDDProps{:} 'interface', 'input', 'output', 'parent', 'userdata'};

% Add the group properties to the list.
for i = 1:length(jobject)
    if ~isempty(findstr(class(jobject(i)), 'ICDevice'))
        gp = jobject(i).getPropertyGroups;
        for j = 0:gp.size-1
            nonUDDProps{end+1} = lower(char(gp.elementAt(j)));
        end
    end
end

nonUDDProps = unique(nonUDDProps);

% Determine if a non-UDD property was specified.
propOut = props;
valOut = vals;
propsIndex = [];
count = 1;

for i = 1:length(nonUDDProps)
    allIndex = strmatch(nonUDDProps{i}, lower(props), 'exact');
    index = strmatch(nonUDDProps{i}, lower(propOut), 'exact');
    if ~isempty(index)
        % Remove the non-UDD property and value.
        propOut(index) = [];
        valOut(index)  = [];
        
        % Store the index of the non-UDD property.
        propsIndex(count) = allIndex;
        count = count+1;
    end
end

% ************************************************************************
% Search objects for non-UDD properties.
function out = checkNonUDDProps(obj, propsIndex, props, vals)

out = [];
for i = 1:length(propsIndex)
    % Get the non-UDD property and value.
    propName = props{propsIndex(i)};
    propValue = vals{propsIndex(i)};
    
    % Find the max to search through.
    if isempty(out)
        if i == 1
	       index = length(obj);
       else
           out = [];
           return;
       end
    else
        index = length(out);
    end

    out = [];
    % Loop through objects and determine if a match exists.
    for k = 1:index
        try
            if isequal(get(obj(k), propName), propValue)
                out = [out obj(k)];
            end
        catch
            % An error occurred during the GET - the property
            % is invalid for that object type.
        end
    end
end

% ------------------------------------------------------------------------
% If a device object exists, determine if the properties match it's input
% and output properties.
function out = localICGroupFind(jobject, varargin)

out = {};

for i = 1:length(jobject)
    % Reset found objects.
    foundOutput = {};
    foundInput  = {};
    
    try
        % Check group properties.
        groups = jobject(i).getPropertyGroups;
        for j = 0:groups.size-1
            groupName = groups.elementAt(j);
            foundGroup = instrfind(eval(['jobject(i).get' groupName]), varargin{:});
            if isempty(foundGroup)
                % Convert [] to {}. Otherwise have {[]}.
                foundGroup = {};    
            elseif (length(foundGroup) == 1) && (isempty(foundGroup(1)))
                foundGroup = {};
            else
                foundGroup = {foundGroup};
            end
                
            % Add to output.
            out = {out{:} foundGroup{:}};
        end
	catch 
        % Object is not a device object.
	end
end

% ---------------------------------------------------------------------------
% Convert the index into all properties into a cell array of property
% value pairs.
function out = localConvertToPVPairs(propsIndex, allPropOut, allValOut)

count = 1;
out = cell(1, length(propsIndex)*2);

for i = 1:length(propsIndex)
    out{count}   = allPropOut{propsIndex(i)};
    out{count+1} = allValOut{propsIndex(i)};
    count=count+2;
end

% ------------------------------------------------------------------------
% Convert objects to their appropriate MATLAB object type.
function obj = javaToMATLAB(allObjects, allChildObjects)

obj = [];

% Convert instrument objects.
for i = 1:length(allObjects)
    if (strcmp(class(allObjects(i)), 'handle.Database'))
    	% Do nothing. 
    elseif strcmp(class(allObjects(i)), 'javahandle.com.mathworks.toolbox.instrument.SerialComm')
        obj = [obj serial(allObjects(i))];
    elseif strcmp(class(allObjects(i)), 'javahandle.com.mathworks.toolbox.instrument.SerialVisa')
        obj = [obj visa(allObjects(i))];
    elseif strcmp(class(allObjects(i)), 'javahandle.com.mathworks.toolbox.instrument.GpibVisa')
        obj = [obj visa(allObjects(i))];
    elseif strcmp(class(allObjects(i)), 'javahandle.com.mathworks.toolbox.instrument.VxiGpibVisa')
    	obj = [obj visa(allObjects(i))];
    elseif strcmp(class(allObjects(i)), 'javahandle.com.mathworks.toolbox.instrument.VxiVisa')
   		obj = [obj visa(allObjects(i))];
    elseif strcmp(class(allObjects(i)), 'javahandle.com.mathworks.toolbox.instrument.TCPIP')
		obj = [obj tcpip(allObjects(i))];
    elseif strcmp(class(allObjects(i)), 'javahandle.com.mathworks.toolbox.instrument.UDP')
		obj = [obj udp(allObjects(i))];
    elseif strcmp(class(allObjects(i)), 'javahandle.com.mathworks.toolbox.instrument.RsibVisa')
		obj = [obj visa(allObjects(i))];
    elseif strcmp(class(allObjects(i)), 'javahandle.com.mathworks.toolbox.instrument.TcpipVisa')
		obj = [obj visa(allObjects(i))];
    elseif strcmp(class(allObjects(i)), 'javahandle.com.mathworks.toolbox.instrument.UsbVisa')
		obj = [obj visa(allObjects(i))];        
    elseif findstr(class(allObjects(i)), 'ICDevice')
		obj = [obj icdevice(allObjects(i))];
    else
        obj= [obj gpib(allObjects(i))];
    end
end

% If icgroup objects were found, add them to the output list.
if isempty(obj)
    obj = allChildObjects;
elseif ~isempty(allChildObjects)
    obj = {obj allChildObjects{:}}';    
end

% If there is only one object, don't return it as a cell.
if iscell(obj) && length(obj) == 1
    obj = obj{:};
end

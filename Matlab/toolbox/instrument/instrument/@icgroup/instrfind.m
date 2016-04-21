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
%   $Revision: 1.1.6.3 $  $Date: 2004/01/16 19:59:56 $

% If in this function, then either OBJ is an icgroup object or one of the property
% values specified is an icgroup object.
if ~isa(obj, 'icgroup')
    % Then one of the property values must be an icgroup object.
    allObj = instrfind;
    pvpairs = {obj varargin{:}};
    output = instrfind(allObj, pvpairs{:});
    return;
end

% Error checking.
if ~isa(obj, 'icgroup')
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
   
	% Determine if an non-udd property was specifeid.
    [allPropOut, allValOut, errflag] = createArrayOfAllProps(varargin{:});
	if (errflag)
        rethrow(lasterror);
	end

    % Find a unique list of properties.
    [allPropOut, i]    = sort(allPropOut);
    allValOut          = allValOut(i);
    [allPropOut, i]    = unique(allPropOut);
    allValOut          = allValOut(i);
    
    [propToSearch, valToSearch, propsIndex] = findNonUDDProps(allPropOut, allValOut);
    
    if (length(propToSearch) == length(allPropOut))
        % No non-udd properties were specified.
		try
	        out = find(jobject, varargin{:});
		catch
            rethrow(lasterror);
		end
        if isempty(out)
            output = [];
            return;
        else
            output = javaToMATLAB(out);
        end
    else
        % Search on the udd properties.
        if ~isempty(propToSearch)
	        out = find(jobject, propToSearch, valToSearch);
        else
            out = find(jobject);
        end
        
        % Search objects for non-udd props.
        if (isempty(out))
            output = [];
            return;
        else
            % Search MATLAB objects for non-udd props. 
            out = checkNonUDDProps(out, propsIndex, allPropOut, allValOut);
  
            % Convert to MATLAB objects.
            output = javaToMATLAB(out);
        end
    end
end

% ------------------------------------------------------------------------
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

% ------------------------------------------------------------------------
% Get the PV pairs minus the non-UDD properties.
function [propOut, valOut, propsIndex] = findNonUDDProps(props, vals)

% Determine the non-UDD properties.
structProps = {'parent'};

% Determine if a non-UDD property was specified.
propOut = props;
valOut = vals;
propsIndex = [];
count = 1;

for i = 1:length(structProps)
    allIndex = strmatch(structProps{i}, lower(props), 'exact');
    index = strmatch(structProps{i}, lower(propOut), 'exact');
    if ~isempty(index)
        % Remove the non-UDD property and value.
        propOut(index) = [];
        valOut(index)  = [];
        
        % Store the index of the non-UDD property.
        propsIndex(count) = allIndex;
        count = count+1;
    end
end

% ------------------------------------------------------------------------
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
% Convert objects to their appropriate MATLAB object type.
function out = javaToMATLAB(allObjects)

out = {};
obj = {};
    
for i = 1:length(allObjects)
    obj = {obj{:} icgroup(allObjects(i))};
end

% If no objects were found. Return.
if isempty(obj)
    return;
end

% Loop through and concatenate those device group objects that have the 
% same parent and same type.
out = {obj{1}};
for i = 2:length(obj)
    % obj1 is always 1-by-1.
    obj1 = obj{i};
    for j= 1:length(out)
        % obj2 could be an array of objects. Extract only first parent.
        obj2 = out{j};
        parent2 = get(obj2, {'Parent'});
        parent2 = parent2{1};
        type2 = get(obj2, {'Type'});
        type2 = type2{1};

        % If equal concatentate.
        if isequal(get(obj1, 'Parent'), parent2) && strcmp(get(obj1, 'Type'), type2)
            out{j} = [obj2 obj1];
        end
    end
end

% Return a column vector.
out = out';

if length(out) == 1
    out = out{:};
end


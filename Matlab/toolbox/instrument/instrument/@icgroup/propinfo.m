function out=propinfo(obj, prop)
%PROPINFO Return instrument or device group object property information.
%
%   OUT = PROPINFO(OBJ) returns a structure array, OUT, with field 
%   names given by the property names for OBJ. Each property name 
%   in OUT contains a structure with the fields:
%
%     Type              - the property data type: 
%                         {'callback', 'double', 'string', 'ASCII Value',
%                         'Instrument Value', 'struct', 'any'}
%     Constraint        - constraints on property values:
%                         {'callback', 'bounded', 'enum', 'ASCII Value', 
%                          'Instrument Value', 'none'}
%     ConstraintValue   - a list of valid string values or a range of
%                         valid values.
%     DefaultValue      - the default value for the property.
%     ReadOnly          - the condition under which a property is read-only:
%                         'always'         - property cannot be configured.
%                         'whileOpen'      - property cannot be configured 
%                                            after object has been connected
%                                            to the instrument.
%                         'whileRecording' - property cannot be configured
%                                            while RecordStatus property is on.
%                         'never'          - property can always be configured.
%     InterfaceSpecific - 1 if the property is interface specific, 
%                         0 if the property is not interface specific.
%
%   OBJ must be a 1-by-1 instrument object or device group object.
%
%   If Type is Instrument Value, then the property can be set to either
%   a string or a double. If either the string or the double values are
%   constrained, the Constraint field will be updated accordingly and the
%   acceptable values will be returned in the ConstraintValue field. If
%   both the string and double values are constrained, Constraint will
%   be Instrument Value and the ConstraintValue field will return the 
%   string and double values that the property can be set to.
%
%   OUT = PROPINFO(OBJ, 'PROPERTY') returns a structure, OUT, for the 
%   property specified by PROPERTY. If PROPERTY is a cell array of strings,
%   a cell array of structures is returned for each property.
%
%   Example:
%       g = visa('ni', 'GPIB0::2::INSTR');
%       out = propinfo(g);
%       out1 = propinfo(g, 'EOSMode');
%
%   See also INSTRHELP.
%

%   MP 7-13-99
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.5 $  $Date: 2004/03/05 18:10:14 $

% Error checking.
if ~isa(obj, 'icgroup')
    error('icgroup:propinfo:invalidOBJ', 'OBJ must be a device group object.');
end
 
if (length(obj) > 1)
   error('icgroup:propinfo:invalidOBJ', 'OBJ must be a 1-by-1 device group object.');
end

% Initialize variables.
fields = {'Type','Constraint', 'ConstraintValue','DefaultValue',...
          'ReadOnly', 'InterfaceSpecific'};
isString = 0;  

switch nargin
case 1
    % Ex. out = propinfo(obj)
    % Call the java method.
    try
	    tempOut = propinfo(igetfield(obj, 'jobject'));
    catch
        error('icgroup:propinfo:opfailed', lasterr);
    end
	
    % Create the first structure.
    propCell = tempOut(1);
    
    % First cell contains the property name.
	propName = char(propCell(1));
    
    % Convert remaining cells to a structure.
	propStruct = cell2struct(cell(propCell(2:end))', fields, 2);
    propStruct = localCleanUpPropStruct(propStruct);
    
    % Create the output structure.
	out = struct(propName, propStruct);

    % Loop through the remaining java Objects and convert to a struct.
	for i = 2:length(tempOut)
       % Create the property structure.       
 	   propCell = tempOut(i);
	   propName = char(propCell(1));
	   propStruct = cell2struct(cell(propCell(2:end))', fields, 2);
       propStruct = localCleanUpPropStruct(propStruct);

       % Append the new structure to the existing out structure.
       out.(propName) = propStruct;
   end

case 2
    % Ex. out = propinfo(obj, 'Status');
    % Ex. out = propinfo(obj, {'Status', 'RecordName'});
   
    % Return if user did not specify any properties.
    if isempty(prop)
        return;
    end
    
    if ~(ischar(prop) || iscellstr(prop))
        error('icgroup:propinfo:invalidPROPERTY', 'PROPERTY must be a string or a cell array of strings.');
    end
     
    % Convert the property to a cell if a string.
    if ischar(prop)
        isString = 1;
        prop = {prop};
    end
    
    % Reshape to make it a 1-by-n cell of property names.
    prop = reshape(prop, 1, numel(prop));
    
    try
	    output = propinfo(igetfield(obj, 'jobject'), prop);
    catch
        error('icgroup:propinfo:opfailed', lasterr);
    end
    
    % Loop through each cell and convert to a structure.
    for i = 1:length(prop)
    	% Convert java Object to a structure.
        output = cell(output);
		out{i} = cell2struct(cell(output{i})', fields, 2);
        out{i} = localCleanUpPropStruct(out{i});
   end
    
    % Convert cell back to a structure.
    if isString
        out = out{1};
    end
end

% **********************************************************
% Clean up the property structure.
function propStruct = localCleanUpPropStruct(propStruct)
    
% Convert a cell of doubles to an array of doubles.
if (strcmp(propStruct.Constraint, 'bounded'))
    propStruct = cleanupBoundedInfo(propStruct);
end

% Convert Instrument Value to a cell.
if (strcmp(propStruct.Constraint, 'Instrument Value'))
    temp  = propStruct.ConstraintValue;
    range = cell(temp(1));
    tempArray{1} = [range{:}];
    for i=2:length(temp)
        tempArray{i} = temp(i);
    end
    propStruct.ConstraintValue = tempArray;
end

% Convert a cell of doubles to an array of doubles.
if strcmp(propStruct.Constraint, 'enum') 
    propStruct.ConstraintValue = cell(propStruct.ConstraintValue);
end

% Convert java objects to struct.
if isa(propStruct.DefaultValue, 'com.mathworks.jmi.types.MLArrayRef')
    propStruct.DefaultValue = propStruct.DefaultValue(1);
elseif isjava(propStruct.DefaultValue)
	propStruct.DefaultValue = struct(propStruct.DefaultValue);
end

% --------------------------------------------------------------
function propStruct = cleanupBoundedInfo(propStruct)

if (isempty(propStruct.ConstraintValue))
    propStruct.Constraint = 'none';
    return;
end

if isa(propStruct.ConstraintValue, 'java.lang.Double[]')
    temp = cell(propStruct.ConstraintValue);
    propStruct.ConstraintValue = [temp{:}];
    return;
end

if length(propStruct.ConstraintValue) == 1
    temp = cell(propStruct.ConstraintValue(1));
    propStruct.ConstraintValue = [temp{:}];
    return;
end

% Ex. propinfo(g, 'CompareBits');
if isa(propStruct.ConstraintValue(1), 'double')
    temp = cell(propStruct.ConstraintValue);
    propStruct.ConstraintValue = [temp{:}];
    return;
end        
 
% Ex. Two double bounded constraints.
out = cell(length(propStruct.ConstraintValue), 1);
for i=1:length(out)
    temp = cell(propStruct.ConstraintValue(i));
    out{i} = [temp{:}];
end
propStruct.ConstraintValue = out;





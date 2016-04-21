function out = set(obj, varargin)
%SET Configure or display IVI Configuration Store object properties.
%
%   IVI Configuration Store object property values cannot be configured
%   with the SET command. The following IVI Configuration Store object
%   properties are configurable with the ADD, COMMIT and REMOVE functions:
%
%       1. DriverSessions
%       2. HardwareAssets
%       3. LogicalNames
%
%   All other IVI Configuration Store object properties are read-only
%   and cannot be modified.
%  
%   See also IVICONFIGURATIONSTORE/ADD, IVICONFIGURATIONSTORE/COMMIT,
%   IVICONFIGURATIONSTORE/GET, IVICONFIGURATIONSTORE/REMOVE.
%

%   MP 7-13-99
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/01/16 20:01:22 $

% Initialize error messages.
error1 = 'Attempt to modify read-only IVI Configuration Store property: ';
error2 = ['can be modified with the ADD, REMOVE or UPDATE functions.' sprintf('\n'),...
    'Type help iviconfigurationstore\\set for more information.'];
error3 = ['All IVI Configuration Store properties are read-only. ' sprintf('\n'),...
    'Type help iviconfiguration\\set for more information.'];
msgid  = 'iviconfigurationstore:set:invalidSet';

% Call builtin set if OBJ isn't an iviconfigurationstore object.
% Ex. set(s, 'UserData', s);
if ~isa(obj, 'iviconfigurationstore')
    try
	    builtin('set', obj, varargin{:});
    catch
        rethrow(lasterror);
    end
    return;
end

% Ex. set(obj)
% Ex. out = set(obj);
if nargin == 1 
    if nargout == 1
        out = [];    
    end
    return;
end

% Ex. set(obj, 'Name')
if (nargin == 2)
    % Ex. set(obj, 'Name')
    prop = varargin{1};             

    % Handle case when property is a string.
    if ischar(prop)       
        % Get the complete name for the property.
        [prop, errflag] = localGetPropertyCompleteName(prop);
        if (errflag)
            rethrow(lasterror);
        end

        % Error appropriately.
        if (localIsStructPropertyName(prop))
            error(msgid, [error1 prop '.' sprintf('\n'), prop ' ' error2]);
        else
            error(msgid, [error1 prop '.']);
        end
    end

    % Handle case when it is a struct.
    if isstruct(prop)
        error(msgid, error3);
    else
        error(msgid, 'Invalid parameter/value pair arguments.');
    end           
else
    % Extract the properties specified.
    [allProps, errflag] = createArrayOfAllProps(varargin{:});
    if (errflag == true)
        rethrow(lasterror);
    end

    % Get the property complete version.
    [allProps, errflag] = localGetPropertyCompleteNames(allProps);
    if (errflag == true)
        rethrow(lasterror);
    end

    % Error appropriately.
    prop = allProps{1};
    if (localIsStructPropertyName(prop))
        error(msgid, ['Changing the ''' allProps{1} ''' property of IVI Configuration ',...
            'Store objects is not allowed.' sprintf('\n'), prop ' ' error2]);
    else
        error(msgid, ['Changing the ''' allProps{1} ''' property of IVI Configuration Store objects is not allowed.']);
    end        
end

% ---------------------------------------------------------
% Create a cell of properties that are being configured.
function [allProps, errflag] = createArrayOfAllProps(varargin)

% Create a cell array of properties that are being configured.
index    = 1;
allProps = {};
errflag  = false;

try
	while index <= nargin
		switch class(varargin{index})
		case 'char'
			% Concatenate properties.
			prop = varargin{index};
			allProps = {allProps{:} prop};			
		
			% Update index.
			index = index+2;        
		case 'cell'
			% Concatenate properties.
			prop = varargin{index};
			if (iscell([prop{:}]))
				errflag = true;
				lasterr('Invalid param-value pairs specified.', 'instrument:instrfind:invalidPVPair');
				return;
			end
			allProps = {allProps{:} prop{:}};			
		
			% Update index.
			index = index+2;        
		case 'struct'
			% Concatenate properties.
			propStruct = varargin{index};
			prop = fieldnames(propStruct);
			allProps = {allProps{:} prop{:}};			
	
			% Update index.
			index = index+1;    
		otherwise
			errflag = true;
			lasterr('Invalid param-value pairs specified.', 'instrument:instrfind:invalidPVPair');
			return;
		end
	end
catch	
	errflag = true;
	lasterr('Invalid param-value pairs specified.', 'instrument:instrfind:invalidPVPair');
	return;
end	

% ---------------------------------------------------------
% Return a list of properties supported by the IVI Configuration
% Store object.
function out = localGetPropertyNames

out = {'ActualLocation', 'DriverSessions', 'HardwareAssets', 'LogicalNames',...
    'MasterLocation', 'Name', 'ProcessLocation', 'PublishedAPIs', 'Revision',...
    'ServerDescription', 'Sessions', 'SoftwareModules', 'SpecificationVersion',...
    'Vendor'};

% ---------------------------------------------------------
% Determine if the property is a structure property and therefore
% needs additional processing.
function out = localIsStructPropertyName(name)

out = any(strcmp(name, {'DriverSessions', 'HardwareAssets', 'LogicalNames', ...
    'PublishedAPIs', 'Sessions', 'SoftwareModules'}));

% ---------------------------------------------------------
function [out, errflag] = localGetPropertyCompleteNames(names)

% Initialize variables.
out = cell(1, length(names));
errflag = false;

% Loop through each name and extract the complete name.
for i = 1:length(names)
    [compName, errflag] = localGetPropertyCompleteName(names{i});
    
    % The name does not exist. Error.
    if errflag == true
        return;
    end
    out{i} = compName;
end    

% ---------------------------------------------------------
% Find the property complete name.
function [out, errflag] = localGetPropertyCompleteName(name)

% Initialize variables.
out = '';
errflag = false;

% Get the supported properties.
allPropertyNames = localGetPropertyNames;

% Find the properties that name could be.
index = strmatch(lower(name), lower(allPropertyNames));

% If more than one was found, error.
if length(index) >= 2
    errflag = true;
    lasterr(['The ''' name ''' property name is ambiguous for IVI Configuration Store objects.'], 'iviconfigurationstore:set:invalidProp');
    return;
end

% If none were found, error.
if isempty(index)
    errflag = true;
    lasterr(['There is no ''' name ''' property for IVI Configuration Store objects.'], 'iviconfigurationstore:set:invalidProp');
    return;
end
   
% Return the case sensitive name.
out = allPropertyNames{index};

function varargout = instrhelp(obj, varargin)
%INSTRHELP Return instrument object function and property help.
%
%   INSTRHELP provides a complete listing of instrument object functions. 
%
%   INSTRHELP('NAME') provides on-line help for the function or property,
%   NAME. If NAME is the class name of an instrument object or device group
%   object, for example, visa, a complete listing of functions and properties
%   for the object class is displayed. The on-line help for the object's 
%   constructor is also displayed. If NAME is the class name of an instrument
%   object with a .m extension, the on-line help for the object's constructor 
%   is displayed.
%
%   Object specific function information can be displayed by specifying
%   NAME to be object/function. For example to display the on-line
%   help for a serial port object's FPRINTF function, NAME would be
%   serial/fprintf.
%
%   Object specific property information can be displayed by specifying
%   NAME to be object.property. For example to display the on-line help
%   for a serial port object's Parity property, NAME would be serial.Parity.
%
%   OUT = INSTRHELP('NAME') returns the help text in string, OUT.
%
%   INSTRHELP(OBJ) displays a complete listing of functions and properties
%   for the object, OBJ, along with the on-line help for the object's 
%   constructor. OBJ must be a 1-by-1 instrument object or a device
%   group object.
%
%   INSTRHELP(OBJ, 'NAME') displays the help for function or property, NAME,
%   for the object, OBJ.
%
%   OUT = INSTRHELP(OBJ, 'NAME') returns the help text in string, OUT.
%
%   Note, if NAME is a device object function or property or a device group
%   object function or property, the object, OBJ, must be specified.
%   
%   When displaying property help, the names in the See also section which
%   contain all upper case letters are function names. The names which
%   contain a mixture of upper and lower case letters are property names.
%
%   When displaying function help, the See also section contains only 
%   function names.
%
%   Example:
%       instrhelp('serial')
%       out = instrhelp('serial.m');
%       instrhelp set
%       instrhelp RecordMode     
%
%       g = gpib('ni', 0, 2);
%       instrhelp(g)
%       instrhelp(g, 'EOSMode');
%       out = instrhelp(g, 'propinfo');
% 
%   See also INSTRUMENT/PROPINFO, ICGROUP/PROPINFO.
%

%   MP 7-13-99
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.5 $  $Date: 2004/03/05 18:10:13 $

% Error checking.
if nargin > 2
    error('icgroup:instrhelp:invalidSyntax', 'Too many input arguments.');
end

if nargout > 1
	error('icgroup:instrhelp:invalidSyntax', 'Too many output arguments.')
end

if ~isa(obj, 'icgroup')
	error('icgroup:instrhelp:invalidArg', 'The first input argument must be a device group object.');
end

if ~any(isvalid(obj))
    error('icgroup:instrhelp:invalidOBJ', 'Device group object OBJ is an invalid object.')
end


% Determine if a function or property name was specified.
name = '';
if (nargin == 2)
    name = varargin{1};
end

% Error checking.
if ~ischar(name)
    error('icgroup:instrhelp:invalidArg', 'The second input argument must be a string.');
end

% Find the directory where the toolbox is installed.
instrRoot = which('instrgate', '-all');
instrRoot = fileparts(instrRoot{1});

% Return results based on arguments passed in.
switch nargin
case 1
    out = localDisplayDriverInfo(obj);
    
	% Create output - either to command line or to output variable.
	switch nargout
	case 0
		out1 = evalc('help([instrRoot filesep ''icgroup'' filesep ''Contents.m''])');
        out2 = evalc('help([instrRoot filesep ''icgroup'' filesep ''icgroup''])'); 
        disp([out1 out2]);
        for i=1:length(out),
            fprintf(out{i})
        end
	case 1
		varargout{1} = [help([instrRoot filesep 'icgroup' filesep 'Contents.m']) help([instrRoot filesep 'icgroup' filesep 'icgroup']) out{:}];
	end
	return;
case 2
    % Initialize variables.
    errflag  = false;
    
    % Check to see if name is a function.
    pathName = localFindPath(name, instrRoot);
    
    if ~isempty(pathName)
        % Path existed. It was a function.
        switch nargout
        case 0
            out = evalc('help(pathName)');
        case 1
            out = help(pathName);
        end
    elseif any(strcmpi(name, {'clear', 'load', 'save'}))
        out = sprintf(instrgate('privateGetHelp', name));
    else
       	% Check to see if name is a property.      
        [errflag, out] = localGetPropDesc(name, obj);
    end
    
    % If not a property or a function, error.
    if errflag
        if (~isempty(strmatch(name, methods(obj))))
            out = sprintf([' ' upper(name) '\n\n   ' upper(name) ' is an inherited MATLAB class method. It is not a valid\n   method for device group objects.\n']);
            switch nargout
                case 0
                    fprintf('\n');
                    disp(out)
                case 1
                    varargout{1} = out;
            end
        else
            switch nargin
                case 1
                    error('icgroup:instrhelp:invalidNAME', ['Invalid instrument control function or property: ''' varargin{1} '''.']);
                case 2
                    error('icgroup:instrhelp:invalidNAME', ['Invalid instrument control function or property: ''' class(obj) '.' name '''.']);
            end
        end
    else
		% Create output - either to command line or to output variable.
		switch nargout
		case 0
            fprintf('\n');
			disp(out)
		case 1
			varargout{1} = out;
		end   
	end
end

% ----------------------------------------------------------------
% Find the pathname when the object directory and method are given.
function [errflag, out] = localGetPropDesc(prop, obj)

% Initialize output.
errflag = false;
out     = '';

try
    jobj = igetfield(obj, 'jobject');
    out = com.mathworks.toolbox.testmeas.device.util.PropertyHelp.getHelp(java(jobj(1)), prop);
catch
    errflag = true;
end

% ----------------------------------------------------------------
% For icdevice object's show the driver specific methods and properties.
function out = localDisplayDriverInfo(obj)

% If a device object return device specific methods and properties.
% Get the methods provided by the icdevice group object's driver.
jobj = igetfield(obj, 'jobject');
jobj = jobj(1);
className = char(mclass(jobj));

driverMethodNames = getMethodNames(jobj);
if isempty(driverMethodNames)
    driverMethodNames = {};
    maxMethodLength   = 0;
    out1 = {['  There are no driver specific methods for class ' className '.' sprintf('\n')]};
else
    driverMethodNames = cell(driverMethodNames);
    maxMethodLength   = max(cellfun('length', driverMethodNames));
end

% Get the properties provided by the icdevice group object's driver.
propertyNames       = getProperties(jobj);
if isempty(propertyNames)
    driverPropertyNames = {};
    maxPropertyLength = 0;
    out2 = {['  There are no driver specific properties for class ' className '.' sprintf('\n')]};
else
    driverPropertyNames = cell(propertyNames.size, 1);
    for i=1:length(driverPropertyNames)
        driverPropertyNames{i} = propertyNames.elementAt(i-1);
    end
    maxPropertyLength = max(cellfun('length', driverPropertyNames));
end

% Calculate the maximum length which will be used for spacing.
maxLength = max(maxMethodLength, maxPropertyLength);

% Print out the method names and property names.
if ~isempty(driverMethodNames)
    out1 = localPrettyPrint(driverMethodNames, maxLength, ['  Driver specific methods for class ' className ':']);
end

if ~isempty(driverPropertyNames)
    out2 = localPrettyPrint(driverPropertyNames, maxLength, ['\n  Driver specific properties for class ' className ':']);
end

% Construct output.
out = {out1{:} out2{:} sprintf('\n')};

% ----------------------------------------------------------------
% Pretty print the methods.
function out = localPrettyPrint(names, maxLength, heading)

% Calculate spacing information.
maxColumns = floor(80/maxLength);
maxSpacing = 2;
numOfRows = ceil(length(names)/maxColumns);

% Reshape the methods into a numOfRows-by-maxColumns matrix.
numToPad = (maxColumns * numOfRows) - length(names);
for i = 1:numToPad
    names = {names{:} ' '};
end
names = reshape(names, numOfRows, maxColumns);

% Print out the methods.
out = {sprintf([heading '\n\n'])};

% Loop through the methods and print them out.
for i = 1:numOfRows
    out = {out{:} sprintf('  ')};
    for j = 1:maxColumns
        m = names{i,j};        
        out = {out{:} sprintf([m blanks(maxLength + maxSpacing - length(m))])};
    end
    out = {out{:} sprintf('\n')};
end

% ----------------------------------------------------------------
% Find the pathname when the object directory and method are given.
function pathname = localFindPath(name, instrRoot)

% Path is not empty.  The file can be in one of three locations.
% instrRoot
% instrRoot\@icgroup

% Initialize variables.
pathname = '';
allpaths = which(name, '-all');

% Case insensitive file/dir comparison for Windows 95/98.
if strcmp(computer,'PCWIN'),
	name = lower(name);
end

% Loop through and check if one of the paths begins with the
% Instrument Control Toolbox's root directory + specified path.
	
% Check instrRoot
index = strmatch([instrRoot filesep name], allpaths);
if ~isempty(index)
	pathname = allpaths{index};
	return;
end

% Check instrRoot\@icgroup
index = strmatch([instrRoot filesep '@icgroup'], allpaths);
if ~isempty(index)
	pathname = allpaths{index};
	return;
end

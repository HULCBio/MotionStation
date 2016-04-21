function varargout = instrhelp(varargin)
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
%   $Revision: 1.13.2.7 $  $Date: 2004/02/09 06:43:09 $

% Error checking.
if nargin == 2
    error('instrument:instrhelp:invalidSyntax', 'The first input must be an instrument object.');
end

if nargout > 1,
	error('instrument:instrhelp:invalidSyntax', 'Too many output arguments.')
end

% Find the directory where the toolbox is installed.
instrRoot = which('instrgate', '-all');
instrRoot = fileparts(instrRoot{1});

% Parse the input.
switch nargin
case 0
   	% Return Contents help.    
    switch nargout
    case 0
        disp(evalc('help([instrRoot filesep ''Contents.m''])'));
    case 1
        varargout{1} = help(instrRoot);
    end
	return;
case 1
    name = varargin{1};
end

% Error checking.
if ~ischar(name)
    error('instrument:instrhelp:invalidSyntax', 'The first input must be a string or an instrument object.');
end

% Get the information on the method or property that is being looked up.
isMethod   = true;
isProperty = false;
includeContents = false;

if ~isempty(findstr(name, '/'))
    % Ex. instrhelp('serial/fopen').
    [className, lookupName] = fileparts(name);    
elseif ~isempty(findstr(name, '.'))
    [nothing, className, lookupName] = fileparts(name);
        
    if strcmp(lookupName, '.m')
        % Ex. instrhelp('fopen.m')
        lookupName = className;
        className  = '';        
    else
        % Ex. instrhelp('serial.BaudRate')
        lookupName = lookupName(2:end);
        isMethod   = false;
        isProperty = true;
    end
else
    lookupName = name;    
    className = '';

    % Determine if lookupName is a directory, in which case the 
    % Contents information is also given.
    if any(strcmp(lookupName, {'serial', 'gpib', 'visa', 'tcpip', 'udp', 'icdevice', 'icgroup', 'iviconfigurationstore'}))
        includeContents = true;
    else
        % Could be one or the other.
        isMethod   = true;
        isProperty = true;
    end
end

% Get the method help.
errflag = false;
if isMethod    
    % Special case for instrument.m - Don't want to output the Contents 
	% help since not a true constructor.
	if (strcmpi(lookupName, 'instrument'))
		switch nargout
		case 0
			disp(evalc('help([instrRoot filesep ''Contents.m''])'));
		case 1
			varargout{1} = help([instrRoot filesep 'Contents.m']);
		end
		return;
	end
    
    pathName = localFindPath(lookupName, className, instrRoot);
    if ~isempty(pathName)
        % Path existed. It was a function.        
        if (includeContents)
            switch nargout
            case 0
                out1 = evalc('help([instrRoot filesep lookupName filesep ''Contents.m''])');
                out2 = evalc('help(pathName)');  
                disp([out1 out2]);
            case 1
                out1 = help([instrRoot filesep lookupName filesep 'Contents.m']);
                out2 = help(pathName);
                varargout{1} = [out1 out2];
            end
            return;
        else
            switch nargout
            case 0
                out = evalc('help(pathName)');
            case 1    
                out = help(pathName);
            end
        end
    elseif any(strcmpi(lookupName, {'clear', 'load', 'save'}))
        if (nargout == 1)
            varargout{1} = sprintf(privateGetHelp(lookupName));
        else
            fprintf(privateGetHelp(lookupName));
        end
        return;
    else
        errflag = true;
        errMsg = 'Invalid instrument control function:';
    end
end

% Get the property help.
if (isProperty && ~isMethod)  || (isProperty && isMethod && (errflag == true))
    [errflag, out] = localGetPropDesc(lookupName, className);
    if (errflag)
        if (isMethod)
            errMsg = 'Invalid instrument control function or property:';
        else
            errMsg = 'Invalid instrument control property:';
        end
    end
end

% If not a property or a function, error.
if errflag
	switch nargin
	case 1
		error('instrument:instrhelp:invalidNAME', [errMsg ' ''' varargin{1} '''.' sprintf('\n') 'If NAME is a device object property or method, try ''instrhelp(OBJ, ''NAME'')''.']);
	case 2          
		error('instrument:instrhelp:invalidNAME', [errMsg ' ''' class(obj) '.' name '''.']);
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
 
% ********************************************************************
% Find the pathname when the object directory and method are given.
function pathname = localFindPath(name, path, instrRoot)

% Path is not empty.  The file can be in one of four locations.
% instrRoot
% instrRoot\@instrument
% instrRoot\@serial, instrRoot\@gpib, instrRoot\@visa

serialRoot = fullfile(matlabroot,'toolbox','matlab','iofun','@serial');
instrRoot2 = fullfile(matlabroot,'toolbox','matlab','iofun','@instrument');
interfaceRoot = fullfile(matlabroot, 'toolbox', 'matlab', 'iofun', '@icinterface');

% Initialize variables.
pathname = '';
allpaths = which(name, '-all');

if any(strcmpi(path, {'visa-serial', 'visa-gpib', 'visa-gpib-vxi', 'visa-vxi', 'visa-tcpip', 'visa-usb', 'visa-rsib'}))
    path = 'visa';
end

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

% Check instrRoot\@instrument
index = strmatch([instrRoot filesep '@instrument'], allpaths);
if ~isempty(index)
	pathname = allpaths{index};
	return;
end

% Check instrRoot\@icinterface
if any(strcmp(path, {'serial', 'gpib', 'visa', 'tcpip', 'udp', ''}))
	index = strmatch([instrRoot filesep '@icinterface'], allpaths);
	if ~isempty(index)
		pathname = allpaths{index};
		return;
	end
end

% Check instrRoot\@icdevice
if (any(strcmp(path, {'icdevice'})))
	index = strmatch([instrRoot filesep '@icdevice'], allpaths);
	if ~isempty(index)
		pathname = allpaths{index};
		return;
    end
end

% Check instrRoot\@iviconfigurationstore
if (any(strcmp(path, {'iviconfigurationstore'})))
	index = strmatch([instrRoot filesep '@iviconfigurationstore'], allpaths);
	if ~isempty(index)
		pathname = allpaths{index};
		return;
    end
end

% Check instrRoot\@serial, instrRoot\@gpib or instrRoot\@visa
if ~isempty(path)
	index = strmatch([instrRoot filesep '@' path], allpaths);
	if ~isempty(index)
	    pathname = allpaths{index};
	    return;
    end 
else
    objectPaths = {[instrRoot filesep '@gpib'], ...
            [instrRoot filesep '@visa'],...
            [instrRoot filesep '@tcpip'],...
            [instrRoot filesep '@udp'],...
            [instrRoot filesep '@instrument'],...
            [instrRoot filesep '@serial'],...
            [instrRoot filesep '@icdevice'],...
            [instrRoot filesep '@icgroup'],...
            [instrRoot filesep '@iviconfigurationstore'],...
            [instrRoot filesep '@gpib']};
    for i = 1:length(objectPaths)
        index = strmatch(objectPaths{i}, allpaths);
    	if ~isempty(index)
	        pathname = allpaths{index};
	        return;
        end
    end
end

% Check instrRoot\instrumentdemos
index = strmatch([instrRoot 'demos' filesep name], allpaths);
if ~isempty(index)
	pathname = allpaths{index};
	return;
end

% If serial, look into the MATLAB serial directories.
if strcmp(path, 'serial') || isempty(path)
    % Check iofun\@serial
	index = strmatch([serialRoot filesep name], allpaths);
	if ~isempty(index)
		pathname = allpaths{index};
		return;
	end
    
    % Check iofun\@instrument.
	index = strmatch([instrRoot2 filesep name], allpaths);
	if ~isempty(index)
		pathname = allpaths{index};
		return;
	end

    % Check iofun\@icinterface.
	index = strmatch([interfaceRoot filesep name], allpaths);
	if ~isempty(index)
		pathname = allpaths{index};
		return;
	end
end

% ********************************************************************
% Find the pathname when the object directory and method are given.
function [errflag, out] = localGetPropDesc(prop, classtype)

% Initialize output.
errflag = false;
out     = '';

% Get property help. First assume it is an icinterface object.
try
    out = com.mathworks.toolbox.instrument.util.PropertyHelp.getHelp(classtype, prop);
catch
    errflag = true;
end

% Property was found.
if errflag == false
    return
end

% Reset flag.
errflag = false;

% Get property help. Assume it is a device object.
try
    out = com.mathworks.toolbox.testmeas.device.util.PropertyHelp.getHelp(prop);
catch
    errflag = true;
end


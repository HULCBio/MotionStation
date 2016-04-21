function obj = gpib(varargin)
%GPIB Construct GPIB object.
%
%   OBJ = GPIB('VENDOR',BOARDINDEX,PRIMARYADDRESS) constructs a
%   GPIB object, OBJ, associated with board index, BOARDINDEX, and
%   instrument primary address, PRIMARYADDRESS. The primary address
%   can range between 0 and 30. The GPIB hardware is supplied by
%   VENDOR. Supported vendors include:
%
%       'agilent'  - Agilent Technologies hardware.
%       'cec'      - Capital Equipment Corporation hardware.
%       'contec'   - CONTEC hardware.
%       'ics'      - ICS Electronics hardware.
%       'iotech'   - IOTech hardware.
%       'keithley' - Keithley hardware.
%       'mcc'      - Measurement Computing Corporation (ComputerBoards) hardware.
%       'ni'       - National Instruments hardware.
%
%   In order to communicate with the instrument, the object, OBJ, must
%   be connected to the instrument with the FOPEN function. 
%
%   When the GPIB object is constructed, the object's Status property
%   is configured to closed. Once the object is connected to the GPIB
%   instrument with the FOPEN function, the Status property is configured
%   to open. Only one GPIB object can be connected to the instrument 
%   with the specified board index, primary address and secondary address
%   at a time.
%
%   OBJ = GPIB('VENDOR',BOARDINDEX,PRIMARYADDRESS,'P1',V1,'P2',V2,...) 
%   constructs a GPIB object, OBJ, associated with board index, BOARDINDEX,
%   and instrument primary address, PRIMARYADDRESS and with the specified
%   property values. If an invalid property name or property value is 
%   specified the object will not be created.
%
%   Note that the param-value pairs can be in any format supported by
%   the SET function, i.e., param-value string pairs, structures, and
%   param-value cell array pairs.  
%
%   At any time you can view a complete listing of GPIB functions and 
%   properties with the INSTRHELP function, i.e., instrhelp gpib.
%
%   Example:
%       % To construct a GPIB object connected to an Agilent Technologies 
%         board at index 0 with an instrument at primary address 1:
%         g = gpib('agilent', 0, 1);
%
%       % To connect the GPIB object to the instrument:
%         fopen(g)	
%
%       % To query the instrument.
%         fprintf(g, '*IDN?');
%         idn = fscanf(g);
%
%       % To disconnect the GPIB object from the instrument.
%         fclose(g); 
%
%   See also ICINTERFACE/FOPEN, INSTRUMENT/PROPINFO, INSTRHELP.
%

%   MP 7-13-99
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.13.2.5 $  $Date: 2004/01/16 19:58:51 $

% Create the parent class.
try
	instr = icinterface('gpib');
catch
    error('instrument:gpib:nojvm', 'GPIB objects require JAVA support.');
end

try
	instrPackage = findpackage('instrument');
catch
end

if isempty(instrPackage)
	instrPackage = schema.package('instrument');
end

switch (nargin)
case 0
   error('instrument:gpib:invalidSyntax', 'The VENDOR must be specified.');
case 1
   if isa(varargin{1}, 'gpib')
      obj = varargin{1};
   elseif isa(varargin{1}, 'com.mathworks.toolbox.instrument.GpibDll') 
      obj.jobject = handle(varargin{1});
      obj.type = 'gpib';
      obj.constructor = 'gpib';
      obj = class(obj, 'gpib', instr);
   elseif ~isempty(findstr(class(varargin{1}), 'com.mathworks.toolbox.instrument.Gpib'))
      obj.jobject = varargin{1};
      obj.type = 'gpib';
      obj.constructor = 'gpib';
      obj = class(obj, 'gpib', instr);
   elseif ishandle(varargin{1})   
       % True if loading an array of objects and the first is a GPIB object. 
       if ~isempty(findstr(class(varargin{1}(1)), 'com.mathworks.toolbox.instrument.Gpib'))
           obj.jobject = varargin{1}; 
           obj.type = 'gpib';
           obj.constructor = 'gpib';
           obj = class(obj, 'gpib', instr);
       else
           error('instrument:gpib:invalidSyntax', 'Invalid VENDOR specified.'); 
       end
   elseif ischar(varargin{1})
      error('instrument:gpib:invalidSyntax', 'The BOARDINDEX and PRIMARYADDRESS must be specified.');
   else
      error('instrument:gpib:invalidSyntax', 'Invalid VENDOR specified.');        
   end
   obj.jobject(1).setMATLABObject(obj);
   return;
case 2
   error('instrument:gpib:invalidSyntax', 'The PRIMARYADDRESS must be specified.');
otherwise
   % Ex. g = gpib('ni', 0, 1);
   % Ex. g = gpib('ni', 0, 1, 'SecondaryAddress', 98);
   [vendor, boardIndex, primAdrs] = deal(varargin{1:3});
end	

% Error checking.
if ~ischar(vendor)
	error('instrument:gpib:invalidVENDOR', 'The VENDOR must be a string.');
end
if isempty(vendor)
	error('instrument:gpib:invalidVENDOR', 'The VENDOR must be a non-empty string.');
end
if ~isa(boardIndex, 'double')
    error('instrument:gpib:invalidBOARDINDEX',' The BOARDINDEX must be a double.');
end
if isempty(boardIndex)
	error('instrument:gpib:invalidBOARDINDEX', 'The BOARDINDEX must be a non-empty double.');
end
if ~isa(primAdrs, 'double') || isempty(primAdrs)
    error('instrument:gpib:invalidPRIMARYADDRESS', 'The PRIMARYADDRESS must be a double ranging between 0 and 30.');
end
if boardIndex < 0
    error('instrument:gpib:invalidBOARDINDEX', 'The BOARDINDEX must be greater than or equal to 0.');
end
if (primAdrs < 0) || (primAdrs > 30)
    error('instrument:gpib:invalidPRIMARYADDRESS', 'The PRIMARYADDRESS must range between 0 and 30.');
end

% Determine the path to the dll. If the path is given use it otherwise try
% to find the associated MathWorks adaptor.
[pathToDll, name, ext] = fileparts(vendor);
if isempty(pathToDll)

	% The adaptor is a MathWorks adaptor - verify that it exists.
	[pathToDll, errflag] = localFindAdaptor(name, ext);
	if errflag
        rethrow(lasterror);
	end
end

% Call the java constructor and store the java object in the jobject field.
try
	obj.jobject = handle(javaObject(['com.mathworks.toolbox.instrument.Gpib' upper(name)], pathToDll, boardIndex, primAdrs));
   	connect(obj.jobject, instrPackage.DefaultDatabase, 'up');
catch
    error('instrument:gpib:invalidInterface', sprintf(['Unable to load ' upper(name) ' GPIB interface. Please check that the necessary\n',...
                   'drivers are installed on your machine.']));
end

obj.type = 'gpib';  
obj.constructor = 'gpib';
   
% Assign the class tag.
obj = class(obj, 'gpib', instr);

% Assign the properties.
if nargin > 3
   try
      set(obj, varargin{4:end});
   catch
      delete(obj); 
      localFixError;
      rethrow(lasterror);
   end
end   

% Pass the OOPs object to java. Used for callbacks.
obj.jobject(1).setMATLABObject(obj);

% *******************************************************************
% Fix the error message.
function localFixError

% Initialize variables.
[errmsg, errid] = lasterr;

% Remove the trailing carriage returns from errmsg.
while errmsg(end) == sprintf('\n')
   errmsg = errmsg(1:end-1);
end

lasterr(errmsg, errid);

% *******************************************************************
% Find the adaptor that is being loaded. The path was not specified.
function [adaptorPath, errflag] = localFindAdaptor(adaptorName, adaptorExt)

% Initialize variables.
adaptorPath = '';
errflag = 0;

% Define the toolbox root location.
instrRoot = which('instrgate', '-all');

% From the adaptorName construct the adaptor filename.
if isempty(adaptorExt)
	adaptorName = lower(['mw' adaptorName 'gpib']);
end

% Define the adaptor directory location.
switch computer
case 'PCWIN'
    instrRoot = [lower(fileparts(instrRoot{1})) 'adaptors'];
	adaptorRoot = fullfile(instrRoot, 'win32', [adaptorName '.dll']);
case 'SOL2'
    instrRoot = [fileparts(instrRoot{1}) 'adaptors'];
    adaptorRoot = fullfile(instrRoot, 'sol2', [adaptorName '.so']);
case 'GLNX86'
    instrRoot = [fileparts(instrRoot{1}) 'adaptors'];
    adaptorRoot = fullfile(instrRoot, 'glnx86', [adaptorName '.so']);
otherwise
	errflag = 1;
	lasterr(['GPIB hardware on the ' computer ' platform is not supported.'], 'instrument:gpib:unsupportedPlatform');
	return;
end

% Determine if the adaptor exists.
if exist(adaptorRoot) 
	adaptorPath = adaptorRoot;
else
	errflag = 1;
	lasterr('The specified VENDOR adaptor could not be found.', 'instrument:gpib:adaptorNotFound');
end

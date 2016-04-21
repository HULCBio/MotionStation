function obj = visa(vendor, name, varargin)
%VISA Construct VISA object.
%
%   OBJ = VISA('VENDOR', 'RSRCNAME') constructs a VISA object, OBJ, of type
%   RSRCNAME. The possible VENDORs are:
%
%       VENDOR         Description
%       ======         ===========
%       agilent        Agilent Technologies VISA.
%       ni             National Instruments VISA.
%       tek            Tektronix VISA.
%
%   RSRCNAME is a symbolic name for the instrument with the following
%   format (values in brackets [] are optional):
%        
%       Interface      RSRCNAME
%       =========      ========
%       GPIB           GPIB[board]::primary_address::[secondary_address]::INSTR
%       VXI            VXI[chassis]::VXI_logical_address::INSTR
%       GPIB-VXI       GPIB-VXI[chassis]::VXI_logical_address::INSTR
%       Serial         ASRL[port_number]::INSTR
%       TCPIP          TCPIP[board]::remote_host::[lan_device_name]::INSTR
%       USB            USB[board]::manid::model_code::serial_No::[interface_No]::INSTR
%       RSIB           RSIB::remote_host::INSTR  (provided by NI VISA only).
%
%   The following describes the parameters given above:
%
%       Parameter            Description
%       =========            ===========
%       board                Board index (optional - defaults to 0).
%       chassis              Chassis index (optional - defaults to 0).
%       interface_No         USB interface.
%       lan_device_name      Local Area Network (LAN) device name 
%                            (optional - defaults to inst0).  
%       manid                Manufacturer ID of the USB instrument.
%       model_code           Model code for the USB instrument.
%       port_number          Com port number (optional - defaults to 1).
%       primary_address      Primary address of the GPIB device.
%       remote_host          Host name or IP address of the instrument.
%       secondary_address    Secondary address of the GPIB device 
%                            (optional - if not specified, none is assumed).
%       serial_No            Index of the instrument on the USB hub.
%       VXI_logical_address  Logical address of the VXI instrument.
%
%   OBJ's RsrcName property is updated to reflect the RSRCNAME with default 
%   values specified where appropriate.
%
%   RSRCNAME can be the VISA alias for the instrument.
%
%   In order to communicate with the instrument, the VISA object must be 
%   connected to the instrument with the FOPEN function. 
%
%   When the VISA object is constructed, the object's Status property
%   is closed. Once the object is connected to the instrument with the
%   FOPEN function, the Status property is configured to open. Only one
%   VISA object can be connected to the same instrument at a time.
%
%   OBJ = VISA('VENDOR','RSRCNAME','P1',V1,'P2',V2,...) constructs a 
%   VISA object, OBJ, of type RSRCNAME and with the specified property 
%   values. If an invalid property name or property value is specified 
%   OBJ will not be created.
%
%   Note that the param-value pairs can be in any format supported by
%   the SET function, i.e., param-value string pairs, structures, and
%   param-value cell array pairs.  
%
%   At any time you can view a complete listing of VISA functions and 
%   properties with the INSTRHELP function, i.e., instrhelp visa.
%
%   Example:
%       % To construct a VISA-GPIB object connected to Board 4 with an
%       % instrument with primary address 1 and no secondary address.
%         g = visa('ni', 'GPIB4::1::0::INSTR');
%
%       % To construct a VISA-VXI object that communicates with a VXI 
%       % instrument located at logical address 8 in the first VXI system.
%         v = visa('agilent', 'VXI0::8::INSTR');
%
%       % To construct a VISA-serial object that is connected to COM2.
%         s = visa('tek', 'ASRL2::INSTR');
%
%       % To connect the VISA-GPIB object to the instrument:
%         fopen(g)	
%
%       % To query the instrument.
%         fprintf(g, '*IDN?');
%         idn = fscanf(g);
%
%       % To disconnect the VISA-GPIB object from the instrument.
%         fclose(g); 
%
%   See also ICINTERFACE/FOPEN, INSTRUMENT/PROPINFO, DEMOV_INTRO, INSTRHELP.
%

%   MP 7-13-99
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.13.2.6 $  $Date: 2004/01/16 20:02:29 $

% Initialize error messages.
errMsg = 'Invalid RSRCNAME specified. Type ''instrhelp visa'' for more information.';
errMsg2 = sprintf(['Unable to create VISA object either due to an invalid RSRCNAME or the necessary\n',...
          'drivers are not installed. Type ''instrhelp visa'' for more information.']);

% Create the parent class.
try
	instr = icinterface('visa');
catch
    error('instrument:visa:nojvm', 'VISA objects require JAVA support.');
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
   error('instrument:visa:invalidSyntax', 'The VENDOR must be specified.');
case 1
   if strcmp(class(vendor), 'visa')
      obj = vendor;
   elseif isa(vendor, 'com.mathworks.toolbox.instrument.SerialVisa')
      obj.jobject = handle(vendor);
      obj.type = 'serial';
      obj.constructor = 'visa';
      obj = class(obj, 'visa', instr);
   elseif isa(vendor, 'com.mathworks.toolbox.instrument.GpibVisa')
      obj.jobject = handle(vendor);
      obj.type = 'gpib';
      obj.constructor = 'visa';
      obj = class(obj, 'visa', instr);
   elseif isa(vendor, 'com.mathworks.toolbox.instrument.VxiVisa')
      obj.jobject = handle(vendor);
      obj.type = 'vxi';
      obj.constructor = 'visa';
      obj = class(obj, 'visa', instr);
   elseif isa(vendor, 'com.mathworks.toolbox.instrument.VxiGpibVisa')
      obj.jobject = handle(vendor);
      obj.type = 'gpib-vxi';
      obj.constructor = 'visa';
      obj = class(obj, 'visa', instr);
   elseif isa(vendor, 'com.mathworks.toolbox.instrument.TcpipVisa')
      obj.jobject = handle(vendor);
      obj.type = 'tcpip';
      obj.constructor = 'visa';
      obj = class(obj, 'visa', instr);
   elseif isa(vendor, 'com.mathworks.toolbox.instrument.UsbVisa')
      obj.jobject = handle(vendor);
      obj.type = 'usb';
      obj.constructor = 'visa';
      obj = class(obj, 'visa', instr);
   elseif isa(vendor, 'com.mathworks.toolbox.instrument.RsibVisa')
      obj.jobject = handle(vendor);
      obj.type = 'rsib';
      obj.constructor = 'visa';
      obj = class(obj, 'visa', instr);
   elseif isa(vendor, 'javahandle.com.mathworks.toolbox.instrument.SerialVisa')
      obj.jobject = vendor;
      obj.type = 'serial';
      obj.constructor = 'visa';
      obj = class(obj, 'visa', instr);
   elseif isa(vendor, 'javahandle.com.mathworks.toolbox.instrument.GpibVisa')
      obj.jobject = vendor;
      obj.type = 'gpib';
      obj.constructor = 'visa';
      obj = class(obj, 'visa', instr);
   elseif isa(vendor, 'javahandle.com.mathworks.toolbox.instrument.VxiVisa')
      obj.jobject = vendor;
      obj.type = 'vxi';
      obj.constructor = 'visa';
      obj = class(obj, 'visa', instr);
   elseif isa(vendor, 'javahandle.com.mathworks.toolbox.instrument.VxiGpibVisa')
      obj.jobject = vendor;
      obj.type = 'gpib-vxi';
      obj.constructor = 'visa';
      obj = class(obj, 'visa', instr);
   elseif isa(vendor, 'javahandle.com.mathworks.toolbox.instrument.TcpipVisa')
      obj.jobject = vendor;
      obj.type = 'tcpip';
      obj.constructor = 'visa';
      obj = class(obj, 'visa', instr);
   elseif isa(vendor, 'javahandle.com.mathworks.toolbox.instrument.UsbVisa')
      obj.jobject = vendor;
      obj.type = 'usb';
      obj.constructor = 'visa';
      obj = class(obj, 'visa', instr);      
   elseif isa(vendor, 'javahandle.com.mathworks.toolbox.instrument.RsibVisa')
      obj.jobject = vendor;
      obj.type = 'rsib';
      obj.constructor = 'visa';
      obj = class(obj, 'visa', instr);
   elseif ishandle(vendor)
      % True if loading an array of objects and the first is a VISA object. 
      if ~isempty(findstr(class(vendor(1)), 'com.mathworks.toolbox.instrument.'))
          obj.jobject = vendor;
          obj.type = 'rsib';
          obj.constructor = 'visa';
          obj = class(obj, 'visa', instr);
      else
         error('instrument:visa:invalidSyntax', 'The RSRCNAME must be specified.');
      end
   else
      error('instrument:visa:invalidSyntax', 'The RSRCNAME must be specified.');
   end
   obj.jobject(1).setMATLABObject(obj);
   return;
otherwise
	% Error checking.
	if ~ischar(vendor)
		error('instrument:visa:invalidVENDOR', 'The VENDOR must be a string.');
	end
	if isempty(vendor)
		error('instrument:visa:invalidVENDOR', 'The VENDOR must be a non-empty string.');
	end
	if ~ischar(name)
		error('instrument:visa:invalidRSRCNAME', 'The RSRCNAME must be a string. Type ''instrhelp visa'' for a list of valid RSRCNAMEs.');
	end
	if isempty(name)
		error('instrument:visa:invalidRSRCNAME', 'The RSRCNAME must be a non-empty string. Type ''instrhelp visa'' for a list of valid RSRCNAMEs.');
	end
	
	% Ex. v = visa('ni', 'ASRL1::INSTR');
	% Ex. v = visa('agilent', 'GPIB0::1::97::INSTR', 'Tag', 'visa-gpib');
	
	% Determine the path to the dll. If the path is given use it otherwise try
	% to find the associated MathWorks adaptor.
	[pathToDll, vendor, ext] = fileparts(vendor);
	if isempty(pathToDll)
       
		% The adaptor is a MathWorks adaptor - verify that it exists.
		[pathToDll, errflag] = localFindAdaptor(vendor, ext);
		if errflag
			rethrow(lasterror);
		end
	end
	
	[pathToDll, temp, ext] = fileparts(pathToDll);
	vendor = [temp ext];   
       
	% Parse the input name and determine which type of object is being
	% created.
	[type, name, alias, errflag] = localParseName(name, pathToDll, vendor);
	if (errflag == true)
        error('instrument:visa:invalidRSRCNAME', errMsg)
	end	
	
	% Call the java constructor and store the java object in the
	% jobject field.
	switch (type)
	case 'serial'
      try
         obj.jobject = handle(com.mathworks.toolbox.instrument.SerialVisa(pathToDll,vendor,name,alias));
         connect(obj.jobject, instrPackage.DefaultDatabase, 'up');
         obj.type = 'serial';
         obj.constructor = 'visa';
      catch
         error('instrument:visa:invalidRSRCNAME', errMsg2);
      end   
	case 'gpib'
      try
         obj.jobject = handle(com.mathworks.toolbox.instrument.GpibVisa(pathToDll, vendor,name,alias));   
         connect(obj.jobject, instrPackage.DefaultDatabase, 'up');
         obj.type = 'gpib';
         obj.constructor = 'visa';
      catch
         error('instrument:visa:invalidRSRCNAME', errMsg2);
      end   
	case 'vxi'    
      try
         obj.jobject = handle(com.mathworks.toolbox.instrument.VxiVisa(pathToDll, vendor, name, alias));   
         connect(obj.jobject, instrPackage.DefaultDatabase, 'up');
         obj.type = 'vxi';
         obj.constructor = 'visa';
      catch
         error('instrument:visa:invalidRSRCNAME', errMsg2);
      end   
	case 'gpib-vxi'
      try
         obj.jobject = handle(com.mathworks.toolbox.instrument.VxiGpibVisa(pathToDll, vendor, name, alias));   
		 connect(obj.jobject, instrPackage.DefaultDatabase, 'up');
         obj.type = 'gpib-vxi';
         obj.constructor = 'visa';
      catch
         error('instrument:visa:invalidRSRCNAME', errMsg2);
      end 
    case 'tcpip'
      try
         obj.jobject = handle(com.mathworks.toolbox.instrument.TcpipVisa(pathToDll, vendor, name, alias));   
		 connect(obj.jobject, instrPackage.DefaultDatabase, 'up');
         obj.type = 'tcpip';
         obj.constructor = 'visa';
      catch
         error('instrument:visa:invalidRSRCNAME', errMsg2);    
      end
    case 'usb'
      try
         obj.jobject = handle(com.mathworks.toolbox.instrument.UsbVisa(pathToDll, vendor, name, alias));   
		 connect(obj.jobject, instrPackage.DefaultDatabase, 'up');
         obj.type = 'usb';
         obj.constructor = 'visa';
      catch
         error('instrument:visa:invalidRSRCNAME', errMsg2);    
      end
    case 'rsib'
      try
         obj.jobject = handle(com.mathworks.toolbox.instrument.RsibVisa(pathToDll, vendor, name, alias));   
		 connect(obj.jobject, instrPackage.DefaultDatabase, 'up');
         obj.type = 'rsib';
         obj.constructor = 'visa';
      catch
         error('instrument:visa:invalidRSRCNAME', errMsg2);    
      end
	end
	
	% Assign the class tag.
	obj = class(obj, 'visa', instr);
	
	% Set the specified property-value pairs.
	if nargin > 2
      try
         set(obj, varargin{:});
      catch
         delete(obj); 
         localFixError;
         rethrow(lasterror);
      end
	end   
end	

% Pass the OOPs object to java. Used for callbacks.
obj.jobject(1).setMATLABObject(obj);

% ********************************************************************
% Determine the type of object that is being created.
function [type, rsrcName, alias, errflag] = localParseName(name, pathToDll,vendor)

% Initialize variables.
type     = '';
rsrcName = '';
alias    = '';
errflag  = false;

% Determine the resource name from the specified resource name. This will
% allow users to use an alias for their resource name.
try
    tempobj = com.mathworks.toolbox.instrument.SerialVisa(pathToDll,vendor,'ASRL1::INSTR','');
    info = getAliasInfo(tempobj, name);
    if ~isempty(info)
        info = cell(info);
    end
    tempobj.dispose;
catch
    errflag = true;
    return;
end

% If there is no information returned, then it is an invalid resource
% name/alias. If the first element is not an INSTR, error.
if isempty(info) || ~strcmpi(info{1}, 'INSTR')
    errflag = true;
    return;
end

% Otherwise the alias/resource name was mapped to a resource name.
rsrcName = info{2};
alias    = info{3};

% Determine the type of object to create.
if strmatch('ASRL', upper(rsrcName))    
   % ASRL1::INSTR
   type = 'serial';
elseif strmatch('GPIB-VXI', upper(rsrcName))
   % GPIB-VXI0::7::INSTR.
   type = 'gpib-vxi';
elseif strmatch('GPIB', upper(rsrcName))   
   % GPIB0::1::97::INSTR
   type = 'gpib';
elseif strmatch('RSIB', upper(rsrcName))
    %RSIB::ipaddress::INSTR
    type = 'rsib';
elseif strmatch('VXI', upper(rsrcName))
   % VXI0::1::INSTR
   type = 'vxi';
elseif strmatch('TCPIP', upper(rsrcName))
    % TCPIP::123.34.16.210::INSTR
    type = 'tcpip';
elseif strmatch('USB', upper(rsrcName))
    % USB::0x1234::125::A22-5::INSTR
    type = 'usb';
else
   errflag = true;
end

% *******************************************************************
% Fix the error message.
function localFixError

% Initialize variables.
[errmsg, id] = lasterr;

% Remove the trailing carriage returns from errmsg.
while errmsg(end) == sprintf('\n')
   errmsg = errmsg(1:end-1);
end

lasterr(errmsg, id);

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
	adaptorName = lower(['mw' adaptorName 'visa']);
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
	lasterr(['The VISA adaptor on the ' computer ' platform is not supported.'], 'instrument:visa:unsupportedPlatform');
	return;
end

% Determine if the adaptor exists.
if exist(adaptorRoot)
	adaptorPath = adaptorRoot;
else
	errflag = 1;
	lasterr('Invalid VENDOR specified. Type ''instrhelp visa'' for more information.', 'instrument:visa:adaptorNotFound');
end

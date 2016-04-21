function out = instrhwinfo(object, adaptor, interface)
%INSTRHWINFO Return information on available hardware.
%localGetMATLABDriverInfo
%   OUT = INSTRHWINFO returns a structure, OUT, which contains instrument
%   control hardware information. This information includes the toolbox
%   version, MATLAB version, supported interfaces and supported driver 
%   types.
%
%   OUT = INSTRHWINFO('INTERFACE') returns a structure, OUT, which 
%   contains information related to the specified interface, INTERFACE.
%   INTERFACE can be 'gpib', 'visa', 'serial', 'tcpip' or 'udp'. For the
%   GPIB and VISA interfaces, this information includes installed adaptors.
%   For the serial port interface, this information includes available
%   hardware. For the TCPIP and UDP interfaces, this information includes
%   the local host address.
%
%   OUT = INSTRHWINFO('DRIVERTYPE') returns a structure, OUT, which contains
%   information related to the specified driver type, DRIVERTYPE.
%   DRIVERTYPE can be 'matlab', 'vxipnp', or 'ivi'. If DRIVERTYPE is
%   MATLAB, this information includes the MATLAB instrument drivers found
%   on the MATLAB path. If DRIVERTYPE is vxipnp, this information includes
%   the found VXIplug&play drivers. If DRIVERTYPE is ivi, this information
%   includes the avialable logical names and information on the IVI
%   configuration store.
%
%   OUT = INSTRHWINFO('INTERFACE', 'ADAPTOR') returns a structure, OUT,
%   which contains information related to the specified adaptor, ADAPTOR,
%   for the specified INTERFACE. This information includes adaptor version
%   and available hardware. INTERFACE can be set to either 'gpib' or 'visa'.  
%   Supported adaptors include:
% 
%             Interface:      Adaptor:
%             ==========      ======== 
%             gpib            agilent, cec, contec, ics, iotech, keithley, 
%                             mcc, ni
%             visa            agilent, ni, tek
%
%   OUT = INSTRHWINFO('DRIVERTYPE', 'DRIVERNAME') returns a structure, OUT,
%   which contains information related to the specified driver, DRIVERNAME
%   for the specified DRIVERTYPE. DRIVERTYPE can be set to 'matlab',
%   'vxipnp'. The available DRIVERNAME values are returned by
%   INSTRHWINFO('DRIVERTYPE').
%
%   OUT = INSTRHWINFO('ivi', 'LOGICALNAME') returns a structure, OUT, which
%   contains information related to the specified logical name,
%   LOGICALNAME. The available logical name values are returned by
%   INSTRHWINFO('ivi').
%
%   OUT = INSTRHWINFO('INTERFACE', 'ADAPTOR', 'TYPE') returns a structure,
%   OUT, which contains information on the specified type, TYPE. INTERFACE
%   can only be 'visa'. ADAPTOR can be 'agilent', 'ni' or 'tek'. TYPE can
%   be  'gpib', 'vxi', 'gpib-vxi', 'serial', 'tcpip', 'usb' or 'rsib'.
%    	
%   OUT = INSTRHWINFO(OBJ) where OBJ is any instrument object or a device 
%   group object, returns  a structure, OUT, containing information on OBJ.
%   For GPIB and VISA objects, OUT contains adaptor and vendor supplied DLL
%   information. For serial port, tcpip and udp objects, OUT contains JAR
%   file information. For device objects and device group objects, OUT 
%   contains driver and instrument information. If OBJ is an array of 
%   objects then OUT is a 1-by-N cell array of structures where N is the
%   length of OBJ.   
%
%   OUT = INSTRHWINFO(OBJ, 'FieldName') returns the hardware information 
%   for the specified fieldname, FieldName, to OUT. FieldName can be any of
%   the fieldnames defined in the INSTRHWINFO(OBJ) structure. FieldName can
%   be a single string or a cell array of strings. OUT is a M-by-N cell
%   array where M is the length of OBJ and N is the length of FieldName.
%
%   Example:
%       out1 = instrhwinfo
%       out2 = instrhwinfo('serial');
%       out3 = instrhwinfo('gpib', 'ni');
%       out4 = instrhwinfo('visa', 'ni');
%       out5 = instrhwinfo('visa', 'ni', 'gpib');
%       obj = visa('ni', 'ASRL1::INSTR');
%       out6 = instrhwinfo(obj);
%       out7 = instrhwinfo(obj, 'AdaptorName');
%
%   See also INSTRHELP.
%

%   MP 7-13-99
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.19.4.8 $  $Date: 2004/02/09 06:43:10 $

% Error if java is not running.
if ~usejava('jvm')
	error('instrument:instrhwinfo:nojvm', 'INSTRHWINFO requires JAVA support.');
end

switch nargin
case 0
	% Ex. out = instrhwinfo
	
	% Create the output structure.
	out.MATLABVersion = localGetVersion('MATLAB');
    if strcmp(computer, 'GLNX86')
        out.SupportedInterfaces = {'serial', 'tcpip', 'udp'};
        out.SupportedDrivers = {'matlab'};
    else
    	out.SupportedInterfaces = {'gpib', 'serial', 'visa','tcpip','udp'};	
        out.SupportedDrivers = {'matlab', 'vxipnp', 'ivi'};
    end
	out.ToolboxName = 'Instrument Control Toolbox';
	out.ToolboxVersion = localGetVersion('instrument');
	
case 1
	% Ex. out = instrhwinfo('serial');
	
	% Determine the jar file version.
	jarFileVersion = com.mathworks.toolbox.instrument.Instrument.jarVersion;
	
	if ~ischar(object)
		error('instrument:instrhwinfo:invalidInterface', 'Invalid INTERFACE specified. Type ''instrhelp instrhwinfo'' for a list of valid INTERFACEs.');
	end
	
	% Create the output structure.
	switch lower(object)
	case 'serial'
		try
			fields = {'AvailableSerialPorts', 'JarFileVersion', ...
					'ObjectConstructorName', 'SerialPorts'};
			s = com.mathworks.toolbox.instrument.SerialComm('temp'); 
			tempOut = hardwareInfo(s);
			dispose(s);

			% Create the output structure.
			tempOut = cell(tempOut);
			out = cell2struct(tempOut', fields, 2);
			out.JarFileVersion = jarFileVersion;
		catch
            rethrow(lasterror);
		end
	case 'gpib'
		[pathToDll, errflag] = localFindPath;
		if errflag
            rethrow(lasterror);
		end
		try
			out.InstalledAdaptors = com.mathworks.toolbox.instrument.GpibDll.findValidAdaptors(pathToDll);
			out.InstalledAdaptors = out.InstalledAdaptors';
			out.JarFileVersion = jarFileVersion;
		catch
            rethrow(lasterror);
		end
	case {'visa'}
		[pathToDll, errflag] = localFindPath;
		if errflag
            rethrow(lasterror);
		end
		try
			out.InstalledAdaptors = com.mathworks.toolbox.instrument.SerialVisa.findValidAdaptors(pathToDll);
			out.InstalledAdaptors = out.InstalledAdaptors';
			out.JarFileVersion = jarFileVersion;
		catch 
            rethrow(lasterror);
		end
	case 'tcpip'
		try
			fields = {'LocalHost','JarFileVersion'};
			t = com.mathworks.toolbox.instrument.TCPIP('temp',80); 
			tempOut = hardwareInfo(t);
			dispose(t);

			% Create the output structure.
			tempOut = cell(tempOut);
			out = cell2struct(tempOut', fields, 2);
			out.JarFileVersion = jarFileVersion;
		catch
            rethrow(lasterror);
		end
	case 'udp'
		try
			fields = {'LocalHost','JarFileVersion'};
			u = com.mathworks.toolbox.instrument.UDP('temp',9090); 
			tempOut = hardwareInfo(u);
			dispose(u);

			% Create the output structure.
			tempOut = cell(tempOut);
			out = cell2struct(tempOut', fields, 2);
			out.JarFileVersion = jarFileVersion;
		catch
            rethrow(lasterror);
		end
    case 'matlab'
        out = localFindMATLABDrivers;
    case 'vxipnp'
        out = localFindVXIPnPDrivers;
    case 'ivi'
        out = localFindIVIDrivers;
	otherwise
		error('instrument:instrhwinfo:invalidInterface', 'Invalid INTERFACE specified. Type ''instrhelp instrhwinfo'' for a list of valid INTERFACEs.');
	end
case 2
	% Ex. out = instrhwinfo('gpib', 'ni');
	% Ex. out = instrhwinfo('gpib', 'keithley');
	
	if ~ischar(object)
		error('instrument:instrhwinfo:invalidInterface', 'Invalid INTERFACE specified. Type ''instrhelp instrhwinfo'' for a list of valid INTERFACEs.');
	end
    
	if ~ischar(adaptor)
        if any(strcmp(object, {'gpib', 'serial', 'tcpip', 'udp', 'visa'}))
    		error('instrument:instrhwinfo:invalidAdaptor', 'Invalid ADAPTOR specified. Type ''instrhelp instrhwinfo'' for a list of valid ADAPTORs.');
        else
    		error('instrument:instrhwinfo:invalidDriverName', 'Invalid DRIVERNAME specified. Type ''instrhelp instrhwinfo'' for more information.');
        end
	end
	
	switch lower(object)
	case 'gpib'
        adaptor = lower(adaptor);
        
		% Find the path to the dll.
		[pathToDll, errflag] = localFindAdaptor(['mw' adaptor 'gpib']);
		if errflag
            rethrow(lasterror);
		end
		
		% Create the output structure.		   
		try 
			fields = {'AdaptorDllName', 'AdaptorDllVersion', 'AdaptorName',...
					'InstalledBoardIds', 'ObjectConstructorName', 'VendorDllName', ...
					'VendorDriverDescription'};
			jobject = javaObject(['com.mathworks.toolbox.instrument.Gpib' upper(adaptor)], pathToDll, 0, 0); 
			tempOut = hardwareInfo(jobject, pathToDll, adaptor, fileparts(pathToDll));
			dispose(jobject);
		catch
			error('instrument:instrhwinfo:adpatorNotFound', 'Specified ADAPTOR was not found or could not be loaded.');
		end
        
       	% Create the output structure.
    	tempOut = cell(tempOut);
	    out = cell2struct(tempOut', fields, 2);
        
        % Format InstalledBoardIds and ObjectConstructorName.
        out.InstalledBoardIds = unique(double(out.InstalledBoardIds))';
        if (isempty(out.ObjectConstructorName))
            out.ObjectConstructorName = {};
        end
        return;
	case 'visa'
		adaptor = lower(adaptor);
        
        % Find the path to the dll.
		[pathToDll, errflag] = localFindAdaptor(['mw' adaptor 'visa']);
		if errflag
            rethrow(lasterror);
		end
		
		% Construct the input to the SerialVisa constructor.
		[path, name, ext] = fileparts(pathToDll);
		vendor = [name ext];
		name = 'ASRL1::INSTR';
		
		% If a valid adaptor is specified create the output structure.
		try
			fields = {'AdaptorDllName', 'AdaptorDllVersion', 'AdaptorName',...
					'AvailableChassis', 'AvailableSerialPorts', 'InstalledBoardIds',...
					'ObjectConstructorName', 'SerialPorts', 'VendorDllName',...
					'VendorDriverDescription', 'VendorDriverVersion'};
			jobject = com.mathworks.toolbox.instrument.SerialVisa(path,vendor,name,'');
			tempOut = hardwareInfo(jobject, pathToDll, adaptor);  
			dispose(jobject);
		catch
			error('instrument:instrhwinfo:adpatorNotFound', 'Specified ADAPTOR was not found or could not be loaded.');
		end
    case 'matlab'
        [out, errflag] = localGetMATLABDriverInfo(adaptor);
        if (errflag == true)
            rethrow(lasterror);
        end
        return;
    case 'vxipnp'
        [out, errflag] = localGetVXIPnPDriverInfo(adaptor);
        if (errflag == true)
            rethrow(lasterror);
        end
        return;
    case 'ivi'
        [out, errflag] = localGetIVIDriverInfo(adaptor);
        if (errflag == true)
            rethrow(lasterror);
        end
        return;
	otherwise
		error('instrument:instrhwinfo:invalidInterface', 'Invalid INTERFACE specified. Type ''instrhelp instrhwinfo'' for a list of valid INTERFACEs.');
	end
	
	% Create the output structure.
	tempOut = cell(tempOut);
	out = cell2struct(tempOut', fields, 2);
	
case 3
	% Ex. instrhwinfo('visa', 'ni', 'serial');  
	
	% Error checking.
	if ~strcmpi(object, 'visa')
		error('instrument:instrhwinfo:invalidSyntax', 'Invalid syntax using specified INTERFACE. Type ''instrhelp instrhwinfo'' for more information.');
	end
	
	% Get the object specific information.
	try
		[errflag, out] = localFindSpecificVisaInformation(adaptor, interface);
	catch
        rethrow(lasterror);
	end
	
	% Error if necessary.
	if errflag 
       rethrow(lasterror);
	end   
end

% *********************************************************************
% Three input case.
function [errflag, out] = localFindSpecificVisaInformation(adaptor, interface)

out = [];

% Find the path to the dll.
[pathToDll, errflag] = localFindAdaptor(['mw' adaptor 'visa']);

% Return if an error occurred.
if errflag
	return;
end

% Verify type of interface.
if ~ischar(interface)
    lasterr('Invalid TYPE specified. Type ''instrhelp instrhwinfo'' for a list of valid TYPEs.', 'instrument:instrhwinfo:invalidInterface');
	errflag = 1;
	return;
end

% Construct inputs to SerialVisa constructor.
[path, vendor, ext] = fileparts(pathToDll);
vendor = [vendor ext];
name = 'ASRL1::INSTR';

% Get the interface specific information.
try
	% Define the fields.
	fields = {'AdaptorDllName', 'AdaptorDllVersion', 'AdaptorName',...
			'AvailableChassis', 'AvailableSerialPorts', 'InstalledBoardIds',...
			'ObjectConstructorName', 'SerialPorts', 'VendorDllName',...
			'VendorDriverDescription', 'VendorDriverVersion'};
	
	% Create the object.
	jobject =  com.mathworks.toolbox.instrument.SerialVisa(path,vendor,name,'');
	
	% Get the information.
	switch lower(interface)
	case 'serial'
		tempOut = hardwareInfoOnSerial(jobject, pathToDll, adaptor);
	case 'gpib'
		tempOut = hardwareInfoOnGPIB(jobject, pathToDll, adaptor);
	case 'vxi'
		tempOut = hardwareInfoOnVXI(jobject, pathToDll, adaptor);
	case 'gpib-vxi'
		tempOut = hardwareInfoOnGPIBVXI(jobject, pathToDll, adaptor);
    case 'rsib'
        tempOut = hardwareInfoOn(jobject, pathToDll, adaptor, 'RSIB');
    case 'tcpip'
        tempOut = hardwareInfoOn(jobject, pathToDll, adaptor, 'TCPIP');
    case 'usb'
        tempOut = hardwareInfoOn(jobject, pathToDll, adaptor, 'USB');
	otherwise
		lasterr('Invalid TYPE specified. Type ''instrhelp instrhwinfo'' for a list of valid TYPEs.', 'instrument:instrhwinfo:invalidInterface');
		errflag = 1;
		dispose(jobject);
		return;
	end
	
	% Get rid of the object.
	dispose(jobject);
catch
	errflag = 1;
	lasterr('Specified ADAPTOR was not found or could not be loaded.', 'instrument:instrhwinfo:invalidAdaptor');
	return
end

% Create the output structure.
tempOut = cell(tempOut);
out = cell2struct(tempOut', fields, 2);

% -------------------------------------------------------------------
% Find the path to the dll.
function [pathToDll, errflag] = localFindPath

% Initialize variables.
pathToDll = '';
errflag = 0;

% Define the toolbox root location.
pathToDll = which('instrgate', '-all');

switch computer
case 'PCWIN'
    pathToDll = [lower(fileparts(pathToDll{1})) 'adaptors'];
	pathToDll = fullfile(pathToDll, 'win32');
case 'SOL2'
    pathToDll = [fileparts(pathToDll{1}) 'adaptors'];
    pathToDll = fullfile(pathToDll, 'sol2');
otherwise
	errflag = 1;
    lasterr('The specified INTERFACE is not supported on this platform.', 'instrument:instrhwinfo:invalidPlatform');
end

% -------------------------------------------------------------------
% Find the adaptor that is being loaded. The path was not specified.
% name is mwnigpib, mwnivisa, mwagilentgpib, etc.
function [adaptorPath, errflag] = localFindAdaptor(name)

% Initialize variables.
adaptorPath = '';
errflag = 0;

% Define the toolbox root location.
instrRoot = which('instrgate', '-all');

% Define the adaptor directory location.
switch computer
case 'PCWIN'
    instrRoot = [lower(fileparts(instrRoot{1})) 'adaptors'];
	adaptorRoot = fullfile(instrRoot, 'win32', [name '.dll']);
case 'SOL2'
    instrRoot = [fileparts(instrRoot{1}) 'adaptors'];
    adaptorRoot = fullfile(instrRoot, 'sol2', [name '.so']);
otherwise
	errflag = 1;
    lasterr('The specified INTERFACE is not supported on this platform.', 'instrument:instrhwinfo:invalidPlatform');
    return;
end

% Determine if the adaptor exists.
if exist(adaptorRoot)
	adaptorPath = adaptorRoot;
else
	errflag = 1;
	lasterr('The specified VENDOR adaptor could not be found.', 'instrument:instrhwinfo:adpatorNotFound');
end

% -------------------------------------------------------------------
% Output the version of the toolbox and MATLAB.
function str = localGetVersion(product)

try
	% Get the version information.
	verinfo = ver(product);
	
	% Get the version string.
	str = [verinfo(1).Version ' ' verinfo(1).Release];
catch
	str = '';
end

% -------------------------------------------------------------------
% Called by: instrhwinfo('matlab')
function out = localFindMATLABDrivers

import com.mathworks.toolbox.instrument.device.ICDriverInfo;

% Scan for the MATLAB instrument drivers. Scan can take a long time so
% store the data away so that if user calls instrhwinfo('matlab', driver)
% we can just look up the driver path information. 
ICDriverInfo.defineMATLABDrivers(privateBrowserHelper('find_MATLAB_drivers'));
out.InstalledDrivers = cell(ICDriverInfo.getMATLABDriverNames)';

% -------------------------------------------------------------------
% Called by: instrhwinfo('vxipnp')
function out = localFindVXIPnPDrivers

% Scan for VXIplug&play drivers. Information is of the form: Name, Directory.
driverInfo = privateBrowserHelper('find_vxipnp_drivers');

out.InstalledDrivers = '';
out.VXIPnPRootPath   = privateGetVXIPNPPath;

if isempty(driverInfo)
   return;
end

% Construct the cell of VXIplug&play driver names.
names = cell(1, length(driverInfo)/2);
count = 1;
for i=1:2:length(driverInfo)
    names{count} = driverInfo{i};
    count = count+1;
end    

out.InstalledDrivers = names;

% -------------------------------------------------------------------
% Called by: instrhwinfo('ivi')
function out = localFindIVIDrivers

% Determine if IVI is installed.
rootPath = privateGetIviPath;

if isempty(rootPath)
    % IVI is not installed.
    out.LogicalNames = {};
    out.ProgramIDs   = {};
    out.Modules      = {};
    out.ConfigurationServerVersion = '';
    out.MasterConfigurationStore   = '';
    out.IVIRootPath                = '';
    return;
end

% Create the configuration store object.
store = iviconfigurationstore;

% Construct the output.
out.LogicalNames               = {};
out.ProgramIDs                 = {};
out.Modules                    = {};
out.ConfigurationServerVersion = get(store, 'Revision');
out.MasterConfigurationStore   = get(store, 'MasterLocation');
out.IVIRootPath                = rootPath;

logicalNames = get(store, 'LogicalNames');
if ~isempty(logicalNames)
    out.LogicalNames = {logicalNames.Name};
end

modules = get(store, 'SoftwareModules');

for idx = 1:length(modules)
    if (~isempty(modules(idx).ProgID))
%         if (isempty(out.ProgramIDs))
%             out.ProgramIDs = {modules(idx).ProgID};
%         else
            out.ProgramIDs{end + 1} = modules(idx).ProgID;
%         end
    else
        name = modules(idx).ModulePath;
        idx = strfind(name, '.');
        if (~isempty(idx))
            name = name(1:(idx(1) - 1));
        end
        if (strcmp(name(end-2:end), '_32'))
            name = name(1:end-3);
        end
%         if (isempty(out.Modules))
%             out.Modules = {name};
%         else
            out.Modules{end + 1} = name;
%         end
    end
end
% --------------------------------------------------------------------
% Called by: instrhwinfo('matlab', driver)
function [out, errflag] = localGetMATLABDriverInfo(driverName)

import com.mathworks.toolbox.instrument.device.ICDriverInfo;

% Initialize variables.
out     = [];
errflag = false;
scanned = false;

% Extract just the driver name and just the extension.
[pathstr, driverName, ext] = fileparts(driverName);
if isempty(ext)
    ext = '.mdd';
end
driverName = [driverName ext];

% If the driver does not exist. Scan for it.
if ICDriverInfo.isDriver(driverName) == false
    ICDriverInfo.defineMATLABDrivers(privateBrowserHelper('find_MATLAB_drivers'));
    scanned = true;
    
    % If the driver does not exist after scanning for it, error.
    if ICDriverInfo.isDriver(driverName) == false
        errflag = true;
        lasterr('The specified MATLAB instrument driver could not be found on the MATLAB path.', 'instrument:instrhwinfo:driverNotFound');
        return;
    end    
end

% Determine if the driver is still at the specified location.
driverPath = char(ICDriverInfo.getMATLABDriverPath(driverName));
driverName = char(ICDriverInfo.getMATLABDriverName(driverName));
fullDriverName = fullfile(driverPath, driverName);

if exist(fullfile(driverPath, driverName)) == 0
    % The driver no longer exists. Re-scan.
    if (scanned == false)
        ICDriverInfo.defineMATLABDrivers(privateBrowserHelper('find_MATLAB_drivers'));
        scanned = true;    
    end
    
    % If the driver does not exist after scanning for it, error.
    if ICDriverInfo.isDriver(driverName) == false 
        errflag = true;
        lasterr('The specified MATLAB instrument driver could not be found on the MATLAB path.', 'instrument:instrhwinfo:driverNotFound');
        return;
    end    

    if exist(fullfile(driverPath, driverName)) == 0
        errflag = true;
        lasterr('The specified MATLAB instrument driver could not be found on the MATLAB path.', 'instrument:instrhwinfo:driverNotFound');
        return;
    end
end

% Parse the driver.
try
    parser = com.mathworks.toolbox.instrument.device.drivers.xml.Parser(fullDriverName);
    parser.parse; 
catch
    errflag = true;
    lasterr('The specified MATLAB instrument driver could not be parsed.', 'instrument:instrhwinfo:driverInvalid');
    return;
end

% Construct the output.
out.Manufacturer  = char(parser.getInstrumentManufacturer);
out.Model         = char(parser.getInstrumentModel);
out.Type          = char(parser.getInstrumentType);
out.DriverType    = char(parser.getDriverType);
out.DriverName    = fullDriverName;
out.DriverVersion = char(parser.getInstrumentVersion);
out.DriverDllName = '';

switch (out.DriverType)
case 'VXIplug&play'
    driverDllName     = [char(parser.getDriverName) '_32.dll'];
    out.DriverDllName = fullfile(privateGetVXIPNPPath, 'bin',driverDllName);
case 'IVI-COM'
    % COM drivers do not necessarily have a 1-1 dll mapping like the other
    % drivers.
case 'IVI-C'
    driverDllName     = [char(parser.getDriverName) '.dll'];
    out.DriverDllName = fullfile(privateGetIviPath, 'bin',driverDllName);
end

% -------------------------------------------------------------------
% Called by: instrhwinfo('vxipnp', driver)
function [out, errflag] = localGetVXIPnPDriverInfo(driverName)

import com.mathworks.toolbox.instrument.device.drivers.vxipnp.VXIPnPLoader;

% Initialize variables.
out     = [];
errflag = false;

% Scan for VXIplug&play drivers. Information is of the form: Name, Directory.
driverInfo = privateBrowserHelper('find_vxipnp_drivers');

% Determine if the driver name the user specified exists.
driverLocation = -1;
for i=1:2:length(driverInfo)
    if strcmpi(driverInfo{i}, driverName);
        driverLocation = i;
        break;
    end
end    

% Return if the driver is not found.
if driverLocation == -1
    errflag = true;
    lasterr('The specified VXIplug&play driver could not be found.', 'instrument:instrhwinfo:driverNotFound');
    return;
end

% Parse the driver.
fullDriverName = fullfile(driverInfo{driverLocation+1}, driverName);
driverDllName  = [lower(driverName) '_32.dll'];
model          = VXIPnPLoader.toBasicMatlabDriverModel([fullDriverName '.fp']);

% Construct the output.
out.Manufacturer   = char(model.getInstrumentManufacturer);
out.Model          = char(model.getInstrumentModel);
out.DriverVersion  = char(model.getInstrumentVersion);
out.DriverDllName  = fullfile(privateGetVXIPNPPath, 'bin',driverDllName); 

% -------------------------------------------------------------------
% Called by: instrhwinfo('ivi', 'logicalName')
function [out, errflag] = localGetIVIDriverInfo(logicalName)

% Initialize variables.
out     = [];
errflag = false;

% Determine if IVI is installed.
rootPath = privateGetIviPath;

if isempty(rootPath)
    % IVI is not installed.
    errflag = true;
    lasterr('The IVI Configuration Server could not be accessed or is not installed.', 'instrument:instrhwinfo:IVIInstall');
    return;
end

% Initialize the output structure.
out.DriverSession             = '';
out.HardwareAsset             = '';
out.SoftwareModule            = '';
out.IOResourceDescriptor      = '';
out.SupportedInstrumentModels = '';
out.ModuleDescription         = '';
out.ModuleLocation            = '';

% Create the store.
store = iviconfigurationstore;

% Find the information for the specified logical name.
lnInfo = get(store, 'LogicalName');
info = localFindIVIInfo(lnInfo, logicalName);

% The specified logical name could not be found.
if isempty(info)
    errflag = true;
    lasterr('Invalid logical name specified. Type ''instrhwinfo(''ivi'')'' for a list of valid logical names.', 'instrument:instrhwinfo:invalidLogicalName');
    return;
end

% If no driver session is specified for this logical name, return.
out.DriverSession = info.Session;
if isempty(out.DriverSession)
    return;
end

% Find the information about the driver session.
dsInfo = get(store, 'DriverSession');
info = localFindIVIInfo(dsInfo, out.DriverSession);

% Get the software module and hardware asset used by driver session.
out.SoftwareModule = info.SoftwareModule;
out.HardwareAsset  = info.HardwareAsset;

% Fill in the hardware asset information.
if ~isempty(out.HardwareAsset)
    haInfo = get(store, 'HardwareAsset');
    info = localFindIVIInfo(haInfo, out.HardwareAsset);
    
    if ~isempty(info)
        out.IOResourceDescriptor = info.IOResourceDescriptor;
    end
end

% Fill in the software module fields.
if ~isempty(out.SoftwareModule)
    smInfo = get(store, 'SoftwareModule');
    info = localFindIVIInfo(smInfo, out.SoftwareModule);

    if ~isempty(info)
        out.SupportedInstrumentModels = info.SupportedInstrumentModels;
        out.ModuleDescription         = info.Description;
        out.ModuleLocation            = info.ModulePath;
    end
end


% -----------------------------------------------------------------------
function out = localFindIVIInfo(allInfo, value)

% Initialize variables.
out   = [];
found = false;

% Search for the value.
for i=1:length(allInfo)
    if strcmpi(allInfo(i).Name, value)
        found = true;
        break;
    end
end

% The value was not found. Return empty.
if (found == false)
    return;
end

% Extract the value.
out = allInfo(i);


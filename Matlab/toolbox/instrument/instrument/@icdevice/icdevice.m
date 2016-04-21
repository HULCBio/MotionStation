function obj = icdevice(varargin)
%ICDEVICE Construct device object.
%
%   OBJ = ICDEVICE('DRIVER', HWOBJ) constructs a device object, OBJ. The
%   instrument specific information is defined in the MATLAB interface
%   instrument driver, DRIVER. Communication to the instrument is done
%   through the interface object, HWOBJ. An interface object is a serial
%   port, GPIB, VISA, TCPIP or UDP object. If the DRIVER does not exist or
%   HWOBJ is invalid, the device object will not be created.
%
%   Device objects may also be used with VXIplug&play and Interchangeable
%   Virtual Instrument (IVI) drivers. To use these drivers you must first
%   have a MATLAB instrument driver wrapper for the underlying VXIplug&play
%   or IVI driver.  If the MATLAB instrument driver wrapper does not
%   already exist, it may be created using MAKEMID or MIDEDIT. Note that
%   MAKEMID or MIDEDIT only needs to be used once to create the MATLAB
%   instrument driver wrapper.
%
%   OBJ = ICDEVICE('DRIVER') constructs a device object, OBJ using the
%   MATLAB instrument driver, DRIVER. DRIVER must be a MATLAB IVI
%   instrument driver, and the underlying IVI driver must be referenced
%   using a logical name.
%
%   OBJ = ICDEVICE('DRIVER', 'RSRCNAME') constructs a device object, OBJ
%   using the MATLAB instrument driver, DRIVER. DRIVER must be a MATLAB
%   VXIplug&play instrument driver or MATLAB IVI instrument driver.
%   Communication to the instrument is done through the resource specified
%   by RSRCNAME.  For example, all VXIplug&play, and many IVI drivers
%   require VISA resource names for RSRCNAME.
%
%   In order to communicate with the instrument, the device object must be
%   connected to the instrument with the CONNECT function.
%
%   When the device object is constructed, the object's Status property is
%   closed. Once the device object is connected to the instrument with the
%   CONNECT function, the Status property is configured to open.
%
%   OBJ = ICDEVICE('DRIVER', 'P1', V1, 'P2', V2, ...)
%   OBJ = ICDEVICE('DRIVER', 'RSRCNAME', 'P1', V1, 'P2', V2, ...)
%   OBJ = ICDEVICE('DRIVER', HWOBJ, 'P1', V1, 'P2', V2,...)
%
%   constructs a device object, OBJ, with the specified property
%   values. If an invalid property name or property value is specified, the
%   object will not be created.
%
%   Note that the param-value pairs can be in any format supported by the
%   SET function, i.e., param-value string pairs, structures, and
%   param-value cell array pairs.
%
%   Example using a MATLAB interface instrument driver:
%       % Construct a device object that has specific information about a
%       % Tektronix TDS 210 instrument. The instrument information is defined
%       % in a MATLAB interface driver.
%       g = gpib('ni', 0, 2);
%       d = icdevice('tektronix_tds210', g);
%
%       % Connect to the instrument
%       connect(d);
%
%       % List the oscilloscope settings that can be configured.
%       props = set(d);
%
%       % Get the current configuration of the oscilloscope.
%       values = get(d);
%
%       % Disconnect from the instrument and clean up.
%       disconnect(d);
%       delete([g d]);
%
%   Example using a MATLAB VXIplug&play instrument driver:
%       % This example assumes that the 'tktds5k' VXIplug&play driver is
%       % installed on your system.
%       
%       % This first step is only necessary if the MATLAB VXIplug&play
%       % instrument driver for the tktds5k does not exist on your system.
%       makemid('tktds5k', 'Tktds5kMATLABDriver');
%
%       % Construct a device object that uses the VXIplug&play driver.  The
%       % instrument is assumed to be located at a GPIB primary address of
%       % 2.
%       d = icdevice('Tktds5kMATLABDriver', 'GPIB0::2::INSTR');
%
%       % Connect to the instrument
%       connect(d);
%
%       % List the oscilloscope settings that can be configured.
%       props = set(d);
%
%       % Get the current configuration of the oscilloscope.
%       values = get(d);
%
%       % Disconnect from the instrument and clean up.
%       disconnect(d);
%       delete(d);

%
%   See also ICDEVICE/CONNECT, ICDEVICE/DISCONNECT, MAKEMID, MIDEDIT, INSTRHELP.
%

%   MP 10-10-02
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.14 $  $Date: 2004/03/24 20:39:57 $

% Create the parent class.
try
    parent = instrument('icdevice');
catch
    rethrow(lasterror);
end

% Get the instrument package.
try
    instrPackage = findpackage('instrument');
catch
end

% If instrument package does not exist, create it.
if isempty(instrPackage)
    instrPackage = schema.package('instrument');
end

% Initialize variables.
props = {};

% Parse inputs.
switch (nargin)
    case 0
        errorID = 'instrument:icdevice:toofewargs';
        error(errorID, instrgate('privateMessageLookup', errorID));
    case 1
        hwobj = varargin{1};
        if (isa(hwobj, 'com.mathworks.toolbox.instrument.device.ICDeviceHelper'))
            obj.jobject = handle(hwobj);
            obj.type = 'icdevice';
            obj.constructor = 'icdevice';
            obj = class(obj, 'icdevice', parent);
            return;
        elseif (findstr('ICDevice', class(hwobj)))
            obj.jobject = handle(hwobj);
            obj.type = 'icdevice';
            obj.constructor = 'icdevice';
            obj = class(obj, 'icdevice', parent);
            return;
        else
            % MATLAB IVI instrument driver using a logical name.
            driver = varargin{1};
            hwobj = '';  % Indicates logical name in local functions.
        end
    case 2
        % Creating a device object that uses a MATLAB instrument driver.
        driver = varargin{1};
        hwobj  = varargin{2};
    otherwise
        driver = varargin{1};
        hwobj  = varargin{2};
        if isa(hwobj, 'instrument')
            % Creating a device object that uses a MATLAB instrument driver
            % with property values specified.
            props  = varargin(3:end);
        end
end

% Error checking.
if ~ischar(driver)
    errorID = 'instrument:icdevice:invalidDriver';
    error(errorID, instrgate('privateMessageLookup', errorID));
end

% Error checking if creating a device object that uses a MATLAB instrument
% driver.
if (~isempty(hwobj) && ~ischar(hwobj))
    if ~isa(hwobj, 'icinterface')
        errorID = 'instrument:icdevice:invalidType';
        error(errorID, instrgate('privateMessageLookup', errorID));
    end

    if (length(hwobj) > 1)
        errorID = 'instrument:icdevice:invalidLength';
        error(errorID, instrgate('privateMessageLookup', errorID));
    end

    if ~isvalid(hwobj)
        errorID = 'instrument:icdevice:invalidobj';
        error(errorID, instrgate('privateMessageLookup', errorID));
    end
end

% Store the warning state. A warning could occur if there is a problem with
% the driver - on object creation.
warnState = warning('backtrace', 'off');

[mdd, errflag] = localFindMATLABInstrumentDriverPath(driver);

if errflag
    errorID = 'instrument:icdevice:driverNotFound';
    lasterr('The specified MATLAB instrument driver could not be found.  DRIVER must be on the MATLAB path.', errorID);
    rethrow(lasterror);
end

% Create the object.
if ~ischar(hwobj)
    [obj.jobject, errflag] = localCreateMWIDObject(driver, hwobj);
else
    [obj.jobject, errflag] = localCreateWithMatlabInstrumentDriver(mdd, hwobj);
end

if ~errflag && isempty(obj.jobject)
    errflag = true;
    errorID = 'instrument:icdevice:invalidDriver';
    lasterr(['The IVI or VXIplug&play driver referenced in ' driver ' could not be found.'], errorID);
end

if errflag
    rethrow(lasterror);
end

connect(obj.jobject, instrPackage.DefaultDatabase, 'up');

% Assign the type and constructor.
obj.type        = 'icdevice';
obj.constructor = 'icdevice';

% Assign the class tag.
obj = class(obj, 'icdevice', parent);

% Pass the OOPs object to java. Used for callbacks.
obj.jobject(1).setMATLABObject(obj);

% Determine what group objects are supported by the device object.
jobj = java(obj.jobject);
groups = jobj.getPropertyGroups;

for i = 0:groups.size-1
    dc = jobj.getJGroup(groups.elementAt(i));
    dcGroup = icgroup(dc);
    jobj.assignMATLABGroup(groups.elementAt(i), dcGroup, localArray2Cell(dcGroup));
end

% Try configuring the object properties.
if ~isempty(props)
    try
        set(obj, props{:});
    catch
        delete(obj);
        instrgate('privateFixError');
        rethrow(lasterror);
    end
end

% Execute initialization code.
try
    code = char(getCreateInitializationCode(jobj));
    instrgate('privateEvaluateCode', obj, code);
catch
    lasterr(sprintf(['An error occurred while executing the driver create initialization code.\n'...
        '%s\nIf the error is not an instrument error, use MIDEDIT to inspect the driver.'...
        ], lasterr), ...
        'instrument:icdevice:opfailed');
    rethrow(lasterror);
end

% Restore the warning state.
warning(warnState);

% -------------------------------------------------------------------------
% Create a device object that uses a MATLAB Instrument Driver.
function [obj, errflag] = localCreateMWIDObject(driver, hwobj)

% Initialize variables.
obj     = [];

% Find the location of the MATLAB instrument driver.
[driver, errflag] = localFindMATLABInstrumentDriverPath(driver);

if (errflag == true)
    return;
end

% Create the object.
try
    obj = handle(com.mathworks.toolbox.instrument.device.ICDeviceObject.getInstance(driver, hwobj, java(igetfield(hwobj, 'jobject'))));
catch
    errflag = true;
    errorID = 'instrument:icdevice:invalidDriver';
    lasterr(lasterr, errorID);
end

% -------------------------------------------------------------------------
% Find the location of the MATLAB instrument driver.
function [driver, errflag] = localFindMATLABInstrumentDriverPath(driver)

% Initialize variables.
errflag = false;

% Find the driver.
[pathstr, name, ext] = fileparts(driver);
if isempty(ext)
    driver = [driver '.mdd'];
end

if isempty(pathstr)
    driverWithPath = which(driver);
    % If found driver, use it.
    if ~isempty(driverWithPath)
        driver = driverWithPath;
    end
end

% If not on MATLAB path, check the drivers directory.
pathstr = fileparts(driver);
if isempty(pathstr)
    driver = fullfile(matlabroot,'toolbox','instrument','instrument','drivers', driver);
end

% Verify that the driver exists.
if ~exist(driver, 'file')
    errflag = true;
    errorID = 'instrument:icdevice:driverNotFound';
    lasterr(instrgate('privateMessageLookup', errorID), errorID);
    return;
end

% -------------------------------------------------------------------------
% Load a VXIplug&play driver library. Returns false if the driver is not
% found. Throws error if a problem occurs loading the driver.
function [driverFound, errflag] = localLoadVXIPnPLibrary(driverName)

driverFound = true;
errflag = false;

prefix = instrgate('privateGetVXIPNPPath');

if (ispc)
    binary = fullfile(prefix, 'bin', [driverName '_32.dll']);
else
    binary = fullfile(prefix, 'bin', [driverName '.so']);
end

if (~exist(binary, 'file'))
    driverFound = false;
    return;
end

includePath = fullfile(prefix, 'include');
includeFile = fullfile(includePath, [driverName '.h']);

visaIncludePath = instrgate('privateGetIviPath');

if (~isempty(visaIncludePath))
    if (exist(fullfile(visaIncludePath, 'include', 'visa.h'), 'file'))
        visaIncludePath = fullfile(visaIncludePath, 'include');
    else
        visaIncludePath = localToolboxVisaPath;
    end
else
    visaIncludePath = localToolboxVisaPath;
end

if (~libisloaded(driverName))
    errflag = localLoadLib(driverName, binary, includeFile, includePath, visaIncludePath);
end

% -------------------------------------------------------------------------
% Load an IVI-C driver library. Returns false if the driver is not found.
% Throws error if a problem occurs loading the driver.
function [driverFound, errflag] = localLoadIviCLibrary(driverName)

driverFound = true;
errflag = false;

prefix = instrgate('privateGetIviPath');

binary = fullfile(prefix, 'Bin', [driverName '_32.dll']);

if (~exist(binary, 'file'))
    binary = fullfile(prefix, 'Bin', [driverName '.dll']);
end

if (~exist(binary, 'file'))
    driverFound = false;
    return;
end

includePath = fullfile(prefix, 'Include');
includeFile = fullfile(includePath, [driverName '.h']);

visaIncludePath = instrgate('privateGetVXIPNPPath');

if (~isempty(visaIncludePath))
    if (exist(fullfile(visaIncludePath, 'include', 'visa.h'), 'file'))
        visaIncludePath = fullfile(visaIncludePath, 'include');
    else
        visaIncludePath = localToolboxVisaPath;
    end
else
    visaIncludePath = localToolboxVisaPath;
end

if (~libisloaded(driverName))
    errflag = localLoadLib(driverName, binary, includeFile, includePath, visaIncludePath);
end

% -------------------------------------------------------------------------
function visaIncludePath = localToolboxVisaPath

visaIncludePath = '';

root = fileparts(which('instrgate'));

if (~isempty(root))
    visaIncludePath = fullfile(root, 'private');
end

% -------------------------------------------------------------------------
% localLoadLib is used by both IVI-C and VXIPlug&play once their respective
% drivers and headers have been found.
function errflag = localLoadLib(driverName, binary, includeFile, primaryPath, secondaryPath)

% Some drivers advertise functions in the header that are not in the actual
% library.
s1 = warning('off', 'MATLAB:loadlibrary:functionnotfound');
s2 = warning('off', 'MATLAB:loadlibrary:typenotfound');
s3 = warning('off', 'MATLAB:loadlibrary:cppoutput');
errflag = false;

lastwarn('');

try
    if (isempty(secondaryPath))
        loadlibrary(binary, includeFile, 'alias', driverName, 'includepath', primaryPath);
    else
        loadlibrary(binary, includeFile, 'alias', driverName, ...
            'includepath', primaryPath, 'includepath', secondaryPath);
    end
catch
    errflag = true;
end

warning(s1.state, 'MATLAB:loadlibrary:functionnotfound');
warning(s2.state, 'MATLAB:loadlibrary:typenotfound');
warning(s3.state, 'MATLAB:loadlibrary:cppoutput');

[msg, id] = lastwarn;

if (~isempty(msg))
    if (strcmp(id, 'MATLAB:loadlibrary:typenotfound') == 1)
        warning('instrument:icdevice:missinglibrarydata', ...
            'A datatype used by the library could not located. Some or\nall driver functions may have failed to load. Verify that\nall required header files for the driver are available.');
    end
    if (strcmp(id, 'MATLAB:loadlibrary:cppoutput') == 1)
        warning('instrument:icdevice:preprocessorerror', ...
            'An error occurred loading the driver library. Some or all\ndriver functions may have failed to load. Verify that all\nrequired header files for the driver are available.');
    end
end


% -------------------------------------------------------------------------
% Attempt to locate an IVI-COM driver from a logical name or an explicit
% driver reference.  An error occurs only if a driver is actually located
% but fails to load.
function [progid, comobj, instrType, errflag] = localIviFromUnknown(arg1, arg2)

if (isempty(arg2))
    % Single argument form is a logical name.
    [progid, comobj, instrType, errflag] = localIviFromLogicalName(arg1);
else
    % Two arguments indicate a program id and a resource name.
    [comobj, instrType, errflag] = localIviFromProgramID(arg1);
    progid = arg1;
end

% -------------------------------------------------------------------------
% Load an IVI driver using the configuration server and a logical name.
function [progid, comobj, instrType, errflag] = localIviFromLogicalName(logicalName)

comobj = [];
progid = '';
instrType = '';
errflag = false;

try
    h = actxserver('IviConfigServer.IviConfigStore.1');
    h.Deserialize(h.MasterLocation);
    
    logicalNameRef = [];
    logicals = get(h, 'LogicalNames');

    for idx = 1:logicals.Count
        if (strcmpi(logicalName, logicals.Item(idx).Name) == 1)
            logicalNameRef = logicals.Item(idx);
            break;
        end
    end
    
    swm = logicalNameRef.Session.SoftwareModule;
    progid = swm.ProgID;
    instrType = swm.Prefix;

    for idx = 1:swm.PublishedAPIs.Count
        api = swm.PublishedAPIs.Item(idx, 0, 0, 'IVI-COM');
        if (strcmp('IviDriver', api.Name) ~= 1)
            instrType = api.Name;
            break;
        end
    end
catch
    % Failed to locate a program id through the configuration server for a
    % given logical name.  May or may not be an error to calling function.
    return;
end

try
    comobj = actxserver(progid);
catch
    % A potentially valid driver was identified, however the load failed.
    % This is a failure.
    errflag = true;
end

% -------------------------------------------------------------------------
% Load an IVI driver using a program id and resource name.  Does not use
% the IVI Configuration server.
function [comobj, instrType, errflag] = localIviFromProgramID(progid)

comobj = [];
instrType = [];
errflag = false;

try
    comobj = actxserver(progid);
catch
    return;
end

if (isempty(comobj))
    return;
end

try
    idx = find(progid == '.');
    if (~isempty(idx))
        instrType = progid(1:(idx(1) - 1));
    else
        instrType = progid;
    end
catch
    errflag = true;
end

% -------------------------------------------------------------------------
% Load a MATLAB instrument driver file that is not of type MID.
function [obj, errflag] = localCreateWithMatlabInstrumentDriver(fullDriverName, resourceName)
import com.mathworks.toolbox.instrument.device.ICDeviceObject;
import com.mathworks.toolbox.instrument.device.drivers.xml.Parser;

obj = [];
errflag = false;

try
    parser = Parser(fullDriverName);
    parser.parse;
catch
    errflag = true;
    return;
end

type = parser.getDriverType;

switch (char(type))
    case char(Parser.VXIPNP)
        if (~ispc)
            errflag = true;
            errorID = 'instrument:icdevice:platformNotSupported';
            lasterr('VXIplug&play is supported on the Windows platform only.', errorID);
            return;
        end

        try
            obj = handle(ICDeviceObject.getInstance(parser, resourceName));
            vxiDriverFileName = get(obj, 'DriverName');
            driverFound = localLoadVXIPnPLibrary(vxiDriverFileName);
            if (~driverFound)
                localDispose(obj);
                errflag = true;
                errorID = 'instrument:icdevice:invalidDriver';
                lasterr(sprintf('The VXIplug&play driver referenced in %s\n cannot be found.', fullDriverName),...
                    errorID);
            end
        catch
            localDispose(obj);
            errflag = true;
            errorID = 'instrument:icdevice:invalidDriver';
            lasterr(lasterr, errorID);
            return;
        end

    case char(Parser.IVI_C)
        if (~ispc)
            errflag = true;
            errorID = 'instrument:icdevice:platformNotSupported';
            lasterr('IVI-C is supported on the Windows platform only.', errorID);
            return;
        end

        try
            obj = handle(ICDeviceObject.getInstance(parser, resourceName));
            ivicDriverFileName = get(obj, 'DriverName');
            driverFound = localLoadIviCLibrary(ivicDriverFileName);
            if (~driverFound)
                localDispose(obj);
                errflag = true;
                errorID = 'instrument:icdevice:invalidDriver';
                lasterr(sprintf('The IVI-C driver referenced in %s\n cannot be found.', fullDriverName),...
                    errorID);
            end
        catch
            localDispose(obj);
            errflag = true;
            errorID = 'instrument:icdevice:invalidDriver';
            lasterr(lasterr, errorID);
            return;
        end
        
    case char(Parser.IVI_COM)
        if (~ispc)
            errflag = true;
            errorID = 'instrument:icdevice:platformNotSupported';
            lasterr('IVI-COM is supported on the Windows platform only.', errorID);
            return;
        end

        logicalName = char(parser.getDriverName);
        
        if (strncmpi(logicalName, 'Lecroy.ActiveDSOCtrl', 20) == 1 || ...
            strncmpi(logicalName, 'LeCroy.XStreamDSO', 17) == 1 )
            try
                comobj = actxserver(logicalName);
                obj = handle(ICDeviceObject.getInstance(parser, resourceName, comobj, false));
            catch
                localDispose(obj);
                errflag = true;
                errorID = 'instrument:icdevice:invalidDriver';
                lasterr(lasterr, errorID);
                return;
            end
            return;
        end

        [progid, comobj, instrType, errflag] = localIviFromUnknown(logicalName, resourceName);

        if (errflag || isempty(comobj))
            errflag = true;
            errorID = 'instrument:icdevice:driverNotLoaded';
            if (isempty(resourceName))
                lasterr(['The logical name ''' logicalName ''' referenced in ' fullDriverName ' is not valid or does not point to a valid software module.'], errorID);
            else
                lasterr(['The IVI-COM driver ''' logicalName ''' reference in ' fullDriverName ' could not be instantiated.'], errorID);
            end
            return;
        end

        try
            obj = handle(ICDeviceObject.getInstance(parser, resourceName, comobj, true));
        catch
            localDispose(obj);
            errflag = true;
            errorID = 'instrument:icdevice:invalidDriver';
            lasterr(lasterr, errorID);
            return;
        end
    case char(Parser.MID)
        errorID = 'instrument:icdevice:driverNotLoaded';
        lasterr('The specified driver requires an interface object as the second argument.', errorID);
        errflag = true;
        return;
    otherwise
        errorID = 'instrument:icdevice:unsupportedDriverType';
        lasterr(['The specified driver is an unknown or unsupported type: ' char(type)], errorID);
        errflag = true;
        return;
end

% -------------------------------------------------------------------------
% Convert an array of objects to a cell array.
function out = localArray2Cell(obj)

out = cell(1, length(obj));
for i = 1:length(obj)
    out{i} = obj(i);
end

% -------------------------------------------------------------------------
% Dispose of an invalid java device object.
function localDispose(obj)

if (~isempty(obj))
    dispose(obj);
    disconnect(obj);
    cleanup(obj);
end

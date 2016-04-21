function makemid(driver, varargin)
% MAKEMID Convert a driver to MATLAB instrument driver format.
%
%   MAKEMID('DRIVER') searches through known driver types for DRIVER and creates
%   a MATLAB instrument driver representation of the driver. Known driver types
%   include VXIplug&play, IVI-C and IVI-COM. The MATLAB instrument driver will
%   be saved in  the current working directory as DRIVER.MDD
%
%   The MATLAB instrument driver can then be modified using MIDEDIT to customize
%   the  driver behavior, and may be used to instantiate a device object using
%   ICDEVICE.
%
%   MAKEMID('DRIVER', 'FILENAME') saves the newly created MATLAB instrument
%   driver using the name and path specified by FILENAME.
% 
%   MAKEMID('DRIVER', 'TYPE') and MAKEMID('DRIVER', 'FILENAME', 'TYPE') override
%   the default search order and only look for drivers of type TYPE. Valid
%   types are vxiplug&play, ivi-c, and ivi-com.
%
%   MAKEMID('DRIVER', 'TYPE', 'INTERFACE') and MAKEMID('DRIVER', 'FILENAME',
%   'TYPE', 'INTERFACE') specifies the IVI-COM driver interface to be used for
%   the object. TYPE must be ivi-com'. The driver root interface is serched for
%   the named interface. For example, if the driver supports the IIviScope
%   interface, an INTERFACE value 'IIviScope' will result in a device object
%   that only contains the IVIScope class-compliant properties and methods.
%
%    Examples:
%        makemid('hp34401');
%        makemid('tktds5k', 'C:\MyDrivers\tektronix_5k.mdd');
%        makemid('tktds5k', 'ivi-c');
%        makemid('MyIviLogicalName');
%
%    See also ICDEVICE, MIDEDIT.

%   PE 12-01-03   
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.4 $  $Date: 2004/03/24 20:40:04 $


errorID = 'instrument:makemid:conversionError';

error(nargchk(1, 4, nargin, 'struct'))

if (~ischar(driver))
    error(errorID, 'DRIVER must be a string. Type ''help makemid'' for valid arguments.');
end

interface = '';
drivertype = '';

switch nargin
    case 1
        idx = find(double(driver) == '.');
        if (~isempty(idx))
            filename = fullfile(pwd, [driver(idx+1:end) '.mdd']);
        else
            filename = fullfile(pwd, [driver '.mdd']);
        end
    case 2
        if (~ischar(varargin{1}))
            error(errorID, 'TYPE must be a string. Type ''help makemid'' for valid arguments.');
        end
        if (localIsDriverType(varargin{1}))
            idx = find(double(driver) == '.');
            if (~isempty(idx))
                filename = fullfile(pwd, [driver(idx+1:end) '.mdd']);
            else
                filename = fullfile(pwd, [driver '.mdd']);
            end
            drivertype = varargin{1};
        else
            filename = varargin{1};
        end
    case 3
        if (~ischar(varargin{1}))
            error(errorID, 'TYPE or FILENAME must be a string. Type ''help makemid'' for valid arguments.');
        end
        if (~ischar(varargin{2}))
            error(errorID, 'TYPE or INTERFACE must be a string. Type ''help makemid'' for valid arguments.');
        end
        if (localIsDriverType(varargin{2}))
            drivertype = varargin{2};
            filename = varargin{1};
            idx = find(double(filename) == '.');
            if (isempty(idx))
                filename = [filename '.mdd'];
            end
        else
            drivertype = varargin{1};
            interface = varargin{2};
            idx = find(double(driver) == '.');
            if (~isempty(idx))
                filename = fullfile(pwd, [driver(idx+1:end) '.mdd']);
            else
                filename = fullfile(pwd, [driver '.mdd']);
            end
        end
    case 4
        filename = varargin{1};
        idx = find(double(filename) == '.');
        if (isempty(idx))
            filename = [filename '.mdd'];
        end
        drivertype = varargin{2};
        interface = varargin{3};
end

if (~ischar(filename))
    error(errorID, 'FILENAME must be a string. Type ''help makemid'' for valid arguments.');
end

if (~ischar(interface))
    error(errorID, 'INTERFACE must be a string. Type ''help makemid'' for valid arguments.');
end

if (exist(filename, 'dir'))
    error(errorID, 'FILENAME can not be a directory. Type ''help makemid'' for valid arguments.');
end

if (isempty(strfind(filename, '.')))
    filename = [filename '.mdd'];
end

if (~isempty(interface) && ~isempty(drivertype) && ~strcmpi(drivertype, 'ivi-com'))
     error(errorID, 'INTERFACE can only be specified when TYPE is ivi-com. Type ''help makemid'' for valid arguments.');
end

model = [];

try
    if (~isempty(drivertype))
        switch lower(drivertype)
            case 'vxiplug&play'
                model = localConvertFromVxi(driver, interface);
            case 'ivi-c'
                model = localConvertFromIviC(driver, interface);
            case 'ivi-com'
                model = localConvertFromIviCom(driver, interface);
        end
    else
        model = localConvertFromIviCom(driver, interface);

        if isempty(model)
            model = localConvertFromIviC(driver, interface);
        end

        if isempty(model)
            model = localConvertFromVxi(driver, interface);
        end
    end
catch
    error(errorID, lasterr);
end

if (isempty(model))
    error(errorID, 'The specified driver could not be loaded.');
end

try
    writer = com.mathworks.toolbox.instrument.device.guiutil.midtool.DriverFileWriter(model);
    writer.writeXML(filename);
catch
    error(errorID, sprintf('An error occurred writing the MATLAB instrument driver.\n%s', lasterr));
end

if nargout
    varargout{1} = model;
end

%-------------------------------------------------------------------------------
%
function isdrivertype = localIsDriverType(str)

isdrivertype =  strmatch(lower(str), strvcat('vxiplug&play','ivi-c','ivi-com'), 'exact');

%-------------------------------------------------------------------------------
%
function model = localConvertFromIviCom(driver, interface)

model = [];

[parser, model] = instrgate('privateDeviceConstructorHelper', ...
    'iviParserModelFromLogical', driver, interface);

if (isempty(model))
    [parser, model] = instrgate('privateDeviceConstructorHelper', ...
        'iviParserModelFromProgramId', driver, interface);
end

%-------------------------------------------------------------------------------
%
function model = localConvertFromIviC(driver, interface)
import com.mathworks.toolbox.instrument.device.drivers.vxipnp.VXIPnPLoader;

model = [];

prefix = instrgate('privateGetIviPath');

if (isempty(prefix))
    return
end;

frontPanelFile = fullfile(prefix, 'Drivers', driver, [driver '.fp']);

if (exist(frontPanelFile, 'file'))
    model = VXIPnPLoader.toDriverModel(frontPanelFile, true);
end

%-------------------------------------------------------------------------------
%
function model = localConvertFromVxi(driver, interface)
import com.mathworks.toolbox.instrument.device.drivers.vxipnp.VXIPnPLoader;

model = [];

prefix = instrgate('privateGetVXIPNPPath');

if (isempty(prefix))
    return
end;

frontPanelFile = fullfile(prefix, driver, [driver '.fp']);

if (exist(frontPanelFile, 'file'))
    model = VXIPnPLoader.toDriverModel(frontPanelFile);
end

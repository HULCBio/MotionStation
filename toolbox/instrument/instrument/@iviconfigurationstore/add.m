function add(obj, varargin)
%ADD Add entry to IVI conifiguration store object.
%
%   ADD(OBJ, 'TYPE', 'NAME', ...) adds a new entry TYPE to the IVI
%   configuration store object, OBJ with name, NAME. If an entry of
%   TYPE with NAME exists an error will occur. Based on TYPE additional
%   arguments are required. TYPE can be HardwareAsset, DriverSession or
%   LogicalName.
%
%   ADD(OBJ, 'DriverSession', 'NAME', 'MODULENAME', 'HARDWAREASSETNAME',
%   'P1', 'V1',...) adds a new driver session entry to the IVI
%   configuration  store object, OBJ with name, NAME, using the specified
%   software module name, MODULENAME and hardware asset name,
%   HARDWAREASSETNAME. Optional param-value pairs may be included. All
%   on/off properties are assumed if not specified. Valid parameters for a
%   DriverSession  are:
%
%     Param Name            Value         Description
%     ----------            ------        ------------
%     Description           any string    Description of driver session
%     VirtualNames          struct        A struct array containing virtual
%                                         name mappings.
%     Cache                 on/off        Enable caching if the driver supports it.
%     DriverSetup           any string    This value is software module dependent.
%     InterchangeCheck      on/off        Enable driver interchangeability
%                                         checking if supported.
%     QueryInstrStatus      on/off        Enable instrument status querying
%                                         by the driver.
%     RangeCheck            on/off        Enable extended range checking by
%                                         the driver if supported.
%     RecordCoercions       on/off        Enable recording of coercions by
%                                         the driver if supported.
%     Simulate              on/off        Enable simulation by the driver.
%
%   ADD(OBJ, 'HardwareAsset', 'NAME', 'IORESOURCE', 'P1', 'V1') adds a new
%   hardware asset entry to the IVI configuration store object, OBJ, with
%   name, NAME and resource descriptor, IORESOURCE. Optional param-value
%   pairs may be included. Valid parameters for a HardwareAsset are:
%
%     Param Name            Value         Description
%     ----------            ------        ------------
%     Description           any string    Description of hardware asset
%
%   ADD(OBJ, 'LogicalName', 'NAME', 'SESSIONNAME', 'P1', 'V1') adds a new
%   logical name entry to the IVI configuration store object, OBJ, with
%   name, NAME and driver session name, SESSIONNAME. Optional param-value
%   pairs may be included. Valid parameters for logical names are:
%
%     Param Name            Value         Description
%     ----------            ------        ------------
%     Description           any string    Description of logical name
%
%   ADD(OBJ, S) where S is a structure whose field names are the entry
%   parameter names, adds an entry to IVI configuration store object, OBJ,
%   of the specified type with the values contained in the structure. S 
%   must have a Type field which can be DriverSession, HardwareAsset or
%   LogicalName. S must also have a Name field which is the name of the
%   driver session, hardware asset or logical name to be added.
%
%   Additions made to the configuration store object, OBJ, can be saved
%   to the configuration store data file with the COMMIT function.
%
%   Examples:
%       % Construct IVI configuration store object, c.
%       c = iviconfigurationstore;
%
%       % Add a hardware asset with name, gpib1, and resource description
%       % GPIB0::1::INSTR.
%       add(c, 'HardwareAsset', 'gpib1', 'GPIB0::1::INSTR');
%
%       % Add a driver session with name, S1 that uses the TekScope software
%       % module and the hardware asset with name gpib1.
%       add(c, 'DriverSession', 'S1', 'TekScope', 'gpib1');
%
%       % Add a logical name to configuration store object, c, with name,
%       % MyScope, driver session name, S1 and description, A logical name.
%       add(c, 'LogicalName','MyScope', 'S1', 'Description', 'A logical name');
%
%       % Add a hardware asset with name, gpib3, and resource description,
%       % GPIB0::3::ISNTR.
%       s.Name = 'gpib3';
%       s.IOResourceDescriptor = 'GPIB0::3::INSTR'
%       add(c, s);
%
%       % Save changes to the IVI configuration store data file.
%       commit(c);
%
%   See also IVICONFIGURATIONSTORE/UPDATE, IVICONFIGURATIONSTORE/REMOVE,
%   IVICONFIGURATIONSTORE/COMMIT.
%

%   PE 10-01-03
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/01/16 19:59:27 $

error(nargchk(2, inf, nargin));

errflag = false;

arg = varargin{1};

if isstruct(arg)
    if (nargin > 2)
        error('iviconfigurationstore:add:tooManyArgs', 'Too many input arguments.');
    end
    for idx = 1:length(arg)
        entry = arg(idx);
        if isfield(entry, 'Type') && isfield(entry, 'Name')
            if (~privateVerifyIsMutableEntry(entry.Type))
                error('iviconfigurationstore:add:invalidArgs', 'Invalid Type field in STRUCT.');
            end

            [entry, errflag] = privateVerifyStruct(entry);
            if (errflag)
                error('iviconfigurationstore:update:invalidArgs', lasterr);
            end

            errflag = localAddEntry(obj.cobject, entry);
            if (errflag)
                error('iviconfigurationstore:add:addFailed', lasterr);
            end
        else
            error('iviconfigurationstore:add:invalidArgs',...
                'Invalid STRUCT specified. STRUCT must have ''Type'' and ''Name'' fields.');
        end
    end
elseif ischar(arg)
    error(nargchk(4, inf, nargin));

    if (~privateVerifyIsMutableEntry(arg))
        error('iviconfigurationstore:add:invalidArgs', 'Invalid TYPE.');
    end


    if (~ischar(varargin{2}))
        error('iviconfigurationstore:add:invalidArgs', 'NAME must be a string.');
    end

    entry = privateCreateStruct(arg, varargin{2});

    switch entry.Type
        case 'HardwareAsset'
            entry.IOResourceDescriptor = varargin{3};

            [entry, errflag] = privateFillStruct(entry, varargin{4:end});
            if (errflag)
                error('iviconfigurationstore:add:invalidEntry', lasterr);
            end

            errflag = localAddEntry(obj.cobject, entry);
            if (errflag)
                error('iviconfigurationstore:add:addFailed', lasterr);
            end
        case 'DriverSession'
            error(nargchk(5, inf, nargin));

            entry.SoftwareModule = varargin{3};
            entry.HardwareAsset = varargin{4};

            [entry, errflag] = privateFillStruct(entry, varargin{5:end});
            if (errflag)
                error('iviconfigurationstore:add:invalidEntry', lasterr);
            end

            errflag = localAddEntry(obj.cobject, entry);
            if (errflag)
                error('iviconfigurationstore:add:addFailed', lasterr);
            end
        case 'LogicalName'
            entry.Session = varargin{3};

            [entry, errflag] = privateFillStruct(entry, varargin{4:end});
            if (errflag)
                error('iviconfigurationstore:add:invalidEntry', lasterr);
            end

            errflag = localAddEntry(obj.cobject, entry);
            if (errflag)
                error('iviconfigurationstore:add:addFailed', lasterr);
            end
    end
else
    error('iviconfigurationstore:add:invalidArgs', 'Invalid TYPE or STRUCT.');
end

% ------------------------------------------------------------------------
% Add a new entry to the appropriate configuration store collection.
% ------------------------------------------------------------------------
function errflag = localAddEntry(cobject, item)

errflag = false;

collection = cobject.([item.Type 's']);

if isempty(collection) || isstruct(collection)
    return;
end

entry = privateGetNamedEntry(collection, item.Name, true);

if (~isempty(entry))
    errflag = true;
    lasterr('An entry with the same name exists. Use update to alter an existing entry.');
    return;
end

entry = actxserver(['IviConfigServer.Ivi' item.Type]);

[entry, errflag] = privateUpdateEntry(entry, cobject, item);

if (errflag)
    return;
end

collection.Add(entry);

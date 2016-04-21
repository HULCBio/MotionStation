function update(obj, varargin)
%UPDATE Update entry in IVI configuration store object.
%
%   UPDATE(OBJ, 'TYPE', 'NAME', P1, V1, ...) updates an entry of type, 
%   TYPE, with name, NAME, in IVI configuration store object, OBJ, using 
%   the specified param-value pairs. TYPE can be HardwareAsset,
%   DriverSession, or LogicalName.
%
%   If an entry of TYPE with NAME does not exist, an error will occur.
%
%   Valid parameters for a DriverSession are:
%
%     Param Name            Value         Description
%     ----------            ------        ------------
%     Name                  string        A unique name for the driver session.
%     SoftwareModule        string        The name of a software module entry in the configuration store.
%     HardwareAsset         string        The name of a hardware asset entry in the configuration store.
%     VirtualNames          struct        A struct array containing virtual name mappings.
%     Description           any string    Description of driver session
%     Cache                 on/off        Enable caching if the driver supports it.
%     DriverSetup           any string    This value is software module dependent.
%     InterchangeCheck      on/off        Enable driver interchangeability checking if supported.
%     QueryInstrStatus      on/off        Enable instrument status querying by the driver.
%     RangeCheck            on/off        Enable extended range checking by the driver if supported.
%     RecordCoercions       on/off        Enable recording of coercions by the driver if supported.
%     Simulate              on/off        Enable simulation by the driver.
%
%   Valid parameters for a HardwareAsset are:
%
%     Param Name            Value         Description
%     ----------            ------        ------------
%     Name                  string        A unique name for the hardware asset.
%     Description           any string    Description of the hardware asset.
%     IOResourceDescriptor  string        The I/O address of the hardware asset.
%
%   Valid parameters for a LogicalName are:
%
%     Param Name            Value         Description
%     ----------            ------        ------------
%     Name                  string        A unique name for the logical name.
%     Description           any string    Description of hardware asset
%     Session               string        The name of a driver session entry in the configuration store.
%
%   UPDATE(OBJ, STRUCT) updates the entry using the fields in STRUCT. If an
%   entry with the type and name field in STRUCT does not exist, an error
%   will occur. Note that the Name field cannot be updated using this syntax.
%
%   Examples:
%       c = iviconfigurationstore;
%       update(c, 'DriverSession', 'ScopeSession', 'Description', 'A session.');
%
%   See also IVICONFIGURATIONSTORE/ADD, IVICONFIGURATIONSTORE/REMOVE,
%   IVICONFIGURATIONSTORE/COMMIT.
%

%   PE 10-01-03
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.4 $  $Date: 2004/02/01 21:55:12 $

error(nargchk(2, inf, nargin));

arg = varargin{1};

if isstruct(arg)
    for idx = 1:length(arg)
        entry = arg(idx);
        if isfield(entry, 'Type') && isfield(entry, 'Name')
            if (~privateVerifyIsMutableEntry(entry.Type))
                error('iviconfigurationstore:update:invalidArgs', 'Invalid Type field in STRUCT.');
            end
            
            [entry, errflag] = privateVerifyStruct(entry);
            if (errflag)
                error('iviconfigurationstore:update:invalidArgs', lasterr);
            end
            
            errflag = localUpdateEntry(obj.cobject, entry.Name, entry);
            if (errflag)
                error('iviconfigurationstore:update:updateFailed', lasterr);
            end

        else
            error('iviconfigurationstore:update:invalidArgs',...
                'Invalid STRUCT specified. STRUCT must have ''Type'' and ''Name'' fields.');
        end
    end
elseif ischar(arg)
    error(nargchk(4, inf, nargin));

    if (~privateVerifyIsMutableEntry(arg))
        error('iviconfigurationstore:update:invalidArgs', 'Invalid TYPE.');
    end

    if (~ischar(varargin{2}))
        error('iviconfigurationstore:update:invalidArgs', 'NAME must be a string.');
    end

    entry.Type = arg;
    [entry, errflag] = privateFillStruct(entry, varargin{3:end});
    if (errflag)
        error('iviconfigurationstore:update:invalidArgs', lasterr);
    end
    
    errflag = localUpdateEntry(obj.cobject, varargin{2}, entry);
    if (errflag)
        error('iviconfigurationstore:update:updateFailed', lasterr);
    end
else
    error('iviconfigurationstore:update:invalidArgs', 'Invalid TYPE or STRUCT.');
end


% -------------------------------------------------------------------------
% Update the configuration store entry.
% -------------------------------------------------------------------------
function errflag = localUpdateEntry(cobject, name, item)

errflag = false;

collection = cobject.([item.Type 's']);

if isempty(collection) || isstruct(collection)
    return;
end

entry = privateGetNamedEntry(collection, name, true);

if (isempty(entry))
    lasterr([name ' is not a valid ' item.Type ' entry.']);
    errflag = true;
    return;
end

[unusedEntry, errflag] = privateUpdateEntry(entry, cobject, item);

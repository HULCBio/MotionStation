function remove(obj, varargin)
%REMOVE Remove entry from IVI configuration store object.
%
%   REMOVE(OBJ, 'TYPE', 'NAME') removes an entry of type, TYPE, with name,
%   NAME, from the IVI configuration store object, OBJ. TYPE can be
%   HardwareAsset, DriverSession or LogicalName.
%
%   If an entry of TYPE with NAME does not exist, an error will occur.
%
%   REMOVE(OBJ, STRUCT) remove an entry using the fields in STRUCT. If an
%   entry with the Type and Name field in STRUCT does not exist, an error
%   will occur.
%
%   Examples:
%       c = iviconfigurationstore;
%       remove(c, 'HardwareAsset', 'gpib1');
%
%   See also IVICONFIGURATIONSTORE/UPDATE, IVICONFIGURATIONSTORE/ADD,
%   IVICONFIGURATIONSTORE/COMMIT.

%   PE 10-01-03
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/01/16 20:01:21 $

nargchk(2, 3, nargin);

arg = varargin{1};

errflag = false;

if isstruct(arg)
    for idx = 1:length(arg)
        item = arg(idx);
        if isfield(item, 'Type') && isfield(item, 'Name')
            if (~privateVerifyIsMutableEntry(item.Type))
                error('iviconfigurationstore:remove:invalidArgs', 'Invalid Type field in STRUCT.');
            end

            errflag = localRemoveEntry(obj.cobject, item.Type, item.Name);
            if (errflag)
                error('iviconfigurationstore:remove:removeFailed', lasterr);
            end
        else
            error('iviconfigurationstore:remove:invalidArgs',...
                'Invalid STRUCT specified. STRUCT must have ''Type'' and ''Name'' fields.');
        end
    end
elseif (ischar(arg))
    if (~privateVerifyIsMutableEntry(arg))
        error('iviconfigurationstore:remove:invalidArgs', 'Invalid TYPE.');
    end

    if (nargin < 3 || ~ischar(varargin{2}))
        error('iviconfigurationstore:remove:invalidArgs', 'NAME must be a string.');
    end

    errflag = localRemoveEntry(obj.cobject, arg, varargin{2});
    if (errflag)
        error('iviconfigurationstore:remove:removeFailed', lasterr);
    end
else
    error('iviconfigurationstore:remove:invalidArgs', 'Invalid TYPE or STRUCT.');
end

% -------------------------------------------------------------------------
% Remove the entry from the collection.
% -------------------------------------------------------------------------
function errflag = localRemoveEntry(cobject, type, name)

errflag = false;

collection = cobject.([type 's']);

if isempty(collection) || isstruct(collection)
    return;
end

[entry, index] = privateGetNamedEntry(collection, name, true);

if isempty(index);
    errflag  = true;
    lasterr([name ' is not a valid ' type ' entry.']);
end

try
    collection.Remove(index);
catch
    errflag = true;
    lasterr([name ' could not be removed.  It may be referenced by another entry in the configuration store.']);
end

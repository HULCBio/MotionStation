function out = privateIviComDriverHelper(action, obj, varargin)
%PRIVATEIVICOMDRIVERHELPER Helper function used by IVI-COM device objects.
%
%   PRIVATEIVICOMDRIVERHELPER helper function used by IVI-COM device
%   objects.
%
%   This function should not be called directly by the user.

%   PE 09-03-03
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.4 $  $Date: 2004/03/24 20:40:06 $

out = {};

if (isempty(action) || isempty(obj))
    return;
end

switch (action)
    case 'open'
        invoke(obj, 'Initialize', varargin{1}, false, false, '');
        out{1} = get(obj, 'Initialized');
    case 'close'
        status = get(obj, 'Initialized');
        if (status == true)
            invoke(obj, 'Close');
        end
    case 'status'
        status = get(obj, 'Initialized');
        out{1} = status;
    case 'error'
        driverop = get(obj, 'DriverOperation');
        if (get(driverop, 'QueryInstrumentStatus') == false)
            warning('instrument:icdevice:invalidState', ...
            'The QueryInstrumentStatus is not enabled.  Errors may not be properly reported.');
        end
        util = get(obj, 'Utility');
        [unusedhr, unusedid, message] = invoke(util, 'ErrorQuery', 0, '');
        out{1} = message;
    case 'reset'
        util = get(obj, 'Utility');
        invoke(util, 'Reset');
    case 'selftest'
        util = get(obj, 'Utility');
        [unusedhr, unusedid, message] = invoke(util, 'SelfTest', 0, '');
        out{1} = message;
    case 'model'
        ident = get(obj, 'Identity');
        out{1} = [get(ident, 'InstrumentManufacturer') ' ' get(ident, 'InstrumentModel')];
    case 'group'
        try 
            comobj = varargin{1};
            newSize = comobj.Count;
            groupname = varargin{2};
            group = get(obj, groupname);
            oldSize = length(group);
            if (oldSize < newSize);
                names = {};
                for idx = oldSize:newSize
                    names{end + 1} = [groupname num2str(idx)];
                end

                %fprintf('Update group size: %s\n', groupname);
                privateAddGroupObjects(obj, groupname, newSize, names);
            end
        catch
            fprintf('%s\n', lasterr);
        end
end


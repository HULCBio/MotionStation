function obj = iviconfigurationstore(varargin)
%IVICONFIGURATIONSTORE Construct IVI configuration store object.
%
%   OBJ=IVICONFIGURATIONSTORE constructs an IVI configuration store object,
%   OBJ, and establishes a connection to the IVI Configuration Server. The
%   data in the master configuration store is used.
%
%   OBJ=IVICONFIGURATIONSTORE(FILE) constructs an IVI configuration store
%   object, OBJ, and establishes a connection to the IVI Configuration
%   Server. The data in the configuration store, FILE, is used. If FILE 
%   cannot be found or is not a valid configuration store, an error is
%   returned.
%
%   See also IVICONFIGURATIONSTORE/ADD, IVICONFIGURATIONSTORE/COMMIT,
%   IVICONFIGURATIONSTORE/REMOVE.
%

%   PE 9-30-03
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.3 $  $Date: 2004/02/01 21:55:05 $

if nargin == 0
    try
        h = actxserver('IviConfigServer.IviConfigStore');
        h.ProcessDefaultLocation = '';
    catch
        error('iviconfigurationstore:iviconfigurationstore:loadfailed',...
            'The IVI Configuration Server could not be accessed.');
    end
    
    try        
        useMaster = com.mathworks.toolbox.instrument.Instrument.getPreferenceFile.read('IviUseMasterConfigStore');
        if (~isempty(useMaster) && strcmpi(useMaster, 'true'))
            Deserialize(h, h.MasterLocation);
        else
            location = char(com.mathworks.toolbox.instrument.Instrument.getPreferenceFile.read('IviConfigStoreLocation'));
            if (isempty(location))
                Deserialize(h, h.MasterLocation);
            else
                Deserialize(h, location);
            end
        end
    catch
        error('iviconfigurationstore:iviconfigurationstore:loadfailed',...
            'The IVI Configuration Store could not be loaded.');
    end
    obj.cobject = h;
    obj.location = h.ActualLocation;
    obj = class(obj,'iviconfigurationstore');
elseif isa(varargin{1},'iviconfigurationstore')
    obj = varargin{1};
elseif ischar(varargin{1})
    try
        h = actxserver('IviConfigServer.IviConfigStore');
    catch
        error('iviconfigurationstore:iviconfigurationstore:loadfailed',...
            'The IVI Configuration Server could not be accessed.');
    end
    h.ProcessDefaultLocation = varargin{1};
    try
        Deserialize(h, h.ProcessDefaultLocation);
    catch
        error('iviconfigurationstore:iviconfigurationstore:loadfailed', ...
            ['An error occurred loading the configuration store. ' varargin{1} ' may not be a valid configuration store.']);
    end
    obj.cobject = h;
    obj.location = h.ActualLocation;
    obj = class(obj,'iviconfigurationstore');
else
    error('iviconfigurationstore:iviconfigurationstore:loadfailed', 'STORE must be a string.');
end

function varargout = privateDeviceConstructorHelper(action, varargin)
%PRIVATEDEVICECONSTRUCTORHELPER Helper function used by icdevice constructor.
%
%   PRIVATEDEVICECONSTRUCTORHELPER helper function used by icdevice constructor.
%
%   This function should not be called directly by the user.

%   PE 12-01-03
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.3 $  $Date: 2004/02/01 21:55:22 $

switch (action)
    case 'iviParserModelFromLogical'
        [parser, model] = localParserModelFromLogical(varargin{:});
        varargout{1} = parser;
        varargout{2} = model;
    case 'iviParserModelFromProgramId'
        [parser, model] = localParserModelFromProgramId(varargin{:});
        varargout{1} = parser;
        varargout{2} = model;
    case 'iviProgramIdFromLogical'
        programid = localProgramIdFromLogicalName(varargin{:});
        varargout{1} = programid;
    case 'iviProgramIdFromUnknown'
        [parser, model] = localParserModelFromUnknown(varargin{:});
        varargout{1} = parser;
        varargout{2} = model;
end

%-------------------------------------------------------------------------------
%
function [parser, model] = localParserModelFromUnknown(driver, varargin)

if (nargin == 1)
    interface = '';
else
    interface = varargin{1};
end

[parser, model] = localParserModelFromLogical(driver, interface);

if (isempty(model))
    [parser, model] = localParserModelFromProgramId(driver, interface);
end

% ------------------------------------------------------------------------------
% 
function [parser, model] = localParserModelFromLogical(logicalname, varargin)

programid = localProgramIdFromLogicalName(logicalname);

if (isempty(programid))
    parser = [];
    model = [];
    return;
end

if (nargin == 1)
    interface = '';
else
    interface = varargin{1};
end

[parser, model] = localParserModelFromProgramId(programid, interface, logicalname);

% ------------------------------------------------------------------------------
% 
function [parser, model] = localParserModelFromProgramId(programid, varargin)

switch nargin
    case 1
        drivername = programid;
        interface = '';
    case 2
        drivername = programid;
        interface = varargin{1};
    case 3
        interface = varargin{1};
        drivername = varargin{2};
end

[parser, model] = privateIviComLoader(programid, drivername, interface);

% ------------------------------------------------------------------------------
% 
function programid = localProgramIdFromLogicalName(logicalName)

programid = '';

try
    obj = iviconfigurationstore;
catch
    return
end

logicals = get(obj, 'LogicalNames');
logicalRef = [];

for idx = 1:length(logicals)
    if (strcmpi(logicalName, logicals(idx).Name) == 1)
        logicalRef = logicals(idx);
        break;
    end
end

if (isempty(logicalRef))
    return;
end

sessions = get(obj, 'DriverSessions');
sessionRef = [];

for idx = 1:length(sessions)
    if (strcmpi(logicalRef.Session, sessions(idx).Name) == 1)
        sessionRef = sessions(idx);
        break;
    end
end

if (isempty(sessionRef))
    error('instrument:private:invalidLogicalName', ...
        'The specified logical name references an invalid or incomplete driver session.');
end

modules = get(obj, 'SoftwareModules');
moduleRef = [];

for idx = 1:length(modules)
    if (strcmpi(sessionRef.SoftwareModule, modules(idx).Name) == 1)
        moduleRef = modules(idx);
        break;
    end
end

if (isempty(moduleRef))
    error('instrument:private:invalidLogicalName', ...
        'The specified logical name references an invalid or incomplete software module.');
end

programid = moduleRef.ProgID;

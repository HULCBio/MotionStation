function [entry, errflag] = privateFillStruct(entry, varargin)
%PRIVATEFILLSTRUCT Fill a configuration store structure with FV pairs.
% 

%   PE 10-01-03
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/01/16 20:01:17 $

errflag = false;

if (isempty(varargin))
    return;
end

if (mod(nargin - 1, 2) == 1)
    errflag = true;
    lasterr('Field/value pairs must come in pairs.');
    return;
end

% Replace any 'on'/'off' values with logicals.  Various work arounds to
% deal with the fact that not all FV pairs will be strings (e.g. Virtual
% Names is struct).

v = varargin;
idx = find(~cellfun('isclass', v, 'char'));
vtemp = v;
if (~isempty(idx))
    for index = 1:length(idx)
        vtemp{idx(index)} = '';
    end
end
idx1 = strmatch('on', lower(vtemp), 'exact');
idx2 = strmatch('off', lower(vtemp), 'exact');

if (~isempty(idx1))
    for index = 1:length(idx1)
        v{idx1(index)} = true;
    end
end
if (~isempty(idx2))
    for index = 1:length(idx2)
        v{idx2(index)} = false;
    end
end

% Validate any field names passed as an optional arguments and assign the
% value for valid field names.
fields = localValidFieldNames(entry.Type);

for idx = 1:2:length(v)
    if any(strcmp(v{idx}, fields))
        entry.(v{idx}) = v{idx + 1};
    else
        lasterr(sprintf([v{idx} ' is not a valid ' entry.Type ' field.\nValid fields are %s.'],...
            localValidFieldNameList(entry.Type)));
        errflag = true;
    end
end

% -------------------------------------------------------------------------
% Return a list of valid field names for updating for each collection type.
% -------------------------------------------------------------------------
function out = localValidFieldNames(type)

switch type
    case 'HardwareAsset'
        out = {'Description', 'IOResourceDescriptor'};
    case 'DriverSession'
        out = {'Description', 'HardwareAsset', 'SoftwareModule', 'VirtualNames', 'Cache', 'QueryInstrStatus', 'InterchangeCheck', 'RangeCheck', 'DriverSetup', 'RecordCoercions', 'Simulate'};
    case 'LogicalName'
        out = {'Description', 'Session'};
end

% -------------------------------------------------------------------------
% Return a comma separated list of field name.
% -------------------------------------------------------------------------
function out = localValidFieldNameList(type)

switch type
    case 'HardwareAsset'
        out = 'Description and IOResourceDescriptor';
    case 'DriverSession'
        out = 'Description, HardwareAsset, SoftwareModule, VirtualNames, Cache, QueryInstrStatus, InterchangeCheck, RangeCheck, DriverSetup, RecordCoercions, and Simulate';
    case 'LogicalName'
        out = 'Description and Session';
end

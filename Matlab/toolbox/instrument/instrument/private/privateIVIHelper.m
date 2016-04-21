function out = privateIVIHelper(action, varargin)
%PRIVATEIVIHELPER helper function for working with IVI Config Store.
%
%   PRIVATEIVIHELPER helper function used by the Instrument Control Toolbox
%   browser to:
%      1. Query information from current config store
%      2. Backup current configuration store
%      3. Add, update and remove items in configuration store.
%   
%   This function should not be called directly by the user.
%  
 
%   MP 10-09-03
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.3 $  $Date: 2004/02/01 21:55:24 $

% Initialize output.
out = [];

switch (action)
case 'load'   
   % Parse the input.  
   name = varargin{1};
   if isempty(name)
        name = instrgate('privateIvIMasterLocation');
        if (isempty(name))
            out = 'no items';
            return;
        end
   end
   
   % Construct the store.
   store = iviconfigurationstore(name); 
   
   % Extract the information needed: ActualLocation, Revision,
   % Vendor, HardwareAssets, Software Modules, Driver Sessions
   % and Logical Names.
   out = localGetStoreInfo(store);

case 'saveas'
    % Parse the input.
    name           = varargin{1};
    hardwareAssets = varargin{2};
    driverSessions = varargin{3};
    logicalNames   = varargin{4};
    
    % Copy the master store to the new current store to the new location
    % and name.
    mastername = privateIvIMasterLocation;
    eval(['!cp ' mastername ' ' name]);    
    
    % Create the store and save changes to it.
    store = iviconfigurationstore(name);
    localSaveChanges(store, hardwareAssets, driverSessions, logicalNames);    
case 'save'
    % Parse the input.
    name           = varargin{1};
    hardwareAssets = varargin{2};
    driverSessions = varargin{3};
    logicalNames   = varargin{4};

    % Create store and save changes to it.
    store = iviconfigurationstore(name);    
    localSaveChanges(store, hardwareAssets, driverSessions, logicalNames);
end  

% ---------------------------------------------------------
% Extract the information needed: ActualLocation, Revision,
% Vendor, HardwareAssets, Software Modules, Driver Sessions
% and Logical Names.
function out = localGetStoreInfo(store)

out = cell(1,7);  
out{1} = get(store, 'ActualLocation');
out{2} = get(store, 'Revision');
out{3} = get(store, 'Vendor');
out{4} = localGetSoftwareModuleInfo(store);
out{5} = localGetHardwareAssetInfo(store);
out{6} = localGetDriverSessionInfo(store);
out{7} = localGetLogicalNameInfo(store);

% ---------------------------------------------------------
% Info of the form: Name, Description, Supported Instrument
% Models, Vendor and Revision.
function out = localGetSoftwareModuleInfo(store)

info = store.SoftwareModule;
out = cell(1, length(info));

for i=1:length(info)
    temp = cell(1,4);
    temp{1} = info(i).Name;
    temp{2} = info(i).Description;
    temp{3} = info(i).SupportedInstrumentModels;
    temp{4} = info(i).PhysicalNames;
    out{i} = temp;
end

% ---------------------------------------------------------
% Info of the form: Name, Description, IO Resouce descriptor.
function out = localGetHardwareAssetInfo(store)

info = store.HardwareAsset;
out = cell(1, length(info));

for i=1:length(info)
    temp = cell(1,3);
    temp{1} = info(i).Name;
    temp{2} = info(i).Description;
    temp{3} = info(i).IOResourceDescriptor;
    out{i} = temp;
end

% ---------------------------------------------------------
% Info of the form: Name, Description, Software Module,
% Hardware Asset, Driver Setup, Cache, Interchange Check,
% Query Status, Range Check, Record Coercions, Simulate.
function out = localGetDriverSessionInfo(store)

info = store.DriverSession;
sminfo = store.SoftwareModule;
out = cell(1, length(info) + length(sminfo));

for i=1:length(info)
    temp = cell(1,12);
    temp{1} = info(i).Name;
    temp{2} = info(i).Description;
    temp{3} = info(i).SoftwareModule;
    temp{4} = info(i).HardwareAsset;
    temp{5} = info(i).DriverSetup;
    temp{6} = localStr2bool(info(i).Cache);
    temp{7} = localStr2bool(info(i).InterchangeCheck);
    temp{8} = localStr2bool(info(i).QueryInstrStatus);
    temp{9} = localStr2bool(info(i).RangeCheck);
    temp{10} = localStr2bool(info(i).RecordCoercions);
    temp{11} = localStr2bool(info(i).Simulate);
    temp{12} = localCreateVirtualNameCell(info(i).VirtualNames);
    out{i} = temp;
end

smidx = 1;
for i = length(info)+1:length(out)
    temp = cell(1,2);
    temp{1} = sminfo(smidx).Name;
    temp{2} = sminfo(smidx).PhysicalNames;
    smidx = smidx + 1;
    out{i} = temp;
end

% ---------------------------------------------------------
% Create a cell of the virtual name to physical name mappings.
function out = localCreateVirtualNameCell(s)

out = {};
count = 1;

if isempty(s)
    return;
end

out = cell(1, length(s)*2)
for i = 1:length(s)
    out{count} = s(i).MapTo;
    out{count+1} = s(i).Name;
    count = count+2;
end

% ---------------------------------------------------------
% Create a structure of the virtual name to physical name
% mappings.
function out = localCreateVirtualNameStruct(c)

count = 1;
out = '';

for i = 1:length(c)/2
    if ~isempty(c{count+1})
        out(i).Type  = 'VirtualName';
        out(i).MapTo = c{count};
        out(i).Name  = c{count+1};
    end
    count = count+2;
end    

% ---------------------------------------------------------
% Convert the string 'on' to true and the string 'off' to
% false.
function out = localStr2bool(s)

if strcmp(s, 'on')
    out = true;
else
    out = false;
end

% ---------------------------------------------------------
% Info of the form: Name, Description, Driver Session.
function out = localGetLogicalNameInfo(store)

info = store.LogicalName;
out = cell(1, length(info));

for i=1:length(info)
    temp = cell(1,3);
    temp{1} = info(i).Name;
    temp{2} = info(i).Description;
    temp{3} = info(i).Session;
    out{i} = temp;
end

% ---------------------------------------------------------
function localSaveChanges(store, hardwareAssets, driverSessions, logicalNames)

import java.util.Hashtable;

% Get the names listed in the GUI.
gui_ln = localGetGUINames(logicalNames);
gui_ds = localGetGUINames(driverSessions);
gui_ha = localGetGUINames(hardwareAssets);

% Get the names listed in the store.
t = store.LogicalNames;
if isempty(t)
    cur_lin = {};
else
    cur_ln = {t.Name};
end

t = store.DriverSessions;
if isempty(t)
    cur_ds = {};
else
    cur_ds = {t.Name};
end

t = store.HardwareAssets;
if isempty(t)
    cur_ha = {};
else
    cur_ha = {t.Name};
end

% Add the hardware assets, driver sessions and logical names.
% Items must be added in that order since a logical name may
% be using a driver session that has not yet been created (so
% the driver session must be created before the logical names).

% Add the hardware assets.
for i=1:length(gui_ha)
    name        = gui_ha{i};
    nextItem    = cell(hardwareAssets.get(name));
    description = nextItem{1};
    ioResource  = nextItem{2};
    
    if (any(strcmp(name, cur_ha)) == true)
        % Hardware asset exists in config store. Update the current
        % settings.
        update(store, 'HardwareAsset', name, 'IOResourceDescriptor', ioResource,...
            'Description', description);
    else
        % Hardware asset does not exist in config store. Add it.
        add(store, 'HardwareAsset', name, ioResource, 'Description', description);
    end
end

% Add the driver sessions.
for i=1:length(gui_ds)
    name     = gui_ds{i};
    nextItem = driverSessions.get(name);
    
    % Get the values associated with the driver session.
    description    = char(nextItem.getDescription);
    driverSetup    = char(nextItem.getDriverSetup);
    hardwareAsset  = char(nextItem.getHardwareAsset);
    softwareModule = char(nextItem.getSoftwareModule);
    cache          = nextItem.getCacheValue;
    query          = nextItem.getQueryValue;
    record         = nextItem.getRecordValue;
    interchange    = nextItem.getInterchangeCheckValue;
    range          = nextItem.getRangeCheckValue;
    simulate       = nextItem.getSimulateValue;
    virtualNames   = localCreateVirtualNameStruct(cell(nextItem.getVirtualNames));
    
    if (any(strcmp(name, cur_ds)) == true)
        % Driver session exists in config store. Update the current
        % settings.
        update(store, 'DriverSession', name, 'Description', description,...
            'DriverSetup', driverSetup, 'HardwareAsset', hardwareAsset,...
            'SoftwareModule', softwareModule, 'Cache', cache,...
            'QueryInstrStatus', query, 'RecordCoercions', record,...
            'InterchangeCheck', interchange, 'RangeCheck', range,...
            'Simulate', simulate, 'VirtualNames', virtualNames);
    else
        % Driver session does not exist in config store. Add it.
        add(store, 'DriverSession', name, softwareModule, hardwareAsset,...
            'Description', description, 'DriverSetup', driverSetup, ...
            'Cache', cache, 'QueryInstrStatus', query,...
            'RecordCoercions', record, 'InterchangeCheck', interchange,...
            'RangeCheck', range, 'Simulate', simulate,...
            'VirtualNames', virtualNames);
    end
end

% Add the logical names.
for i=1:length(gui_ln)
    name          = gui_ln{i};
    nextItem      = cell(logicalNames.get(name));
    description   = nextItem{1};
    driverSession = nextItem{2};
    
    if (any(strcmp(name, cur_ln)) == true)
        % Logical name exists in config store. Update the current
        % settings.
        update(store, 'LogicalName', name, 'Description', description,...
            'Session', driverSession);
    else
        % Logical name does not exist in config store. Add it.
        add(store, 'LogicalName', name, driverSession, 'Description', description);
    end
end

% Remove the logical names, driver sessions and hardware assets.
% Removal must be in that order since a hardware asset cannot
% be deleted if a driver session exists that uses it.

% Remove the logical names that have been deleted.
localRemoveItemsFromStore(store, gui_ln, store.LogicalNames,'LogicalName');

% Remove the driver sessions that have been deleted.
localRemoveItemsFromStore(store, gui_ds, store.DriverSessions, 'DriverSession');

% Remove the hardware assets that have been deleted.
localRemoveItemsFromStore(store, gui_ha, store.HardwareAssets, 'HardwareAsset');

% Save the changes.
commit(store, store.ActualLocation);

% ---------------------------------------------------------
function out = localGetGUINames(gui)

import java.util.Hashtable;
import java.util.Enumeration;

% Get the names that are listed in the GUI.
names = gui.keys;
out   = {};
while (names.hasMoreElements)
    out{end+1} = char(names.nextElement);
end

% ---------------------------------------------------------
function localRemoveItemsFromStore(store, guiNames, current, type)

% Get the names that are listed in the config store.
currentNames = {current.Name};

% If a name exists in the config store but does not exist
% in the GUI, remove it.
for i = 1:length(currentNames)
    if (any(strcmp(currentNames{i}, guiNames)) == false)
        remove(store, type, currentNames{i});
    end
end

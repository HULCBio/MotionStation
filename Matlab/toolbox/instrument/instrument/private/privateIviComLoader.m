function [parser, model] = privateIviComLoader(progid, driverName, instrType)
%PRIVATECOMLOADER Load COM object information for device objects.
%
%   PRIVATECOMLOADER(COMOBJ, LOGICALNAME, TYPE) loads property and method
%   information about COMOBJ into parser and drivermodel objects that can
%   be used to create device objects, or create MATLAB Instrument Driver
%   files.

%   PE 09-03-03
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.3 $  $Date: 2004/02/01 21:55:26 $

import com.mathworks.toolbox.instrument.device.drivers.xml.Parser;
import com.mathworks.toolbox.instrument.device.guiutil.midtool.DriverGroup;

parser = [];
model =[];

try
    if (~isempty(instrType))
        driverInfo = instrgate('privateLoadIviClass', progid, instrType);
    else
        driverInfo = instrgate('privateLoadIviClass', progid);
    end
catch
    return;
end

if (isempty(driverInfo))
    return;
end

% Create the basic DriverModel object to hold the data.
model = com.mathworks.toolbox.instrument.device.guiutil.midtool.DefaultDriverModel;
model.setDriverType(com.mathworks.toolbox.testmeas.device.Device.IVI_COM);
model.setInstrumentType(instrType);
model.setDriverName(driverName);

% The device-level group object for properties and methods.
deviceGroup = model.getGroup(DriverGroup.sDeviceGroupName);

deviceInterface = driverInfo.DefaultInterface;

localAddPropertiesToGroup(model, deviceGroup, deviceInterface{7}, deviceInterface{5}, false);
localAddMethodsToGroup(model, deviceGroup, deviceInterface{8}, deviceInterface{5}, false);

localAddInterfaces(model, deviceInterface{6});

localCreateConnectInitCode(model, deviceInterface{6});

% Parse the driver model data.
parser = Parser(model.createDocument);
parser.parse;

% -------------------------------------------------------------------------
% localAddInterfaces
% -------------------------------------------------------------------------
function localAddInterfaces(model, interfaceList)

import com.mathworks.toolbox.instrument.device.guiutil.midtool.DriverGroup;

for idx = 1:length(interfaceList)
    group = model.getGroup(interfaceList{idx}{3});
    
    if (isempty(group))
        %group = DriverGroup(interfaceList{idx}{3});
        group = DriverGroup.createFromIviInfo(interfaceList{idx}{3}, interfaceList{idx}{2});
        model.add(group);
    end
    %group.setHelpText(interfaceList{idx}{2});
    
    isCollection = ~isempty(interfaceList{idx}{4});
    flattenedInfo = interfaceList{idx}{5};

    if (isCollection)
        localAddPropertiesToGroup(model, group, interfaceList{idx}{4}{7}, flattenedInfo, isCollection);
        localAddMethodsToGroup(model, group, interfaceList{idx}{4}{8}, flattenedInfo, isCollection);
    else
        localAddPropertiesToGroup(model, group, interfaceList{idx}{7}, flattenedInfo, isCollection);
        localAddMethodsToGroup(model, group, interfaceList{idx}{8} , flattenedInfo, isCollection);
    end
end

% -------------------------------------------------------------------------
% localAddPropertiesToGroup
% -------------------------------------------------------------------------
function localAddPropertiesToGroup(model, group, proplist, flattenedInfo, isCollection)

for idx = 1:length(proplist)
    model.add(...
        com.mathworks.toolbox.instrument.device.guiutil.midtool.DriverProperty.createFromIviInfo(...
        proplist{idx}{1}, group, proplist{idx}{2}, ...
        proplist{idx}{3}, proplist{idx}{4}, isCollection, flattenedInfo, ...
        proplist{idx}{5}));
end

% -------------------------------------------------------------------------
% localAddMethodsToGroup
% -------------------------------------------------------------------------
function localAddMethodsToGroup(model, group, methodlist, flattenedInfo, isCollection)

for idx = 1:length(methodlist)
    model.add(...
        com.mathworks.toolbox.instrument.device.guiutil.midtool.DriverFunction.createFromIviInfo(...
        methodlist{idx}{1}, group, methodlist{idx}{2}, methodlist{idx}{3},...
        methodlist{idx}{4}, methodlist{idx}{5}, flattenedInfo, isCollection));
end

% -------------------------------------------------------------------------
% localCreateConnectInitCode
% -------------------------------------------------------------------------
function localCreateConnectInitCode(model, interfaceList)

import com.mathworks.toolbox.instrument.device.guiutil.midtool.DriverModel;

hasCollection = false;

for idx = 1:length(interfaceList)
     if (~isempty(interfaceList{idx}{4}))
         if (~hasCollection)
             model.setConnectInitMCodeForIvi;
             hasCollection = true;
         end
         groupname = [upper(interfaceList{idx}{3}(1)) lower(interfaceList{idx}{3}(2:end))];
         model.appendConnectInitMCodeForIvi(groupname, interfaceList{idx}{5});
     end
end


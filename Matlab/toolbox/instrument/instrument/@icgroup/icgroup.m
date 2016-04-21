function obj = icgroup(jobj)
%ICGROUP Construct device group object.
%
%   ICGROUP construct a device group object.
%
%   If the device object supports a group, then an array of device group
%   objects are created when the device object is created. The group objects
%   can be accessed through a property of the device object. The property 
%   will have the same name as the group.
%
%   This constructor should not be called directly by users.
%
%   See also ICDEVICE.
%

%   MP 9-03-02
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/01/16 19:59:52 $

if (nargin ~= 1)
   error('icgroup:icgroup:invalidArg', 'Device group objects are created on device object creation.');
end

if (isa(jobj, 'com.mathworks.toolbox.testmeas.device.DeviceChild[]') || ...
    isa(jobj, 'com.mathworks.toolbox.testmeas.device.DeviceChild'))
    
    % Assign the first java object to the jobject array.
    obj.jobject = handle(jobj(1));
   
    % Assign the type.
    obj.type    = {'icgroup'};
    
    % Location to store information when saving the object.
    obj.store   = [];
    
    % Assign the remaining java objects to the jobject array.
    for i = 2:length(jobj)  
        obj.jobject = [obj.jobject handle(jobj(i))];
        obj.type    = {obj.type{:} 'icgroup'};
    end
    
    % If only one object, the type field should not be a cell array.
    if length(jobj) == 1
        obj.type = obj.type{:};
    end
    
    % Assign the class.
    obj = class(obj, 'icgroup');
elseif isa(jobj, 'javahandle.com.mathworks.toolbox.instrument.device.ICDeviceChild')
    obj.jobject = jobj;
    obj.type    = {'icgroup'};
    obj.store   = [];
    obj = class(obj, 'icgroup');
elseif (findstr('ICGroup', class(jobj)))
    obj.jobject = jobj;
    obj.type    = {'icgroup'};
    obj.store   = [];
    obj = class(obj, 'icgroup');
else
    error('icgroup:icgroup:invalidArg', 'Device group objects are created on device object creation.');
end


function privateAddGroupObjects(obj, groupname, size, names)
%PRIVATEADDGROUPOBJECTS add objects to a group.
%
%    PRIVATEADDGROUPOBJECTS(OBJ, GROUPNAME, SIZE, NAME) adds
%    additional objects to the group, GROUPNAME, after the device
%    object, OBJ, has been constructed. SIZE Is the new size of the
%    group. NAMES is a cell of HwNames for each group object that
%    will be added to the group.
%
%   This function should not be called directly by the user.
%  
 
%   MP 11-06-03
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/01/16 20:02:30 $

% Get the old size of the group.
group = get(obj, groupname);
oldSize = length(group);

% Get the class name of the group.
group1 = group(1);
jgroup = igetfield(group1, 'jobject');
classname = class(java(jgroup));

% Extract the device java object.
jobj = igetfield(obj, 'jobject');

% Update the size of the group object.
driver = jobj.getDriver;
driver.setGroupSize(groupname, size);

% Update the HwNames for each element in the group
% that is being added.
count = 1;
for i=oldSize+1:size
    driver.setGroupObjectName(groupname, i, names{count});
    count=count+1;
end

% Create the ICGroup java objects. 
jobj.addGroupAfterConnect(classname, groupname);
jgroup = jobj.getJGroup(groupname);

% Create the wrapping M-objects.
mgroup = icgroup(jgroup);

% Pass the M-objects into java so that it be passed back when
% set is called.
mgroupcell = cell(1, length(mgroup));
for i = 1:length(mgroupcell)
    mgroupcell{i} = mgroup(i);
end

jobj.assignMATLABGroup(groupname, mgroup, mgroupcell);
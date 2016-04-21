function out = fieldnames(obj, flag)
%FIELDNAMES Get instrument or device group object property names.
%
%   NAMES=FIELDNAMES(OBJ) returns a cell array of strings containing 
%   the names of the properties associated with instrument object or
%   device group object, OBJ. OBJ can be an array of instrument objects
%   or an array of device group objects.
%

%   MP 6-25-02
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.3 $  $Date: 2004/01/16 19:59:49 $

if ~isa(obj, 'icgroup')
    error('icgroup:fieldnames:invalidOBJ', 'OBJ must be a device group object.');
end

% Error if invalid.
if ~all(isvalid(obj))
   error('icgroup:fieldnames:invalidOBJ', 'Device group object OBJ is an invalid object.');
end

try
    % Extract all the objects.
    jobj = igetfield(obj, 'jobject');
    
    % Get the properties for the first object.
    props = getAllProperties(jobj(1));
    out = cell(props.size, 1);
    for i = 1:props.size
        out{i} = char(props.elementAt(i-1));
    end
catch
    error('icgroup:fieldnames:invalidOBJ', 'Device group object array OBJ cannot mix types.');
end

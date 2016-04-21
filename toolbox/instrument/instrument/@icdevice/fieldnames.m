function out = fieldnames(obj, flag)
%FIELDNAMES Get instrument object property names.
%
%   NAMES=FIELDNAMES(OBJ) returns a cell array of strings containing 
%   the names of the properties associated with instrument object, OBJ.
%   OBJ can be an array of instrument objects of the same type.
%

%   MP 3-14-02
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/01/16 19:59:08 $

if ~isa(obj, 'instrument')
    error('instrument:fieldnames:invalidOBJ', 'OBJ must be an instrument object.');
end

% Error if invalid.
if ~all(isvalid(obj))
   error('instrument:fieldnames:invalidOBJ', 'Instrument object OBJ is an invalid object.');
end

try
    % Extract all the objects.
    jobj = igetfield(obj, 'jobject');
    
    % Get the properties for the first object.
    props = getAllProperties(jobj(1));
    first = cell(props.size, 1);
    for i = 1:props.size
        first{i} = char(props.elementAt(i-1));
    end
    
    % Get the properties for the remaining objects and verify they
    % equal the first objects.    
    for i = 2:length(jobj)
        props = getAllProperties(jobj(i));
        temp = cell(props.size, 1);
        for i = 1:props.size
            temp{i} = char(props.elementAt(i-1));
        end
        if ~isequal(temp, first)
            error('instrument:fieldnames:invalidOBJ', 'Instrument object array OBJ cannot mix instrument object types.');
        end
    end
    out = first;
catch
    error('instrument:fieldnames:invalidOBJ', 'Instrument object array OBJ cannot mix instrument object types.');
end


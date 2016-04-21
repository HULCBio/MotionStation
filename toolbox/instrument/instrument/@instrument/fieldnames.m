function out = fieldnames(obj, flag)
%FIELDNAMES Get instrument or device group object property names.
%
%   NAMES=FIELDNAMES(OBJ) returns a cell array of strings containing 
%   the names of the properties associated with instrument object or
%   device group object, OBJ. OBJ can be an array of instrument objects
%   or an array of device group objects.
%

%   MP 3-14-02
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.2.4 $  $Date: 2004/01/16 20:00:55 $

if ~isa(obj, 'instrument')
    error('instrument:fieldnames:invalidOBJ', 'OBJ must be an instrument object.');
end

% Error if invalid.
if ~all(isvalid(obj))
   error('instrument:fieldnames:invalidOBJ', 'Instrument object OBJ is an invalid object.');
end

try
    out = fieldnames(get(obj));
catch
    error('instrument:fieldnames:invalidOBJ', 'Instrument object array OBJ cannot mix instrument object types.');
end
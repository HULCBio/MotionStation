function out = fieldnames(obj, flag)
%FIELDNAMES Get serial port object property names.
%
%   NAMES=FIELDNAMES(OBJ) returns a cell array of strings containing 
%   the names of the properties associated with serial port object, OBJ.
%   OBJ can be an array of serial port objects.
%

%   MP 3-14-02
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.4.3 $  $Date: 2004/01/16 20:04:13 $

if ~isa(obj, 'instrument')
    error('MATLAB:serial:fieldnames:invalidOBJ', 'OBJ must be an instrument object.');
end

% Error if invalid.
if ~all(isvalid(obj))
   error('MATLAB:serial:fieldnames:invalidOBJ', 'Instrument object OBJ is an invalid object.');
end

try
    out = fieldnames(get(obj));
catch
    error('MATLAB:serial:fieldnames:invalidOBJ', 'Instrument object array OBJ cannot mix instrument object types.');
end
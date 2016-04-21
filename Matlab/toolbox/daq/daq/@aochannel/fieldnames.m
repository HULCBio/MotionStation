function out = fieldnames(obj, flag)
%FIELDNAMES Get AO channel object property names.
%
%    NAMES=FIELDNAMES(OBJ) returns a cell array of strings containing 
%    the names of the properties associated with AO channel object, OBJ.
%    OBJ can be an array.
%
%    NAMES=FIELDNAMES(OBJ, FLAG) returns the same cell array as the previous 
%    syntax and is provided for backwards compatibility. 

%    DK 4-10-02
%    Copyright 1998-2003 The MathWorks, Inc. 
%    $Revision: 1.2.8.4 $  $Date: 2003/08/29 04:39:59 $

% Error if invalid.
if ~all(isvalid(obj))
   error('daq:fieldnames:invalidobject', 'The AO channel object OBJ is an invalid object.');
end

try
    out = fieldnames(get(obj));
catch
    error('daq:fieldnames:mixedarray', 'The object array OBJ contains objects other than AO channel objects.');
end

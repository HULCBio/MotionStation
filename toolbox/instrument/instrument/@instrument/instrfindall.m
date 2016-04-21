function output = instrfindall(obj, varargin)
%INSTRFINDALL Find instrument or device group objects with specified property values.
%
%   OUT = INSTRFINDALL returns all instrument objects that exist in memory
%   regardless of the object's ObjectVisibility property value. The instrument
%   objects are returned as an array to OUT.
%
%   OUT = INSTRFINDALL('P1', V1, 'P2', V2,...) returns an array, OUT, of
%   instrument objects or device group objects whose property names and
%   property values match those passed as param-value pairs, P1, V1, P2,
%   V2,... The param-value pairs can be specified as a cell array. 
%
%   OUT = INSTRFINDALL(S) returns an array, OUT, of instrument objects or
%   device group objects whose property values match those defined in
%   structure S whose field names are object property names and the field
%   values are the requested property values.
%   
%   OUT = INSTRFINDALL(OBJ, 'P1', V1, 'P2', V2,...) restricts the search for 
%   matching param-value pairs to the instrument objects or device group
%   objects listed in OBJ. OBJ can be an array of objects.
%
%   Note that it is permissible to use param-value string pairs, structures,
%   and param-value cell array pairs in the same call to INSTRFINDALL.
%
%   When a property value is specified, it must use the same format as
%   GET returns. For example, if GET returns the Name as 'MyObject',
%   INSTRFINDALL will not find an object with a Name property value of
%   'myobject'. However, properties which have an enumerated list data type
%   will not be case sensitive when searching for property values. For
%   example, INSTRFINDALL will find an object with a RecordDetail property value
%   of 'Verbose' or 'verbose'. The data type of a property can be determined 
%   with PROPINFO's Constraint field.
%
%   Example:
%       g1 = gpib('ni', 0, 1, 'Tag', 'Oscilloscope');
%       g2 = gpib('ni', 0, 2, 'Tag', 'FunctionGenerator');
%       set(g1, 'ObjectVisibility', 'off');
%       out1 = instrfind('Type', 'gpib')
%       out2 = instrfindall('Type', 'gpib');
%
%   See also INSTRUMENT/PROPINFO, INSTRUMENT/GET, INSTRUMENT/INSTRFIND, INSTRHELP.
%

%   MP 9-19-02
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.4 $  $Date: 2004/01/16 20:01:01 $

try
    output = instrfind(obj, varargin{:});
catch
    info = lasterror;    
    error(strrep(info.identifier, 'instrfind', 'instrfindall'), info.message);
end
function [propnames,props] = getSettableValues(obj)
%getSettableValues gets all the settable values of a audioplayer object
%
%    getSettableValues(OBJ) returns the settable values of OBJ as a list of settable
%    property names and a cell array containing the values.
%
%    See Also: AUDIOPLAYER/PRIVATE/RESETVALUES

%    JCS
%    Copyright 2001-2003 The MathWorks, Inc. 
%    $Revision: 1.1.6.1 $  $Date: 2003/12/04 19:00:42 $

propnames = fieldnames(set(obj.internalObj));

% the the settable values of the valid audioplayer object
props = get(obj.internalObj, propnames);



function [propnames,props] = getSettableValues(obj)
%getSettableValues gets all the settable values of a timer object array
%
%    getSettableValues(OBJ) returns the settable values of OBJ as a list of settable
%    property names and a cell array containing the values.
%
%    See Also: TIMER/PRIVATE/RESETVALUES

%    RDD 1-18-2002
%    Copyright 2001-2002 The MathWorks, Inc. 
%    $Revision: 1.2 $  $Date: 2002/03/14 14:35:13 $

objlen = length(obj);

propnames = [];
% foreach valid timer object...
for objnum=1:objlen
    if isJavaTimer(obj.jobject(objnum)) % valid java object found
        if isempty(propnames) % if settable propnames are not yet known, get them from set
            propnames = fieldnames(set(obj.jobject(objnum)));
        end
        % the the settable values of the valid timer object
        props{objnum} = get(obj.jobject(objnum),propnames);
    end
end
